# Authentication Configuration

## Overview

The dancee_server uses selective authentication to protect only the Swagger documentation while keeping the Events API publicly accessible.

## Authentication Rules

### Protected Routes (Basic Auth Required in Production)
- `/api` - Swagger UI
- `/api/*` - Swagger static assets (CSS, JS, etc.)
- `/api-json` - Swagger JSON specification

### Public Routes (No Authentication)
- `/events/list` - List all events
- `/events/favorites` - List user favorites
- `POST /events/favorites` - Add event to favorites
- `DELETE /events/favorites/:eventId` - Remove event from favorites
- `/scraper/*` - Event scraping endpoints
- `/` - Health check

## Configuration

### Environment Variables

Set these in production:
```bash
SWAGGER_USER=your_username
SWAGGER_PASSWORD=your_secure_password
NODE_ENV=production
```

### Development Mode

In development (`NODE_ENV !== 'production'`), all routes including Swagger are accessible without authentication.

## Implementation Details

The `SwaggerAuthMiddleware` is applied to routes matching `api*` and `api-json`, but internally checks the exact path to exclude Events API routes (`/api/events`, `/api/favorites`).

This allows:
- ✅ Swagger documentation protected in production
- ✅ Events API publicly accessible
- ✅ Frontend can access events without authentication
- ✅ Swagger remains secure from unauthorized access

## Testing

### Test Swagger Protection (Production)
```bash
# Should require authentication
curl http://localhost:3001/api

# Should return 401 Unauthorized
```

### Test Events API (No Auth Required)
```bash
# Should work without authentication
curl http://localhost:3001/events/list

# Should return event list
```

## Security Notes

1. **Change default credentials** - Never use default `admin/changeme` in production
2. **Use strong passwords** - Generate secure passwords for Swagger access
3. **HTTPS recommended** - Basic auth sends credentials in base64 (easily decoded)
4. **Environment variables** - Store credentials securely, never commit to git
