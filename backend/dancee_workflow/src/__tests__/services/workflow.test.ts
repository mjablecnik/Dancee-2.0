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
const mockClassifyEventType = vi.fn();
const mockExtractEventParts = vi.fn();
const mockExtractEventInfo = vi.fn();
const mockTranslateEventContent = vi.fn();
const mockResolveVenue = vi.fn();
const mockComputeDances = vi.fn();

vi.mock("../../clients/scraper-client", () => ({
  scrapeEvent: (...args: unknown[]) => mockScrapeEvent(...args),
}));
vi.mock("../../clients/directus-client", () => ({
  findEventByOriginalUrl: (...args: unknown[]) => mockFindEventByOriginalUrl(...args),
  createEvent: (...args: unknown[]) => mockCreateEvent(...args),
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
vi.mock("../../core/schemas", async (importOriginal) => {
  const actual = await importOriginal<typeof import("../../core/schemas")>();
  return {
    ...actual,
    computeDances: (...args: unknown[]) => mockComputeDances(...args),
  };
});

// Import workflow AFTER mocks are set up
import { eventWorkflow } from "../../services/workflow";

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
  mockResolveVenue.mockResolvedValue({ id: 1, name: "Test Venue" });
  mockComputeDances.mockReturnValue(["salsa", "bachata"]);
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

// ---- Property 21: Events collection does not contain title or description fields ----

describe("Property 21: Events collection does not contain title or description fields", () => {
  it("the object passed to createEvent has no top-level title or description", async () => {
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
          expect("title" in lastCallP21[0]).toBe(false);
          expect("description" in lastCallP21[0]).toBe(false);
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
      mockComputeDances.mockReturnValue([]);
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
          mockComputeDances.mockReturnValue([]);
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

  it("unsupported event type returns null without calling createEvent", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.constantFrom("other", "lesson", "course"),
        async (unsupportedType) => {
          vi.clearAllMocks();
          mockFindEventByOriginalUrl.mockResolvedValue(null);

          const ctx = makeMockCtx();
          mockScrapeEvent.mockResolvedValue(makeFacebookEvent());
          mockClassifyEventType.mockResolvedValue(unsupportedType);

          const result = await runWorkflow(ctx, "https://facebook.com/events/123");

          expect(result).toBeNull();
          expect(mockCreateEvent).not.toHaveBeenCalled();
        }
      )
    );
  });
});
