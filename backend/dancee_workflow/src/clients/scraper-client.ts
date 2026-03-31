import { log } from "../core/logger";
import { TerminalError } from "@restatedev/restate-sdk";
import { ZodError } from "zod";
import { FacebookEventSchema, FacebookEventListItemSchema, type FacebookEvent, type FacebookEventListItem } from "../core/schemas";
import { scrapeFacebookEvent, scrapeFacebookEventList } from "../services/scraper";

/** Base URL for Facebook event pages. Used to construct canonical event URLs
 * when the scraper returns an event without a `url` field. */
export const FACEBOOK_EVENTS_BASE_URL = "https://www.facebook.com/events";

/** Builds a canonical Facebook event URL from an event ID. */
export function buildFacebookEventUrl(eventId: string): string {
  return `${FACEBOOK_EVENTS_BASE_URL}/${eventId}`;
}

// Error message patterns that indicate a permanent failure (no point retrying).
const PERMANENT_ERROR_PATTERNS = [
  "No event data found",
  "not a valid URL",
  "Cannot extract event ID",
  "not an event ID",
  "page not found",
  "content not available",
  "this content isn't available",
  "Cannot read properties of null",
  "Cannot read properties of undefined",
];

/**
 * Checks if a scraper error is permanent (should not be retried by Restate).
 * Permanent errors include: page not found, invalid URL, no event data,
 * and Zod validation failures (malformed response data won't fix on retry).
 * Transient errors (timeouts, network issues) should be retried.
 */
function isPermanentScraperError(err: unknown): boolean {
  if (err instanceof ZodError) return true;
  const message = err instanceof Error ? err.message : String(err);
  const lower = message.toLowerCase();
  return PERMANENT_ERROR_PATTERNS.some((p) => lower.includes(p.toLowerCase()));
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
  try {
    const parsed = new URL(eventIdOrUrl);
    const segments = parsed.pathname.split("/").filter(Boolean);

    const eventsIdx = segments.indexOf("events");
    if (eventsIdx !== -1 && eventsIdx + 1 < segments.length) {
      const candidate = segments[eventsIdx + 1];
      if (candidate && !candidate.includes(".") && !KNOWN_NON_ID_SEGMENTS.has(candidate)) {
        return candidate;
      }
    }

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
  const eventUrl = eventIdOrUrl.startsWith("http")
    ? eventIdOrUrl
    : buildFacebookEventUrl(eventIdOrUrl);
  try {
    const data = await scrapeFacebookEvent(eventUrl);
    return FacebookEventSchema.parse(data);
  } catch (err) {
    if (isPermanentScraperError(err)) {
      const message = err instanceof Error ? err.message : String(err);
      throw new TerminalError(`Failed to scrape/parse event [${eventUrl}]: ${message}`);
    }
    throw err;
  }
}

export async function scrapeEventList(
  pageUrl: string,
  eventType?: "upcoming" | "past",
): Promise<FacebookEventListItem[]> {
  let data: unknown[];
  try {
    data = await scrapeFacebookEventList(pageUrl, eventType);
  } catch (err) {
    if (isPermanentScraperError(err)) {
      const message = err instanceof Error ? err.message : String(err);
      throw new TerminalError(`Failed to scrape event list [${pageUrl}]: ${message}`);
    }
    throw err;
  }
  if (!Array.isArray(data)) {
    throw new TerminalError(`Scraper returned unexpected response for [${pageUrl}]: expected array`);
  }
  const events: FacebookEventListItem[] = [];
  for (const item of data) {
    const result = FacebookEventListItemSchema.safeParse(item);
    if (result.success) {
      events.push(result.data);
    } else {
      log({ level: "warn", message: "scrapeEventList: dropping malformed event item", item, error: result.error.message });
    }
  }
  return events;
}
