# Quick Start - Events API

## Start the Server

```bash
cd backend/dancee_server

# Install dependencies (if not already done)
task install

# Start development server
task dev
```

Server will start on `http://localhost:3001`

## Test the API

### Option 1: Swagger UI (Recommended)

Open your browser and go to:
```
http://localhost:3001/api
```

You'll see an interactive API documentation where you can:
- View all endpoints
- Test endpoints directly
- See request/response examples
- Try different parameters

### Option 2: curl Commands

```bash
# 1. List all events
curl http://localhost:3001/api/events

# 2. Add event to favorites
curl -X POST http://localhost:3001/api/favorites \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","eventId":"event-001"}'

# 3. Get user favorites
curl http://localhost:3001/api/favorites?userId=user123

# 4. List events with favorites marked
curl http://localhost:3001/api/events?userId=user123

# 5. Remove event from favorites
curl -X DELETE "http://localhost:3001/api/favorites/event-001?userId=user123"
```

### Option 3: HTTP File

If using VS Code with REST Client extension:

1. Open `test-events-endpoints.http`
2. Click "Send Request" above any request
3. View response in split pane

## Available Endpoints

### GET /api/events
List all dance events

**Query Parameters:**
- `userId` (optional) - Mark favorites for this user

**Example:**
```
http://localhost:3001/api/events?userId=user123
```

### GET /api/favorites
List user's favorite events

**Query Parameters:**
- `userId` (required) - User identifier

**Example:**
```
http://localhost:3001/api/favorites?userId=user123
```

### POST /api/favorites
Add event to favorites

**Body:**
```json
{
  "userId": "user123",
  "eventId": "event-001"
}
```

### DELETE /api/favorites/:eventId
Remove event from favorites

**Query Parameters:**
- `userId` (required) - User identifier

**Example:**
```
http://localhost:3001/api/favorites/event-001?userId=user123
```

## Sample Events

The API includes 8 sample events:

1. **event-001** - Prague Salsa Night
2. **event-002** - Bachata Sensual Workshop & Party
3. **event-003** - Prague Kizomba Festival 2024
4. **event-004** - Swing Dance Open Lesson
5. **event-005** - Traditional Tango Milonga
6. **event-006** - Brazilian Zouk Intensive Weekend
7. **event-007** - Salsa & Bachata Fusion Night
8. **event-008** - West Coast Swing Beginner Workshop

## Testing Workflow

1. **List all events** - See what events are available
2. **Add favorites** - Add some events to user's favorites
3. **Get favorites** - Verify favorites were added
4. **List with userId** - See events with favorites marked
5. **Remove favorites** - Remove some favorites
6. **Verify removal** - Check favorites list again

## Troubleshooting

### Server won't start

```bash
# Clean and reinstall
task clean
task install
task dev
```

### Port 3001 already in use

Change port in `src/main.ts` or set environment variable:
```bash
PORT=3002 task dev
```

### CORS errors

CORS is already enabled in `main.ts`. If issues persist, check your frontend URL.

## Next Steps

- Read [EVENTS_API.md](./EVENTS_API.md) for complete API documentation
- Read [MIGRATION_FROM_DART.md](./MIGRATION_FROM_DART.md) for implementation details
- Check [EVENTS_MODULE_SUMMARY.md](./EVENTS_MODULE_SUMMARY.md) for overview

## Development

### Run tests

```bash
task test
```

### Watch mode

```bash
task test-watch
```

### Lint code

```bash
task lint
```

### Format code

```bash
task format
```

## Production Build

```bash
task build
task start
```

---

**Happy coding! 🎉**
