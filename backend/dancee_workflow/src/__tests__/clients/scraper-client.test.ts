import { describe, it, expect, vi, afterEach } from "vitest";
import fc from "fast-check";

// Mock config before importing the client
vi.mock("../../core/config", () => ({
  config: { scraperBaseUrl: "http://scraper-test" },
}));

import { scrapeEvent, scrapeEventList } from "../../clients/scraper-client";

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
