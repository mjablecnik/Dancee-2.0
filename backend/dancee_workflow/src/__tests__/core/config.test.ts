import { describe, it, expect, vi, beforeEach } from "vitest";

// Mock dotenv so it does not load a .env file and override env vars set in tests.
vi.mock("dotenv", () => ({ config: vi.fn() }));

// Mock @sentry/node so Sentry.init is not called during tests.
vi.mock("@sentry/node", () => ({
  init: vi.fn(),
  withScope: vi.fn(),
  captureException: vi.fn(),
}));

beforeEach(() => {
  vi.resetModules();
});

async function importConfig(envOverrides: Record<string, string | undefined>) {
  // Apply env var overrides
  const saved: Record<string, string | undefined> = {};
  for (const [key, value] of Object.entries(envOverrides)) {
    saved[key] = process.env[key];
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
  const mod = await import("../../core/config");
  // Restore env vars after import
  for (const [key, savedValue] of Object.entries(saved)) {
    if (savedValue === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = savedValue;
    }
  }
  return mod;
}

// ---- validateConfig unit tests (Requirement 15) ----

describe("validateConfig: no throw when all required vars are present", () => {
  it("does not throw when all required env vars are set", async () => {
    const { validateConfig } = await importConfig({
      OPENROUTER_API_KEY: "key",
      DIRECTUS_BASE_URL: "http://directus",
      DIRECTUS_ACCESS_TOKEN: "token",
      SCRAPER_BASE_URL: "http://scraper",
    });
    expect(() => validateConfig()).not.toThrow();
  });
});

describe("validateConfig: throws for each missing required var individually", () => {
  it("throws when OPENROUTER_API_KEY is missing", async () => {
    const { validateConfig } = await importConfig({
      OPENROUTER_API_KEY: undefined,
      DIRECTUS_BASE_URL: "http://directus",
      DIRECTUS_ACCESS_TOKEN: "token",
      SCRAPER_BASE_URL: "http://scraper",
    });
    expect(() => validateConfig()).toThrow("OPENROUTER_API_KEY");
  });

  it("throws when DIRECTUS_BASE_URL is missing", async () => {
    const { validateConfig } = await importConfig({
      OPENROUTER_API_KEY: "key",
      DIRECTUS_BASE_URL: undefined,
      DIRECTUS_ACCESS_TOKEN: "token",
      SCRAPER_BASE_URL: "http://scraper",
    });
    expect(() => validateConfig()).toThrow("DIRECTUS_BASE_URL");
  });

  it("throws when DIRECTUS_ACCESS_TOKEN is missing", async () => {
    const { validateConfig } = await importConfig({
      OPENROUTER_API_KEY: "key",
      DIRECTUS_BASE_URL: "http://directus",
      DIRECTUS_ACCESS_TOKEN: undefined,
      SCRAPER_BASE_URL: "http://scraper",
    });
    expect(() => validateConfig()).toThrow("DIRECTUS_ACCESS_TOKEN");
  });

  it("throws when SCRAPER_BASE_URL is missing", async () => {
    const { validateConfig } = await importConfig({
      OPENROUTER_API_KEY: "key",
      DIRECTUS_BASE_URL: "http://directus",
      DIRECTUS_ACCESS_TOKEN: "token",
      SCRAPER_BASE_URL: undefined,
    });
    expect(() => validateConfig()).toThrow("SCRAPER_BASE_URL");
  });
});

describe("validateConfig: throws with all missing var names when multiple are missing", () => {
  it("lists all missing var names in the error message", async () => {
    const { validateConfig } = await importConfig({
      OPENROUTER_API_KEY: undefined,
      DIRECTUS_BASE_URL: undefined,
      DIRECTUS_ACCESS_TOKEN: "token",
      SCRAPER_BASE_URL: "http://scraper",
    });
    let errorMessage = "";
    try {
      validateConfig();
    } catch (e) {
      errorMessage = (e as Error).message;
    }
    expect(errorMessage).toContain("OPENROUTER_API_KEY");
    expect(errorMessage).toContain("DIRECTUS_BASE_URL");
    expect(errorMessage).not.toContain("DIRECTUS_ACCESS_TOKEN");
    expect(errorMessage).not.toContain("SCRAPER_BASE_URL");
  });

  it("error message contains instruction to set the variables", async () => {
    const { validateConfig } = await importConfig({
      OPENROUTER_API_KEY: undefined,
      DIRECTUS_BASE_URL: "http://directus",
      DIRECTUS_ACCESS_TOKEN: "token",
      SCRAPER_BASE_URL: "http://scraper",
    });
    expect(() => validateConfig()).toThrow(/Set these variables before starting/);
  });
});
