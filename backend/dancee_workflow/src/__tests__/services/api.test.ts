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

const mockListEvents = vi.fn();
vi.mock("../../clients/directus-client", () => ({
  listEvents: (...args: unknown[]) => mockListEvents(...args),
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
  it("listEvents is called with published status filter", async () => {
    const mockEvents = [{ id: 1, status: "published" }];
    mockListEvents.mockResolvedValue(mockEvents);

    const ctx = makeMockCtx();
    const result = await serviceDef.handlers.listEvents(ctx);

    expect(mockListEvents).toHaveBeenCalledOnce();
    const [filter] = mockListEvents.mock.calls[0] as [{ status: { _eq: string } }];
    expect(filter.status._eq).toBe("published");
    expect(result).toEqual(mockEvents);
  });

  it("always filters by published status regardless of stored events", async () => {
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
          // Return only published events (simulating Directus filtering)
          const published = events.filter((e) => e.status === "published");
          mockListEvents.mockResolvedValue(published);

          const ctx = makeMockCtx();
          await serviceDef.handlers.listEvents(ctx);

          expect(mockListEvents).toHaveBeenCalledOnce();
          const [filter] = mockListEvents.mock.calls[0] as [{ status: { _eq: string } }];
          expect(filter.status._eq).toBe("published");
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
          mockListEvents.mockResolvedValue(events);

          const ctx = makeMockCtx();
          const result = await serviceDef.handlers.listEvents(ctx);

          expect(result).toEqual(events);
        }
      )
    );
  });

  it("forwards an explicit filter override when provided via x-dancee-filter header", async () => {
    const mockEvents = [{ id: 2, status: "draft" }];
    mockListEvents.mockResolvedValue(mockEvents);

    const customFilter = { status: { _eq: "draft" } };
    const ctx = makeMockCtx({ "x-dancee-filter": JSON.stringify(customFilter) });
    const result = await serviceDef.handlers.listEvents(ctx);

    expect(mockListEvents).toHaveBeenCalledOnce();
    const [filter] = mockListEvents.mock.calls[0] as [Record<string, unknown>];
    expect(filter).toEqual(customFilter);
    expect(result).toEqual(mockEvents);
  });
});
