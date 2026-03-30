import { describe, it, expect, vi, beforeAll } from "vitest";

// --- Mock all side-effectful dependencies before importing index.ts ---

vi.mock("../core/config", () => ({
  config: {
    corsOrigins: "*",
    appPort: 9080,
  },
  validateConfig: vi.fn(),
  initSentry: vi.fn(),
  captureError: vi.fn(),
}));

// Capture the HTTP request handler from http2.createServer
let capturedHandler: (
  req: Record<string, unknown>,
  res: Record<string, unknown>
) => void;

vi.mock("http2", () => ({
  createServer: vi.fn((handler) => {
    capturedHandler = handler;
    return { listen: vi.fn() };
  }),
}));

// Mock Restate SDK — just need a stub that returns a handler function
const mockRestateHandler = vi.fn();
vi.mock("@restatedev/restate-sdk", () => ({
  endpoint: vi.fn(() => ({
    bind: vi.fn().mockReturnThis(),
    http2Handler: vi.fn(() => mockRestateHandler),
  })),
  workflow: (def: unknown) => def,
  service: (def: unknown) => def,
}));

// Mock all services so they don't execute real logic
vi.mock("../services/api", () => ({ apiService: {} }));
vi.mock("../services/workflow", () => ({ eventWorkflow: {} }));
vi.mock("../services/batch", () => ({ batchService: {} }));

// Import index.ts after mocks — this triggers server setup and captures the handler
await import("../index");

// Helper: build a minimal mock request/response pair
function makeMockReqRes(overrides: {
  method?: string;
  url?: string;
  origin?: string;
} = {}) {
  const { method = "GET", url = "/api/events/list", origin } = overrides;
  const headers: Record<string, string | undefined> = {};
  if (origin) headers["origin"] = origin;

  const setHeaderCalls: Array<[string, string]> = [];
  const res = {
    setHeader: vi.fn((name: string, value: string) => {
      setHeaderCalls.push([name, value]);
    }),
    writeHead: vi.fn(),
    end: vi.fn(),
    _headers: setHeaderCalls,
  };

  const req = {
    method,
    url,
    headers,
  };

  return { req, res };
}

describe("index.ts: route mapping", () => {
  it("maps /api/event to /ApiService/processEvent", () => {
    const { req, res } = makeMockReqRes({ method: "POST", url: "/api/event" });
    capturedHandler(req, res);
    expect(req.url).toBe("/ApiService/processEvent");
    expect(mockRestateHandler).toHaveBeenCalledWith(req, res);
  });

  it("maps /api/events/process to /ApiService/processBatch", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/process" });
    capturedHandler(req, res);
    expect(req.url).toBe("/ApiService/processBatch");
  });

  it("maps /api/events/list to /ApiService/listEvents", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list" });
    capturedHandler(req, res);
    expect(req.url).toBe("/ApiService/listEvents");
  });

  it("passes unmapped paths through to restateHandler unchanged", () => {
    const { req, res } = makeMockReqRes({ url: "/restate/health" });
    capturedHandler(req, res);
    expect(req.url).toBe("/restate/health");
  });

  it("preserves query string when mapping routes", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list?filter=%7B%7D" });
    capturedHandler(req, res);
    expect(req.url).toBe("/ApiService/listEvents?filter=%7B%7D");
  });
});

describe("index.ts: CORS headers", () => {
  it("sets Access-Control-Allow-Methods and Access-Control-Allow-Headers on all requests", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list" });
    capturedHandler(req, res);
    const headerMap = Object.fromEntries(
      (res._headers as Array<[string, string]>).map(([k, v]) => [k, v])
    );
    expect(headerMap["Access-Control-Allow-Methods"]).toBeDefined();
    expect(headerMap["Access-Control-Allow-Headers"]).toBeDefined();
  });

  it("sets Access-Control-Allow-Origin: * when no origin header and corsOrigins is *", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list" });
    capturedHandler(req, res);
    const headerMap = Object.fromEntries(
      (res._headers as Array<[string, string]>).map(([k, v]) => [k, v])
    );
    expect(headerMap["Access-Control-Allow-Origin"]).toBe("*");
  });

  it("echoes back request origin in Access-Control-Allow-Origin when corsOrigins is *", () => {
    const { req, res } = makeMockReqRes({
      url: "/api/events/list",
      origin: "https://app.example.com",
    });
    capturedHandler(req, res);
    const headerMap = Object.fromEntries(
      (res._headers as Array<[string, string]>).map(([k, v]) => [k, v])
    );
    expect(headerMap["Access-Control-Allow-Origin"]).toBe("https://app.example.com");
  });
});

describe("index.ts: OPTIONS preflight handling", () => {
  it("responds with 204 and does not call restateHandler for OPTIONS requests", () => {
    const { req, res } = makeMockReqRes({ method: "OPTIONS", url: "/api/event" });
    const restateCallsBefore = mockRestateHandler.mock.calls.length;
    capturedHandler(req, res);
    expect(res.writeHead).toHaveBeenCalledWith(204);
    expect(res.end).toHaveBeenCalled();
    // restateHandler must NOT be called for preflight
    expect(mockRestateHandler.mock.calls.length).toBe(restateCallsBefore);
  });
});

describe("index.ts: filter query parameter forwarding", () => {
  it("forwards filter query param as x-dancee-filter header for /api/events/list", () => {
    const filter = JSON.stringify({ category: { _eq: "dance" } });
    const encoded = encodeURIComponent(filter);
    const { req, res } = makeMockReqRes({
      url: `/api/events/list?filter=${encoded}`,
    });
    capturedHandler(req, res);
    // URLSearchParams.get() decodes the value, so the header contains the decoded JSON string
    expect((req.headers as Record<string, string>)["x-dancee-filter"]).toBe(filter);
  });

  it("does not set x-dancee-filter for non-list routes", () => {
    const { req, res } = makeMockReqRes({
      url: "/api/events/process?filter=something",
    });
    capturedHandler(req, res);
    expect((req.headers as Record<string, string>)["x-dancee-filter"]).toBeUndefined();
  });

  it("does not set x-dancee-filter when no filter param is present", () => {
    const { req, res } = makeMockReqRes({ url: "/api/events/list" });
    capturedHandler(req, res);
    expect((req.headers as Record<string, string>)["x-dancee-filter"]).toBeUndefined();
  });
});
