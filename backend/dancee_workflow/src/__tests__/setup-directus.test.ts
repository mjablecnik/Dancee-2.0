import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";

// Set required env vars before the script reads them at module load
process.env.DIRECTUS_BASE_URL = "http://directus-test";
process.env.DIRECTUS_ACCESS_TOKEN = "test-admin-token";

// Mock dotenv so it doesn't override our test env vars
vi.mock("dotenv", () => ({ config: vi.fn() }));

type FetchCall = { url: string; method: string };

function makeFetchMock(
  responseFactory: (url: string, method: string) => { ok: boolean; status: number; data?: unknown }
) {
  const mock = vi.fn().mockImplementation(async (url: string, init?: RequestInit) => {
    const method = init?.method ?? "GET";
    const { ok, status, data } = responseFactory(url, method);
    return {
      ok,
      status,
      json: async () => data ?? {},
      text: async () => String(status),
    };
  });
  return mock;
}

function getCallsFrom(mock: ReturnType<typeof vi.fn>): FetchCall[] {
  return (mock.mock.calls as Array<[string, RequestInit?]>).map(([url, init]) => ({
    url,
    method: init?.method ?? "GET",
  }));
}

beforeEach(() => {
  vi.resetModules();
});

afterEach(() => {
  vi.unstubAllGlobals();
});

// ---- env var validation ----

describe("env var validation: throws when required vars are missing", () => {
  it("rejects ready with an error when DIRECTUS_BASE_URL is not set", async () => {
    const origUrl = process.env.DIRECTUS_BASE_URL;
    const origToken = process.env.DIRECTUS_ACCESS_TOKEN;
    delete process.env.DIRECTUS_BASE_URL;
    process.env.DIRECTUS_ACCESS_TOKEN = "some-token";

    // process.exit may be called from the ready catch — stub it so the test runner is not killed
    const exitSpy = vi.spyOn(process, "exit").mockImplementation(() => undefined as never);
    const errorSpy = vi.spyOn(console, "error").mockImplementation(() => {});

    vi.resetModules();
    const { ready } = await import("../../scripts/setup-directus");
    await ready; // The catch handler in ready swallows the error and calls process.exit(1)

    expect(errorSpy).toHaveBeenCalledWith(
      "Setup failed:",
      expect.objectContaining({ message: expect.stringContaining("DIRECTUS_BASE_URL") }),
    );
    expect(exitSpy).toHaveBeenCalledWith(1);

    errorSpy.mockRestore();
    exitSpy.mockRestore();
    if (origUrl !== undefined) process.env.DIRECTUS_BASE_URL = origUrl;
    if (origToken !== undefined) process.env.DIRECTUS_ACCESS_TOKEN = origToken;
  });

  it("rejects ready with an error when DIRECTUS_ACCESS_TOKEN is not set", async () => {
    const origUrl = process.env.DIRECTUS_BASE_URL;
    const origToken = process.env.DIRECTUS_ACCESS_TOKEN;
    process.env.DIRECTUS_BASE_URL = "http://directus-test";
    delete process.env.DIRECTUS_ACCESS_TOKEN;

    const exitSpy = vi.spyOn(process, "exit").mockImplementation(() => undefined as never);
    const errorSpy = vi.spyOn(console, "error").mockImplementation(() => {});

    vi.resetModules();
    const { ready } = await import("../../scripts/setup-directus");
    await ready;

    expect(errorSpy).toHaveBeenCalledWith(
      "Setup failed:",
      expect.objectContaining({ message: expect.stringContaining("DIRECTUS_ACCESS_TOKEN") }),
    );
    expect(exitSpy).toHaveBeenCalledWith(1);

    errorSpy.mockRestore();
    exitSpy.mockRestore();
    if (origUrl !== undefined) process.env.DIRECTUS_BASE_URL = origUrl;
    if (origToken !== undefined) process.env.DIRECTUS_ACCESS_TOKEN = origToken;
  });
});

// ---- createCollectionIfNotExists ----

describe("createCollectionIfNotExists: idempotency", () => {
  it("skips POST /collections when collection already exists", async () => {
    const mock = makeFetchMock((url, method) => {
      if (method === "GET") {
        return { ok: true, status: 200, data: { data: { exists: true } } };
      }
      return { ok: true, status: 200, data: { data: {} } };
    });
    vi.stubGlobal("fetch", mock);

    const { ready } = await import("../../scripts/setup-directus");
    await ready;

    const calls = getCallsFrom(mock);
    const collectionPosts = calls.filter(
      (c) => c.method === "POST" && c.url.endsWith("/collections")
    );
    expect(collectionPosts).toHaveLength(0);
  });

  it("sends POST /collections when collection does not exist", async () => {
    const mock = makeFetchMock((url, method) => {
      if (method === "GET") {
        return { ok: false, status: 404, data: {} };
      }
      return { ok: true, status: 200, data: { data: {} } };
    });
    vi.stubGlobal("fetch", mock);

    const { ready } = await import("../../scripts/setup-directus");
    await ready;

    const calls = getCallsFrom(mock);
    const collectionPosts = calls.filter(
      (c) => c.method === "POST" && c.url.includes("/collections")
    );
    expect(collectionPosts.length).toBeGreaterThan(0);
  });
});

// ---- createFieldIfNotExists ----

describe("createFieldIfNotExists: idempotency", () => {
  it("skips POST /fields when fields already exist", async () => {
    const mock = makeFetchMock((url, method) => {
      if (method === "GET") {
        return { ok: true, status: 200, data: { data: { exists: true } } };
      }
      return { ok: true, status: 200, data: { data: {} } };
    });
    vi.stubGlobal("fetch", mock);

    const { ready } = await import("../../scripts/setup-directus");
    await ready;

    const calls = getCallsFrom(mock);
    const fieldPosts = calls.filter(
      (c) => c.method === "POST" && c.url.includes("/fields/")
    );
    expect(fieldPosts).toHaveLength(0);
  });

  it("sends POST /fields when fields do not exist", async () => {
    const mock = makeFetchMock((url, method) => {
      if (method === "GET") {
        return { ok: false, status: 404, data: {} };
      }
      return { ok: true, status: 200, data: { data: {} } };
    });
    vi.stubGlobal("fetch", mock);

    const { ready } = await import("../../scripts/setup-directus");
    await ready;

    const calls = getCallsFrom(mock);
    const fieldPosts = calls.filter(
      (c) => c.method === "POST" && c.url.includes("/fields/")
    );
    expect(fieldPosts.length).toBeGreaterThan(0);
  });
});

// ---- seedLanguages: no duplicates ----

describe("seedLanguages: no duplicate language seeding", () => {
  it("skips POST for languages that already exist", async () => {
    const mock = makeFetchMock((url, method) => {
      if (method === "GET") {
        return { ok: true, status: 200, data: { data: { exists: true } } };
      }
      return { ok: true, status: 200, data: { data: {} } };
    });
    vi.stubGlobal("fetch", mock);

    const { ready } = await import("../../scripts/setup-directus");
    await ready;

    const calls = getCallsFrom(mock);
    const languagePosts = calls.filter(
      (c) => c.method === "POST" && c.url.includes("/items/languages")
    );
    expect(languagePosts).toHaveLength(0);
  });

  it("seeds all three languages when they don't exist", async () => {
    const mock = makeFetchMock((url, method) => {
      if (method === "GET" && url.includes("/items/languages/")) {
        return { ok: false, status: 404, data: {} };
      }
      if (method === "GET") {
        return { ok: true, status: 200, data: { data: { exists: true } } };
      }
      return { ok: true, status: 200, data: { data: {} } };
    });
    vi.stubGlobal("fetch", mock);

    const { ready } = await import("../../scripts/setup-directus");
    await ready;

    const calls = getCallsFrom(mock);
    const languagePosts = calls.filter(
      (c) => c.method === "POST" && c.url.includes("/items/languages")
    );
    expect(languagePosts).toHaveLength(3);
  });

  it("seeds only missing languages when some already exist", async () => {
    const seeded = new Set(["cs"]);
    const mock = makeFetchMock((url, method) => {
      if (method === "GET" && url.includes("/items/languages/")) {
        const code = url.split("/items/languages/")[1];
        if (seeded.has(code)) {
          return { ok: true, status: 200, data: { data: { code } } };
        }
        return { ok: false, status: 404, data: {} };
      }
      if (method === "GET") {
        return { ok: true, status: 200, data: { data: { exists: true } } };
      }
      return { ok: true, status: 200, data: { data: {} } };
    });
    vi.stubGlobal("fetch", mock);

    const { ready } = await import("../../scripts/setup-directus");
    await ready;

    const calls = getCallsFrom(mock);
    const languagePosts = calls.filter(
      (c) => c.method === "POST" && c.url.includes("/items/languages")
    );
    // Only en and es are missing (cs already exists)
    expect(languagePosts).toHaveLength(2);
  });
});
