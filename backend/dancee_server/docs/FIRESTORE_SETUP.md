# Firestore Setup Guide

This guide explains how to configure and use Firestore for data persistence in the Dancee Server.

## Overview

The application uses Firebase Admin SDK to connect to Firestore for storing:
- **Events** - Dance events with details (venue, time, dances, etc.)
- **Favorites** - User favorite events

## Firestore Collections Structure

```
firestore/
├── events/                    # Main events collection
│   └── {eventId}/            # Document per event
│       ├── title
│       ├── description
│       ├── organizer
│       ├── venue
│       ├── startTime
│       ├── endTime
│       └── ...
│
└── favorites/                 # User favorites collection
    └── {userId}/             # Document per user
        └── events/           # Subcollection of favorite events
            └── {eventId}/    # Document per favorite event
                ├── title
                ├── description
                └── ...
```

## Setup Instructions

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Enable Firestore Database:
   - Go to "Build" → "Firestore Database"
   - Click "Create database"
   - Choose production mode or test mode
   - Select a location

### 2. Generate Service Account Key

For local development:

1. Go to Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save the JSON file securely (e.g., `serviceAccountKey.json`)
4. **IMPORTANT**: Never commit this file to git!

### 3. Configure Environment Variables

#### Local Development (without Docker)

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Create secrets folder and move service account key:
   ```bash
   mkdir -p secrets
   mv ~/Downloads/serviceAccountKey.json secrets/
   ```

3. Set the path in `.env`:
   ```env
   FIREBASE_SERVICE_ACCOUNT_PATH=./secrets/serviceAccountKey.json
   ```

#### Docker Development

1. Same as above - create `secrets/` folder and `.env` file
2. Docker Compose automatically mounts:
   - `./secrets:/app/secrets` - Firebase credentials
   - `./.env:/app/.env` - Environment variables

3. Start with Docker:
   ```bash
   task docker-dev
   ```

#### Production (Cloud Run, Fly.io, etc.)

Leave `FIREBASE_SERVICE_ACCOUNT_PATH` empty to use application default credentials:
```env
FIREBASE_SERVICE_ACCOUNT_PATH=
```

The application will automatically use the default credentials provided by the hosting platform.

### 4. Firestore Security Rules

Set up security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events collection - read-only for all, write for authenticated users
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Favorites collection - users can only access their own favorites
    match /favorites/{userId}/events/{eventId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Usage

### Sample Data Initialization

The application automatically initializes Firestore with sample events on first startup if the `events` collection is empty.

To disable this behavior, comment out the `initializeSampleData()` call in `EventRepository` constructor.

### Repository Methods

#### EventRepository

```typescript
// Get all events
const events = await eventRepository.getAllEvents();

// Get event by ID
const event = await eventRepository.getEventById('event-001');

// Check if event exists
const exists = await eventRepository.eventExists('event-001');

// Save event
await eventRepository.saveEvent(eventDto);

// Delete event
await eventRepository.deleteEvent('event-001');
```

#### FavoritesRepository

```typescript
// Get user's favorites
const favorites = await favoritesRepository.getFavorites('user123');

// Add favorite
await favoritesRepository.addFavorite('user123', eventDto);

// Remove favorite
await favoritesRepository.removeFavorite('user123', 'event-001');
```

## Troubleshooting

### Error: "Firestore not initialized"

**Cause**: Firebase Admin SDK failed to initialize.

**Solutions**:
1. Check that `FIREBASE_SERVICE_ACCOUNT_PATH` points to a valid JSON file
2. Verify the service account key has correct permissions
3. Check application logs for initialization errors

### Error: "Permission denied"

**Cause**: Firestore security rules are blocking the operation.

**Solutions**:
1. Review security rules in Firebase Console
2. For development, temporarily use test mode rules
3. Ensure authentication is properly configured

### Error: "Cannot find module"

**Cause**: Service account path is incorrect.

**Solutions**:
1. Use relative path: `./secrets/serviceAccountKey.json`
2. Verify the file exists at the specified location
3. Check file permissions
4. **For Docker**: Ensure secrets folder is mounted in docker-compose.yml
5. **For Docker**: Restart containers after adding secrets folder

### Error: "ENOENT: no such file or directory"

**Cause**: Service account file not found (common in Docker).

**Solutions**:
1. Verify `secrets/` folder exists in project root
2. Verify service account JSON file is in `secrets/` folder
3. **For Docker**: Check docker-compose.yml has volume mount:
   ```yaml
   volumes:
     - ./secrets:/app/secrets
     - ./.env:/app/.env
   ```
4. Restart Docker containers:
   ```bash
   task docker-dev-down
   task docker-dev
   ```

## Best Practices

1. **Never commit service account keys** - Add to `.gitignore`
2. **Use environment variables** - Keep configuration separate from code
3. **Enable logging** - Monitor Firestore operations in production
4. **Set up indexes** - Create composite indexes for complex queries
5. **Use batched writes** - For multiple operations, use Firestore batches
6. **Handle errors gracefully** - Always catch and log Firestore errors

## Migration from In-Memory Storage

The Firestore implementation maintains the same interface as the previous in-memory storage, so no changes are needed in the service layer.

Key differences:
- Data persists across server restarts
- Supports multiple server instances
- Requires Firebase project setup
- Slightly higher latency (network calls)

## Additional Resources

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
