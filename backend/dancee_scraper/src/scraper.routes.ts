import { Router } from 'express';
import { ScraperController } from './scraper.controller';

const router = Router();
const scraperController = new ScraperController();

// GET /api/scraper - API info
router.get('/', scraperController.getInfo);

// GET /api/scraper/event/:eventId - Scrape single event
router.get('/event/:eventId', scraperController.scrapeEvent);

// GET /api/scraper/events?pageId=xxx&eventType=upcoming - Scrape event list
router.get('/events', scraperController.scrapeEventList);

export default router;
