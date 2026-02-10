# Dancee Server

A simple NestJS REST API server for the Dancee application.

## Prerequisites

- Node.js (v18 or higher)
- npm

## Installation

```bash
task install
# or
npm install
```

## Running the Application

### Development Mode (with hot reload)
```bash
task dev
# or
npm run start:dev
```

The server will start on `http://localhost:3001`

### Production Mode
```bash
task build
task start
# or
npm run build
npm run start:prod
```

## Available Tasks

- `task install` - Install dependencies
- `task dev` - Start development server with hot reload
- `task start` - Start production server
- `task build` - Build the application
- `task lint` - Run linter
- `task format` - Format code with prettier
- `task test` - Run tests
- `task test-watch` - Run tests in watch mode
- `task test-e2e` - Run end-to-end tests
- `task clean` - Clean build artifacts

## API Endpoints

### GET /
Returns a simple "Hello World!" message.

**Response:**
```
Hello World!
```

### GET /scraper/event/:eventId
Scrape a single Facebook event by ID or URL.

**Parameters:**
- `eventId` (path parameter) - Facebook event ID or URL

**Example:**
```bash
GET http://localhost:3001/scraper/event/115982989234742
```

**Response:**
```json
{
  "id": "115982989234742",
  "name": "Example Event",
  "description": "This is an example event description.",
  "location": {
    "id": "118309434891614",
    "name": "Example Location Label",
    "address": "123 Example St",
    "city": { "name": "Los Angeles", "id": "111983945494775" },
    "coordinates": {
      "latitude": 37.1234,
      "longitude": -122.1234
    }
  },
  "photo": {
    "url": "https://www.facebook.com/photo/?fbid=595982989234742",
    "imageUri": "https://scontent.fyyc3-1.fna.fbcdn.net/v/..."
  },
  "startTimestamp": 1681000200,
  "endTimestamp": 1681004700,
  "formattedDate": "Saturday, April 8, 2023 at 6:30 PM – 7:45 PM UTC-06",
  "hosts": [...],
  "usersResponded": 10
}
```

### GET /scraper/events?pageId=xxx&eventType=upcoming
Scrape a list of events from a Facebook page, group, or profile.

**Query Parameters:**
- `pageId` (required) - Facebook page/group/profile ID or URL
- `eventType` (optional) - Filter by `upcoming` or `past` events

**Example:**
```bash
GET http://localhost:3001/scraper/events?pageId=123456789&eventType=upcoming
```

**Response:**
```json
[
  {
    "id": "916236709985575",
    "name": "NEW YEAR EVE 2025",
    "url": "https://www.facebook.com/events/916236709985575/",
    "date": "Tue, Dec 31, 2024",
    "isCanceled": false,
    "isPast": false
  },
  {
    "id": "591932410074832",
    "name": "REGGAETON NIGHT",
    "url": "https://www.facebook.com/events/591932410074832/",
    "date": "Fri, Nov 22, 2024",
    "isCanceled": false,
    "isPast": false
  }
]
```

## Project Structure

```
src/
├── app.controller.ts    # Main controller with routes
├── app.module.ts        # Root module
├── app.service.ts       # Business logic
└── main.ts             # Application entry point
```

## Features

- ✅ CORS enabled for frontend communication
- ✅ Hot reload in development mode
- ✅ TypeScript support
- ✅ ESLint and Prettier configured
- ✅ Jest testing setup
- ✅ Task automation with Taskfile
- ✅ Facebook event scraping with `facebook-event-scraper`
- ✅ Input validation with class-validator
- ✅ Structured logging

## Facebook Event Scraper

This server includes endpoints for scraping Facebook event data using the `facebook-event-scraper` package.

**Capabilities:**
- Scrape detailed information from individual Facebook events
- Scrape lists of events from Facebook pages, groups, or profiles
- Filter events by upcoming or past
- Extract event details including location, photos, hosts, timestamps, and more

**Limitations:**
- Only works with public Facebook events (no authentication)
- Facebook's terms of service prohibit automated scraping - use at your own risk

For detailed usage examples, see [EXAMPLES.md](./EXAMPLES.md)

## Development

The server runs on port 3001 by default (configurable via PORT environment variable).

CORS is enabled to allow requests from the Flutter frontend application.
