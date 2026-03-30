import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";

// Mock config before importing the client
vi.mock("../../core/config", () => ({
  config: { nominatimBaseUrl: "https://nominatim-test.example.com", nominatimTimeoutMs: 5000 },
}));

import { reverseGeocode, resetThrottle } from "../../clients/nominatim-client";

beforeEach(() => {
  resetThrottle();
  vi.clearAllMocks();
});

afterEach(() => {
  vi.restoreAllMocks();
});

function makeNominatimResponse(overrides: Record<string, unknown> = {}) {
  return {
    display_name: "Main Street 1, Prague, CZ",
    address: {
      road: "Main Street",
      house_number: "1",
      city: "Prague",
      state: "Prague",
      country: "Czech Republic",
      country_code: "cz",
      postcode: "11000",
    },
    ...overrides,
  };
}

// ---- Successful reverse geocoding ----

describe("reverseGeocode: successful response", () => {
  it("returns parsed NominatimResponse on success", async () => {
    const mockResponse = makeNominatimResponse();
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      })
    );

    const result = await reverseGeocode(50.0, 14.0);

    expect(result.address?.road).toBe("Main Street");
    expect(result.address?.city).toBe("Prague");
    expect(result.address?.state).toBe("Prague");
  });

  it("sends request to Nominatim URL with correct lat/lon parameters", async () => {
    let capturedUrl = "";
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((url: string) => {
        capturedUrl = url;
        return Promise.resolve({
          ok: true,
          status: 200,
          json: async () => makeNominatimResponse(),
        });
      })
    );

    await reverseGeocode(50.0760, 14.4181);

    expect(capturedUrl).toContain("nominatim-test.example.com");
    expect(capturedUrl).toContain("lat=50.076");
    expect(capturedUrl).toContain("lon=14.4181");
    expect(capturedUrl).toContain("format=json");
  });

  it("sends User-Agent header in request", async () => {
    let capturedInit: RequestInit | undefined;
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((_url: string, init: RequestInit) => {
        capturedInit = init;
        return Promise.resolve({
          ok: true,
          status: 200,
          json: async () => makeNominatimResponse(),
        });
      })
    );

    await reverseGeocode(50.0, 14.0);

    const headers = capturedInit?.headers as Record<string, string>;
    expect(headers?.["User-Agent"]).toBeDefined();
    expect(headers?.["User-Agent"]).toContain("dancee_workflow");
  });

  it("handles missing optional address fields without error", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => ({ display_name: "Unknown" }),
      })
    );

    const result = await reverseGeocode(0.0, 0.0);

    expect(result.address).toBeUndefined();
    expect(result.display_name).toBe("Unknown");
  });
});

// ---- HTTP error propagation ----

describe("reverseGeocode: HTTP error propagation", () => {
  it("throws an error with status code when HTTP response is not ok", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 429,
        text: async () => "Too Many Requests",
      })
    );

    await expect(reverseGeocode(50.0, 14.0)).rejects.toThrow("429");
  });

  it("includes response text in error message", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: false,
        status: 500,
        text: async () => "Internal Server Error",
      })
    );

    await expect(reverseGeocode(50.0, 14.0)).rejects.toThrow("Internal Server Error");
  });
});

// ---- Response schema validation ----

describe("reverseGeocode: response schema validation", () => {
  it("accepts a response with no address field (all optional)", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => ({}),
      })
    );

    const result = await reverseGeocode(0.0, 0.0);
    expect(result).toEqual({});
  });
});

// ---- Throttle behavior ----

describe("reverseGeocode: throttle behavior", () => {
  it("delays second call when called rapidly in succession", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => makeNominatimResponse(),
      })
    );

    // Use real timers but spy on setTimeout to detect the delay
    const setTimeoutSpy = vi.spyOn(globalThis, "setTimeout");

    const start = Date.now();
    await reverseGeocode(50.0, 14.0); // First call — no delay
    await reverseGeocode(51.0, 15.0); // Second call — should trigger throttle delay

    // setTimeout should have been called for the throttle
    // (either directly or via the new Promise inside throttle)
    const elapsed = Date.now() - start;
    // The second call must have been delayed by ~1000ms. But in tests we don't
    // actually want to wait 1s, so we verify setTimeout was called with a
    // non-zero delay instead.
    const throttleCall = setTimeoutSpy.mock.calls.find(
      ([, delay]) => typeof delay === "number" && (delay as number) > 0
    );
    expect(throttleCall).toBeDefined();

    setTimeoutSpy.mockRestore();
    void elapsed; // suppress unused warning
  });

  it("does not delay when resetThrottle is called between requests", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        json: async () => makeNominatimResponse(),
      })
    );

    const setTimeoutSpy = vi.spyOn(globalThis, "setTimeout");

    await reverseGeocode(50.0, 14.0); // First call
    resetThrottle(); // Reset the throttle state
    await reverseGeocode(51.0, 15.0); // Should not be delayed

    // After resetThrottle, no positive-delay setTimeout should be needed
    const throttleCall = setTimeoutSpy.mock.calls.find(
      ([, delay]) => typeof delay === "number" && (delay as number) > 0
    );
    expect(throttleCall).toBeUndefined();

    setTimeoutSpy.mockRestore();
  });
});
