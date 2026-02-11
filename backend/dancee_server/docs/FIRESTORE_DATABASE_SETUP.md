# Firestore Database Setup - Quick Fix

## Error: "5 NOT_FOUND"

If you see this error in logs:
```
[EventRepository] Failed to get all events
[EventRepository] Error: 5 NOT_FOUND:
```

This means the Firestore database hasn't been created yet in your Firebase project.

## Solution: Create Firestore Database

### Step 1: Open Firebase Console

Go to your project console:
```
https://console.firebase.google.com/project/dancee-b5c0d
```

Or general link:
```
https://console.firebase.google.com/
```

### Step 2: Navigate to Firestore

1. In the left sidebar, click **"Build"**
2. Click **"Firestore Database"**

### Step 3: Create Database

1. Click the **"Create database"** button
2. Choose a mode:
   - **Production mode** (recommended for production)
   - **Test mode** (easier for development - allows all reads/writes)

3. Click **"Next"**

### Step 4: Select Location

1. Choose a location closest to your users:
   - **europe-west3** (Frankfurt) - for Europe
   - **us-central1** (Iowa) - for US
   - **asia-northeast1** (Tokyo) - for Asia

2. Click **"Enable"**

### Step 5: Wait for Creation

The database creation takes 1-2 minutes. You'll see a loading screen.

### Step 6: Verify Database is Ready

Once created, you should see:
- Empty Firestore console with "Start collection" button
- Database location shown at the top

### Step 7: Restart Server

```bash
# Stop Docker container
task docker-dev-down

# Start again
task docker-dev

# Or if running locally
# Press Ctrl+C and run:
task dev
```

### Step 8: Verify Success

Check logs for:
```
[FirebaseService] Firebase initialized with service account credentials
[FirebaseService] Firestore connection established
[EventRepository] Initializing Firestore with sample data...
[EventRepository] Successfully initialized 8 sample events
```

### Step 9: Verify in Firebase Console

1. Go back to Firestore Database in Firebase Console
2. You should see an `events` collection with 8 documents
3. Click on any event to see the data

## Security Rules (Optional)

For development, you can use test mode rules (allow all):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

For production, use secure rules:
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

## Troubleshooting

### Database creation stuck?

- Refresh the page
- Try a different browser
- Check Firebase status: https://status.firebase.google.com/

### Still getting NOT_FOUND error?

1. Verify database is enabled in Firebase Console
2. Check that you selected the correct project
3. Verify service account has Firestore permissions
4. Wait 1-2 minutes after database creation
5. Restart the server

### Wrong project?

Check your service account file:
```bash
cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json | grep project_id
```

Should show: `"project_id": "dancee-b5c0d"`

## Quick Links

- **Your Firebase Console**: https://console.firebase.google.com/project/dancee-b5c0d
- **Firestore Database**: https://console.firebase.google.com/project/dancee-b5c0d/firestore
- **Firebase Status**: https://status.firebase.google.com/

---

**After completing these steps, your Firestore database will be ready and the server will automatically initialize with sample events!**
