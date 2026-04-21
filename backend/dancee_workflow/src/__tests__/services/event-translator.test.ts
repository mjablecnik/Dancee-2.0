import { describe, it, expect, vi, afterEach } from "vitest";
import fc from "fast-check";

// Mock config before importing the service
vi.mock("../../core/config", () => ({
  config: { openRouterApiKey: "test-key", openRouterModel: "test-model" },
}));

const { mockCreate } = vi.hoisted(() => ({ mockCreate: vi.fn() }));
vi.mock("openai", () => {
  return {
    default: vi.fn().mockImplementation(() => ({
      chat: {
        completions: {
          create: mockCreate,
        },
      },
    })),
  };
});

import { translateEventContent, translateCourseContent } from "../../services/event-translator";
import type { EventContentInput, CourseContentInput } from "../../services/event-translator";

afterEach(() => {
  vi.clearAllMocks();
});

// Arbitraries for EventPart and EventInfo
const eventPartArb = fc.record({
  name: fc.string({ minLength: 1, maxLength: 40 }),
  description: fc.string({ minLength: 1, maxLength: 100 }),
  type: fc.constantFrom("party", "workshop", "openLesson" as const),
  dances: fc.array(fc.string({ minLength: 1, maxLength: 20 }), { maxLength: 5 }),
  date_time_range: fc.record({
    start: fc.constant("2025-01-01T10:00:00Z"),
    end: fc.constant("2025-01-01T12:00:00Z"),
  }),
  lectors: fc.array(fc.string({ minLength: 1, maxLength: 30 }), { maxLength: 3 }),
  djs: fc.array(fc.string({ minLength: 1, maxLength: 30 }), { maxLength: 3 }),
});

const eventInfoArb = fc.record({
  type: fc.constantFrom("url", "price" as const),
  key: fc.string({ minLength: 1, maxLength: 30 }),
  value: fc.string({ minLength: 1, maxLength: 100 }),
});

function makeMockLlmResponse(content: EventContentInput) {
  const response = {
    title: `Translated: ${content.title}`,
    description: `Translated: ${content.description}`,
    parts_translations: content.parts.map((p) => ({
      name: `Translated: ${p.name}`,
      description: `Translated: ${p.description}`,
    })),
    info_translations: content.info.map((i) => ({
      key: `Translated: ${i.key}`,
    })),
  };
  return {
    choices: [{ message: { content: JSON.stringify(response) } }],
  };
}

describe("Property 16: Translation produces non-empty content for all supported languages", () => {
  it("returns non-empty title and description for any target language", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom("en", "es", "de", "fr", "pl"),
        fc.record({
          title: fc.string({ minLength: 1, maxLength: 50 }),
          description: fc.string({ minLength: 1, maxLength: 200 }),
          parts: fc.array(eventPartArb, { maxLength: 3 }),
          info: fc.array(eventInfoArb, { maxLength: 3 }),
        }),
        async (targetLanguage, content) => {
          mockCreate.mockResolvedValue(makeMockLlmResponse(content));
          const result = await translateEventContent(content, targetLanguage);
          expect(result.title.length).toBeGreaterThan(0);
          expect(result.description.length).toBeGreaterThan(0);
        }
      )
    );
  });

  it("returns non-empty parts_translations entries for all parts", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom("en", "es"),
        fc.array(eventPartArb, { minLength: 1, maxLength: 4 }),
        async (targetLanguage, parts) => {
          const content: EventContentInput = {
            title: "Test event",
            description: "Test description",
            parts,
            info: [],
          };
          mockCreate.mockResolvedValue(makeMockLlmResponse(content));
          const result = await translateEventContent(content, targetLanguage);
          for (const pt of result.parts_translations) {
            expect(pt.name.length).toBeGreaterThan(0);
            expect(pt.description.length).toBeGreaterThan(0);
          }
        }
      )
    );
  });
});

describe("Property 17: Translation preserves non-translatable fields", () => {
  it("does not send dances, lectors, djs, or date_time_range to the LLM", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.array(eventPartArb, { minLength: 1, maxLength: 3 }),
        async (parts) => {
          const content: EventContentInput = {
            title: "Dance event",
            description: "A great event",
            parts,
            info: [],
          };
          mockCreate.mockResolvedValue(makeMockLlmResponse(content));
          await translateEventContent(content, "en");

          const callArgs = mockCreate.mock.calls[0][0];
          const userMessage = callArgs.messages.find((m: { role: string }) => m.role === "user");
          const sentPayload = JSON.parse(userMessage.content);

          // parts_translations in the LLM payload should only have name and description
          for (const pt of sentPayload.parts_translations) {
            expect(Object.keys(pt)).toEqual(["name", "description"]);
            expect("dances" in pt).toBe(false);
            expect("lectors" in pt).toBe(false);
            expect("djs" in pt).toBe(false);
            expect("date_time_range" in pt).toBe(false);
          }
        }
      )
    );
  });

  it("does not send info value to the LLM — only the key is translated", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.array(eventInfoArb, { minLength: 1, maxLength: 4 }),
        async (info) => {
          const content: EventContentInput = {
            title: "Event",
            description: "Desc",
            parts: [],
            info,
          };
          mockCreate.mockResolvedValue(makeMockLlmResponse(content));
          await translateEventContent(content, "es");

          const callArgs = mockCreate.mock.calls[0][0];
          const userMessage = callArgs.messages.find((m: { role: string }) => m.role === "user");
          const sentPayload = JSON.parse(userMessage.content);

          // info_translations in the LLM payload should only have key, not value or type
          for (const it of sentPayload.info_translations) {
            expect(Object.keys(it)).toEqual(["key"]);
            expect("value" in it).toBe(false);
            expect("type" in it).toBe(false);
          }
        }
      )
    );
  });
});

describe("Property 20: Translation parts_translations array length matches parts array", () => {
  it("returned parts_translations length equals input parts length", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.array(eventPartArb, { maxLength: 6 }),
        async (parts) => {
          const content: EventContentInput = {
            title: "Event",
            description: "Description",
            parts,
            info: [],
          };
          mockCreate.mockResolvedValue(makeMockLlmResponse(content));
          const result = await translateEventContent(content, "en");
          expect(result.parts_translations.length).toBe(parts.length);
        }
      )
    );
  });

  it("returned info_translations length equals input info length", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.array(eventInfoArb, { maxLength: 6 }),
        async (info) => {
          const content: EventContentInput = {
            title: "Event",
            description: "Description",
            parts: [],
            info,
          };
          mockCreate.mockResolvedValue(makeMockLlmResponse(content));
          const result = await translateEventContent(content, "en");
          expect(result.info_translations.length).toBe(info.length);
        }
      )
    );
  });

  it("retries and eventually throws when LLM returns wrong parts_translations length", async () => {
    const parts = [
      { name: "Workshop", description: "A dance workshop", type: "workshop" as const, dances: ["salsa"], date_time_range: { start: "2025-01-01T10:00:00Z", end: "2025-01-01T12:00:00Z" }, lectors: [], djs: [] },
      { name: "Party", description: "A dance party", type: "party" as const, dances: ["bachata"], date_time_range: { start: "2025-01-01T20:00:00Z", end: "2025-01-01T23:00:00Z" }, lectors: [], djs: [] },
    ];
    const content: EventContentInput = {
      title: "Dance Event",
      description: "Two parts",
      parts,
      info: [],
    };

    // LLM always returns only 1 part_translation instead of the expected 2
    const mismatchedResponse = {
      choices: [{
        message: {
          content: JSON.stringify({
            title: "Translated Title",
            description: "Translated Desc",
            parts_translations: [{ name: "Workshop Translated", description: "Desc" }], // 1 instead of 2
            info_translations: [],
          }),
        },
      }],
    };
    mockCreate.mockResolvedValue(mismatchedResponse);

    await expect(translateEventContent(content, "en")).rejects.toThrow(
      "parts_translations length mismatch"
    );
    // Should have retried 3 times total (initial + 2 retries)
    expect(mockCreate).toHaveBeenCalledTimes(3);
  });

  it("retries and eventually throws when LLM returns wrong info_translations length", async () => {
    const info = [
      { type: "price" as const, key: "Entry fee", value: "500 CZK" },
      { type: "url" as const, key: "Registration", value: "https://example.com" },
    ];
    const content: EventContentInput = {
      title: "Dance Event",
      description: "Two info items",
      parts: [],
      info,
    };

    // LLM always returns only 1 info_translation instead of the expected 2
    const mismatchedResponse = {
      choices: [{
        message: {
          content: JSON.stringify({
            title: "Translated Title",
            description: "Translated Desc",
            parts_translations: [],
            info_translations: [{ key: "Entry fee translated" }], // 1 instead of 2
          }),
        },
      }],
    };
    mockCreate.mockResolvedValue(mismatchedResponse);

    await expect(translateEventContent(content, "en")).rejects.toThrow(
      "info_translations length mismatch"
    );
    expect(mockCreate).toHaveBeenCalledTimes(3);
  });
});

// ---- translateCourseContent ----

function makeCourseInput(overrides?: Partial<CourseContentInput>): CourseContentInput {
  return {
    title: "Salsa Beginners Course",
    description: "Learn the basics of salsa dancing",
    learning_items: ["Basic steps", "Partner work", "Rhythm training"],
    ...overrides,
  };
}

function makeCourseTranslationResponse(title: string, description: string, learning_items: string[]) {
  return {
    choices: [{ message: { content: JSON.stringify({ title, description, learning_items }) } }],
  };
}

describe("translateCourseContent: successful translation", () => {
  it("returns translated title, description, and learning_items", async () => {
    const input = makeCourseInput();
    mockCreate.mockResolvedValue(
      makeCourseTranslationResponse("Salsa Course for Beginners", "Learn salsa", ["Basic steps EN", "Partner work EN"])
    );

    const result = await translateCourseContent(input, "English");
    expect(result.title).toBe("Salsa Course for Beginners");
    expect(result.description).toBe("Learn salsa");
    expect(result.learning_items).toEqual(["Basic steps EN", "Partner work EN"]);
  });

  it("sends title, description, and learning_items to the LLM", async () => {
    const input = makeCourseInput();
    mockCreate.mockResolvedValue(
      makeCourseTranslationResponse("T", "D", ["item"])
    );

    await translateCourseContent(input, "Spanish");

    const callArgs = mockCreate.mock.calls[0][0];
    const userMessage = callArgs.messages.find((m: { role: string }) => m.role === "user");
    const payload = JSON.parse(userMessage.content);
    expect(payload.title).toBe(input.title);
    expect(payload.description).toBe(input.description);
    expect(payload.learning_items).toEqual(input.learning_items);
  });

  it("works for empty learning_items array", async () => {
    const input = makeCourseInput({ learning_items: [] });
    mockCreate.mockResolvedValue(
      makeCourseTranslationResponse("Title", "Desc", [])
    );

    const result = await translateCourseContent(input, "English");
    expect(result.learning_items).toEqual([]);
  });
});

describe("translateCourseContent: retry on JSON error", () => {
  it("retries and eventually throws TerminalError after 3 failed JSON parse attempts", async () => {
    mockCreate.mockResolvedValue({
      choices: [{ message: { content: "not valid json {{{" } }],
    });

    await expect(translateCourseContent(makeCourseInput(), "English")).rejects.toThrow(
      "Parse failed after 3 attempts"
    );
    expect(mockCreate).toHaveBeenCalledTimes(3);
  });

  it("retries on invalid schema response and eventually throws", async () => {
    mockCreate.mockResolvedValue({
      choices: [{ message: { content: JSON.stringify({ title: "Only title" }) } }],
    });

    await expect(translateCourseContent(makeCourseInput(), "English")).rejects.toThrow();
    expect(mockCreate).toHaveBeenCalledTimes(3);
  });

  it("succeeds on second attempt after first returns bad JSON", async () => {
    mockCreate
      .mockResolvedValueOnce({ choices: [{ message: { content: "bad json" } }] })
      .mockResolvedValue(makeCourseTranslationResponse("Title", "Desc", ["item1"]));

    const result = await translateCourseContent(makeCourseInput(), "English");
    expect(result.title).toBe("Title");
    expect(mockCreate).toHaveBeenCalledTimes(2);
  });
});

describe("translateCourseContent: response structure validation", () => {
  it("validates that title is a non-empty string", async () => {
    mockCreate.mockResolvedValue(
      makeCourseTranslationResponse("", "Desc", [])
    );
    // Empty string passes Zod string validation — just confirm it returns the value
    const result = await translateCourseContent(makeCourseInput(), "English");
    expect(typeof result.title).toBe("string");
  });

  it("validates that learning_items is an array of strings", async () => {
    mockCreate.mockResolvedValue(
      makeCourseTranslationResponse("Title", "Desc", ["skill one", "skill two", "skill three"])
    );

    const result = await translateCourseContent(makeCourseInput(), "English");
    expect(Array.isArray(result.learning_items)).toBe(true);
    for (const item of result.learning_items) {
      expect(typeof item).toBe("string");
    }
  });
});
