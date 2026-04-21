import { describe, it, expect, vi } from "vitest";
import fc from "fast-check";
import {
  parseEventType,
  parseJsonResponse,
  filterEventInfo,
  computeDances,
  SUPPORTED_EVENT_TYPES,
  EventPartSchema,
  FacebookEventSchema,
} from "../../core/schemas";

describe("parseEventType", () => {
  it("Property 4: always returns a valid EventType", () => {
    fc.assert(
      fc.property(fc.string(), (value) => {
        const result = parseEventType(value);
        const validTypes = ["party", "workshop", "lesson", "course", "festival", "holiday", "other"];
        expect(validTypes).toContain(result);
      })
    );
  });

  it("returns 'other' for unrecognized values", () => {
    expect(parseEventType("unknown")).toBe("other");
    expect(parseEventType("")).toBe("other");
  });

  it("returns the type for recognized values (case-insensitive)", () => {
    expect(parseEventType("party")).toBe("party");
    expect(parseEventType("PARTY")).toBe("party");
    expect(parseEventType("Workshop")).toBe("workshop");
    expect(parseEventType("  FESTIVAL  ")).toBe("festival");
  });
});

// JSON.stringify(-0) === "0" (positive zero), so -0 doesn't survive a JSON round-trip.
// This helper detects -0 anywhere in a value tree so we can exclude such values from tests.
function hasNegativeZero(v: unknown): boolean {
  if (Object.is(v, -0)) return true;
  if (Array.isArray(v)) return v.some(hasNegativeZero);
  if (v !== null && typeof v === "object") return Object.values(v as Record<string, unknown>).some(hasNegativeZero);
  return false;
}

describe("parseJsonResponse", () => {
  it("Property 6: strips markdown code fences before parsing JSON", () => {
    const obj = { key: "value", num: 42 };
    const json = JSON.stringify(obj);

    // No fences
    expect(parseJsonResponse(json)).toEqual(obj);

    // With ```json fences
    expect(parseJsonResponse("```json\n" + json + "\n```")).toEqual(obj);

    // With ``` fences (no language)
    expect(parseJsonResponse("```\n" + json + "\n```")).toEqual(obj);
  });

  it("handles leading text/whitespace before code fence", () => {
    const obj = { key: "value" };
    const json = JSON.stringify(obj);

    // Leading newlines before fence
    expect(parseJsonResponse("\n\n```json\n" + json + "\n```")).toEqual(obj);

    // Explanatory text before fence
    expect(parseJsonResponse("Here is the result:\n```json\n" + json + "\n```")).toEqual(obj);

    // Leading whitespace and language-less fence
    expect(parseJsonResponse("  ```\n" + json + "\n```")).toEqual(obj);
  });

  it("parses plain JSON without fences", () => {
    fc.assert(
      // Exclude values containing -0 since JSON.stringify(-0) === "0", breaking round-trips
      fc.property(fc.jsonValue().filter((v) => !hasNegativeZero(v)), (value) => {
        const json = JSON.stringify(value);
        expect(parseJsonResponse(json)).toEqual(value);
      })
    );
  });

  it("strips code fences and parses correctly", () => {
    fc.assert(
      // Exclude values containing -0 since JSON.stringify(-0) === "0", breaking round-trips
      fc.property(fc.jsonValue().filter((v) => !hasNegativeZero(v)), (value) => {
        const json = JSON.stringify(value);
        const withFences = "```json\n" + json + "\n```";
        expect(parseJsonResponse(withFences)).toEqual(value);
      })
    );
  });
});

describe("filterEventInfo", () => {
  it("logs a warning for each item that fails schema validation", () => {
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    filterEventInfo([{ type: "invalid-type", key: "x", value: "y" }]);
    expect(warnSpy).toHaveBeenCalledWith(
      expect.stringContaining("dropping item that failed validation"),
    );
    warnSpy.mockRestore();
  });

  it("does not warn for valid items", () => {
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    filterEventInfo([{ type: "url", key: "Registration", value: "https://example.com" }]);
    expect(warnSpy).not.toHaveBeenCalled();
    warnSpy.mockRestore();
  });

  it("Property 8: filters out entries with empty or null values", () => {
    const items = [
      { type: "url", key: "Registration", value: "https://example.com" },
      { type: "price", key: "Price", value: "" },
      { type: "price", key: "Price2", value: "10 EUR" },
      { type: "url", key: "Link", value: null },
    ];
    const result = filterEventInfo(items);
    expect(result.every((item) => item.value !== "" && item.value !== null)).toBe(true);
    expect(result).toHaveLength(2);
  });

  it("returns valid EventInfo items only", () => {
    fc.assert(
      fc.property(
        fc.array(
          fc.record({
            type: fc.constantFrom("url", "price"),
            key: fc.string({ minLength: 1 }),
            value: fc.string(),
          })
        ),
        (items) => {
          const result = filterEventInfo(items);
          expect(result.every((item) => item.value !== "" && item.value !== null)).toBe(true);
        }
      )
    );
  });
});

describe("computeDances", () => {
  it("Property 15: computed dances is the unique set from all parts, capped at 6", () => {
    fc.assert(
      fc.property(
        fc.array(
          fc.record({
            name: fc.string(),
            description: fc.string(),
            type: fc.constantFrom("party", "workshop", "openLesson"),
            dances: fc.array(fc.string({ minLength: 1 })),
            date_time_range: fc.record({
              start: fc.constant("2024-01-01T18:00:00Z"),
              end: fc.constant("2024-01-01T22:00:00Z"),
            }),
            lectors: fc.array(fc.string()),
            djs: fc.array(fc.string()),
          })
        ),
        (parts) => {
          const result = computeDances(parts);
          // Result must be a unique set
          expect(result).toHaveLength(new Set(result).size);
          // Result must be capped at 6
          expect(result.length).toBeLessThanOrEqual(6);
          // All result entries must come from the parts' dances (first-seen order)
          const allDances = parts.flatMap((p) => p.dances);
          for (const dance of result) {
            expect(allDances).toContain(dance);
          }
        }
      )
    );
  });

  it("returns empty array when no parts", () => {
    expect(computeDances([])).toEqual([]);
  });

  it("deduplicates dances across parts", () => {
    const parts = [
      {
        name: "Workshop",
        description: "",
        type: "workshop" as const,
        dances: ["Salsa", "Bachata"],
        date_time_range: { start: "2024-01-01T18:00:00Z", end: "2024-01-01T20:00:00Z" },
        lectors: [],
        djs: [],
      },
      {
        name: "Party",
        description: "",
        type: "party" as const,
        dances: ["Salsa", "Kizomba"],
        date_time_range: { start: "2024-01-01T20:00:00Z", end: "2024-01-01T23:00:00Z" },
        lectors: [],
        djs: [],
      },
    ];
    const result = computeDances(parts);
    expect(result).toHaveLength(3);
    expect(result).toContain("Salsa");
    expect(result).toContain("Bachata");
    expect(result).toContain("Kizomba");
  });
});

// Helper to build a minimal valid FacebookEvent for schema parsing
function makeFbEventRaw(overrides: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    id: "123",
    name: "Test Event",
    startTimestamp: 1700000000,
    url: "https://facebook.com/events/123",
    ...overrides,
  };
}

describe("FacebookEventSchema.endTimestamp: <= 0 transforms to null", () => {
  it("transforms 0 endTimestamp to null", () => {
    const result = FacebookEventSchema.parse(makeFbEventRaw({ endTimestamp: 0 }));
    expect(result.endTimestamp).toBeNull();
  });

  it("transforms negative endTimestamp to null", () => {
    const result = FacebookEventSchema.parse(makeFbEventRaw({ endTimestamp: -1 }));
    expect(result.endTimestamp).toBeNull();
  });

  it("keeps positive endTimestamp as-is", () => {
    const result = FacebookEventSchema.parse(makeFbEventRaw({ endTimestamp: 1700010000 }));
    expect(result.endTimestamp).toBe(1700010000);
  });

  it("keeps null endTimestamp as null", () => {
    const result = FacebookEventSchema.parse(makeFbEventRaw({ endTimestamp: null }));
    expect(result.endTimestamp).toBeNull();
  });

  it("keeps undefined endTimestamp as undefined when field is absent", () => {
    const result = FacebookEventSchema.parse(makeFbEventRaw());
    expect(result.endTimestamp).toBeUndefined();
  });

  it("Property: any endTimestamp <= 0 is transformed to null", () => {
    fc.assert(
      fc.property(fc.integer({ max: 0 }), (ts) => {
        const result = FacebookEventSchema.parse(makeFbEventRaw({ endTimestamp: ts }));
        expect(result.endTimestamp).toBeNull();
      })
    );
  });
});
