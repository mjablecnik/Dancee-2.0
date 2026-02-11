# Dancee Server

A simple NestJS REST API server for the Dancee application.

## Prerequisites

- Node.js (v18 or higher)
- npm

## Installation

```bash
# 1. Install dependencies
task install
# or
npm install

# 2. Create .env file from example
cp .env.example .env

# 3. Edit .env with your configuration (optional for development)
# See docs/ENVIRONMENT_SETUP.md for details
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

### Local Development
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

### Docker Tasks
- `task docker-dev` - Start development server in Docker with hot reload
- `task docker-dev-down` - Stop development Docker container
- `task docker-prod` - Build and start production Docker container
- `task docker-prod-down` - Stop production Docker container
- `task docker-prod-logs` - View production Docker container logs
- `task docker-clean` - Remove all Docker containers, images, and volumes

**📦 For complete Docker setup guide, see [DOCKER.md](./docs/DOCKER.md)**

## API Endpoints

### Interactive API Documentation (Swagger)

**📚 Full interactive API documentation is available at:**
```
http://localhost:3001/api
```

The Swagger UI provides:
- Interactive endpoint testing
- Complete request/response schemas
- Parameter documentation
- Example requests and responses

**🔒 Production Security:**
In production environments, Swagger documentation is protected with HTTP Basic Authentication. Only authorized users with valid credentials can access the API documentation.

**Security Documentation:**
- 🚀 [Quick Start (5 min)](./docs/SWAGGER_SECURITY_QUICKSTART.md) - Fast setup guide
- 📚 [Documentation Index](./docs/SWAGGER_SECURITY_INDEX.md) - Complete guide navigation
- ✅ [Deployment Checklist](./docs/SWAGGER_SECURITY_CHECKLIST.md) - Pre-deployment tasks
- 📘 [Complete Security Guide](./docs/SWAGGER_SECURITY.md) - Detailed documentation
- 💻 [Usage Examples](./docs/SWAGGER_SECURITY_EXAMPLES.md) - Code examples in 10+ languages

For more details, see [SWAGGER.md](./docs/SWAGGER.md)

### API Modules

This server provides two main API modules:

1. **Events API** (`/api/events`, `/api/favorites`) - Dance event management and user favorites
   - See [EVENTS_API.md](./docs/EVENTS_API.md) for detailed documentation
   
2. **Scraper API** (`/scraper/*`) - Facebook event scraping
   - See examples below and [EXAMPLES.md](./docs/EXAMPLES.md)

### Quick Reference

### GET /
Returns a simple "Hello World!" message.

**Response:**
```
Hello World!
```

---

## Events API

### GET /api/events
List all dance events, optionally marking favorites for a user.

**Query Parameters:**
- `userId` (optional) - User identifier to mark favorites

**Example:**
```bash
GET http://localhost:3001/api/events?userId=user123
```

### GET /api/favorites
List all favorite events for a user.

**Query Parameters:**
- `userId` (required) - User identifier

**Example:**
```bash
GET http://localhost:3001/api/favorites?userId=user123
```

### POST /api/favorites
Add an event to user favorites.

**Body:**
```json
{
  "userId": "user123",
  "eventId": "event-001"
}
```

### DELETE /api/favorites/:eventId
Remove an event from user favorites.

**Query Parameters:**
- `userId` (required) - User identifier

**Example:**
```bash
DELETE http://localhost:3001/api/favorites/event-001?userId=user123
```

**📖 For complete Events API documentation, see [EVENTS_API.md](./docs/EVENTS_API.md)**

---

## Scraper API

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
├── app/                     # Main application module
│   ├── app.controller.ts   # Main controller
│   ├── app.module.ts       # Root module
│   └── app.service.ts      # Business logic
├── events/                  # Events API module
│   ├── dto/                # Data Transfer Objects
│   ├── repositories/       # Data access layer
│   ├── events.controller.ts
│   ├── events.service.ts
│   └── events.module.ts
├── firebase/               # Firebase integration
│   ├── firebase.module.ts
│   └── firebase.service.ts
├── scraper/                # Scraper API module
│   ├── dto/
│   ├── scraper.controller.ts
│   ├── scraper.service.ts
│   └── scraper.module.ts
└── main.ts                 # Application entry point
docs/                       # Documentation
├── EVENTS_API.md          # Events API documentation
├── SWAGGER.md             # Swagger setup guide
├── FIRESTORE_SETUP.md     # Firestore configuration
└── EXAMPLES.md            # Usage examples
```

## Features

- ✅ CORS enabled for frontend communication
- ✅ Hot reload in development mode
- ✅ TypeScript support
- ✅ ESLint and Prettier configured
- ✅ Jest testing setup
- ✅ Task automation with Taskfile
- ✅ **Events API** - Dance event management and user favorites
- ✅ **Firestore Integration** - Persistent data storage with Firebase
- ✅ **Scraper API** - Facebook event scraping with `facebook-event-scraper`
- ✅ Input validation with class-validator
- ✅ Structured logging
- ✅ **Swagger/OpenAPI documentation** - Interactive API docs at `/api`

## Data Storage

This application uses **Firebase Firestore** for persistent data storage.

**Collections:**
- `events` - Dance events with details (venue, time, dances, etc.)
- `favorites` - User favorite events (subcollection per user)

**Setup:**
1. Create Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. **Enable Firestore Database** (see [Database Setup Guide](./docs/FIRESTORE_DATABASE_SETUP.md))
3. Generate service account key
4. Configure `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`

**Documentation:**
- 🚨 [Database Setup](./docs/FIRESTORE_DATABASE_SETUP.md) - **START HERE if you get "NOT_FOUND" error**
- 🚀 [Quick Reference](./docs/FIRESTORE_QUICK_REFERENCE.md) - Fast setup commands
- 📚 [Complete Setup Guide](./docs/FIRESTORE_SETUP.md) - Detailed configuration

**Sample Data:**
The application automatically initializes Firestore with sample events on first startup if the collection is empty.

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

## Deployment

### Fly.io (Automated)

Use deployment scripts for easy deployment:

```bash
# Interactive deployment (recommended for first time)
task deploy

# Quick deployment (for updates)
task deploy-quick

# View logs
task deploy-logs

# Check status
task deploy-status
```

**Manual deployment:**

```bash
# Set secrets
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"
fly secrets set SWAGGER_USER=admin
fly secrets set SWAGGER_PASSWORD=your-secure-password

# Deploy
fly deploy
```

**Documentation:**
- 📜 [Deploy Scripts Guide](./docs/DEPLOY_SCRIPTS.md) - Automated deployment scripts
- 🚀 [Quick Deploy Guide](./docs/FLY_IO_QUICK_DEPLOY.md) - 5-minute deployment
- 📚 [Complete Deployment Guide](./docs/FLY_IO_DEPLOYMENT.md) - Detailed instructions
- 🧠 [Memory Optimization](./docs/MEMORY_OPTIMIZATION.md) - Fix memory issues

### Docker Production

```bash
task docker-prod
```

See [DOCKER.md](./docs/DOCKER.md) for complete Docker documentation.
