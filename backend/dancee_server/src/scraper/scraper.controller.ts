import { Controller, Get, Query, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { ScraperService } from './scraper.service';

@Controller('scraper')
export class ScraperController {
  constructor(private readonly scraperService: ScraperService) {}

  /**
   * GET /scraper
   * Get API usage information
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  getInfo() {
    return {
      message: 'Facebook Event Scraper API',
      version: '1.0.0',
      endpoints: {
        'GET /scraper/event/:eventId': {
          description: 'Scrape a single Facebook event',
          parameters: {
            eventId: 'Facebook event ID or full URL (must be public)',
          },
          examples: [
            'GET /scraper/event/1987385505448084',
            'GET /scraper/event/https://www.facebook.com/events/1987385505448084',
          ],
        },
        'GET /scraper/events': {
          description: 'Scrape a list of events from a page/group/profile',
          parameters: {
            pageId: 'Facebook page/group/profile ID or URL (required)',
            eventType: 'Filter by "upcoming" or "past" (optional)',
          },
          examples: [
            'GET /scraper/events?pageId=123456789&eventType=upcoming',
            'GET /scraper/events?pageId=https://www.facebook.com/yourpage',
          ],
        },
      },
      notes: [
        'Only PUBLIC Facebook events can be scraped',
        'Events must be active and accessible',
        'Rate limiting may apply',
        'Use at your own risk - Facebook ToS prohibit automated scraping',
      ],
    };
  }

  /**
   * GET /scraper/event/:eventId
   * Scrape a single Facebook event by ID or URL
   * 
   * @param eventId - Facebook event ID (e.g., "115982989234742") or full URL
   * @returns Full event data including location, photos, hosts, etc.
   * 
   * Example: GET /scraper/event/115982989234742
   */
  @Get('event/:eventId')
  @HttpCode(HttpStatus.OK)
  async scrapeEvent(@Param('eventId') eventId: string) {
    return this.scraperService.scrapeEvent(eventId);
  }

  /**
   * GET /scraper/events?pageId=xxx&eventType=upcoming
   * Scrape a list of events from a Facebook page, group, or profile
   * 
   * @param pageId - Facebook page/group/profile ID or URL (required)
   * @param eventType - Filter by 'upcoming' or 'past' events (optional)
   * @returns Array of event summaries
   * 
   * Example: GET /scraper/events?pageId=123456789&eventType=upcoming
   */
  @Get('events')
  @HttpCode(HttpStatus.OK)
  async scrapeEventList(
    @Query('pageId') pageId: string,
    @Query('eventType') eventType?: 'upcoming' | 'past',
  ) {
    if (!pageId) {
      throw new Error('pageId query parameter is required');
    }
    return this.scraperService.scrapeEventList(pageId, eventType);
  }
}
