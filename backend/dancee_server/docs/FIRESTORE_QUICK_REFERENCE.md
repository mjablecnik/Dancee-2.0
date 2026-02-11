# Firestore Quick Reference

Quick commands and configuration for Firestore integration.

## Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Edit .env and set Firebase credentials
# For local development (recommended - use secrets folder):
FIREBASE_SERVICE_ACCOUNT_PATH=./secrets/serviceAccountKey.json

# Or use absolute path:
FIREBASE_SERVICE_ACCOUNT_PATH=/absolute/path/to/serviceAccountKey.json

# For production (Cloud Run, Fly.io):
FIREBASE_SERVICE_ACCOUNT_PATH=
```

## Get Service Account Key

1. Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save as `serviceAccountKey.json`
4. **Never commit to git!**

## Start Development Server

```bash
# Install dependencies
task install

# Start with hot reload
task dev
```

## Firestore Collections

```
events/              # All dance events
  {eventId}/         # Event document

favorites/           # User favorites
  {userId}/          # User document
    events/          # Subcollection
      {eventId}/     # Favorite event document
```

## API Endpoints

```bash
# Get all events
GET /events?userId=user123

# Get user favorites
GET /events/favorites?userId=user123

# Add favorite
POST /events/favorites
{
  "userId": "user123",
  "eventId": "event-001"
}

# Remove favorite
DELETE /events/favorites?userId=user123&eventId=event-001
```

## Testing

```bash
# Test in Swagger UI
http://localhost:3001/api

# Test with curl
curl http://localhost:3001/events
```

## Common Issues

| Issue | Solution |
|-------|----------|
| "Firestore not initialized" | Check `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env` |
| "Cannot find module" | Use absolute path for service account key |
| "Permission denied" | Check Firestore security rules |
| Empty events list | Sample data loads on first startup |

## Production Deployment

1. Set environment variable on hosting platform
2. Use application default credentials (leave `FIREBASE_SERVICE_ACCOUNT_PATH` empty)
3. Verify Firestore security rules
4. Monitor logs for initialization

## See Also

- [FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md) - Detailed setup guide
- [EVENTS_API.md](./EVENTS_API.md) - API documentation
- [Firebase Console](https://console.firebase.google.com/)
