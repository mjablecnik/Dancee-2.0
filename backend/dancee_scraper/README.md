# Dancee Scraper

Simple Express REST API for Facebook event scraping.

## Quick Start

```bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Run in development mode
npm run dev

# Build for production
npm run build

# Run production server
npm start
```

## API Endpoints

### GET /api/scraper
Get API information and usage examples.

### GET /api/scraper/event
Scrape a single Facebook event.

**Query Parameters:**
- `url` (required) - Full Facebook event URL

**Example:**
```bash
curl "http://localhost:3002/api/scraper/event?url=https://www.facebook.com/events/1987385505448084"
```

### GET /api/scraper/events
Scrape a list of events from a Facebook page/group/profile.

**Query Parameters:**
- `url` (required) - Full Facebook page/group/profile URL
- `eventType` (optional) - Filter by "upcoming" or "past"

**Example:**
```bash
curl "http://localhost:3002/api/scraper/events?url=https://www.facebook.com/yourpage&eventType=upcoming"
```

## Environment Variables

- `PORT` - Server port (default: 3002)
- `NODE_ENV` - Environment (development/production)

## Notes

- Only PUBLIC Facebook events can be scraped
- Events must be active and accessible
- Use at your own risk - Facebook ToS prohibit automated scraping
