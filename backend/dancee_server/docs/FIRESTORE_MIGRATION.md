# Migration from In-Memory to Firestore

This document explains the changes made to migrate from in-memory storage to Firestore.

## What Changed

### Before (In-Memory Storage)
- Data stored in JavaScript arrays and Maps
- Data lost on server restart
- Single server instance only
- No setup required

### After (Firestore)
- Data persisted in Firebase Firestore
- Data survives server restarts
- Supports multiple server instances
- Requires Firebase project setup

## Code Changes

### 1. New Firebase Module

**Created:**
- `src/firebase/firebase.module.ts` - Global module for Firebase
- `src/firebase/firebase.service.ts` - Service for Firestore connection

**Purpose:**
- Initialize Firebase Admin SDK on startup
- Provide Firestore instance to repositories

### 2. Updated Repositories

#### EventRepository (`src/events/repositories/event.repository.ts`)

**Before:**
```typescript
private events: EventDto[] = [];

async getAllEvents(): Promise<EventDto[]> {
  return [...this.events];
}
```

**After:**
```typescript
constructor(private readonly firebaseService: FirebaseService) {}

async getAllEvents(): Promise<EventDto[]> {
  const firestore = this.firebaseService.getFirestore();
  const snapshot = await firestore.collection('events').get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}
```

**New Methods:**
- `saveEvent(event: EventDto)` - Add or update event
- `deleteEvent(eventId: string)` - Remove event

#### FavoritesRepository (`src/events/repositories/favorites.repository.ts`)

**Before:**
```typescript
private favorites: Map<string, EventDto[]> = new Map();

async getFavorites(userId: string): Promise<EventDto[]> {
  return [...(this.favorites.get(userId) || [])];
}
```

**After:**
```typescript
constructor(private readonly firebaseService: FirebaseService) {}

async getFavorites(userId: string): Promise<EventDto[]> {
  const firestore = this.firebaseService.getFirestore();
  const snapshot = await firestore
    .collection('favorites')
    .doc(userId)
    .collection('events')
    .get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}
```

### 3. Updated App Module

**Added FirebaseModule import:**
```typescript
@Module({
  imports: [FirebaseModule, ScraperModule, EventsModule],
  // ...
})
```

### 4. Environment Configuration

**Added to `.env.example`:**
```env
FIREBASE_SERVICE_ACCOUNT_PATH=
```

## Service Layer - No Changes Required

The service layer (`EventsService`) remains unchanged because repositories maintain the same interface:

```typescript
// This code works with both in-memory and Firestore
const events = await this.eventRepository.getAllEvents();
const favorites = await this.favoritesRepository.getFavorites(userId);
```

## API - No Changes Required

All API endpoints work exactly the same:
- `GET /api/events?userId=user123`
- `GET /api/favorites?userId=user123`
- `POST /api/favorites`
- `DELETE /api/favorites/:eventId?userId=user123`

## Setup Required

### For Developers

1. Create Firebase project
2. Generate service account key
3. Set `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`
4. Start server - sample data loads automatically

See [FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md) for detailed instructions.

### For Production

1. Deploy to Cloud Run, Fly.io, or similar
2. Leave `FIREBASE_SERVICE_ACCOUNT_PATH` empty
3. Platform provides default credentials automatically

## Benefits

✅ **Data Persistence** - Survives server restarts
✅ **Scalability** - Multiple server instances can share data
✅ **Reliability** - Firebase handles backups and replication
✅ **Real-time** - Can add real-time listeners in future
✅ **Security** - Firestore security rules protect data

## Considerations

⚠️ **Setup Required** - Need Firebase project and credentials
⚠️ **Network Latency** - Slightly slower than in-memory (milliseconds)
⚠️ **Costs** - Firebase has free tier, then pay-as-you-go
⚠️ **Dependencies** - Requires `firebase-admin` package

## Rollback (If Needed)

To revert to in-memory storage:

1. Restore old repository files from git history
2. Remove FirebaseModule from AppModule imports
3. Remove Firebase configuration from `.env`

```bash
git checkout HEAD~1 -- src/events/repositories/
git checkout HEAD~1 -- src/app.module.ts
```

## Testing

All existing tests should pass without modification because the repository interface remains the same.

For integration tests with Firestore:
- Use Firebase Emulator Suite for local testing
- See [Firebase Testing Guide](https://firebase.google.com/docs/emulator-suite)

## Questions?

See documentation:
- [FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md) - Setup guide
- [FIRESTORE_QUICK_REFERENCE.md](./FIRESTORE_QUICK_REFERENCE.md) - Quick commands
