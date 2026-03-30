import { z } from "zod";
import { log } from "./logger";

// ---- Facebook schemas ----

export const FacebookEventSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string().optional(),
  startTimestamp: z.number(),
  // Transform: values <= 0 are treated as null (same rule as toIsoOrNull).
  // Facebook never schedules events at Unix epoch; a zero/negative timestamp
  // means unset/invalid data. This encodes the constraint at the schema level
  // so consumers receive null rather than a misleading zero.
  endTimestamp: z
    .number()
    .nullable()
    .optional()
    .transform((ts) => (ts !== null && ts !== undefined && ts <= 0 ? null : ts)),
  timezone: z.string().optional(),
  location: z
    .object({
      name: z.string().optional(),
      address: z.string().optional(),
      city: z.string().optional(),
      country: z.string().optional(),
      // NOTE: design specifies only `country`, but Facebook returns `countryCode`
      // (ISO alpha-2 code). Implementation uses countryCode which is more precise
      // and correct for the venue-resolver mapping. This is an intentional improvement.
      countryCode: z.string().optional(),
      latitude: z.number().optional(),
      longitude: z.number().optional(),
    })
    .optional(),
  hosts: z
    .array(
      z.object({
        name: z.string(),
        id: z.string(),
        url: z.string(),
        type: z.string(),
      })
    )
    .optional(),
  url: z.string(),
});

export type FacebookEvent = z.infer<typeof FacebookEventSchema>;
export type FacebookLocation = NonNullable<FacebookEvent["location"]>;

// ---- Event type ----

export const SUPPORTED_EVENT_TYPES = ["party", "workshop", "festival", "holiday"] as const;
const ALL_EVENT_TYPES = ["party", "workshop", "lesson", "course", "festival", "holiday", "other"] as const;

export const EventTypeSchema = z.enum(ALL_EVENT_TYPES);
export type EventType = z.infer<typeof EventTypeSchema>;

export function parseEventType(value: string): EventType {
  const parsed = EventTypeSchema.safeParse(value.toLowerCase().trim());
  return parsed.success ? parsed.data : "other";
}

// ---- EventPart ----

export const EventPartSchema = z.object({
  name: z.string(),
  description: z.string(),
  type: z.enum(["party", "workshop", "openLesson"]),
  dances: z.array(z.string()),
  date_time_range: z.object({
    start: z.string(),
    end: z.string(),
  }),
  lectors: z.array(z.string()),
  djs: z.array(z.string()),
});

export type EventPart = z.infer<typeof EventPartSchema>;

// ---- EventInfo ----

export const EventInfoSchema = z.object({
  type: z.enum(["url", "price"]),
  key: z.string(),
  value: z.string(),
});

export type EventInfo = z.infer<typeof EventInfoSchema>;

export function filterEventInfo(items: unknown[]): EventInfo[] {
  return items
    .map((item) => {
      const result = EventInfoSchema.safeParse(item);
      if (!result.success) {
        log({ level: "warn", message: "filterEventInfo: dropping item that failed validation", item, error: result.error.message });
      }
      return result;
    })
    .filter((result): result is { success: true; data: EventInfo } => result.success)
    .map((result) => result.data)
    .filter((item) => item.value !== "" && item.value !== null);
}

export function computeDances(parts: EventPart[]): string[] {
  const seen = new Set<string>();
  for (const part of parts) {
    for (const dance of part.dances) {
      seen.add(dance);
    }
  }
  return Array.from(seen);
}

// ---- Directus schemas ----

export const DirectusEventTranslationSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  events_id: z.union([z.number(), z.string()]).optional(),
  languages_code: z.string(),
  title: z.string(),
  description: z.string(),
  parts_translations: z.array(z.object({ name: z.string(), description: z.string() })),
  info_translations: z.array(z.object({ key: z.string() })),
});

export type DirectusEventTranslation = z.infer<typeof DirectusEventTranslationSchema>;

export const DirectusEventSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  original_description: z.string(),
  organizer: z.string(),
  // Directus may return venue IDs as number (auto-increment) or string (UUID).
  // Align with DirectusVenueSchema.id to avoid type mismatch at runtime.
  venue: z.union([z.number(), z.string()]).nullable().optional(),
  start_time: z.string(),
  end_time: z.string().nullable().optional(),
  timezone: z.string(),
  original_url: z.string(),
  parts: z.array(EventPartSchema),
  info: z.array(EventInfoSchema),
  dances: z.array(z.string()),
  status: z.enum(["published", "draft", "archived"]).optional(),
  translation_status: z.enum(["complete", "partial", "missing"]).optional(),
  translations: z.array(DirectusEventTranslationSchema).optional(),
});

export type DirectusEvent = z.infer<typeof DirectusEventSchema>;

export const DirectusLanguageSchema = z.object({
  code: z.string(),
  name: z.string(),
});

export type DirectusLanguage = z.infer<typeof DirectusLanguageSchema>;

export const DirectusVenueSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  name: z.string(),
  street: z.string(),
  number: z.string(),
  town: z.string(),
  country: z.string(),
  postal_code: z.string(),
  region: z.string(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
});

export type DirectusVenue = z.infer<typeof DirectusVenueSchema>;

export const DirectusGroupSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  url: z.string(),
  type: z.string().optional(),
  updated_at: z.string().nullable().optional(),
});

export type DirectusGroup = z.infer<typeof DirectusGroupSchema>;

export const DirectusErrorSchema = z.object({
  id: z.union([z.number(), z.string()]).optional(),
  url: z.string(),
  message: z.string(),
  datetime: z.string(),
});

export type DirectusError = z.infer<typeof DirectusErrorSchema>;

// ---- Nominatim schema ----

export const NominatimResponseSchema = z.object({
  display_name: z.string().optional(),
  address: z
    .object({
      road: z.string().optional(),
      house_number: z.string().optional(),
      city: z.string().optional(),
      town: z.string().optional(),
      village: z.string().optional(),
      county: z.string().optional(),
      state: z.string().optional(),
      country: z.string().optional(),
      country_code: z.string().optional(),
      postcode: z.string().optional(),
    })
    .optional(),
});

export type NominatimResponse = z.infer<typeof NominatimResponseSchema>;

// ---- Date/time utilities ----

export function toIsoOrNull(timestamp: number | null | undefined): string | null {
  // Treating 0 and negative values as null is intentional: Requirement 1.4 says
  // null/missing/invalid timestamps map to null. While 0 (Unix epoch) is technically
  // valid, Facebook never schedules events at 1970-01-01T00:00:00Z — a zero timestamp
  // is always invalid/unset data in practice. This is a documented practical decision.
  if (timestamp === null || timestamp === undefined || timestamp <= 0) return null;
  try {
    const d = new Date(timestamp * 1000);
    if (isNaN(d.getTime())) return null;
    return d.toISOString();
  } catch {
    return null;
  }
}

// ---- JSON parsing ----

export function parseJsonResponse(raw: string): unknown {
  // Find the first code fence block anywhere in the response (LLMs may return
  // explanatory text before the fence, or use leading whitespace/newlines).
  const fenceMatch = raw.match(/```(?:json)?\s*\n?([\s\S]*?)\n?\s*```/i);
  if (fenceMatch) {
    return JSON.parse(fenceMatch[1].trim());
  }
  return JSON.parse(raw.trim());
}
