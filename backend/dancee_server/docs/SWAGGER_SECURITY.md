# Swagger Documentation Security

This guide explains how Swagger API documentation is protected in production environments.

## Overview

The Swagger documentation at `/api` is protected with **HTTP Basic Authentication** in production. This ensures that only authorized users can access the API documentation.

## Security Behavior

### Development Environment
- **No authentication required** - Swagger is freely accessible
- Access directly at: `http://localhost:3001/api`

### Production Environment
- **Authentication required** - Username and password needed
- Browser will prompt for credentials
- Unauthorized access returns `401 Unauthorized`

## Configuration

### Environment Variables

Add these variables to your `.env` file or environment configuration:

```bash
# Required for production
NODE_ENV=production

# Swagger credentials (CHANGE THESE!)
SWAGGER_USER=your_username
SWAGGER_PASSWORD=your_secure_password
```

### Default Credentials

If not configured, the system uses these defaults (NOT SECURE):
- **Username**: `admin`
- **Password**: `changeme`

⚠️ **CRITICAL**: Always change these in production!

## Setup Instructions

### 1. Local Development

No setup needed - authentication is disabled in development.

```bash
# Just run the server
task dev
```

### 2. Production Deployment

**Step 1**: Set environment variables

```bash
export NODE_ENV=production
export SWAGGER_USER=your_username
export SWAGGER_PASSWORD=your_secure_password
```

**Step 2**: Start the server

```bash
task start
```

**Step 3**: Access Swagger

Navigate to `https://your-domain.com/api` and enter credentials when prompted.

## Accessing Protected Swagger

### Browser Access

1. Navigate to `/api` endpoint
2. Browser shows authentication dialog
3. Enter username and password
4. Access granted if credentials are correct

### Programmatic Access

Use HTTP Basic Authentication header:

```bash
# Using curl
curl -u username:password https://your-domain.com/api

# Using Authorization header
curl -H "Authorization: Basic $(echo -n 'username:password' | base64)" \
  https://your-domain.com/api
```

### Testing Tools (Postman, Insomnia)

1. Select "Basic Auth" authentication type
2. Enter username and password
3. Tool automatically adds Authorization header

## Security Best Practices

### ✅ DO:
- **Change default credentials** immediately in production
- **Use strong passwords** (minimum 16 characters, mixed case, numbers, symbols)
- **Store credentials securely** (environment variables, secrets manager)
- **Rotate credentials regularly** (every 90 days recommended)
- **Use HTTPS** in production (never HTTP)
- **Limit access** to only necessary team members
- **Monitor access logs** for unauthorized attempts

### ❌ DON'T:
- Don't commit credentials to version control
- Don't use default credentials in production
- Don't share credentials via insecure channels (email, chat)
- Don't use the same password for multiple services
- Don't disable authentication in production

## Implementation Details

### Middleware

The security is implemented via `SwaggerAuthMiddleware`:

```typescript
// src/middleware/swagger-auth.middleware.ts
@Injectable()
export class SwaggerAuthMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Skip in development
    if (process.env.NODE_ENV !== 'production') {
      return next();
    }
    
    // Verify credentials
    // ...
  }
}
```

### Protected Routes

The middleware protects these routes:
- `/api` - Swagger UI
- `/api-json` - OpenAPI JSON specification

### How It Works

1. **Request received** for `/api` or `/api-json`
2. **Check environment** - Skip if development
3. **Parse Authorization header** - Extract credentials
4. **Verify credentials** - Compare with environment variables
5. **Grant or deny access** - Return 401 if invalid

## Troubleshooting

### Problem: Can't access Swagger in production

**Solution**: Check environment variables are set correctly

```bash
echo $NODE_ENV
echo $SWAGGER_USER
# Don't echo password in production!
```

### Problem: Browser keeps asking for credentials

**Solution**: 
- Clear browser cache and cookies
- Verify credentials are correct
- Check server logs for authentication errors

### Problem: Getting 401 even with correct credentials

**Solution**:
- Ensure `NODE_ENV=production` is set
- Verify no typos in username/password
- Check middleware is properly registered in `app.module.ts`

### Problem: Want to disable authentication temporarily

**Solution**: Set `NODE_ENV=development` (NOT recommended for production)

```bash
export NODE_ENV=development
```

## Advanced Configuration

### Custom Authentication Logic

To modify authentication behavior, edit:
```
src/middleware/swagger-auth.middleware.ts
```

### Multiple Users

For multiple users, consider:
1. **Environment variables with multiple credentials**
2. **Database-backed authentication**
3. **Integration with existing auth system**
4. **OAuth/JWT for API documentation**

### IP Whitelisting

Add IP restrictions in middleware:

```typescript
const allowedIPs = ['192.168.1.100', '10.0.0.50'];
const clientIP = req.ip;

if (!allowedIPs.includes(clientIP)) {
  return res.status(403).send('Forbidden');
}
```

## Security Checklist

Before deploying to production:

- [ ] Changed default SWAGGER_USER
- [ ] Changed default SWAGGER_PASSWORD
- [ ] Used strong password (16+ characters)
- [ ] Set NODE_ENV=production
- [ ] Verified authentication works
- [ ] Enabled HTTPS
- [ ] Documented credentials securely
- [ ] Shared credentials only with authorized team
- [ ] Set up credential rotation schedule
- [ ] Configured monitoring/logging

## Related Documentation

- [Swagger Setup Guide](./SWAGGER_SETUP.md)
- [Swagger Usage Examples](./SWAGGER.md)
- [Deployment Guide](./DEPLOYMENT.md)

## Support

For security concerns or questions:
1. Check this documentation
2. Review middleware implementation
3. Consult team security guidelines
4. Contact system administrator

---

**Remember**: Security is only as strong as your weakest credential. Always use strong, unique passwords and follow security best practices.
