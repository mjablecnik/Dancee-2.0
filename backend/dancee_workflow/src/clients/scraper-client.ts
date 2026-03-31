import { config } from "../core/config";
import { log } from "../core/logger";
import { FacebookEventSchema, type FacebookEvent } from "../core/schemas";

/** Base URL for Facebook event pages. Used to construct canonical event URLs
 * when the scraper returns an event without a `url` field. */
export const FACEBOOK_EVENTS_BASE_URL = "https://www.facebook.com/events";

/** Builds a canonical Facebook event URL from an event ID. */
export function buildFacebookEventUrl(eventId: string): string {
  return `${FACEBOOK_EVENTS_BASE_URL}/${eventId}`;
}

async function fetchJson(url: string): Promise<unknown> {
  const response = await fetch(url, {
    signal: AbortSignal.timeout(config.scraperTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Scraper API error ${response.status}: ${text}`);
  }
  return response.json();
}

// Known Facebook (and generic) URL path segments that are route names, not event IDs.
// A URL whose last segment is one of these is missing the actual event ID.
const KNOWN_NON_ID_SEGMENTS = new Set([
  "events",
  "pages",
  "groups",
  "profile",
  "home",
  "watch",
  "marketplace",
]);

export function extractEventId(eventIdOrUrl: string): string {
  // If a full URL is provided (e.g. https://www.facebook.com/events/123456),
  // extract the event ID from the path segments after /events/.
  // For URLs like /events/123/456/ the first numeric segment (123) is the
  // parent event ID; the second is a sibling instance (event_time_id).
  try {
    const parsed = new URL(eventIdOrUrl);
    const segments = parsed.pathname.split("/").filter(Boolean);

    // Find the "events" segment and take the first ID after it
    const eventsIdx = segments.indexOf("events");
    if (eventsIdx !== -1 && eventsIdx + 1 < segments.length) {
      const candidate = segments[eventsIdx + 1];
      if (candidate && !candidate.includes(".") && !KNOWN_NON_ID_SEGMENTS.has(candidate)) {
        return candidate;
      }
    }

    // Fallback: take the last segment
    const last = segments[segments.length - 1];
    if (!last || last.includes(".")) {
      throw new Error(
        `Cannot extract event ID from URL "${eventIdOrUrl}": ` +
          "the URL does not contain a valid event ID path segment.",
      );
    }
    if (KNOWN_NON_ID_SEGMENTS.has(last)) {
      throw new Error(
        `Cannot extract event ID from URL "${eventIdOrUrl}": ` +
          `"${last}" is a route component, not an event ID.`,
      );
    }
    return last;
  } catch (err) {
    if (err instanceof TypeError) {
      // Not a valid URL — treat the input as a bare event ID
    } else {
      throw err;
    }
  }
  if (!eventIdOrUrl) {
    throw new Error("Event ID must be a non-empty string.");
  }
  return eventIdOrUrl;
}

export async function scrapeEvent(eventIdOrUrl: string): Promise<FacebookEvent> {
  // Pass the full URL or ID to the scraper — the scraper service handles both.
  // We encode the entire value as a path segment.
  const url = `${config.scraperBaseUrl}/api/scraper/event/${encodeURIComponent(eventIdOrUrl)}`;
  const data = await fetchJson(url);
  return FacebookEventSchema.parse(data);
}

export async function scrapeEventList(
  pageId: string,
  eventType?: "upcoming" | "past",
): Promise<FacebookEvent[]> {
  const params = new URLSearchParams({ pageId });
  if (eventType !== undefined) {
    params.set("eventType", eventType);
  }
  const url = `${config.scraperBaseUrl}/api/scraper/events?${params.toString()}`;
  const data = await fetchJson(url);
  if (!Array.isArray(data)) {
    throw new Error("Scraper API returned unexpected response: expected array");
  }
  const events: FacebookEvent[] = [];
  for (const item of data) {
    const result = FacebookEventSchema.safeParse(item);
    if (result.success) {
      events.push(result.data);
    } else {
      log({ level: "warn", message: "scrapeEventList: dropping malformed event item", item, error: result.error.message });
    }
  }
  return events;
}
