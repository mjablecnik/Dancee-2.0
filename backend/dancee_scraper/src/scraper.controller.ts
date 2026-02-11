import { Request, Response, NextFunction } from 'express';
import { ScraperService } from './scraper.service';

export class ScraperController {
  private scraperService: ScraperService;

  constructor() {
    this.scraperService = new ScraperService();
  }

  /**
   * GET /api/scraper
   * Get API usage information
   */
  getInfo = (req: Request, res: Response) => {
    res.json({
      message: 'Facebook Event Scraper API',
      version: '1.0.0',
      endpoints: {
        'GET /api/scraper/event/:eventId': {
          description: 'Scrape a single Facebook event',
          parameters: {
            eventId: 'Facebook event ID or full URL (must be public)'
          },
          examples: [
            'GET /api/scraper/event/1987385505448084',
            'GET /api/scraper/event/https://www.facebook.com/events/1987385505448084'
          ]
        },
        'GET /api/scraper/events': {
          description: 'Scrape a list of events from a page/group/profile',
          parameters: {
            pageId: 'Facebook page/group/profile ID or URL (required)',
            eventType: 'Filter by "upcoming" or "past" (optional)'
          },
          examples: [
            'GET /api/scraper/events?pageId=123456789&eventType=upcoming',
            'GET /api/scraper/events?pageId=https://www.facebook.com/yourpage'
          ]
        }
      },
      notes: [
        'Only PUBLIC Facebook events can be scraped',
        'Events must be active and accessible',
        'Rate limiting may apply',
        'Use at your own risk - Facebook ToS prohibit automated scraping'
      ]
    });
  };

  /**
   * GET /api/scraper/event/:eventId
   * Scrape a single Facebook event by ID or URL
   */
  scrapeEvent = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { eventId } = req.params;
      const eventData = await this.scraperService.scrapeEvent(eventId);
      res.json(eventData);
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /api/scraper/events?pageId=xxx&eventType=upcoming
   * Scrape a list of events from a Facebook page, group, or profile
   */
  scrapeEventList = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { pageId, eventType } = req.query;

      if (!pageId || typeof pageId !== 'string') {
        return res.status(400).json({
          error: 'Bad Request',
          message: 'pageId query parameter is required'
        });
      }

      const validEventType = eventType === 'upcoming' || eventType === 'past' 
        ? eventType 
        : undefined;

      const events = await this.scraperService.scrapeEventList(pageId, validEventType);
      res.json(events);
    } catch (error) {
      next(error);
    }
  };
}
