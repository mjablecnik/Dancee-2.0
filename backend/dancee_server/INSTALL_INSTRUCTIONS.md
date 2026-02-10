# Installation Instructions

## After Pulling Latest Changes

The project now uses `express-basic-auth` for Swagger authentication. You need to install the new dependency:

```bash
cd backend/dancee_server
npm install
```

This will install:
- `express-basic-auth` - Basic authentication middleware
- `@types/express-basic-auth` - TypeScript types

## Running the Application

### Development Mode (No Authentication)
```bash
npm run start:dev
```

### Production Mode (With Swagger Authentication)
```bash
NODE_ENV=production npm run start:prod
```

## Docker

### Rebuild Docker Image
```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

The Docker build will automatically install all dependencies including the new `express-basic-auth` package.

## Verification

After installation, verify the setup:

1. **Start the server:**
   ```bash
   npm run start:dev
   ```

2. **Test Swagger (Development - No Auth):**
   - Visit: http://localhost:3001/api
   - Should load without authentication

3. **Test Events API (Always Public):**
   - Visit: http://localhost:3001/events/list
   - Should return events without authentication

4. **Test Production Mode:**
   ```bash
   NODE_ENV=production npm run start:prod
   ```
   - Visit: http://localhost:3001/api
   - Should prompt for username/password
   - Default: admin/changeme (change in .env file)

## Environment Variables

Ensure your `.env` file contains:

```bash
NODE_ENV=production
PORT=3001
SWAGGER_USER=admin
SWAGGER_PASSWORD=your_secure_password
```

## Troubleshooting

### Module Not Found Error
If you see: `Cannot find module 'express-basic-auth'`

**Solution:**
```bash
npm install
```

### TypeScript Errors
If you see type errors related to `express-basic-auth`:

**Solution:**
```bash
npm install --save-dev @types/express-basic-auth
```

### Docker Build Fails
If Docker build fails with dependency errors:

**Solution:**
```bash
# Clean Docker cache
docker-compose -f docker-compose.prod.yml down
docker system prune -a
docker-compose -f docker-compose.prod.yml up -d --build
```
