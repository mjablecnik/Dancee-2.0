import { describe, it, expect, vi, afterEach } from "vitest";

// Mock the local scraper service
const mockScrapeFacebookEvent = vi.fn();
const mockScrapeFacebookEventList = vi.fn();
vi.mock("../../services/scraper", () => ({
  scrapeFacebookEvent: (...args: unknown[]) => mockScrapeFacebookEvent(...args),
  scrapeFacebookEventList: (...args: unknown[]) => mockScrapeFacebookEventList(...args),
}));

import { scrapeEvent, scrapeEventList, extractEventId } from "../../clients/scraper-client";

afterEach(() => {
  vi.restoreAllMocks();
  mockScrapeFacebookEvent.mockReset();
  mockScrapeFacebookEventList.mockReset();
});

describe("scrapeEvent: calls local scraper and validates with schema", () => {
  it("converts bare event ID to full Facebook URL", async () => {
    mockScrapeFacebookEvent.mockResolvedValue({
      id: "123456789",
      name: "Test Event",
      startTimestamp: 1700000000,
      url: "https://www.facebook.com/events/123456789",
    });

    await scrapeEvent("123456789");
    expect(mockScrapeFacebookEvent).toHaveBeenCalledWith(
      "https://www.facebook.com/events/123456789",
    );
  });

  it("passes full URL directly to scraper", async () => {
    const fbUrl = "https://www.facebook.com/events/123456789";
    mockScrapeFacebookEvent.mockResolvedValue({
      id: "123456789",
      name: "Test Event",
      startTimestamp: 1700000000,
      url: fbUrl,
    });

    await scrapeEvent(fbUrl);
    expect(mockScrapeFacebookEvent).toHaveBeenCalledWith(fbUrl);
  });

  it("propagates scraper errors", async () => {
    mockScrapeFacebookEvent.mockRejectedValue(new Error("Scrape failed"));
    await expect(scrapeEvent("some-event-id")).rejects.toThrow("Scrape failed");
  });
});

describe("scrapeEventList: calls local scraper and filters results", () => {
  it("returns only valid events and skips malformed items", async () => {
    const validEvent = {
      id: "123",
      name: "Valid Event",
      startTimestamp: 1700000000,
      url: "https://facebook.com/events/123",
    };
    const malformedEvent = { id: "bad" };

    mockScrapeFacebookEventList.mockResolvedValue([validEvent, malformedEvent]);

    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    const result = await scrapeEventList("page123");
    warnSpy.mockRestore();

    expect(result).toHaveLength(1);
    expect(result[0].id).toBe("123");
  });

  it("passes eventType to scraper", async () => {
    mockScrapeFacebookEventList.mockResolvedValue([]);
    await scrapeEventList("page123", "upcoming");
    expect(mockScrapeFacebookEventList).toHaveBeenCalledWith("page123", "upcoming");
  });

  it("omits eventType when not provided", async () => {
    mockScrapeFacebookEventList.mockResolvedValue([]);
    await scrapeEventList("page123");
    expect(mockScrapeFacebookEventList).toHaveBeenCalledWith("page123", undefined);
  });

  it("logs a warning for each malformed item", async () => {
    const malformed = [{ id: "bad1" }, { id: "bad2" }];
    mockScrapeFacebookEventList.mockResolvedValue(malformed);

    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    await scrapeEventList("page123");
    expect(warnSpy).toHaveBeenCalledTimes(2);
    warnSpy.mockRestore();
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
      "Cannot extract event ID",
    );
  });

  it("throws when URL last segment contains a dot (hostname-like)", () => {
    expect(() => extractEventId("https://example.com")).toThrow(
      "Cannot extract event ID",
    );
  });

  it("throws when URL last segment is a known route component 'events'", () => {
    expect(() => extractEventId("https://facebook.com/events/")).toThrow(
      "Cannot extract event ID",
    );
    expect(() => extractEventId("https://www.facebook.com/events")).toThrow(
      "Cannot extract event ID",
    );
  });

  it("throws when URL last segment is another known route component", () => {
    expect(() => extractEventId("https://facebook.com/pages/")).toThrow(
      "Cannot extract event ID",
    );
    expect(() => extractEventId("https://facebook.com/groups")).toThrow(
      "Cannot extract event ID",
    );
  });
});
