import { describe, it, expect, vi, beforeEach } from "vitest";
import fc from "fast-check";

// Mock config before importing anything that uses it
vi.mock("../../core/config", () => ({
  config: {
    openRouterApiKey: "test-key",
    openRouterModel: "test-model",
    directusBaseUrl: "http://directus-test",
    directusAccessToken: "test-token",
    corsOrigins: "*",
  },
  captureError: vi.fn(),
}));

// Mock restate SDK
vi.mock("@restatedev/restate-sdk", () => ({
  service: (def: { name: string; handlers: Record<string, unknown> }) => def,
  TerminalError: class TerminalError extends Error {
    errorCode?: number;
    constructor(msg: string, opts?: { errorCode?: number }) {
      super(msg);
      this.name = "TerminalError";
      this.errorCode = opts?.errorCode;
    }
  },
}));

const mockListPublishedEvents = vi.fn();
vi.mock("../../clients/directus-client", () => ({
  listPublishedEvents: (...args: unknown[]) => mockListPublishedEvents(...args),
}));

const mockLog = vi.fn();
vi.mock("../../core/logger", () => ({
  log: (...args: unknown[]) => mockLog(...args),
}));

// Import after mocks
import { apiService } from "../../services/api";

const serviceDef = apiService as unknown as {
  handlers: {
    processEvent: (ctx: MockCtx, req: Record<string, unknown>) => Promise<unknown>;
    listEvents: (ctx: MockCtx) => Promise<unknown>;
    processBatch: (ctx: MockCtx) => Promise<unknown>;
  };
};

type MockCtx = {
  rand: { uuidv4: () => string };
  workflowClient: ReturnType<typeof vi.fn>;
  serviceSendClient: ReturnType<typeof vi.fn>;
  request: () => { headers: Map<string, string> };
};

function makeMockCtx(headers: Record<string, string> = {}): MockCtx {
  const workflowHandle = { run: vi.fn().mockResolvedValue({ id: 1 }) };
  const serviceHandle = { processAll: vi.fn() };
  return {
    rand: { uuidv4: () => "test-uuid" },
    workflowClient: vi.fn().mockReturnValue(workflowHandle),
    serviceSendClient: vi.fn().mockReturnValue(serviceHandle),
    request: () => ({ headers: new Map(Object.entries(headers)) }),
  };
}

beforeEach(() => {
  vi.clearAllMocks();
});

// ---- Property 14: Missing URL field returns 400 ----

describe("Property 14: Missing URL field returns 400", () => {
  it("throws TerminalError with errorCode 400 when url is missing", async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate requests without a url field
        fc.record({
          other: fc.option(fc.string(), { nil: undefined }),
        }),
        async (body) => {
          const ctx = makeMockCtx();
          const req = body as Record<string, unknown>;

          let thrown: unknown;
          try {
            await serviceDef.handlers.processEvent(ctx, req);
          } catch (e) {
            thrown = e;
          }

          expect(thrown).toBeDefined();
          expect((thrown as Error).name).toBe("TerminalError");
          expect((thrown as { errorCode?: number }).errorCode).toBe(400);
        }
      )
    );
  });

  it("throws TerminalError with errorCode 400 when url is empty string", async () => {
    const ctx = makeMockCtx();
    let thrown: unknown;
    try {
      await serviceDef.handlers.processEvent(ctx, { url: "" });
    } catch (e) {
      thrown = e;
    }

    expect(thrown).toBeDefined();
    expect((thrown as Error).name).toBe("TerminalError");
    expect((thrown as { errorCode?: number }).errorCode).toBe(400);
  });

  it("does not throw when url is a non-empty string", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.string({ minLength: 1, maxLength: 100 }),
        async (url) => {
          const ctx = makeMockCtx();
          // Should not throw — may resolve with whatever the workflow returns
          const result = await serviceDef.handlers.processEvent(ctx, { url });
          expect(result).toBeDefined();
        }
      )
    );
  });
});

// ---- Property 24: List events endpoint returns only published events by default ----

describe("Property 24: List events endpoint returns only published events by default", () => {
  it("listPublishedEvents is called with no extra filter when no header is present", async () => {
    // The API service always enforces status:published via listPublishedEvents.
    const mockEvents = [{ id: 1, status: "published" }];
    mockListPublishedEvents.mockResolvedValue(mockEvents);

    const ctx = makeMockCtx();
    const result = await serviceDef.handlers.listEvents(ctx);

    expect(mockListPublishedEvents).toHaveBeenCalledOnce();
    const [extraFilter] = mockListPublishedEvents.mock.calls[0] as [unknown];
    expect(extraFilter).toBeUndefined();
    expect(result).toEqual(mockEvents);
  });

  it("always uses listPublishedEvents regardless of stored events", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.array(
          fc.record({
            id: fc.integer({ min: 1, max: 9999 }),
            status: fc.constantFrom("published", "draft", "archived"),
          }),
          { maxLength: 10 }
        ),
        async (events) => {
          vi.clearAllMocks();
          const published = events.filter((e) => e.status === "published");
          mockListPublishedEvents.mockResolvedValue(published);

          const ctx = makeMockCtx();
          await serviceDef.handlers.listEvents(ctx);

          // API layer always uses listPublishedEvents (status:published enforced inside it)
          expect(mockListPublishedEvents).toHaveBeenCalledOnce();
        }
      )
    );
  });

  it("returns the events array from listEvents", async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.array(
          fc.record({
            id: fc.integer({ min: 1 }),
            status: fc.constant("published"),
          }),
          { maxLength: 5 }
        ),
        async (events) => {
          vi.clearAllMocks();
          mockListPublishedEvents.mockResolvedValue(events);

          const ctx = makeMockCtx();
          const result = await serviceDef.handlers.listEvents(ctx);

          expect(result).toEqual(events);
        }
      )
    );
  });

  it("passes the parsed x-dancee-filter as extraFilter to listPublishedEvents", async () => {
    const mockEvents = [{ id: 2, status: "published" }];
    mockListPublishedEvents.mockResolvedValue(mockEvents);

    // Use an allowed filter field (sanitizeFilter strips disallowed fields)
    const extraFilter = { dances: { _contains: "salsa" } };
    const ctx = makeMockCtx({ "x-dancee-filter": JSON.stringify(extraFilter) });
    const result = await serviceDef.handlers.listEvents(ctx);

    expect(mockListPublishedEvents).toHaveBeenCalledOnce();
    const [calledExtraFilter] = mockListPublishedEvents.mock.calls[0] as [Record<string, unknown>];
    // The extra filter is passed to listPublishedEvents which merges it with published filter
    expect(calledExtraFilter).toEqual(extraFilter);
    expect(result).toEqual(mockEvents);
  });

  it("logs a warning and falls back to no extra filter when x-dancee-filter header is invalid JSON", async () => {
    const mockEvents = [{ id: 3, status: "published" }];
    mockListPublishedEvents.mockResolvedValue(mockEvents);

    const ctx = makeMockCtx({ "x-dancee-filter": "not-valid-json{" });
    const result = await serviceDef.handlers.listEvents(ctx);

    // Warning logged about invalid JSON
    expect(mockLog).toHaveBeenCalledWith(
      expect.objectContaining({ level: "warn", message: expect.stringContaining("invalid JSON") }),
    );
    // Still calls listPublishedEvents with no extra filter
    expect(mockListPublishedEvents).toHaveBeenCalledOnce();
    const [extraFilter] = mockListPublishedEvents.mock.calls[0] as [unknown];
    expect(extraFilter).toBeUndefined();
    expect(result).toEqual(mockEvents);
  });

  it("strips disallowed filter fields and logs a warning for each", async () => {
    const mockEvents = [{ id: 4, status: "published" }];
    mockListPublishedEvents.mockResolvedValue(mockEvents);

    // Mix of allowed (dances) and disallowed (status, secret_field) fields
    const filter = { dances: { _contains: "bachata" }, status: { _eq: "draft" }, secret_field: "x" };
    const ctx = makeMockCtx({ "x-dancee-filter": JSON.stringify(filter) });
    await serviceDef.handlers.listEvents(ctx);

    expect(mockListPublishedEvents).toHaveBeenCalledOnce();
    const [calledFilter] = mockListPublishedEvents.mock.calls[0] as [Record<string, unknown>];
    // Only the allowed field should pass through
    expect(calledFilter).toEqual({ dances: { _contains: "bachata" } });
    // Warnings logged for each stripped field
    expect(mockLog).toHaveBeenCalledWith(
      expect.objectContaining({ level: "warn", message: expect.stringContaining("status") }),
    );
    expect(mockLog).toHaveBeenCalledWith(
      expect.objectContaining({ level: "warn", message: expect.stringContaining("secret_field") }),
    );
  });
});
