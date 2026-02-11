# Troubleshooting Guide - Dancee Events API

Common issues and their solutions.

## Firebase Connection Issues

### Error: "project id is required to access Firestore"

**Cause:** `GOOGLE_CLOUD_PROJECT` environment variable is not set.

**Solution:**

**Local development (.env file):**
```env
GOOGLE_CLOUD_PROJECT=dancee-b5c0d
```

**Fly.io:**
```bash
fly secrets set GOOGLE_CLOUD_PROJECT=dancee-b5c0d --app dancee-events
```

**Docker:**
```yaml
# docker-compose.yml
environment:
  - GOOGLE_CLOUD_PROJECT=dancee-b5c0d
```

**Systemd:**
```ini
# /etc/systemd/system/dancee-events.service
Environment="GOOGLE_CLOUD_PROJECT=dancee-b5c0d"
```

### Error: "Failed to initialize Firebase"

**Cause:** Firebase credentials are not properly configured.

**Solution:**

1. **Check if credentials file exists:**
```bash
ls -la secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json
```

2. **Verify environment variable is set:**
```bash
# Local
cat .env | grep FIREBASE

# Fly.io
fly secrets list --app dancee-events

# Docker
docker-compose config | grep FIREBASE
```

3. **Set credentials properly:**

**Fly.io:**
```bash
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)" --app dancee-events
```

**Docker:**
```bash
export FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"
docker-compose up -d
```

### Error: "Firestore database not found"

**Cause:** Firestore is not enabled in Firebase Console.

**Solution:**

1. Go to [Firebase Console](https://console.firebase.google.com/project/dancee-b5c0d)
2. Click "Build" → "Firestore Database"
3. Click "Create database"
4. Choose "Start in production mode" or "Start in test mode"
5. Select a location (e.g., europe-west3)
6. Wait for database creation to complete
7. Restart the server

### Error: "Permission denied" when accessing Firestore

**Cause:** Service account doesn't have proper permissions.

**Solution:**

1. Go to [IAM & Admin](https://console.cloud.google.com/iam-admin/iam?project=dancee-b5c0d)
2. Find your service account: `firebase-adminsdk-fbsvc@dancee-b5c0d.iam.gserviceaccount.com`
3. Ensure it has these roles:
   - Firebase Admin SDK Administrator Service Agent
   - Cloud Datastore User (or Owner)
4. If missing, add the roles
5. Restart the server

## Server Issues

### Error: "bind: address already in use"

**Cause:** Port is already in use by another process.

**Solution:**

**Option 1: Change port**
```env
PORT=3003
```

**Option 2: Kill process using the port**
```bash
# Find process
lsof -i :8080

# Kill process
kill -9 <PID>
```

### Error: "No .env file found"

**Cause:** `.env` file doesn't exist (this is OK for production).

**Solution:**

**For local development:**
```bash
cp .env.example .env
# Edit .env with your values
```

**For production:**
This is expected. Set environment variables directly:
```bash
export PORT=8080
export ENV=production
export GOOGLE_CLOUD_PROJECT=dancee-b5c0d
export FIREBASE_SERVICE_ACCOUNT_JSON="..."
```

### Server starts but doesn't respond

**Cause:** Server is listening on wrong interface or port.

**Solution:**

1. **Check logs:**
```bash
# Fly.io
fly logs --app dancee-events

# Docker
docker-compose logs -f

# Systemd
sudo journalctl -u dancee-events -f
```

2. **Verify port binding:**
```bash
# Check if server is listening
netstat -tulpn | grep 8080
```

3. **Test locally:**
```bash
curl http://localhost:8080/health
```

## Build Issues

### Error: "go: module not found"

**Cause:** Dependencies are not downloaded.

**Solution:**
```bash
go mod download
go mod tidy
```

### Error: "undefined: firebase.Config"

**Cause:** Import is missing or incorrect.

**Solution:**

Check imports in `internal/firebase/client.go`:
```go
import (
    firebase "firebase.google.com/go/v4"
)
```

### Build succeeds but binary doesn't run

**Cause:** Missing dependencies or wrong architecture.

**Solution:**

**For Linux:**
```bash
CGO_ENABLED=0 GOOS=linux go build -o dancee_events main.go
```

**For Windows:**
```bash
GOOS=windows go build -o dancee_events.exe main.go
```

**For macOS:**
```bash
GOOS=darwin go build -o dancee_events main.go
```

## Docker Issues

### Error: "Cannot connect to Docker daemon"

**Cause:** Docker is not running.

**Solution:**
```bash
# Start Docker
sudo systemctl start docker

# Or on macOS/Windows
# Start Docker Desktop
```

### Error: "Image build failed"

**Cause:** Dockerfile error or missing files.

**Solution:**

1. **Check Dockerfile syntax**
2. **Ensure all files are present:**
```bash
ls -la main.go go.mod go.sum
```

3. **Build with verbose output:**
```bash
docker build --no-cache -t dancee-events .
```

### Container starts but exits immediately

**Cause:** Application crashes on startup.

**Solution:**

1. **Check logs:**
```bash
docker logs dancee-events
```

2. **Run interactively:**
```bash
docker run -it --rm dancee-events
```

3. **Check environment variables:**
```bash
docker inspect dancee-events | grep -A 20 Env
```

## API Issues

### Error: 404 Not Found

**Cause:** Wrong endpoint URL.

**Solution:**

Ensure you're using the correct URL format:
```bash
# Correct
curl http://localhost:8080/api/events/list

# Wrong
curl http://localhost:8080/events/list  # Missing /api
```

### Error: CORS error from frontend

**Cause:** CORS is not properly configured.

**Solution:**

Check CORS middleware in `main.go`:
```go
router.Use(func(c *gin.Context) {
    c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
    c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS")
    c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
    
    if c.Request.Method == "OPTIONS" {
        c.AbortWithStatus(204)
        return
    }
    
    c.Next()
})
```

For production, change `*` to your frontend domain:
```go
c.Writer.Header().Set("Access-Control-Allow-Origin", "https://yourdomain.com")
```

### Error: 500 Internal Server Error

**Cause:** Application error.

**Solution:**

1. **Check logs for error details**
2. **Common causes:**
   - Firebase connection failed
   - Firestore query error
   - Invalid data format

3. **Test Firebase connection:**
```bash
curl http://localhost:8080/health
```

If health check fails, it's a Firebase issue.

### Empty response or no data

**Cause:** Firestore collection is empty.

**Solution:**

The app auto-populates sample data on first run. If data is missing:

1. **Check logs for initialization:**
```
Initializing Firestore with sample data...
Successfully initialized X sample events
```

2. **Manually check Firestore:**
   - Go to Firebase Console
   - Open Firestore Database
   - Check if `events` collection exists

3. **Restart server to trigger initialization:**
```bash
# Fly.io
fly apps restart dancee-events

# Docker
docker-compose restart

# Systemd
sudo systemctl restart dancee-events
```

## Performance Issues

### Slow response times

**Cause:** Multiple possible causes.

**Solution:**

1. **Check Firestore indexes:**
   - Go to Firebase Console → Firestore → Indexes
   - Create composite indexes if needed

2. **Monitor memory usage:**
```bash
# Fly.io
fly status --app dancee-events

# Docker
docker stats dancee-events
```

3. **Check network latency:**
```bash
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080/api/events/list
```

### High memory usage

**Cause:** Memory leak or too many concurrent requests.

**Solution:**

1. **Restart service:**
```bash
# Fly.io
fly apps restart dancee-events

# Docker
docker-compose restart
```

2. **Increase memory limit:**

**Fly.io (fly.toml):**
```toml
[[vm]]
  memory_mb = 512  # Increase from 256
```

**Docker (docker-compose.yml):**
```yaml
services:
  dancee-events:
    deploy:
      resources:
        limits:
          memory: 512M
```

## Deployment Issues

### Fly.io: "App not found"

**Cause:** App hasn't been created yet.

**Solution:**
```bash
fly apps create dancee-events --org personal
```

### Fly.io: "Secret not set"

**Cause:** Firebase credentials secret is missing.

**Solution:**
```bash
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)" --app dancee-events
```

### Fly.io: Deployment fails

**Cause:** Various reasons.

**Solution:**

1. **Check build logs:**
```bash
fly logs --app dancee-events
```

2. **Verify fly.toml is correct**
3. **Try deploying with verbose output:**
```bash
fly deploy --verbose --app dancee-events
```

## Getting Help

If you're still experiencing issues:

1. **Check logs thoroughly:**
   - Look for error messages
   - Check stack traces
   - Note any warnings

2. **Verify configuration:**
   - All environment variables are set
   - Firebase credentials are valid
   - Firestore is enabled

3. **Test components individually:**
   - Test Firebase connection
   - Test API endpoints
   - Test with curl/Postman

4. **Review documentation:**
   - [Setup Guide](./SETUP.md)
   - [Deployment Guide](./DEPLOYMENT.md)
   - [API Documentation](./API.md)

5. **Common debugging commands:**
```bash
# Check environment
env | grep -E '(PORT|ENV|GOOGLE_CLOUD_PROJECT|FIREBASE)'

# Test health endpoint
curl http://localhost:8080/health

# Test API endpoint
curl http://localhost:8080/api/events/list

# Check logs
tail -f logs/app.log  # If logging to file
```
