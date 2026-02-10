# Swagger Authentication Middleware Fix

## Problem Description

The `SwaggerAuthMiddleware` was experiencing a critical bug where `req.path` always returned `"/"` regardless of the actual request path. This caused the middleware to fail at correctly identifying which routes should be protected with authentication.

### Symptoms

```
Testing path:  /
Testing path:  /
Testing path:  /
```

All requests showed path as `"/"`, including:
- `/api` (Swagger UI)
- `/events/list` (Events API)
- `/events/favorites` (Favorites API)

## Root Cause

When middleware is applied globally in NestJS using `.forRoutes('*')`, the Express `req.path` property gets normalized and may not contain the full path. This is a known behavior in Express/NestJS when middleware is applied at the application level.

## Solution

**Changed from:** `req.path`  
**Changed to:** `req.originalUrl || req.url`

### Code Changes

**Before:**
```typescript
const path = req.path;
```

**After:**
```typescript
const fullUrl = req.originalUrl || req.url;
// Remove query string if present
const path = fullUrl.split('?')[0];
```

### Why This Works

- **`req.originalUrl`**: Contains the full original URL path including query strings
- **`req.url`**: Fallback that also contains the full URL path
- **Query string handling**: Split by `?` to get clean path for comparison

## Expected Behavior

After the fix, the middleware correctly:

### ✅ Protects Swagger Routes (Production Only)
- `/api` - Requires basic auth
- `/api/` - Requires basic auth
- `/api/*` - All Swagger static assets require basic auth

### ✅ Allows Public Routes
- `/events/list` - Public access
- `/events/favorites` - Public access
- `/scraper/*` - Public access
- `/api-json` - Public access (OpenAPI spec)

### ✅ Development Mode
- All routes accessible without authentication when `NODE_ENV !== 'production'`

## Testing

All 16 unit tests pass, including new path detection tests:

```bash
npm test -- swagger-auth.middleware.spec.ts
```

### Test Coverage

- ✅ Development environment bypass
- ✅ Production authentication enforcement
- ✅ Correct credentials acceptance
- ✅ Incorrect credentials rejection
- ✅ Path detection for all route types
- ✅ Query string handling
- ✅ Fallback to `req.url` when `originalUrl` unavailable

## Configuration

### Environment Variables

```bash
# Production mode (enables authentication)
NODE_ENV=production

# Swagger credentials (defaults shown)
SWAGGER_USER=admin
SWAGGER_PASSWORD=changeme
```

### Docker/Fly.io Deployment

Ensure these environment variables are set in your deployment:

```yaml
# fly.toml
[env]
  NODE_ENV = "production"

# Set secrets via Fly CLI
fly secrets set SWAGGER_USER=your_username
fly secrets set SWAGGER_PASSWORD=your_secure_password
```

## Verification

To verify the fix is working:

1. **Start the server:**
   ```bash
   npm run dev
   ```

2. **Check console logs:**
   ```
   Testing path:  /api
   Testing path:  /events/list
   Testing path:  /events/favorites
   ```

3. **Test endpoints:**
   - Visit `http://localhost:3001/api` - Should show Swagger UI (no auth in dev)
   - Visit `http://localhost:3001/events/list` - Should return events (public)
   - Visit `http://localhost:3001/events/favorites` - Should return favorites (public)

4. **Test production mode:**
   ```bash
   NODE_ENV=production npm run start
   ```
   - Visit `http://localhost:3001/api` - Should prompt for basic auth
   - Visit `http://localhost:3001/events/list` - Should work without auth

## Related Files

- `src/middleware/swagger-auth.middleware.ts` - Main middleware implementation
- `src/middleware/swagger-auth.middleware.spec.ts` - Unit tests
- `src/app.module.ts` - Middleware registration
- `src/main.ts` - Swagger setup

## References

- [Express Request Object Documentation](https://expressjs.com/en/api.html#req)
- [NestJS Middleware Documentation](https://docs.nestjs.com/middleware)
- [Swagger Basic Authentication](https://swagger.io/docs/specification/authentication/basic-authentication/)
