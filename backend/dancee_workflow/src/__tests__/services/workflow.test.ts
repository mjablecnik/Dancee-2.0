import { describe, it, expect, vi, beforeEach } from "vitest";
import fc from "fast-check";

// Mock config before importing anything that uses it
vi.mock("../../core/config", () => ({
  config: {
    openRouterApiKey: "test-key",
    openRouterModel: "test-model",
    directusBaseUrl: "http://directus-test",
    directusAccessToken: "test-token",
  },
  captureError: vi.fn(),
}));

// Mock restate SDK so workflow() returns the definition object directly,
// allowing us to extract the handler for unit testing
vi.mock("@restatedev/restate-sdk", () => ({
  workflow: (def: { name: string; handlers: Record<string, unknown> }) => def,
  TerminalError: class TerminalError extends Error {
    constructor(msg: string, opts?: { errorCode?: number }) {
      super(msg);
      this.name = "TerminalError";
      if (opts) void opts;
    }
  },
}));

// Mocks for external dependencies
const mockScrapeEvent = vi.fn();
const mockFindEventByOriginalUrl = vi.fn();
const mockCreateEvent = vi.fn();
const mockCreateSkippedEvent = vi.fn();
const mockFindErrorByUrl = vi.fn();
const mockCreateError = vi.fn();
const mockClassifyEventType = vi.fn();
const mockExtractEventParts = vi.fn();
const mockExtractEventInfo = vi.fn();
const mockTranslateEventContent = vi.fn();
const mockResolveVenue = vi.fn();
vi.mock("../../clients/scraper-client", () => ({
  scrapeEvent: (...args: unknown[]) => mockScrapeEvent(...args),
}));
vi.mock("../../clients/directus-client", () => ({
  findEventByOriginalUrl: (...args: unknown[]) => mockFindEventByOriginalUrl(...args),
  createEvent: (...args: unknown[]) => mockCreateEvent(...args),
  createSkippedEvent: (...args: unknown[]) => mockCreateSkippedEvent(...args),
  findErrorByUrl: (...args: unknown[]) => mockFindErrorByUrl(...args),
  createError: (...args: unknown[]) => mockCreateError(...args),
}));
vi.mock("../../services/event-parser", () => ({
  classifyEventType: (...args: unknown[]) => mockClassifyEventType(...args),
  extractEventParts: (...args: unknown[]) => mockExtractEventParts(...args),
  extractEventInfo: (...args: unknown[]) => mockExtractEventInfo(...args),
}));
vi.mock("../../services/event-translator", () => ({
  translateEventContent: (...args: unknown[]) => mockTranslateEventContent(...args),
}));
vi.mock("../../services/venue-resolver", () => ({
  resolveVenue: (...args: unknown[]) => mockResolveVenue(...args),
}));
// No mock for computeDances — it is a pure function with no side effects,
// so the real implementation is used directly in workflow tests.

// Import workflow AFTER mocks are set up
import { eventWorkflow, computeTranslationStatus } from "../../services/workflow";

// Helper: create a minimal mock Restate WorkflowContext
function makeMockCtx(key = "test-run-id") {
  const state: Record<string, unknown> = {};
  return {
    key,
    set: vi.fn((k: string, v: unknown) => {
      state[k] = v;
    }),
    get: vi.fn((k: string) => state[k]),
    // ctx.run executes the function directly (no Restate durability in tests)
    run: vi.fn((_name: string, fn: () => unknown) => fn()),
    _state: state,
  };
}

// Access the raw handler from the workflow definition (works because we mocked restate.workflow)
const workflowDef = eventWorkflow as unknown as {
  handlers: { run: (ctx: ReturnType<typeof makeMockCtx>, url: string) => Promise<unknown> };
};
const runWorkflow = workflowDef.handlers.run;

// Shared arbitraries
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

function makeFacebookEvent(overrides: Record<string, unknown> = {}) {
  return {
    id: "123",
    name: "Test Dance Event",
    description: "A great dance event",
    startTimestamp: 1700000000,
    endTimestamp: 1700010000,
    url: "https://facebook.com/events/123",
    hosts: [{ name: "Test Host", id: "456" }],
    location: {
      name: "Test Venue",
      address: "Main Street 1",
      city: "Prague",
      countryCode: "CZ",
      latitude: 50.0,
      longitude: 14.0,
    },
    ...overrides,
  };
}

beforeEach(() => {
  vi.clearAllMocks();
  // Default mock implementations
  mockFindEventByOriginalUrl.mockResolvedValue(null);
  mockFindErrorByUrl.mockResolvedValue(null);
  mockCreateError.mockResolvedValue({ id: 1, url: "", message: "", datetime: new Date().toISOString() });
  mockCreateSkippedEvent.mockResolvedValue({ id: 1, original_url: "", reason: "" });
  mockResolveVenue.mockResolvedValue({ id: 1, name: "Test Venue" });
  mockCreateEvent.mockImplementation((event: unknown) =>
    Promise.resolve({ ...(event as object), id: 99 })
  );
});

// ---- Property 19: Czech extraction output maps to "cs" translation record ----

describe("Property 19: Czech extraction output maps to 'cs' translation record", () => {
  it("first translation in array has languages_code 'cs' with extracted title and description", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          title: fc.string({ minLength: 1, maxLength: 60 }),
          description: fc.string({ minLength: 1, maxLength: 200 }),
          parts: fc.array(eventPartArb, { maxLength: 3 }),
        }),
        async ({ title, description, parts }) => {
          const ctx = makeMockCtx();
          mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
          mockClassifyEventType.mockResolvedValue("party");
          mockExtractEventParts.mockResolvedValue({ title, description, parts });
          mockExtractEventInfo.mockResolvedValue([]);
          mockTranslateEventContent.mockResolvedValue({
            title: "EN " + title,
            description: "EN " + description,
            parts_translations: parts.map((p) => ({ name: "EN " + p.name, description: "EN " + p.description })),
            info_translations: [],
          });

          await runWorkflow(ctx, "https://facebook.com/events/123");

          const lastCall = mockCreateEvent.mock.lastCall as [{ translations: Array<{ languages_code: string; title: string; description: string }> }];
          const csTranslation = lastCall[0].translations.find(
            (t) => t.languages_code === "cs"
          );

          expect(csTranslation).toBeDefined();
          expect(csTranslation!.title).toBe(title);
          expect(csTranslation!.description).toBe(description);
        }
      )
    );
  });

  it("'cs' translation parts_translations mirrors extracted parts name and description", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.array(eventPartArb, { minLength: 1, maxLength: 4 }),
        async (parts) => {
          const ctx = makeMockCtx();
          mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
          mockClassifyEventType.mockResolvedValue("workshop");
          mockExtractEventParts.mockResolvedValue({
            title: "Czech Title",
            description: "Czech Description",
            parts,
          });
          mockExtractEventInfo.mockResolvedValue([]);
          mockTranslateEventContent.mockResolvedValue({
            title: "Translated",
            description: "Translated",
            parts_translations: parts.map((p) => ({ name: "T: " + p.name, description: "T: " + p.description })),
            info_translations: [],
          });

          await runWorkflow(ctx, "https://facebook.com/events/123");

          const lastCall2 = mockCreateEvent.mock.lastCall as [{ translations: Array<{ languages_code: string; parts_translations: Array<{ name: string; description: string }> }> }];
          const csTranslation = lastCall2[0].translations.find((t) => t.languages_code === "cs");

          expect(csTranslation!.parts_translations).toHaveLength(parts.length);
          for (let i = 0; i < parts.length; i++) {
            expect(csTranslation!.parts_translations[i].name).toBe(parts[i].name);
            expect(csTranslation!.parts_translations[i].description).toBe(parts[i].description);
          }
        }
      )
    );
  });
});

// ---- Property 21: Events collection stores title from extracted data ----

describe("Property 21: Events collection stores the extracted title", () => {
  it("the object passed to createEvent contains the extracted title", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          title: fc.string({ minLength: 1, maxLength: 60 }),
          description: fc.string({ minLength: 1, maxLength: 200 }),
        }),
        async ({ title, description }) => {
          const ctx = makeMockCtx();
          mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
          mockClassifyEventType.mockResolvedValue("festival");
          mockExtractEventParts.mockResolvedValue({ title, description, parts: [] });
          mockExtractEventInfo.mockResolvedValue([]);
          mockTranslateEventContent.mockResolvedValue({
            title: "EN",
            description: "EN",
            parts_translations: [],
            info_translations: [],
          });

          await runWorkflow(ctx, "https://facebook.com/events/123");

          const lastCallP21 = mockCreateEvent.mock.lastCall as [Record<string, unknown>];
          expect(lastCallP21[0].title).toBe(title);
        }
      )
    );
  });
});

// ---- Property 22: New events default to published status ----

describe("Property 22: New events default to published status", () => {
  it("every newly created event has status 'published'", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom("party", "workshop", "festival", "holiday"),
        async (eventType) => {
          const ctx = makeMockCtx();
          mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
          mockClassifyEventType.mockResolvedValue(eventType);
          mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
          mockExtractEventInfo.mockResolvedValue([]);
          mockTranslateEventContent.mockResolvedValue({
            title: "EN",
            description: "EN",
            parts_translations: [],
            info_translations: [],
          });

          await runWorkflow(ctx, "https://facebook.com/events/123");

          const lastCallP22 = mockCreateEvent.mock.lastCall as [{ status: string }];
          expect(lastCallP22[0].status).toBe("published");
        }
      )
    );
  });
});

// ---- Property 23: Translation status reflects actual translation completeness ----

describe("Property 23: Translation status reflects actual translation completeness", () => {
  it("translation_status is 'complete' when cs, en, and es translations all succeed", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
    mockClassifyEventType.mockResolvedValue("party");
    mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
    mockExtractEventInfo.mockResolvedValue([]);
    // Both en and es succeed
    mockTranslateEventContent.mockResolvedValue({
      title: "Translated",
      description: "Translated",
      parts_translations: [],
      info_translations: [],
    });

    await runWorkflow(ctx, "https://facebook.com/events/123");

    const [createdEvent] = mockCreateEvent.mock.calls[0] as [{ translation_status: string; translations: Array<{ languages_code: string }> }];
    expect(createdEvent.translations.map((t) => t.languages_code).sort()).toEqual(["cs", "en", "es"]);
    expect(createdEvent.translation_status).toBe("complete");
  });

  it("translation_status is 'partial' when only cs and en succeed (es fails)", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
    mockClassifyEventType.mockResolvedValue("party");
    mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
    mockExtractEventInfo.mockResolvedValue([]);

    let callCount = 0;
    mockTranslateEventContent.mockImplementation(() => {
      callCount++;
      if (callCount === 1) {
        // en succeeds
        return Promise.resolve({ title: "EN", description: "EN", parts_translations: [], info_translations: [] });
      }
      // es fails
      return Promise.reject(new Error("Translation failed"));
    });

    await runWorkflow(ctx, "https://facebook.com/events/123");

    const [createdEvent] = mockCreateEvent.mock.calls[0] as [{ translation_status: string; translations: Array<{ languages_code: string }> }];
    expect(createdEvent.translations.map((t) => t.languages_code).sort()).toEqual(["cs", "en"]);
    expect(createdEvent.translation_status).toBe("partial");
  });

  it("translation_status is 'partial' when only cs (both en and es fail)", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
    mockClassifyEventType.mockResolvedValue("party");
    mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
    mockExtractEventInfo.mockResolvedValue([]);
    mockTranslateEventContent.mockRejectedValue(new Error("Translation failed"));

    await runWorkflow(ctx, "https://facebook.com/events/123");

    const [createdEvent] = mockCreateEvent.mock.calls[0] as [{ translation_status: string; translations: Array<{ languages_code: string }> }];
    expect(createdEvent.translations.map((t) => t.languages_code)).toEqual(["cs"]);
    expect(createdEvent.translation_status).toBe("partial");
  });

  it("translation_status is property-based: complete iff cs+en+es present", async () => {
    // Test computeTranslationStatus logic through the workflow by injecting
    // arbitrary combinations via mock successes/failures
    const cases: Array<{ enFails: boolean; esFails: boolean; expected: string }> = [
      { enFails: false, esFails: false, expected: "complete" },
      { enFails: true, esFails: false, expected: "partial" },
      { enFails: false, esFails: true, expected: "partial" },
      { enFails: true, esFails: true, expected: "partial" },
    ];

    for (const { enFails, esFails, expected } of cases) {
      vi.clearAllMocks();
      mockFindEventByOriginalUrl.mockResolvedValue(null);
      mockResolveVenue.mockResolvedValue({ id: 1 });
      mockCreateEvent.mockImplementation((e: unknown) => Promise.resolve({ ...(e as object), id: 99 }));

      const ctx = makeMockCtx();
      mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
      mockClassifyEventType.mockResolvedValue("party");
      mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
      mockExtractEventInfo.mockResolvedValue([]);

      let callIdx = 0;
      mockTranslateEventContent.mockImplementation(() => {
        // First call = en, second = es
        const idx = callIdx++;
        const shouldFail = idx === 0 ? enFails : esFails;
        if (shouldFail) return Promise.reject(new Error("fail"));
        return Promise.resolve({ title: "T", description: "D", parts_translations: [], info_translations: [] });
      });

      await runWorkflow(ctx, "https://facebook.com/events/123");

      const [createdEvent] = mockCreateEvent.mock.calls[0] as [{ translation_status: string }];
      expect(createdEvent.translation_status).toBe(expected);
    }
  });
});

// ---- Property 18: Translation failure isolation ----

describe("Property 18: Translation failure isolation", () => {
  it("event is still created even when all translations fail", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
    mockClassifyEventType.mockResolvedValue("party");
    mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
    mockExtractEventInfo.mockResolvedValue([]);
    mockTranslateEventContent.mockRejectedValue(new Error("LLM failure"));

    const result = await runWorkflow(ctx, "https://facebook.com/events/123");

    // createEvent should still be called
    expect(mockCreateEvent).toHaveBeenCalledOnce();
    expect(result).toBeDefined();
  });

  it("event is still created with remaining translations when one language fails", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom(0, 1), // which translation call fails (0=en, 1=es)
        async (failIdx) => {
          vi.clearAllMocks();
          mockFindEventByOriginalUrl.mockResolvedValue(null);
          mockResolveVenue.mockResolvedValue({ id: 1 });
              mockCreateEvent.mockImplementation((e: unknown) => Promise.resolve({ ...(e as object), id: 99 }));

          const ctx = makeMockCtx();
          mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
          mockClassifyEventType.mockResolvedValue("holiday");
          mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
          mockExtractEventInfo.mockResolvedValue([]);

          let callIdx = 0;
          mockTranslateEventContent.mockImplementation(() => {
            const idx = callIdx++;
            if (idx === failIdx) return Promise.reject(new Error("fail"));
            return Promise.resolve({
              title: "Translated",
              description: "Translated",
              parts_translations: [],
              info_translations: [],
            });
          });

          await runWorkflow(ctx, "https://facebook.com/events/123");

          // Event must still be created despite one failing translation
          expect(mockCreateEvent).toHaveBeenCalledOnce();

          const lastCallP18 = mockCreateEvent.mock.lastCall as [{ translations: Array<{ languages_code: string }> }];
          // cs is always present, plus one of en/es should be present
          expect(lastCallP18[0].translations.length).toBe(2);
          expect(lastCallP18[0].translations[0].languages_code).toBe("cs");
        }
      )
    );
  });

  it("unsupported event type 'other' returns skipped response without calling createEvent", async () => {
    vi.clearAllMocks();
    mockFindEventByOriginalUrl.mockResolvedValue(null);
    mockCreateSkippedEvent.mockResolvedValue({ id: 1, original_url: "", reason: "" });

    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
    mockClassifyEventType.mockResolvedValue("other");

    const result = await runWorkflow(ctx, "https://facebook.com/events/123");

    expect(result).toEqual({ status: "skipped", reason: `Unsupported event type: other` });
    expect(mockCreateEvent).not.toHaveBeenCalled();
  });
});

// ---- Early startTimestamp validation ----

describe("Early startTimestamp validation: rejects invalid timestamps before LLM calls", () => {
  it("throws TerminalError immediately for zero startTimestamp without calling classify", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent({ startTimestamp: 0 }));

    await expect(runWorkflow(ctx, "https://facebook.com/events/123")).rejects.toThrow(
      "Invalid startTimestamp"
    );
    expect(mockClassifyEventType).not.toHaveBeenCalled();
  });

  it("throws TerminalError immediately for negative startTimestamp without calling classify", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent({ startTimestamp: -1 }));

    await expect(runWorkflow(ctx, "https://facebook.com/events/123")).rejects.toThrow(
      "Invalid startTimestamp"
    );
    expect(mockClassifyEventType).not.toHaveBeenCalled();
  });

  it("proceeds normally for positive startTimestamp", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent({ startTimestamp: 1700000000 }));
    mockClassifyEventType.mockResolvedValue("party");
    mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
    mockExtractEventInfo.mockResolvedValue([]);
    mockTranslateEventContent.mockResolvedValue({
      title: "EN",
      description: "EN",
      parts_translations: [],
      info_translations: [],
    });

    await expect(runWorkflow(ctx, "https://facebook.com/events/123")).resolves.toBeDefined();
    expect(mockClassifyEventType).toHaveBeenCalledOnce();
  });
});

// ---- Venue id warning ----

describe("Venue id warning: warns when resolveVenue returns venue without id", () => {
  it("logs a warning when venue has no id and stores null as venue association", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
    mockClassifyEventType.mockResolvedValue("party");
    mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
    mockExtractEventInfo.mockResolvedValue([]);
    // Return a venue without an id field
    mockResolveVenue.mockResolvedValue({ name: "No ID Venue" });
    mockTranslateEventContent.mockResolvedValue({
      title: "EN",
      description: "EN",
      parts_translations: [],
      info_translations: [],
    });

    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});

    await runWorkflow(ctx, "https://facebook.com/events/123");

    expect(warnSpy).toHaveBeenCalledWith(
      expect.stringContaining("resolveVenue returned a venue without an id"),
    );
    // venue stored as null because venue.id is undefined
    const [createdEvent] = mockCreateEvent.mock.calls[0] as [{ venue: unknown }];
    expect(createdEvent.venue).toBeNull();

    warnSpy.mockRestore();
  });

  it("does not warn when resolveVenue returns a venue with an id", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
    mockClassifyEventType.mockResolvedValue("party");
    mockExtractEventParts.mockResolvedValue({ title: "T", description: "D", parts: [] });
    mockExtractEventInfo.mockResolvedValue([]);
    mockResolveVenue.mockResolvedValue({ id: 42, name: "Venue With ID" });
    mockTranslateEventContent.mockResolvedValue({
      title: "EN",
      description: "EN",
      parts_translations: [],
      info_translations: [],
    });

    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});

    await runWorkflow(ctx, "https://facebook.com/events/123");

    expect(warnSpy).not.toHaveBeenCalledWith(
      expect.stringContaining("resolveVenue returned a venue without an id"),
    );
    warnSpy.mockRestore();
  });
});

// ---- Error tracking catch block ----

describe("Error tracking: catch block logs failure via createError", () => {
  it("calls createError when workflow throws", async () => {
    const ctx = makeMockCtx();
    const scrapeError = new Error("Scraper unavailable");
    mockScrapeEvent.mockRejectedValue(scrapeError);

    await expect(runWorkflow(ctx, "https://facebook.com/events/err1")).rejects.toThrow(
      "Scraper unavailable"
    );

    expect(mockCreateError).toHaveBeenCalledWith(
      expect.objectContaining({
        url: "https://facebook.com/events/err1",
      })
    );
  });

  it("always calls createError even when an error record already exists (dedup handled inside createError)", async () => {
    const ctx = makeMockCtx();
    mockScrapeEvent.mockRejectedValue(new Error("Network error"));
    mockCreateError.mockResolvedValue({
      id: 42,
      url: "https://facebook.com/events/err2",
      message: "Network error",
      datetime: new Date().toISOString(),
    });

    await expect(runWorkflow(ctx, "https://facebook.com/events/err2")).rejects.toThrow(
      "Network error"
    );

    expect(mockCreateError).toHaveBeenCalledWith(
      expect.objectContaining({
        url: "https://facebook.com/events/err2",
      })
    );
  });

  it("re-throws the original error after logging it", async () => {
    const ctx = makeMockCtx();
    const originalError = new Error("LLM timeout");
    mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
    mockClassifyEventType.mockRejectedValue(originalError);
    mockFindErrorByUrl.mockResolvedValue(null);

    await expect(runWorkflow(ctx, "https://facebook.com/events/err3")).rejects.toThrow(
      "LLM timeout"
    );

    expect(mockCreateError).toHaveBeenCalledOnce();
  });
});

// ---- computeTranslationStatus unit tests (Property 24: business rule per Requirement 24) ----

describe("computeTranslationStatus: direct unit tests (Requirement 24)", () => {
  it("returns 'complete' when cs, en, and es are all present", () => {
    const translations = [
      { languages_code: "cs", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "en", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "es", title: "T", description: "D", parts_translations: [], info_translations: [] },
    ];
    expect(computeTranslationStatus(translations)).toBe("complete");
  });

  it("returns 'partial' when only cs and en are present", () => {
    const translations = [
      { languages_code: "cs", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "en", title: "T", description: "D", parts_translations: [], info_translations: [] },
    ];
    expect(computeTranslationStatus(translations)).toBe("partial");
  });

  it("returns 'partial' when only cs and es are present", () => {
    const translations = [
      { languages_code: "cs", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "es", title: "T", description: "D", parts_translations: [], info_translations: [] },
    ];
    expect(computeTranslationStatus(translations)).toBe("partial");
  });

  it("returns 'partial' when only cs is present", () => {
    const translations = [
      { languages_code: "cs", title: "T", description: "D", parts_translations: [], info_translations: [] },
    ];
    expect(computeTranslationStatus(translations)).toBe("partial");
  });

  it("returns 'missing' when no translations are present", () => {
    expect(computeTranslationStatus([])).toBe("missing");
  });

  it("returns 'partial' when only en is present (no cs)", () => {
    const translations = [
      { languages_code: "en", title: "T", description: "D", parts_translations: [], info_translations: [] },
    ];
    expect(computeTranslationStatus(translations)).toBe("partial");
  });

  it("deduplicates: duplicate language codes do not inflate the count", () => {
    // Two cs entries but still missing en and es → partial (not complete)
    const translations = [
      { languages_code: "cs", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "cs", title: "T2", description: "D2", parts_translations: [], info_translations: [] },
    ];
    expect(computeTranslationStatus(translations)).toBe("partial");
  });

  it("returns 'partial' when an unexpected language code is present alongside cs", () => {
    const translations = [
      { languages_code: "cs", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "fr", title: "T", description: "D", parts_translations: [], info_translations: [] },
    ];
    // cs present but not en+es → partial
    expect(computeTranslationStatus(translations)).toBe("partial");
  });

  it("returns 'complete' when all three codes are present with duplicates", () => {
    // All three languages present, plus a duplicate cs — duplicates do not affect the result
    const translations = [
      { languages_code: "cs", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "en", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "es", title: "T", description: "D", parts_translations: [], info_translations: [] },
      { languages_code: "cs", title: "T2", description: "D2", parts_translations: [], info_translations: [] },
    ];
    expect(computeTranslationStatus(translations)).toBe("complete");
  });
});
