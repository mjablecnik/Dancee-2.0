# Fly.io Quick Deploy Checklist

Fast deployment guide - 5 minutes to production!

## Prerequisites

✅ Fly.io account created
✅ Fly CLI installed
✅ Firebase project with Firestore enabled
✅ Service account key downloaded

## Quick Deploy Steps

### 1. Login

```bash
fly auth login
```

### 2. Set Firebase Credentials

```bash
# From backend/dancee_server directory
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"
fly secrets set FIREBASE_SERVICE_ACCOUNT_PATH=""
```

### 3. Set Swagger Credentials

```bash
fly secrets set SWAGGER_USER=admin
fly secrets set SWAGGER_PASSWORD=your-secure-password
```

### 4. Deploy

```bash
fly deploy
```

### 5. Verify

```bash
# Check status
fly status

# View logs
fly logs

# Test endpoint
curl https://dancee-server.fly.dev/events/list
```

## Expected Output

```
[FirebaseService] Loading service account from environment variable
[FirebaseService] Firebase initialized with service account from environment
[FirebaseService] Firestore connection established
[EventRepository] Events collection already has 8 events
🚀 Dancee Server is running on: http://0.0.0.0:3001
```

## Your URLs

- **API**: https://dancee-server.fly.dev/
- **Swagger**: https://dancee-server.fly.dev/api
- **Events**: https://dancee-server.fly.dev/events/list

## Common Issues

### Issue: "Firestore not initialized"
```bash
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"
fly apps restart dancee-server
```

### Issue: "5 NOT_FOUND"
Enable Firestore in Firebase Console:
https://console.firebase.google.com/project/dancee-b5c0d/firestore

### Issue: "Out of memory"
```bash
fly scale memory 1024
```

## Update Deployment

```bash
# Make changes to code
# Then deploy
fly deploy
```

## View Logs

```bash
fly logs
```

## That's it! 🎉

Your API is now live at: **https://dancee-server.fly.dev/**

For detailed guide, see [FLY_IO_DEPLOYMENT.md](./FLY_IO_DEPLOYMENT.md)
