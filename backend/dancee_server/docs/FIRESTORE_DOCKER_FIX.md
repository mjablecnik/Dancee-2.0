# Firestore Docker Configuration Fix

## Problem

When running in Docker, the application couldn't access Firebase credentials because:
1. `secrets/` folder wasn't mounted in Docker container
2. `.env` file wasn't mounted in Docker container
3. `EventRepository` tried to initialize before Firebase was ready

## Solutions Applied

### 1. Fixed Initialization Timing

**File**: `src/events/repositories/event.repository.ts`

**Change**: Implemented `OnModuleInit` to ensure Firebase is initialized before sample data loads.

```typescript
// Before
constructor(private readonly firebaseService: FirebaseService) {
  this.initializeSampleData(); // Called too early!
}

// After
constructor(private readonly firebaseService: FirebaseService) {}

async onModuleInit() {
  await this.initializeSampleData(); // Called after Firebase is ready
}
```

### 2. Fixed Path Resolution

**File**: `src/firebase/firebase.service.ts`

**Change**: Use `path.resolve()` to properly handle relative paths in Docker.

```typescript
// Before
const serviceAccount = require(serviceAccountPath);

// After
const absolutePath = path.resolve(process.cwd(), serviceAccountPath);
const serviceAccount = require(absolutePath);
```

### 3. Updated Docker Compose (Development)

**File**: `docker-compose.dev.yml`

**Changes**:
- Added `secrets/` folder mount
- Added `.env` file mount
- Changed to use `env_file` instead of hardcoded environment variables

```yaml
volumes:
  - ./src:/app/src
  - ./secrets:/app/secrets      # NEW: Mount secrets
  - ./.env:/app/.env             # NEW: Mount .env
  - /app/node_modules

env_file:
  - .env                         # NEW: Load from .env file
```

### 4. Updated Docker Compose (Production)

**File**: `docker-compose.prod.yml`

**Changes**:
- Added `secrets/` folder mount

```yaml
volumes:
  - ./secrets:/app/secrets       # NEW: Mount secrets
```

## How to Use

### Development with Docker

```bash
# 1. Ensure secrets folder exists with service account key
ls secrets/serviceAccountKey.json

# 2. Ensure .env is configured
cat .env | grep FIREBASE_SERVICE_ACCOUNT_PATH

# 3. Restart Docker containers
task docker-dev-down
task docker-dev

# 4. Check logs for successful initialization
docker logs dancee-server-dev
```

### Expected Log Output

```
[FirebaseService] Loading service account from: /app/secrets/serviceAccountKey.json
[FirebaseService] Firebase initialized with service account credentials
[FirebaseService] Firestore connection established
[EventRepository] Initializing Firestore with sample data...
[EventRepository] Successfully initialized 8 sample events
```

## Troubleshooting

### "Firestore not initialized"

**Cause**: Firebase initialization failed or timing issue.

**Solution**:
1. Check that `secrets/` folder is mounted
2. Verify service account path in `.env`
3. Check Docker logs for Firebase initialization errors
4. Restart containers

### "Cannot find module"

**Cause**: Service account file not accessible in Docker.

**Solution**:
1. Verify `secrets/` folder exists: `ls secrets/`
2. Verify file is in secrets: `ls secrets/*.json`
3. Check docker-compose.yml has volume mount
4. Restart containers: `task docker-dev-down && task docker-dev`

### "ENOENT: no such file or directory"

**Cause**: Path resolution issue in Docker.

**Solution**:
1. Use relative path: `./secrets/serviceAccountKey.json`
2. Don't use absolute paths like `/home/user/...`
3. Ensure `.env` is mounted in docker-compose.yml

## Files Modified

1. `src/firebase/firebase.service.ts` - Path resolution fix
2. `src/events/repositories/event.repository.ts` - Initialization timing fix
3. `docker-compose.dev.yml` - Added volume mounts
4. `docker-compose.prod.yml` - Added secrets mount

## Testing

```bash
# Stop existing containers
task docker-dev-down

# Start fresh
task docker-dev

# Watch logs
docker logs -f dancee-server-dev

# Test API
curl http://localhost:3001/api/events

# Check Swagger
open http://localhost:3001/api
```

## Production Deployment

For production (Cloud Run, Fly.io, etc.):
1. Don't mount secrets folder
2. Set `FIREBASE_SERVICE_ACCOUNT_PATH=` (empty)
3. Platform provides default credentials automatically

---

**Status**: ✅ Fixed and Tested
**Date**: February 11, 2026
