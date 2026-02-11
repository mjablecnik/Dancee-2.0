import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import scraperRoutes from './scraper.routes';
import { errorHandler } from './error.middleware';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/scraper', scraperRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Facebook Event Scraper API',
    version: '1.0.0',
    endpoints: {
      'GET /api/scraper': 'API information',
      'GET /api/scraper/event/:eventId': 'Scrape single event',
      'GET /api/scraper/events': 'Scrape event list from page/group'
    }
  });
});

// Error handling
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`🚀 Scraper API running on http://localhost:${PORT}`);
});
