import { describe, it, expect, vi, afterEach } from "vitest";
import fc from "fast-check";

// Mock config before importing the client
vi.mock("../../core/config", () => ({
  config: { scraperBaseUrl: "http://scraper-test", scraperTimeoutMs: 5000 },
}));

import { scrapeEvent, scrapeEventList, extractEventId } from "../../clients/scraper-client";

afterEach(() => {
  vi.restoreAllMocks();
});

describe("Property 1: Scraper client error propagation", () => {
  it("propagates HTTP errors with status code", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.integer({ min: 400, max: 599 }),
        fc.string(),
        async (status, message) => {
          vi.stubGlobal(
            "fetch",
            vi.fn().mockResolvedValue({
              ok: false,
              status,
              text: async () => message,
            })
          );
          await expect(scrapeEvent("some-event-id")).rejects.toThrow(
            `Scraper API error ${status}`
          );
        }
      )
    );
  });

  it("propagates HTTP errors for event list", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.integer({ min: 400, max: 599 }),
        fc.string(),
        async (status, message) => {
          vi.stubGlobal(
            "fetch",
            vi.fn().mockResolvedValue({
              ok: false,
              status,
              text: async () => message,
            })
          );
          await expect(scrapeEventList("some-page-id")).rejects.toThrow(
            `Scraper API error ${status}`
          );
        }
      )
    );
  });
});

describe("extractEventId: extracts event ID from full URLs and bare IDs", () => {
  it("returns bare event ID unchanged", () => {
    expect(extractEventId("123456789")).toBe("123456789");
    expect(extractEventId("my-event-id")).toBe("my-event-id");
  });

  it("extracts ID from Facebook event URL", () => {
    expect(extractEventId("https://www.facebook.com/events/123456789")).toBe("123456789");
    expect(extractEventId("https://facebook.com/events/987654321")).toBe("987654321");
  });

  it("uses the last path segment from any URL", () => {
    expect(extractEventId("https://example.com/events/abc-event")).toBe("abc-event");
  });
});

describe("extractEventId: rejects invalid URLs and empty IDs", () => {
  it("throws when URL has no event ID path segment (only hostname)", () => {
    expect(() => extractEventId("https://www.facebook.com/")).toThrow(
      "Cannot extract event ID"
    );
  });

  it("throws when URL last segment contains a dot (hostname-like)", () => {
    expect(() => extractEventId("https://example.com")).toThrow(
      "Cannot extract event ID"
    );
  });

  it("throws when URL last segment is a known route component 'events'", () => {
    expect(() => extractEventId("https://facebook.com/events/")).toThrow(
      "Cannot extract event ID"
    );
    expect(() => extractEventId("https://www.facebook.com/events")).toThrow(
      "Cannot extract event ID"
    );
  });

  it("throws when URL last segment is another known route component", () => {
    expect(() => extractEventId("https://facebook.com/pages/")).toThrow(
      "Cannot extract event ID"
    );
    expect(() => extractEventId("https://facebook.com/groups")).toThrow(
      "Cannot extract event ID"
    );
  });
});

describe("scrapeEvent: uses only event ID in path, not full URL", () => {
  it("passes bare event ID directly in path", async () => {
    let capturedUrl = "";
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((url: string) => {
        capturedUrl = url;
        return Promise.resolve({
          ok: false,
          status: 404,
          text: async () => "not found",
        });
      })
    );
    await expect(scrapeEvent("123456789")).rejects.toThrow();
    expect(capturedUrl).toContain("/api/scraper/event/123456789");
    expect(capturedUrl).not.toContain("http%3A");
  });

  it("extracts event ID from full Facebook URL before encoding", async () => {
    let capturedUrl = "";
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((url: string) => {
        capturedUrl = url;
        return Promise.resolve({
          ok: false,
          status: 404,
          text: async () => "not found",
        });
      })
    );
    await expect(scrapeEvent("https://www.facebook.com/events/123456789")).rejects.toThrow();
    expect(capturedUrl).toContain("/api/scraper/event/123456789");
    expect(capturedUrl).not.toContain("http%3A");
  });
});

describe("scrapeEventList: handles malformed items gracefully", () => {
  it("returns only valid events and skips malformed items", async () => {
    const validEvent = {
      id: "123",
      name: "Valid Event",
      startTimestamp: 1700000000,
      url: "https://facebook.com/events/123",
    };
    const malformedEvent = { id: "bad" }; // missing required fields

    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => [validEvent, malformedEvent],
      })
    );

    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    const result = await scrapeEventList("page123");
    warnSpy.mockRestore();

    expect(result).toHaveLength(1);
    expect(result[0].id).toBe("123");
  });

  it("logs a warning for each malformed item", async () => {
    const malformed = [{ id: "bad1" }, { id: "bad2" }];

    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => malformed,
      })
    );

    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    await scrapeEventList("page123");
    expect(warnSpy).toHaveBeenCalledTimes(2);
    warnSpy.mockRestore();
  });
});

describe("Property 3: Event type query parameter inclusion", () => {
  it("includes eventType param when provided", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom("upcoming", "past" as const),
        fc.string({ minLength: 1, maxLength: 20 }),
        async (eventType, pageId) => {
          let capturedUrl = "";
          vi.stubGlobal(
            "fetch",
            vi.fn().mockImplementation((url: string) => {
              capturedUrl = url;
              return Promise.resolve({
                ok: true,
                status: 200,
                json: async () => [],
              });
            })
          );
          await scrapeEventList(pageId, eventType);
          const parsed = new URL(capturedUrl);
          expect(parsed.searchParams.get("eventType")).toBe(eventType);
          expect(parsed.searchParams.get("pageId")).toBe(pageId);
        }
      )
    );
  });

  it("omits eventType param when not provided", async () => {
    let capturedUrl = "";
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((url: string) => {
        capturedUrl = url;
        return Promise.resolve({
          ok: true,
          status: 200,
          json: async () => [],
        });
      })
    );
    await scrapeEventList("page123");
    expect(capturedUrl).not.toContain("eventType");
  });
});
