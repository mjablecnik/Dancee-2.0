import {
  scrapeFbEvent,
  scrapeFbEventList,
  EventType,
} from "facebook-event-scraper";

/**
 * Scrape a single Facebook event by URL.
 * Wraps the facebook-event-scraper library for direct in-process usage.
 */
export async function scrapeFacebookEvent(eventUrl: string): Promise<unknown> {
  try {
    console.log(`Scraping event: ${eventUrl}`);
    const eventData = await scrapeFbEvent(eventUrl);
    console.log(`Successfully scraped event: ${eventUrl}`);
    return eventData;
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`Failed to scrape event ${eventUrl}:`, message);
    throw new Error(
      `Failed to scrape event [${eventUrl}]: ${message}`,
    );
  }
}

/**
 * Scrape a list of events from a Facebook page, group, or profile.
 * Wraps the facebook-event-scraper library for direct in-process usage.
 */
export async function scrapeFacebookEventList(
  pageUrl: string,
  eventType?: "upcoming" | "past",
): Promise<unknown[]> {
  try {
    console.log(`Scraping event list from: ${pageUrl} (type: ${eventType ?? "all"})`);

    let fbEventType: EventType | undefined;
    if (eventType === "upcoming") {
      fbEventType = EventType.Upcoming;
    } else if (eventType === "past") {
      fbEventType = EventType.Past;
    }

    const events = await scrapeFbEventList(pageUrl, fbEventType);
    console.log(`Successfully scraped ${events.length} events from: ${pageUrl}`);
    return events;
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`Failed to scrape event list from ${pageUrl}:`, message);
    throw new Error(
      `Failed to scrape event list [${pageUrl}]: ${message}`,
    );
  }
}
