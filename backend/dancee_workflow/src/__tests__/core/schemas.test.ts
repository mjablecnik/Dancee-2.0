import { describe, it, expect } from "vitest";
import fc from "fast-check";
import {
  parseEventType,
  parseJsonResponse,
  filterEventInfo,
  computeDances,
  SUPPORTED_EVENT_TYPES,
  EventPartSchema,
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
  it("Property 15: computed dances is the unique set from all parts", () => {
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
          // Result must contain all dances from parts
          const allDances = parts.flatMap((p) => p.dances);
          for (const dance of allDances) {
            if (dance !== "") {
              expect(result).toContain(dance);
            }
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
