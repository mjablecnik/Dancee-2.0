# Dancee Server Setup Complete ✅

## What Was Created

A NestJS REST API server with Facebook event scraping capabilities.

## Project Structure

```
backend/dancee_server/
├── src/
│   ├── app.controller.ts          # Main controller (Hello World)
│   ├── app.module.ts              # Root module
│   ├── app.service.ts             # Main service
│   ├── main.ts                    # Application entry point
│   └── scraper/                   # Facebook scraper module
│       ├── dto/
│       │   └── scrape-event.dto.ts    # Data transfer objects
│       ├── scraper.controller.ts      # Scraper endpoints
│       ├── scraper.service.ts         # Scraper business logic
│       └── scraper.module.ts          # Scraper module definition
├── test/                          # E2E tests
├── taskfile.yaml                  # Task automation
├── package.json                   # Dependencies
├── README.md                      # English documentation
├── QUICK_START.md                 # Czech quick start guide
├── EXAMPLES.md                    # API usage examples
├── test-endpoints.http            # HTTP test file
└── .env.example                   # Environment variables template

```

## Installed Packages

- `@nestjs/common`, `@nestjs/core`, `@nestjs/platform-express` - NestJS framework
- `facebook-event-scraper` - Facebook event scraping library
- `class-validator`, `class-transformer` - Input validation
- `typescript`, `ts-node` - TypeScript support
- `jest`, `supertest` - Testing framework
- `eslint`, `prettier` - Code quality tools

## API Endpoints

### 1. GET /
Simple health check endpoint returning "Hello World!"

### 2. GET /scraper/event/:eventId
Scrape detailed information from a single Facebook event.

**Parameters:**
- `eventId` - Facebook event ID or URL

**Returns:** Full event object with location, photos, hosts, timestamps, etc.

### 3. GET /scraper/events?pageId=xxx&eventType=upcoming
Scrape a list of events from a Facebook page/group/profile.

**Query Parameters:**
- `pageId` (required) - Facebook page/group/profile ID or URL
- `eventType` (optional) - Filter by `upcoming` or `past`

**Returns:** Array of event summaries

## How to Start

### Development Mode
```bash
cd backend/dancee_server
task dev
```

Server will run on `http://localhost:3001`

### Test the Endpoints

**Using curl:**
```bash
# Test hello world
curl http://localhost:3001/

# Test event scraping (replace with real event ID)
curl http://localhost:3001/scraper/event/YOUR_EVENT_ID

# Test event list scraping (replace with real page ID)
curl "http://localhost:3001/scraper/events?pageId=YOUR_PAGE_ID&eventType=upcoming"
```

**Using browser:**
- Open `http://localhost:3001/` for hello world
- Open `http://localhost:3001/scraper/event/YOUR_EVENT_ID` for event details
- Open `http://localhost:3001/scraper/events?pageId=YOUR_PAGE_ID&eventType=upcoming` for event list

**Using VS Code REST Client:**
- Open `test-endpoints.http` file
- Click "Send Request" above each endpoint

## Features

✅ CORS enabled for frontend communication
✅ Hot reload in development mode
✅ TypeScript with strict type checking
✅ Input validation with class-validator
✅ Structured logging
✅ Error handling
✅ Task automation with Taskfile
✅ Facebook event scraping
✅ Comprehensive documentation

## Important Notes

### Facebook Scraper Limitations
- Only works with **public** Facebook events (no authentication required)
- Facebook's terms of service prohibit automated scraping - use at your own risk
- Rate limiting may apply if too many requests are made

### Multi-date Events
Events with multiple dates will have `parentEvent` and `siblingEvents` fields populated.

### Finding IDs
- **Event ID**: Found in Facebook event URL: `https://www.facebook.com/events/115982989234742/` → ID is `115982989234742`
- **Page ID**: Found in Facebook page URL or via Facebook's Graph API

## Next Steps

1. **Test with real Facebook events**: Replace placeholder IDs in examples with real event/page IDs
2. **Integrate with frontend**: Use the API endpoints in your Flutter app
3. **Add caching**: Consider adding Redis or in-memory caching for frequently accessed events
4. **Add database**: Store scraped events in a database for offline access
5. **Add authentication**: Protect endpoints if needed
6. **Deploy**: Deploy to production (Fly.io, Heroku, AWS, etc.)

## Documentation Files

- `README.md` - Complete English documentation
- `QUICK_START.md` - Czech quick start guide
- `EXAMPLES.md` - Detailed API usage examples with code samples
- `test-endpoints.http` - HTTP test file for VS Code REST Client

## Support

For issues or questions:
1. Check the documentation files
2. Review the examples in `EXAMPLES.md`
3. Test endpoints using `test-endpoints.http`
4. Check NestJS documentation: https://docs.nestjs.com
5. Check facebook-event-scraper: https://github.com/francescov1/facebook-event-scraper

---

**Server is ready to use! 🚀**

Start with: `task dev`
