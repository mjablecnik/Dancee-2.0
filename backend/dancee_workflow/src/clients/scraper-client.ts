import { config } from "../core/config";
import { FacebookEventSchema, type FacebookEvent } from "../core/schemas";

async function fetchJson(url: string): Promise<unknown> {
  const response = await fetch(url);
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Scraper API error ${response.status}: ${text}`);
  }
  return response.json();
}

export async function scrapeEvent(eventIdOrUrl: string): Promise<FacebookEvent> {
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
  return data.map((item) => FacebookEventSchema.parse(item));
}
