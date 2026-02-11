# Firestore Setup Checklist

Use this checklist to set up Firestore for the Dancee Server.

## Prerequisites

- [ ] Node.js v18+ installed
- [ ] npm installed
- [ ] Google account for Firebase

## Firebase Project Setup

- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Create new project or select existing one
- [ ] Enable Firestore Database
  - [ ] Go to "Build" → "Firestore Database"
  - [ ] Click "Create database"
  - [ ] Choose production mode or test mode
  - [ ] Select a location (closest to your users)

## Service Account Key (Local Development)

- [ ] Go to Project Settings → Service Accounts
- [ ] Click "Generate new private key"
- [ ] Save JSON file as `serviceAccountKey.json`
- [ ] Store file in secure location (NOT in project directory)
- [ ] Note the absolute path to the file

## Environment Configuration

- [ ] Copy `.env.example` to `.env`
  ```bash
  cp .env.example .env
  ```

- [ ] Edit `.env` file
- [ ] Set `FIREBASE_SERVICE_ACCOUNT_PATH` to path (relative or absolute)
  ```env
  # Recommended: Use relative path with secrets folder
  FIREBASE_SERVICE_ACCOUNT_PATH=./secrets/serviceAccountKey.json
  
  # Or use absolute path
  FIREBASE_SERVICE_ACCOUNT_PATH=/absolute/path/to/serviceAccountKey.json
  ```

## Dependencies

- [ ] Verify `firebase-admin` is in `package.json` (should already be there)
- [ ] Install dependencies
  ```bash
  task install
  ```

## Start Server

- [ ] Start development server
  ```bash
  task dev
  ```

- [ ] Check logs for successful Firebase initialization
  ```
  [FirebaseService] Firebase initialized with service account credentials
  [FirebaseService] Firestore connection established
  ```

- [ ] Check logs for sample data initialization
  ```
  [EventRepository] Initializing Firestore with sample data...
  [EventRepository] Successfully initialized 8 sample events
  ```

## Verify Data in Firebase Console

- [ ] Go to Firebase Console → Firestore Database
- [ ] Verify `events` collection exists
- [ ] Verify 8 sample events are present
- [ ] Check event documents have correct structure

## Test API Endpoints

- [ ] Open Swagger UI: `http://localhost:3001/api`
- [ ] Test GET `/api/events`
  - [ ] Should return 8 sample events
- [ ] Test GET `/api/favorites?userId=testuser`
  - [ ] Should return empty array (no favorites yet)
- [ ] Test POST `/api/favorites`
  - [ ] Body: `{ "userId": "testuser", "eventId": "event-001" }`
  - [ ] Should return success
- [ ] Test GET `/api/favorites?userId=testuser` again
  - [ ] Should return 1 favorite event
- [ ] Test DELETE `/api/favorites/event-001?userId=testuser`
  - [ ] Should return success
- [ ] Verify in Firebase Console
  - [ ] Check `favorites/testuser/events` subcollection

## Security Rules (Production)

- [ ] Go to Firebase Console → Firestore Database → Rules
- [ ] Update security rules for production:
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /events/{eventId} {
        allow read: if true;
        allow write: if request.auth != null;
      }
      
      match /favorites/{userId}/events/{eventId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```
- [ ] Publish rules

## Production Deployment

- [ ] Set environment variable on hosting platform
  ```env
  FIREBASE_SERVICE_ACCOUNT_PATH=
  ```
  (Leave empty for default credentials)

- [ ] Deploy application
- [ ] Verify logs show successful Firebase initialization
- [ ] Test API endpoints in production
- [ ] Monitor Firebase Console for usage

## Troubleshooting

If you encounter issues, check:

- [ ] Service account key path is correct (relative or absolute)
- [ ] Service account key file exists and is readable
- [ ] If using relative path, it's relative to project root
- [ ] Firebase project has Firestore enabled
- [ ] Environment variable is set correctly
- [ ] Application logs for error messages
- [ ] Firebase Console for Firestore status

## Documentation

Refer to these documents for more information:

- [ ] [FIRESTORE_QUICK_REFERENCE.md](./FIRESTORE_QUICK_REFERENCE.md) - Quick commands
- [ ] [FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md) - Detailed setup guide
- [ ] [FIRESTORE_IMPLEMENTATION_SUMMARY.md](./FIRESTORE_IMPLEMENTATION_SUMMARY.md) - Implementation details
- [ ] [FIRESTORE_MIGRATION.md](./FIRESTORE_MIGRATION.md) - Migration information

## Success Criteria

✅ Server starts without errors
✅ Firebase initialization logs appear
✅ Sample data loads automatically
✅ Events visible in Firebase Console
✅ API endpoints return correct data
✅ Favorites can be added and removed
✅ Data persists after server restart

---

**Need Help?**
- Check [FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md) troubleshooting section
- Review application logs
- Check Firebase Console status
