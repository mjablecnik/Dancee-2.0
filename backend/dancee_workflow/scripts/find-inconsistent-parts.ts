/**
 * Finds future events that have parts with past datetimes.
 *
 * This detects inconsistencies where start_time is in the future
 * but some part date_time_range values are in the past (likely
 * because parts are still in UTC while start_time was converted to local).
 *
 * Usage: bun run scripts/find-inconsistent-parts.ts
 */
import * as dotenv from "dotenv";
dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";

if (!DIRECTUS_BASE_URL || !DIRECTUS_ACCESS_TOKEN) {
  console.error("Missing DIRECTUS_BASE_URL or DIRECTUS_ACCESS_TOKEN in .env");
  process.exit(1);
}

function authHeaders(): Record<string, string> {
  return {
    Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
    "Content-Type": "application/json",
  };
}

interface EventPart {
  name: string;
  date_time_range: { start: string | null; end: string | null };
}

interface DirectusEvent {
  id: number | string;
  title: string;
  start_time: string;
  timezone: string;
  parts: EventPart[];
}

async function fetchAllEvents(): Promise<DirectusEvent[]> {
  const allEvents: DirectusEvent[] = [];
  let page = 1;
  const limit = 100;

  while (true) {
    const url = `${DIRECTUS_BASE_URL}/items/events?fields=id,title,start_time,timezone,parts&limit=${limit}&page=${page}`;
    const res = await fetch(url, { headers: authHeaders() });
    if (!res.ok) {
      throw new Error(`Failed to fetch page ${page}: ${res.status} ${await res.text()}`);
    }
    const json = (await res.json()) as { data: DirectusEvent[] };
    if (json.data.length === 0) break;
    allEvents.push(...json.data);
    if (json.data.length < limit) break;
    page++;
  }

  return allEvents;
}

async function main(): Promise<void> {
  const now = new Date();
  console.log(`Current time: ${now.toISOString()}\n`);

  const events = await fetchAllEvents();
  console.log(`Total events: ${events.length}\n`);

  let found = 0;

  for (const event of events) {
    const startTime = new Date(event.start_time);

    // Only future events
    if (startTime <= now) continue;

    // Check parts for past datetimes
    if (!event.parts || event.parts.length === 0) continue;

    const pastParts = event.parts.filter((p) => {
      const partStart = p.date_time_range.start ? new Date(p.date_time_range.start) : null;
      const partEnd = p.date_time_range.end ? new Date(p.date_time_range.end) : null;
      return (partStart && partStart < now) || (partEnd && partEnd < now);
    });

    if (pastParts.length === 0) continue;

    found++;
    console.log(`[${event.id}] "${event.title}" (tz: ${event.timezone})`);
    console.log(`  start_time: ${event.start_time} (future)`);
    for (const p of pastParts) {
      console.log(`  part "${p.name}": start=${p.date_time_range.start}, end=${p.date_time_range.end} (PAST)`);
    }
    console.log();
  }

  console.log(`Found ${found} future events with past part datetimes.`);
}

main().catch((err) => {
  console.error("Failed:", err);
  process.exit(1);
});
