import { describe, it, expect, vi, beforeEach } from "vitest";
import { ZodError } from "zod";

// Mock config before importing the parser
vi.mock("../../core/config", () => ({
  config: {
    openRouterApiKey: "test-key",
    openRouterModel: "test-model",
  },
}));

// Use vi.hoisted so mockCreate is available inside the hoisted vi.mock factory
const { mockCreate } = vi.hoisted(() => ({ mockCreate: vi.fn() }));

vi.mock("openai", () => ({
  default: vi.fn().mockImplementation(() => ({
    chat: {
      completions: {
        create: mockCreate,
      },
    },
  })),
}));

import {
  classifyEventType,
  extractEventParts,
  extractEventInfo,
  retryOnJsonError,
  isJsonOrValidationError,
} from "../../services/event-parser";

function makeOpenAIResponse(content: string) {
  return {
    choices: [{ message: { content } }],
  };
}

beforeEach(() => {
  vi.clearAllMocks();
});

// ---- isJsonOrValidationError ----

describe("isJsonOrValidationError", () => {
  it("returns true for SyntaxError", () => {
    expect(isJsonOrValidationError(new SyntaxError("bad json"))).toBe(true);
  });

  it("returns true for ZodError", async () => {
    const { z } = await import("zod");
    try {
      z.string().parse(123);
    } catch (e) {
      expect(isJsonOrValidationError(e as ZodError)).toBe(true);
    }
  });

  it("returns false for generic Error", () => {
    expect(isJsonOrValidationError(new Error("network error"))).toBe(false);
  });

  it("returns false for non-Error values", () => {
    expect(isJsonOrValidationError("string")).toBe(false);
    expect(isJsonOrValidationError(null)).toBe(false);
  });
});

// ---- retryOnJsonError ----

describe("retryOnJsonError", () => {
  it("returns result on first success", async () => {
    const fn = vi.fn().mockResolvedValue("success");
    const result = await retryOnJsonError(fn);
    expect(result).toBe("success");
    expect(fn).toHaveBeenCalledOnce();
  });

  it("retries up to maxAttempts on SyntaxError and eventually throws", async () => {
    const fn = vi.fn().mockRejectedValue(new SyntaxError("bad json"));
    await expect(retryOnJsonError(fn, 3)).rejects.toThrow(SyntaxError);
    expect(fn).toHaveBeenCalledTimes(3);
  });

  it("retries up to maxAttempts on ZodError and eventually throws", async () => {
    const { z } = await import("zod");
    let zodErr: ZodError | undefined;
    try { z.string().parse(123); } catch (e) { zodErr = e as ZodError; }
    const fn = vi.fn().mockRejectedValue(zodErr!);
    await expect(retryOnJsonError(fn, 3)).rejects.toThrow(ZodError);
    expect(fn).toHaveBeenCalledTimes(3);
  });

  it("succeeds on second attempt after first SyntaxError", async () => {
    const fn = vi.fn()
      .mockRejectedValueOnce(new SyntaxError("bad json"))
      .mockResolvedValueOnce("success");
    const result = await retryOnJsonError(fn, 3);
    expect(result).toBe("success");
    expect(fn).toHaveBeenCalledTimes(2);
  });

  it("throws immediately (no retry) for non-JSON/Zod errors", async () => {
    const networkError = new Error("network timeout");
    const fn = vi.fn().mockRejectedValue(networkError);
    await expect(retryOnJsonError(fn, 3)).rejects.toThrow("network timeout");
    // Only one attempt — no retry on non-JSON errors
    expect(fn).toHaveBeenCalledOnce();
  });

  it("uses default maxAttempts of 3", async () => {
    const fn = vi.fn().mockRejectedValue(new SyntaxError("bad json"));
    await expect(retryOnJsonError(fn)).rejects.toThrow(SyntaxError);
    expect(fn).toHaveBeenCalledTimes(3);
  });
});

// ---- classifyEventType ----

describe("classifyEventType", () => {
  it("returns the recognized event type from LLM response", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse("party"));
    const result = await classifyEventType("A dance party description");
    expect(result).toBe("party");
  });

  it("returns 'other' for unrecognized LLM response (Requirement 3.3)", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse("concert"));
    const result = await classifyEventType("Some description");
    expect(result).toBe("other");
  });

  it("handles case-insensitive LLM responses", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse("WORKSHOP"));
    const result = await classifyEventType("Workshop description");
    expect(result).toBe("workshop");
  });

  it("handles empty LLM response by returning 'other'", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse(""));
    const result = await classifyEventType("Some description");
    expect(result).toBe("other");
  });
});

// ---- extractEventParts ----

describe("extractEventParts", () => {
  const validPartsResponse = JSON.stringify({
    title: "Salsa Workshop",
    description: "A great workshop",
    parts: [
      {
        name: "Workshop",
        description: "Salsa basics",
        type: "workshop",
        dances: ["salsa"],
        date_time_range: { start: "2025-01-01T10:00:00Z", end: "2025-01-01T12:00:00Z" },
        lectors: ["Alice"],
        djs: [],
      },
    ],
  });

  it("parses a valid LLM response and returns structured data", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse(validPartsResponse));
    const result = await extractEventParts("Workshop description");
    expect(result.title).toBe("Salsa Workshop");
    expect(result.parts).toHaveLength(1);
    expect(result.parts[0].name).toBe("Workshop");
  });

  it("strips markdown code fences before parsing (Requirement 17.3)", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse("```json\n" + validPartsResponse + "\n```"));
    const result = await extractEventParts("Workshop description");
    expect(result.title).toBe("Salsa Workshop");
  });

  it("retries 3 times on invalid JSON and throws SyntaxError (Requirement 4.3)", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse("not valid json at all"));
    await expect(extractEventParts("Description")).rejects.toThrow(SyntaxError);
    // 3 attempts total (1 initial + 2 retries)
    expect(mockCreate).toHaveBeenCalledTimes(3);
  });

  it("throws immediately on non-JSON/Zod error without retrying", async () => {
    mockCreate.mockRejectedValue(new Error("OpenAI API error"));
    await expect(extractEventParts("Description")).rejects.toThrow("OpenAI API error");
    expect(mockCreate).toHaveBeenCalledOnce();
  });

  it("succeeds on retry after initial invalid JSON", async () => {
    mockCreate
      .mockResolvedValueOnce(makeOpenAIResponse("bad json"))
      .mockResolvedValueOnce(makeOpenAIResponse(validPartsResponse));
    const result = await extractEventParts("Description");
    expect(result.title).toBe("Salsa Workshop");
    expect(mockCreate).toHaveBeenCalledTimes(2);
  });
});

// ---- extractEventInfo ----

describe("extractEventInfo", () => {
  const validInfoResponse = JSON.stringify([
    { type: "price", key: "Entry fee", value: "10 EUR" },
    { type: "url", key: "Register", value: "https://example.com/register" },
  ]);

  it("parses a valid LLM response and returns EventInfo list", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse(validInfoResponse));
    const result = await extractEventInfo("Event with prices");
    expect(result).toHaveLength(2);
    expect(result[0].type).toBe("price");
    expect(result[1].type).toBe("url");
  });

  it("filters out entries with empty values (Requirement 5.3)", async () => {
    const responseWithEmpty = JSON.stringify([
      { type: "price", key: "Entry", value: "" },
      { type: "url", key: "Link", value: "https://example.com" },
    ]);
    mockCreate.mockResolvedValue(makeOpenAIResponse(responseWithEmpty));
    const result = await extractEventInfo("Description");
    expect(result).toHaveLength(1);
    expect(result[0].key).toBe("Link");
  });

  it("returns empty array when LLM returns empty array", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse("[]"));
    const result = await extractEventInfo("Description");
    expect(result).toEqual([]);
  });

  it("retries on invalid JSON and throws after 3 attempts", async () => {
    mockCreate.mockResolvedValue(makeOpenAIResponse("not json"));
    await expect(extractEventInfo("Description")).rejects.toThrow(SyntaxError);
    expect(mockCreate).toHaveBeenCalledTimes(3);
  });

  it("throws immediately on non-JSON error without retrying", async () => {
    mockCreate.mockRejectedValue(new Error("Rate limit"));
    await expect(extractEventInfo("Description")).rejects.toThrow("Rate limit");
    expect(mockCreate).toHaveBeenCalledOnce();
  });
});
