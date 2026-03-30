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

function authHeaders(): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${config.directusAccessToken}`,
  };
}

async function directusGet(path: string): Promise<unknown> {
  const response = await fetch(`${config.directusBaseUrl}${path}`, {
    headers: authHeaders(),
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
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Directus POST ${path} error ${response.status}: ${text}`);
  }
  return response.json();
}

async function directusPatch(path: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${config.directusBaseUrl}${path}`, {
    method: "PATCH",
    headers: authHeaders(),
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Directus PATCH ${path} error ${response.status}: ${text}`);
  }
  return response.json();
}

// ---- Events ----

export async function createEvent(event: DirectusEvent): Promise<DirectusEvent> {
  const data = await directusPost("/items/events", event);
  return DirectusEventSchema.parse((data as { data: unknown }).data);
}

export async function findEventByOriginalUrl(originalUrl: string): Promise<DirectusEvent | null> {
  const encoded = encodeURIComponent(originalUrl);
  const data = await directusGet(`/items/events?filter[original_url][_eq]=${encoded}&limit=1`);
  const items = (data as { data: unknown[] }).data;
  if (!items || items.length === 0) return null;
  return DirectusEventSchema.parse(items[0]);
}

export async function listEvents(filter?: Record<string, unknown>): Promise<DirectusEvent[]> {
  const defaultFilter = { status: { _eq: "published" } };
  const appliedFilter = filter ?? defaultFilter;
  const encoded = encodeURIComponent(JSON.stringify(appliedFilter));
  const data = await directusGet(`/items/events?filter=${encoded}`);
  const items = (data as { data: unknown[] }).data;
  return z.array(DirectusEventSchema).parse(items);
}

// ---- Venues ----

export async function createVenue(venue: DirectusVenue): Promise<DirectusVenue> {
  const data = await directusPost("/items/venues", venue);
  return DirectusVenueSchema.parse((data as { data: unknown }).data);
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
  const items = (data as { data: unknown[] }).data;
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
  const items = (data as { data: unknown[] }).data;
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
  return DirectusGroupSchema.parse((data as { data: unknown }).data);
}

export async function getGroupsOrderedByUpdatedAt(): Promise<DirectusGroup[]> {
  const data = await directusGet("/items/groups?sort=updated_at");
  const items = (data as { data: unknown[] }).data;
  return z.array(DirectusGroupSchema).parse(items);
}

export async function updateGroupTimestamp(
  id: string | number,
  updatedAt: string,
): Promise<DirectusGroup> {
  const data = await directusPatch(`/items/groups/${id}`, { updated_at: updatedAt });
  return DirectusGroupSchema.parse((data as { data: unknown }).data);
}

// ---- Errors ----

export async function createError(entry: Omit<DirectusError, "id">): Promise<DirectusError> {
  const existing = await findErrorByUrl(entry.url);
  if (existing) {
    return existing;
  }
  const data = await directusPost("/items/errors", entry);
  return DirectusErrorSchema.parse((data as { data: unknown }).data);
}

export async function findErrorByUrl(url: string): Promise<DirectusError | null> {
  const encoded = encodeURIComponent(url);
  const data = await directusGet(`/items/errors?filter[url][_eq]=${encoded}&limit=1`);
  const items = (data as { data: unknown[] }).data;
  if (!items || items.length === 0) return null;
  return DirectusErrorSchema.parse(items[0]);
}

// ---- Languages ----

export async function getLanguages(): Promise<DirectusLanguage[]> {
  const data = await directusGet("/items/languages");
  const items = (data as { data: unknown[] }).data;
  return z.array(DirectusLanguageSchema).parse(items);
}

export async function createLanguage(
  code: string,
  name: string,
): Promise<DirectusLanguage> {
  const data = await directusPost("/items/languages", { code, name });
  return DirectusLanguageSchema.parse((data as { data: unknown }).data);
}
