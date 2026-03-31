/**
 * Fix script: Nullify part datetimes that are inconsistent with the event's start_time.
 *
 * For future events where parts have past datetimes (hallucinated by LLM),
 * this script sets those part date_time_range values to null.
 *
 * Usage: bun run scripts/fix-inconsistent-parts.ts [--dry-run]
 */
import * as dotenv from "dotenv";
dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";
const DRY_RUN = process.argv.includes("--dry-run");

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
  description: string;
  type: string;
  dances: string[];
  date_time_range: { start: string | null; end: string | null };
  lectors: string[];
  djs: string[];
}

interface DirectusEvent {
  id: number | string;
  title: string;
  start_time: string;
  end_time: string | null;
  timezone: string;
  parts: EventPart[];
}

async function fetchAllEvents(): Promise<DirectusEvent[]> {
  const allEvents: DirectusEvent[] = [];
  let page = 1;
  const limit = 100;

  while (true) {
    const url = `${DIRECTUS_BASE_URL}/items/events?fields=id,title,start_time,end_time,timezone,parts&limit=${limit}&page=${page}`;
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

async function updateEvent(id: number | string, patch: Record<string, unknown>): Promise<void> {
  const url = `${DIRECTUS_BASE_URL}/items/events/${id}`;
  const res = await fetch(url, {
    method: "PATCH",
    headers: authHeaders(),
    body: JSON.stringify(patch),
  });
  if (!res.ok) {
    throw new Error(`Failed to update event ${id}: ${res.status} ${await res.text()}`);
  }
}

function isPartTimeInconsistent(
  part: EventPart,
  eventStart: Date,
  eventEnd: Date | null,
): boolean {
  // Allow parts up to 7 days after event start (festivals)
  const maxEnd = eventEnd
    ? new Date(eventEnd.getTime() + 24 * 60 * 60 * 1000)
    : new Date(eventStart.getTime() + 7 * 24 * 60 * 60 * 1000);
  // Allow parts to start up to 1 day before event start
  const minStart = new Date(eventStart.getTime() - 24 * 60 * 60 * 1000);

  const partStart = part.date_time_range.start ? new Date(part.date_time_range.start) : null;
  const partEnd = part.date_time_range.end ? new Date(part.date_time_range.end) : null;

  if (partStart && (isNaN(partStart.getTime()) || partStart < minStart || partStart > maxEnd)) {
    return true;
  }
  if (partEnd && (isNaN(partEnd.getTime()) || partEnd < minStart || partEnd > maxEnd)) {
    return true;
  }
  return false;
}

async function migrate(): Promise<void> {
  console.log(`Mode: ${DRY_RUN ? "DRY RUN" : "LIVE"}`);
  console.log("Fetching all events from Directus...");

  const events = await fetchAllEvents();
  console.log(`Found ${events.length} events\n`);

  let fixed = 0;
  let skipped = 0;
  let errors = 0;

  for (const event of events) {
    if (!event.parts || event.parts.length === 0) {
      skipped++;
      continue;
    }

    const eventStart = new Date(event.start_time);
    const eventEnd = event.end_time ? new Date(event.end_time) : null;

    const hasInconsistent = event.parts.some((p) =>
      isPartTimeInconsistent(p, eventStart, eventEnd)
      || !p.date_time_range.start
      || !p.date_time_range.end
    );

    if (!hasInconsistent) {
      skipped++;
      continue;
    }

    // Fill inconsistent part times with event's own times
    const fixedParts = event.parts.map((p) => {
      if (isPartTimeInconsistent(p, eventStart, eventEnd)) {
        return {
          ...p,
          date_time_range: {
            start: event.start_time,
            end: event.end_time ?? event.start_time,
          },
        };
      }
      // Also fill nulls with event times
      return {
        ...p,
        date_time_range: {
          start: p.date_time_range.start ?? event.start_time,
          end: p.date_time_range.end ?? (event.end_time ?? event.start_time),
        },
      };
    });

    const badCount = event.parts.filter((p) =>
      isPartTimeInconsistent(p, eventStart, eventEnd)
    ).length;

    console.log(`[${event.id}] "${event.title}" — nullified ${badCount}/${event.parts.length} part times`);

    if (!DRY_RUN) {
      try {
        await updateEvent(event.id, { parts: fixedParts });
      } catch (err) {
        console.error(`  Error: ${err}`);
        errors++;
        continue;
      }
    }

    fixed++;
  }

  console.log(`\nDone. Fixed: ${fixed}, Skipped: ${skipped}, Errors: ${errors}`);
}

migrate().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
