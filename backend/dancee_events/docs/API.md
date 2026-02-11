# API Documentation - Dancee Events

Complete API reference for the Dancee Events REST API.

## Base URL

```
http://localhost:8080/api
```

## Endpoints

### Base URLs

The API supports two base URL formats for backward compatibility:

**Recommended (with /api prefix):**
```
http://localhost:8080/api
```

**Legacy (without /api prefix):**
```
http://localhost:8080
```

Both formats work identically. The `/api` prefix is recommended for new integrations.

Check if the server is running.

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "ok"
}
```

---

### List All Events

Retrieve all dance events. Optionally mark favorite events for a specific user.

**Endpoint:** 
- `GET /api/events/list` (recommended)
- `GET /events/list` (legacy, backward compatible)

**Query Parameters:**
- `userId` (optional): User identifier to mark favorite events

**Example Request:**
```bash
# Without user
curl http://localhost:8080/api/events/list

# With user (marks favorites)
curl "http://localhost:8080/api/events/list?userId=user123"
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

### List Favorite Events

Retrieve all favorite events for a specific user.

**Endpoint:** 
- `GET /api/events/favorites` (recommended)
- `GET /events/favorites` (legacy, backward compatible)

**Query Parameters:**
- `userId` (required): User identifier

**Example Request:**
```bash
curl "http://localhost:8080/api/events/favorites?userId=user123"
```

**Response:** `200 OK`
```json
[
  {
    "id": "event-001",
    "title": "Prague Salsa Night",
    "organizer": "Prague Salsa Club",
    ...
  }
]
```

**Error Response:** `400 Bad Request`
```json
{
  "error": "userId query parameter is required"
}
```

---

### Add Favorite

Add an event to a user's favorites.

**Endpoint:** 
- `POST /api/events/favorites` (recommended)
- `POST /events/favorites` (legacy, backward compatible)

**Request Body:**
```json
{
  "userId": "user123",
  "eventId": "event-001"
}
```

**Example Request:**
```bash
curl -X POST http://localhost:8080/api/events/favorites \
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

`400 Bad Request` - Missing required fields:
```json
{
  "error": "userId and eventId are required"
}
```

`404 Not Found` - Event doesn't exist:
```json
{
  "error": "Event not found"
}
```

---

### Remove Favorite

Remove an event from a user's favorites.

**Endpoint:** 
- `DELETE /api/events/favorites/:eventId` (recommended)
- `DELETE /events/favorites/:eventId` (legacy, backward compatible)

**Path Parameters:**
- `eventId`: Event identifier to remove

**Query Parameters:**
- `userId` (required): User identifier

**Example Request:**
```bash
curl -X DELETE "http://localhost:8080/api/events/favorites/event-001?userId=user123"
```

**Response:** `204 No Content`

**Error Responses:**

`400 Bad Request` - Missing userId:
```json
{
  "error": "userId query parameter is required"
}
```

`404 Not Found` - Event doesn't exist:
```json
{
  "error": "Event not found"
}
```

---

## Data Models

### Event

```json
{
  "id": "string",
  "title": "string",
  "description": "string (optional)",
  "organizer": "string",
  "venue": {
    "name": "string",
    "address": {
      "street": "string",
      "city": "string",
      "postalCode": "string",
      "country": "string"
    },
    "description": "string (optional)",
    "latitude": "number (optional)",
    "longitude": "number (optional)"
  },
  "startTime": "string (ISO 8601)",
  "endTime": "string (ISO 8601, optional)",
  "duration": "number (milliseconds, optional)",
  "dances": ["string"],
  "info": [
    {
      "type": "string (price|url|text)",
      "key": "string",
      "value": "string"
    }
  ],
  "parts": [
    {
      "name": "string",
      "description": "string (optional)",
      "type": "string (party|workshop|openLesson|course)",
      "startTime": "string (ISO 8601)",
      "endTime": "string (ISO 8601, optional)",
      "djs": ["string (optional)"],
      "lectors": ["string (optional)"]
    }
  ],
  "isFavorite": "boolean (optional)"
}
```

### AddFavoriteRequest

```json
{
  "userId": "string (required)",
  "eventId": "string (required)"
}
```

---

## Error Handling

All errors follow this format:

```json
{
  "error": "Error message description"
}
```

### HTTP Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `204 No Content` - Request successful, no content to return
- `400 Bad Request` - Invalid request parameters
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

---

## CORS

The API has CORS enabled and accepts requests from any origin (`*`).

Allowed methods: `GET`, `POST`, `DELETE`, `OPTIONS`

Allowed headers: `Content-Type`, `Authorization`

---

## Rate Limiting

Currently, there is no rate limiting implemented. This may be added in future versions.

---

## Authentication

Currently, the API does not require authentication. User identification is done via the `userId` parameter.

In production, you should implement proper authentication and authorization.
