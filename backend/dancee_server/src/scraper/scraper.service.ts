import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { 
  scrapeFbEvent, 
  scrapeFbEventFromFbid, 
  scrapeFbEventList, 
  EventType 
} from 'facebook-event-scraper';

@Injectable()
export class ScraperService {
  private readonly logger = new Logger(ScraperService.name);

  /**
   * Scrape a single Facebook event by ID or URL
   * @param eventId - Facebook event ID or URL
   * @returns Scraped event data
   */
  async scrapeEvent(eventId: string): Promise<any> {
    try {
      this.logger.log(`Scraping event: ${eventId}`);
      
      let eventData;
      
      // Check if it's a URL or just an ID
      if (eventId.includes('facebook.com') || eventId.includes('fb.com')) {
        // It's a URL
        eventData = await scrapeFbEvent(eventId);
      } else {
        // It's just an ID
        eventData = await scrapeFbEventFromFbid(eventId);
      }
      
      this.logger.log(`Successfully scraped event: ${eventId}`);
      return eventData;
    } catch (error) {
      this.logger.error(`Failed to scrape event ${eventId}:`, error.message);
      throw new BadRequestException(
        `Failed to scrape event: ${error.message}. Make sure the event is public and the ID/URL is correct.`,
      );
    }
  }

  /**
   * Scrape a list of events from a Facebook page, group, or profile
   * @param pageId - Facebook page/group/profile ID or URL
   * @param eventType - Filter by 'upcoming' or 'past' events (optional)
   * @returns List of scraped events
   */
  async scrapeEventList(
    pageId: string,
    eventType?: 'upcoming' | 'past',
  ): Promise<any[]> {
    try {
      this.logger.log(
        `Scraping event list from: ${pageId} (type: ${eventType || 'all'})`,
      );
      
      // Convert string to EventType enum
      let fbEventType: EventType | undefined;
      if (eventType === 'upcoming') {
        fbEventType = EventType.Upcoming;
      } else if (eventType === 'past') {
        fbEventType = EventType.Past;
      }
      
      const events = await scrapeFbEventList(pageId, fbEventType);
      this.logger.log(
        `Successfully scraped ${events.length} events from: ${pageId}`,
      );
      return events;
    } catch (error) {
      this.logger.error(
        `Failed to scrape event list from ${pageId}:`,
        error.message,
      );
      throw new BadRequestException(
        `Failed to scrape event list: ${error.message}. Make sure the page/group/profile is public and the ID/URL is correct.`,
      );
    }
  }
}
