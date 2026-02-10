# Swagger Security - Quick Start Guide

**⚡ 5-Minute Setup for Production Swagger Protection**

## What This Does

Protects your Swagger API documentation (`/api`) with username and password in production environments.

- ✅ **Development**: No authentication (easy testing)
- 🔒 **Production**: Username + password required

## Setup Steps

### 1. Set Environment Variables

Create or edit your `.env` file:

```bash
NODE_ENV=production
SWAGGER_USER=your_username
SWAGGER_PASSWORD=your_secure_password
```

⚠️ **IMPORTANT**: Change `your_username` and `your_secure_password` to actual values!

### 2. Start the Server

```bash
task start
```

### 3. Access Swagger

Open browser: `http://localhost:3001/api`

Enter credentials when prompted.

## That's It! 🎉

Your Swagger documentation is now protected.

## Quick Test

**Without credentials:**
```bash
curl http://localhost:3001/api
# Returns: 401 Unauthorized
```

**With credentials:**
```bash
curl -u your_username:your_secure_password http://localhost:3001/api
# Returns: Swagger HTML
```

## Common Commands

### Development (No Auth)
```bash
export NODE_ENV=development
task dev
# Access: http://localhost:3001/api (no password needed)
```

### Production (With Auth)
```bash
export NODE_ENV=production
export SWAGGER_USER=admin
export SWAGGER_PASSWORD=mySecurePass123!
task start
# Access: http://localhost:3001/api (password required)
```

## Security Checklist

Before deploying:

- [ ] Changed default username
- [ ] Changed default password (use strong password!)
- [ ] Set `NODE_ENV=production`
- [ ] Tested authentication works
- [ ] Never committed `.env` file to git

## Need More Help?

See detailed documentation:
- [SWAGGER_SECURITY.md](./SWAGGER_SECURITY.md) - Complete guide
- [SWAGGER_SECURITY_EXAMPLES.md](./SWAGGER_SECURITY_EXAMPLES.md) - Usage examples

## Troubleshooting

**Problem**: Can't access Swagger
- **Solution**: Check `NODE_ENV` is set to `production`

**Problem**: Wrong credentials
- **Solution**: Verify `SWAGGER_USER` and `SWAGGER_PASSWORD` environment variables

**Problem**: Want to disable temporarily
- **Solution**: Set `NODE_ENV=development` (not recommended for production!)

---

**Quick Tip**: Use a password manager to generate and store strong passwords!
