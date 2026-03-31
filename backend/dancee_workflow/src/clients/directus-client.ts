import { config } from "../core/config";
import {
  DirectusEventSchema,
  DirectusVenueSchema,
  DirectusGroupSchema,
  DirectusErrorSchema,
  DirectusLanguageSchema,
  type DirectusEvent,
  type DirectusVenue,
  type DirectusGroup,
  type DirectusError,
  type DirectusLanguage,
} from "../core/schemas";
import { z } from "zod";

/**
 * Validates that a Directus API response contains the expected `data` envelope field
 * and returns its value. Throws a descriptive error if the shape is unexpected
 * (e.g. auth error, wrong endpoint, or API version mismatch) so that callers receive
 * a meaningful message instead of a confusing Zod parse failure downstream.
 */
function extractDirectusData(response: unknown, context: string): unknown {
  if (typeof response !== "object" || response === null || !("data" in response)) {
    throw new Error(
      `Unexpected Directus response shape in ${context}: ` +
      `expected object with 'data' field, got: ${JSON.stringify(response)?.slice(0, 100)}`,
    );
  }
  return (response as { data: unknown }).data;
}

function authHeaders(): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${config.directusAccessToken}`,
  };
}

async function directusGet(path: string): Promise<unknown> {
  const response = await fetch(`${config.directusBaseUrl}${path}`, {
    headers: authHeaders(),
    signal: AbortSignal.timeout(config.directusTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Directus GET ${path} error ${response.status}: ${text}`);
  }
  return response.json();
}

async function directusPost(path: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${config.directusBaseUrl}${path}`, {
    method: "POST",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(config.directusTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    const bodyPreview = JSON.stringify(body).slice(0, 200);
    throw new Error(`Directus POST ${path} error ${response.status}: ${text} (body: ${bodyPreview})`);
  }
  return response.json();
}

async function directusPatch(path: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${config.directusBaseUrl}${path}`, {
    method: "PATCH",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(config.directusTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    const bodyPreview = JSON.stringify(body).slice(0, 200);
    throw new Error(`Directus PATCH ${path} error ${response.status}: ${text} (body: ${bodyPreview})`);
  }
  return response.json();
}

// ---- Events ----

export async function createEvent(event: DirectusEvent): Promise<DirectusEvent> {
  const data = await directusPost("/items/events", event);
  return DirectusEventSchema.parse(extractDirectusData(data, "createEvent"));
}

export async function findEventByOriginalUrl(originalUrl: string): Promise<DirectusEvent | null> {
  const encoded = encodeURIComponent(originalUrl);
  const data = await directusGet(`/items/events?filter[original_url][_eq]=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findEventByOriginalUrl") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusEventSchema.parse(items[0]);
}

export async function getEventById(id: string | number): Promise<DirectusEvent | null> {
  try {
    const data = await directusGet(`/items/events/${id}?fields=*,translations.*`);
    return DirectusEventSchema.parse(extractDirectusData(data, "getEventById"));
  } catch {
    return null;
  }
}

export async function updateEvent(id: string | number, patch: Partial<DirectusEvent>): Promise<DirectusEvent> {
  const data = await directusPatch(`/items/events/${id}`, patch);
  return DirectusEventSchema.parse(extractDirectusData(data, "updateEvent"));
}

export async function deleteEventTranslations(eventId: string | number): Promise<void> {
  // Fetch existing translation IDs for this event
  const data = await directusGet(
    `/items/events_translations?filter[events_id][_eq]=${eventId}&fields=id`,
  );
  const items = extractDirectusData(data, "deleteEventTranslations") as { id: number }[];
  if (!items || items.length === 0) return;

  // Delete each translation
  for (const item of items) {
    await fetch(`${config.directusBaseUrl}/items/events_translations/${item.id}`, {
      method: "DELETE",
      headers: authHeaders(),
      signal: AbortSignal.timeout(config.directusTimeoutMs),
    });
  }
}

export async function listPublishedEvents(extraFilter?: Record<string, unknown>): Promise<DirectusEvent[]> {
  const publishedFilter = { status: { _eq: "published" } };
  const effectiveFilter = extraFilter
    ? { _and: [publishedFilter, extraFilter] }
    : publishedFilter;
  const encoded = encodeURIComponent(JSON.stringify(effectiveFilter));
  const data = await directusGet(`/items/events?filter=${encoded}&fields=*,translations.*,venue.*`);
  const items = extractDirectusData(data, "listPublishedEvents") as unknown[];
  return z.array(DirectusEventSchema).parse(items);
}

export async function listEvents(filter: Record<string, unknown>): Promise<DirectusEvent[]> {
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(`/items/events?filter=${encoded}`);
  const items = extractDirectusData(data, "listEvents") as unknown[];
  return z.array(DirectusEventSchema).parse(items);
}

// ---- Venues ----

export async function createVenue(venue: DirectusVenue): Promise<DirectusVenue> {
  const data = await directusPost("/items/venues", venue);
  return DirectusVenueSchema.parse(extractDirectusData(data, "createVenue"));
}

export async function findVenue(
  name: string,
  street: string,
  town: string,
): Promise<DirectusVenue | null> {
  const filter = {
    _and: [
      { name: { _eq: name } },
      { street: { _eq: street } },
      { town: { _eq: town } },
    ],
  };
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(`/items/venues?filter=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findVenue") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusVenueSchema.parse(items[0]);
}

export async function findVenueByCoordinates(
  latitude: number,
  longitude: number,
): Promise<DirectusVenue | null> {
  const filter = {
    _and: [{ latitude: { _eq: latitude } }, { longitude: { _eq: longitude } }],
  };
  const encoded = encodeURIComponent(JSON.stringify(filter));
  const data = await directusGet(`/items/venues?filter=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findVenueByCoordinates") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusVenueSchema.parse(items[0]);
}

// ---- Groups ----

/**
 * Creates a new group record in Directus.
 *
 * NOTE: Groups (Facebook page/group URLs used as event sources) are not created
 * programmatically by the workflow — they are added manually via the Directus
 * admin UI. This function exists for completeness and potential future use.
 * The batch processing service only reads and updates existing groups.
 */
export async function createGroup(group: DirectusGroup): Promise<DirectusGroup> {
  const data = await directusPost("/items/groups", group);
  return DirectusGroupSchema.parse(extractDirectusData(data, "createGroup"));
}

export async function getGroupsOrderedByUpdatedAt(): Promise<DirectusGroup[]> {
  const data = await directusGet("/items/groups?sort=updated_at");
  const items = extractDirectusData(data, "getGroupsOrderedByUpdatedAt") as unknown[];
  return z.array(DirectusGroupSchema).parse(items);
}

export async function updateGroupTimestamp(
  id: string | number,
  updatedAt: string,
): Promise<DirectusGroup> {
  const data = await directusPatch(`/items/groups/${id}`, { updated_at: updatedAt });
  return DirectusGroupSchema.parse(extractDirectusData(data, "updateGroupTimestamp"));
}

// ---- Errors ----

export async function createError(
  entry: Omit<DirectusError, "id" | "datetime"> & { datetime?: string },
): Promise<DirectusError> {
  const now = entry.datetime ?? new Date().toISOString();
  const existing = await findErrorByUrl(entry.url);
  if (existing) {
    // Update the existing row with the latest message and timestamp
    const data = await directusPatch(`/items/errors/${existing.id}`, {
      message: entry.message,
      datetime: now,
    });
    return DirectusErrorSchema.parse(extractDirectusData(data, "createError:update"));
  }
  const fullEntry = { ...entry, datetime: now };
  const data = await directusPost("/items/errors", fullEntry);
  return DirectusErrorSchema.parse(extractDirectusData(data, "createError"));
}

export async function findErrorByUrl(url: string): Promise<DirectusError | null> {
  const encoded = encodeURIComponent(url);
  const data = await directusGet(`/items/errors?filter[url][_eq]=${encoded}&limit=1`);
  const items = extractDirectusData(data, "findErrorByUrl") as unknown[];
  if (!items || items.length === 0) return null;
  return DirectusErrorSchema.parse(items[0]);
}

// ---- Languages ----

export async function getLanguages(): Promise<DirectusLanguage[]> {
  const data = await directusGet("/items/languages");
  const items = extractDirectusData(data, "getLanguages") as unknown[];
  return z.array(DirectusLanguageSchema).parse(items);
}

export async function createLanguage(
  code: string,
  name: string,
): Promise<DirectusLanguage> {
  const data = await directusPost("/items/languages", { code, name });
  return DirectusLanguageSchema.parse(extractDirectusData(data, "createLanguage"));
}
