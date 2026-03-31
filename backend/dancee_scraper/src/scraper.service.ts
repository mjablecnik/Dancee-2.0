import {
  scrapeFbEvent,
  scrapeFbEventList,
  EventType
} from 'facebook-event-scraper';

export class ScraperService {
  /**
   * Scrape a single Facebook event by URL
   * @param eventUrl - Full Facebook event URL
   * @returns Scraped event data
   */
  async scrapeEvent(eventUrl: string): Promise<any> {
    try {
      console.log(`Scraping event: ${eventUrl}`);
      const eventData = await scrapeFbEvent(eventUrl);
      console.log(`Successfully scraped event: ${eventUrl}`);
      return eventData;
    } catch (error: any) {
      console.error(`Failed to scrape event ${eventUrl}:`, error.message);
      throw new Error(
        `Failed to scrape event: ${error.message}. Make sure the event is public and the URL is correct.`
      );
    }
  }

  /**
   * Scrape a list of events from a Facebook page, group, or profile
   * @param pageUrl - Full Facebook page/group/profile URL
   * @param eventType - Filter by 'upcoming' or 'past' events (optional)
   * @returns List of scraped events
   */
  async scrapeEventList(
    pageUrl: string,
    eventType?: 'upcoming' | 'past'
  ): Promise<any[]> {
    try {
      console.log(`Scraping event list from: ${pageUrl} (type: ${eventType || 'all'})`);

      // Convert string to EventType enum
      let fbEventType: EventType | undefined;
      if (eventType === 'upcoming') {
        fbEventType = EventType.Upcoming;
      } else if (eventType === 'past') {
        fbEventType = EventType.Past;
      }

      const events = await scrapeFbEventList(pageUrl, fbEventType);
      console.log(`Successfully scraped ${events.length} events from: ${pageUrl}`);
      return events;
    } catch (error: any) {
      console.error(`Failed to scrape event list from ${pageUrl}:`, error.message);
      throw new Error(
        `Failed to scrape event list: ${error.message}. Make sure the page/group/profile is public and the URL is correct.`
      );
    }
  }
}
