# Events API Documentation

## Overview

The Events API provides endpoints for managing dance events and user favorites. This module is a direct port from the Dart `dancee_event_service` to the NestJS `dancee_server`, providing identical functionality with full Swagger documentation.

## Base URL

```
http://localhost:3001/api
```

## Endpoints

### 1. List All Events

Retrieves all available dance events. Optionally marks events as favorites for a specific user.

**Endpoint:** `GET /api/events`

**Query Parameters:**
- `userId` (optional): User identifier to mark favorite events

**Example Request:**
```bash
# Get all events
curl http://localhost:3001/api/events

# Get all events with favorites marked for user
curl http://localhost:3001/api/events?userId=user123
```

**Response:** `200 OK`
```json
[
  {
    "id": "event-001",
    "title": "Prague Salsa Night",
    "description": "Join us for an amazing night of Salsa dancing!",
    "organizer": "Prague Salsa Club",
    "venue": {
      "name": "Lucerna Music Bar",
      "address": {
        "street": "Vodičkova 36",
        "city": "Prague",
        "postalCode": "110 00",
        "country": "Czech Republic"
      },
      "description": "Historic music venue in the heart of Prague",
      "latitude": 50.0813,
      "longitude": 14.4258
    },
    "startTime": "2024-02-15T20:00:00Z",
    "endTime": "2024-02-16T02:00:00Z",
    "duration": 21600000,
    "dances": ["Salsa", "Bachata"],
    "info": [
      {
        "type": "price",
        "key": "Entry Fee",
        "value": "200 Kč"
      }
    ],
    "parts": [
      {
        "name": "Social Dancing",
        "description": "Open social dancing with live band",
        "type": "party",
        "startTime": "2024-02-15T20:00:00Z",
        "endTime": "2024-02-16T02:00:00Z",
        "djs": ["DJ Carlos", "DJ Maria"]
      }
    ],
    "isFavorite": false
  }
]
```

---

### 2. List User Favorites

Retrieves all favorite events for a specific user.

**Endpoint:** `GET /api/favorites`

**Query Parameters:**
- `userId` (required): User identifier

**Example Request:**
```bash
curl http://localhost:3001/api/favorites?userId=user123
```

**Response:** `200 OK`
```json
[
  {
    "id": "event-001",
    "title": "Prague Salsa Night",
    "isFavorite": true,
    ...
  }
]
```

**Error Responses:**
- `400 Bad Request`: userId query parameter is required
- `500 Internal Server Error`: Server error

---

### 3. Add Event to Favorites

Adds an event to a user's favorites list.

**Endpoint:** `POST /api/favorites`

**Request Body:**
```json
{
  "userId": "user123",
  "eventId": "event-001"
}
```

**Example Request:**
```bash
curl -X POST http://localhost:3001/api/favorites \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","eventId":"event-001"}'
```

**Response:** `201 Created`
```json
{
  "message": "Favorite added successfully",
  "userId": "user123",
  "eventId": "event-001"
}
```

**Error Responses:**
- `400 Bad Request`: userId and eventId are required
- `404 Not Found`: Event not found
- `500 Internal Server Error`: Server error

---

### 4. Remove Event from Favorites

Removes an event from a user's favorites list.

**Endpoint:** `DELETE /api/favorites/:eventId`

**Path Parameters:**
- `eventId`: Event identifier to remove

**Query Parameters:**
- `userId` (required): User identifier

**Example Request:**
```bash
curl -X DELETE "http://localhost:3001/api/favorites/event-001?userId=user123"
```

**Response:** `204 No Content`

**Error Responses:**
- `400 Bad Request`: userId query parameter is required
- `404 Not Found`: Event not found
- `500 Internal Server Error`: Server error

---

## Data Models

### Event

```typescript
{
  id: string;                    // Unique event identifier
  title: string;                 // Event title
  description?: string;          // Event description
  organizer: string;             // Event organizer name
  venue: Venue;                  // Event venue details
  startTime: string;             // ISO 8601 datetime
  endTime?: string;              // ISO 8601 datetime
  duration?: number;             // Duration in milliseconds
  dances: string[];              // List of dance styles
  info?: EventInfo[];            // Additional event information
  parts?: EventPart[];           // Event parts/segments
  isFavorite?: boolean;          // Whether event is favorited by user
}
```

### Venue

```typescript
{
  name: string;                  // Venue name
  address: Address;              // Venue address
  description?: string;          // Venue description
  latitude?: number;             // GPS latitude
  longitude?: number;            // GPS longitude
}
```

### Address

```typescript
{
  street: string;                // Street address
  city: string;                  // City name
  postalCode: string;            // Postal code
  country: string;               // Country name
}
```

### EventInfo

```typescript
{
  type: 'price' | 'url' | 'text'; // Info type
  key: string;                    // Info label
  value: string;                  // Info value
}
```

### EventPart

```typescript
{
  name: string;                   // Part name
  description?: string;           // Part description
  type: 'party' | 'workshop' | 'openLesson' | 'course';
  startTime: string;              // ISO 8601 datetime
  endTime?: string;               // ISO 8601 datetime
  djs?: string[];                 // List of DJs
  lectors?: string[];             // List of instructors
}
```

---

## Sample Events

The API includes 8 sample events covering various dance styles:

1. **Prague Salsa Night** - Salsa & Bachata party
2. **Bachata Sensual Workshop & Party** - Workshop + social dancing
3. **Prague Kizomba Festival 2024** - Multi-day festival
4. **Swing Dance Open Lesson** - Free beginner lesson
5. **Traditional Tango Milonga** - Argentine Tango social
6. **Brazilian Zouk Intensive Weekend** - Workshop intensive
7. **Salsa & Bachata Fusion Night** - Mixed styles party
8. **West Coast Swing Beginner Workshop** - Beginner workshop

---

## Testing with Swagger UI

Access the interactive Swagger documentation at:

```
http://localhost:3001/api
```

The Swagger UI allows you to:
- View all endpoint details
- Test endpoints directly from the browser
- See request/response schemas
- Try different parameters and payloads

---

## Architecture

The Events module follows NestJS best practices and mirrors the architecture of the Dart `dancee_event_service`:

```
events/
├── dto/                        # Data Transfer Objects
│   ├── event.dto.ts           # Event data structures
│   └── add-favorite.dto.ts    # Request DTOs
├── repositories/               # Data layer
│   ├── event.repository.ts    # Event data management
│   └── favorites.repository.ts # Favorites data management
├── events.controller.ts        # HTTP endpoints
├── events.service.ts           # Business logic
└── events.module.ts            # Module configuration
```

### Layers:

1. **Controller Layer** (`events.controller.ts`)
   - Handles HTTP requests/responses
   - Validates input parameters
   - Maps to service methods
   - Includes Swagger documentation

2. **Service Layer** (`events.service.ts`)
   - Contains business logic
   - Coordinates between repositories
   - Handles data transformation
   - Validates business rules

3. **Repository Layer** (`repositories/`)
   - Manages data storage (in-memory)
   - Provides data access methods
   - Handles data persistence

---

## Differences from Dart Service

While the functionality is identical, there are some implementation differences:

1. **Language**: TypeScript (NestJS) vs Dart (shelf)
2. **Framework**: NestJS decorators vs shelf handlers
3. **Validation**: class-validator decorators vs manual validation
4. **Documentation**: Swagger decorators vs manual docs
5. **Error Handling**: NestJS exceptions vs Response objects

The API contract remains 100% compatible with the Dart service.

---

## Future Enhancements

Potential improvements for production use:

1. **Database Integration**: Replace in-memory storage with PostgreSQL/MongoDB
2. **Authentication**: Add JWT-based user authentication
3. **Pagination**: Add pagination for event lists
4. **Filtering**: Add filters by date, dance style, location
5. **Search**: Add full-text search capabilities
6. **Caching**: Add Redis caching for performance
7. **Rate Limiting**: Add API rate limiting
8. **Validation**: Enhanced input validation and sanitization

---

## Related Documentation

- [Main README](../README.md) - Project overview
- [Swagger Setup](./SWAGGER.md) - Swagger configuration
- [Examples](./EXAMPLES.md) - Usage examples
- [Scraper API](./SCRAPER_API.md) - Scraper endpoints (if exists)
