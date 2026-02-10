# Environment Setup Guide

## Overview

This guide explains how to set up environment variables for the Dancee Server.

## Environment Files

### `.env.example`
- **Purpose**: Template file with example values
- **Location**: `backend/dancee_server/.env.example`
- **Git**: ✅ Committed to repository
- **Usage**: Copy this file to create your `.env`

### `.env`
- **Purpose**: Actual configuration with real values
- **Location**: `backend/dancee_server/.env`
- **Git**: ❌ NOT committed (in .gitignore)
- **Usage**: Your local/production configuration

## Quick Setup

### First Time Setup

```bash
# Navigate to dancee_server directory
cd backend/dancee_server

# Copy example file to create .env
cp .env.example .env

# Edit .env with your values
# (Use your preferred editor)
```

### For Windows (PowerShell)

```powershell
cd backend\dancee_server
copy .env.example .env
notepad .env
```

## Environment Variables

### Server Configuration

#### `PORT`
- **Description**: Port number for the server
- **Default**: `3001`
- **Example**: `PORT=3001`
- **Required**: No (uses default if not set)

#### `NODE_ENV`
- **Description**: Environment mode
- **Values**: `development`, `production`, `test`
- **Default**: `development`
- **Example**: `NODE_ENV=development`
- **Required**: No (but recommended for production)

**Impact:**
- `development`: Swagger accessible without authentication
- `production`: Swagger requires username/password
- `test`: Used for automated testing

### Swagger Authentication

#### `SWAGGER_USER`
- **Description**: Username for Swagger documentation access
- **Default**: `admin` (if not set)
- **Example**: `SWAGGER_USER=myusername`
- **Required**: No (but strongly recommended for production)
- **Active**: Only when `NODE_ENV=production`

#### `SWAGGER_PASSWORD`
- **Description**: Password for Swagger documentation access
- **Default**: `changeme` (if not set)
- **Example**: `SWAGGER_PASSWORD=mySecurePassword123!`
- **Required**: No (but strongly recommended for production)
- **Active**: Only when `NODE_ENV=production`

⚠️ **SECURITY WARNING**: Always change default credentials in production!

## Configuration Examples

### Development Environment

```bash
# .env for development
PORT=3001
NODE_ENV=development

# Swagger auth not needed in development
# (but can be set for testing)
SWAGGER_USER=admin
SWAGGER_PASSWORD=testPassword123!
```

**Behavior:**
- Server runs on port 3001
- Swagger accessible without password
- Hot reload enabled
- Detailed error messages

### Production Environment

```bash
# .env for production
PORT=3001
NODE_ENV=production

# REQUIRED: Change these!
SWAGGER_USER=your_production_username
SWAGGER_PASSWORD=your_very_secure_password_here
```

**Behavior:**
- Server runs on port 3001
- Swagger requires authentication
- Optimized performance
- Minimal error details

### Testing Environment

```bash
# .env for testing
PORT=3001
NODE_ENV=test

SWAGGER_USER=testuser
SWAGGER_PASSWORD=testpass
```

**Behavior:**
- Used by automated tests
- Test-specific configurations
- Isolated from development/production

## Loading Environment Variables

### Automatic Loading

NestJS automatically loads `.env` file when the application starts.

### Manual Loading (if needed)

```typescript
import { config } from 'dotenv';
config(); // Loads .env file
```

### Accessing Variables

```typescript
// In your code
const port = process.env.PORT ?? 3001;
const nodeEnv = process.env.NODE_ENV ?? 'development';
const swaggerUser = process.env.SWAGGER_USER ?? 'admin';
```

## Security Best Practices

### ✅ DO:

1. **Copy `.env.example` to `.env`**
   ```bash
   cp .env.example .env
   ```

2. **Change default credentials**
   ```bash
   SWAGGER_USER=your_unique_username
   SWAGGER_PASSWORD=your_strong_password
   ```

3. **Use strong passwords**
   - Minimum 16 characters
   - Mix of uppercase, lowercase, numbers, symbols
   - Generate with: `openssl rand -base64 32`

4. **Keep `.env` private**
   - Never commit to git
   - Never share via email/chat
   - Store in password manager

5. **Use different credentials per environment**
   - Development: Simple credentials
   - Production: Strong, unique credentials
   - Testing: Test-specific credentials

### ❌ DON'T:

1. **Don't commit `.env` to git**
   - Already in `.gitignore`
   - Contains sensitive data

2. **Don't use default credentials in production**
   - `admin` / `changeme` are NOT secure
   - Change immediately

3. **Don't share `.env` file**
   - Share `.env.example` instead
   - Each developer creates their own `.env`

4. **Don't hardcode values**
   - Always use environment variables
   - Never put credentials in source code

5. **Don't reuse passwords**
   - Use unique password for each service
   - Use password manager

## Verification

### Check if .env is loaded

```bash
# Start the server
task dev

# Check console output
# Should show: "🚀 Dancee Server is running on: http://localhost:3001"
```

### Check if .env is ignored by git

```bash
git status
# .env should NOT appear in the list

git check-ignore .env
# Should output: .env
```

### Test Swagger authentication

```bash
# Development (no auth)
export NODE_ENV=development
task dev
curl http://localhost:3001/api
# Should return HTML (Swagger UI)

# Production (with auth)
export NODE_ENV=production
task start
curl http://localhost:3001/api
# Should return 401 Unauthorized

curl -u admin:testPassword123! http://localhost:3001/api
# Should return HTML (Swagger UI)
```

## Troubleshooting

### Problem: Server won't start

**Solution**: Check `.env` file exists
```bash
ls -la .env
# Should show the file
```

### Problem: Environment variables not loading

**Solution**: Verify `.env` format
- No spaces around `=`
- No quotes needed (usually)
- One variable per line

**Correct:**
```bash
PORT=3001
NODE_ENV=development
```

**Incorrect:**
```bash
PORT = 3001
NODE_ENV = "development"
```

### Problem: Swagger still asks for password in development

**Solution**: Check `NODE_ENV`
```bash
echo $NODE_ENV
# Should be: development
```

### Problem: Can't access Swagger in production

**Solution**: Verify credentials
```bash
# Check if variables are set
echo $SWAGGER_USER
echo $SWAGGER_PASSWORD

# Test with curl
curl -u $SWAGGER_USER:$SWAGGER_PASSWORD http://localhost:3001/api
```

## Multiple Environments

### Using Multiple .env Files

```bash
.env                    # Default (development)
.env.development        # Development specific
.env.production         # Production specific
.env.test              # Testing specific
.env.local             # Local overrides (also in .gitignore)
```

### Loading Specific Environment

```bash
# Development
NODE_ENV=development npm run start:dev

# Production
NODE_ENV=production npm run start:prod

# Test
NODE_ENV=test npm run test
```

## Docker Configuration

### Using .env with Docker

```dockerfile
# Dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "start:prod"]
```

### docker-compose.yml

```yaml
version: '3.8'
services:
  dancee-server:
    build: .
    ports:
      - "3001:3001"
    env_file:
      - .env
    # Or use environment directly:
    environment:
      - NODE_ENV=production
      - PORT=3001
      - SWAGGER_USER=${SWAGGER_USER}
      - SWAGGER_PASSWORD=${SWAGGER_PASSWORD}
```

## CI/CD Configuration

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
env:
  NODE_ENV: production
  PORT: 3001
  SWAGGER_USER: ${{ secrets.SWAGGER_USER }}
  SWAGGER_PASSWORD: ${{ secrets.SWAGGER_PASSWORD }}
```

### GitLab CI

```yaml
# .gitlab-ci.yml
variables:
  NODE_ENV: production
  PORT: "3001"
  SWAGGER_USER: $SWAGGER_USER
  SWAGGER_PASSWORD: $SWAGGER_PASSWORD
```

## Related Documentation

- [Swagger Security Guide](./SWAGGER_SECURITY.md)
- [Swagger Security Quick Start](./SWAGGER_SECURITY_QUICKSTART.md)
- [Deployment Checklist](./SWAGGER_SECURITY_CHECKLIST.md)

## Quick Reference

```bash
# Create .env from example
cp .env.example .env

# Edit .env
nano .env  # or vim, code, notepad, etc.

# Verify .env is ignored
git check-ignore .env

# Start server
task dev  # development
task start  # production

# Test configuration
curl http://localhost:3001/api
```

---

**Remember**: `.env` contains sensitive data. Never commit it to version control!
