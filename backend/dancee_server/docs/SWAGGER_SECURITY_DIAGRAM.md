# Swagger Security - How It Works

## Authentication Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Request                             │
│                    GET /api or /api-json                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   SwaggerAuthMiddleware                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │ Check NODE_ENV │
                    └────────┬───────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
        ┌──────────────┐          ┌──────────────┐
        │ Development  │          │  Production  │
        └──────┬───────┘          └──────┬───────┘
               │                         │
               ▼                         ▼
        ┌──────────────┐          ┌──────────────────────┐
        │ Allow Access │          │ Check Authorization  │
        │  (No Auth)   │          │      Header          │
        └──────┬───────┘          └──────┬───────────────┘
               │                         │
               │                         │
               │              ┌──────────┴──────────┐
               │              │                     │
               │              ▼                     ▼
               │      ┌──────────────┐      ┌──────────────┐
               │      │ Header Found │      │ No Header    │
               │      └──────┬───────┘      └──────┬───────┘
               │             │                     │
               │             ▼                     ▼
               │      ┌──────────────┐      ┌──────────────┐
               │      │ Parse Base64 │      │ Return 401   │
               │      │  Credentials │      │ Unauthorized │
               │      └──────┬───────┘      └──────────────┘
               │             │
               │             ▼
               │      ┌──────────────────┐
               │      │ Verify Username  │
               │      │   and Password   │
               │      └──────┬───────────┘
               │             │
               │    ┌────────┴────────┐
               │    │                 │
               │    ▼                 ▼
               │ ┌────────┐      ┌────────┐
               │ │ Valid  │      │Invalid │
               │ └───┬────┘      └───┬────┘
               │     │               │
               │     ▼               ▼
               │ ┌────────┐      ┌────────┐
               │ │ Allow  │      │Return  │
               │ │ Access │      │  401   │
               │ └───┬────┘      └────────┘
               │     │
               └─────┴──────────────────────┐
                     │                      │
                     ▼                      ▼
              ┌──────────────┐      ┌──────────────┐
              │ Swagger UI   │      │ 401 Response │
              │   Loaded     │      │   Returned   │
              └──────────────┘      └──────────────┘
```

## Environment-Based Behavior

### Development Mode

```
Request → Middleware → Check NODE_ENV → "development" → Allow Access → Swagger UI
```

**Characteristics:**
- ✅ No authentication required
- ✅ Fast development workflow
- ✅ Easy testing
- ⚠️ Not secure for production

### Production Mode

```
Request → Middleware → Check NODE_ENV → "production" → Check Auth Header
                                                              │
                                                    ┌─────────┴─────────┐
                                                    │                   │
                                                    ▼                   ▼
                                              Valid Creds         Invalid Creds
                                                    │                   │
                                                    ▼                   ▼
                                              Swagger UI          401 Unauthorized
```

**Characteristics:**
- 🔒 Authentication required
- 🔒 Credentials verified
- 🔒 Unauthorized access blocked
- ✅ Production-ready security

## HTTP Basic Authentication

### Request Without Credentials

```http
GET /api HTTP/1.1
Host: localhost:3001
```

**Response:**
```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Swagger Documentation"
Content-Type: text/plain

Authentication required
```

### Request With Credentials

```http
GET /api HTTP/1.1
Host: localhost:3001
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: text/html

<!DOCTYPE html>
<html>
  <!-- Swagger UI HTML -->
</html>
```

## Credential Encoding

### How Basic Auth Works

```
1. Combine username and password with colon:
   username:password

2. Encode to Base64:
   Base64("username:password") = "dXNlcm5hbWU6cGFzc3dvcmQ="

3. Add to Authorization header:
   Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

### Example

```javascript
// JavaScript
const username = 'admin';
const password = 'secret123';
const credentials = btoa(`${username}:${password}`);
// Result: "YWRtaW46c2VjcmV0MTIz"

const authHeader = `Basic ${credentials}`;
// Result: "Basic YWRtaW46c2VjcmV0MTIz"
```

## Middleware Implementation

### File Structure

```
src/
├── middleware/
│   ├── swagger-auth.middleware.ts       # Authentication logic
│   └── swagger-auth.middleware.spec.ts  # Unit tests
└── app.module.ts                        # Middleware registration
```

### Key Components

**1. Middleware Class:**
```typescript
@Injectable()
export class SwaggerAuthMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Authentication logic
  }
}
```

**2. Module Registration:**
```typescript
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(SwaggerAuthMiddleware).forRoutes('api', 'api-json');
  }
}
```

**3. Protected Routes:**
- `/api` - Swagger UI
- `/api-json` - OpenAPI specification

## Security Layers

```
┌─────────────────────────────────────────┐
│         Application Layer               │
│  (Your API endpoints - not protected)   │
└─────────────────────────────────────────┘
                  │
┌─────────────────────────────────────────┐
│      Documentation Layer (Protected)    │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  SwaggerAuthMiddleware            │ │
│  │  - Environment check              │ │
│  │  - Credential verification        │ │
│  │  - Access control                 │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Routes: /api, /api-json               │
└─────────────────────────────────────────┘
                  │
┌─────────────────────────────────────────┐
│         Network Layer                   │
│  (HTTPS, Firewall, etc.)               │
└─────────────────────────────────────────┘
```

## Configuration Flow

```
Environment Variables → Middleware → Authentication Decision
        │
        ├─ NODE_ENV ────────────► Determines if auth is active
        ├─ SWAGGER_USER ────────► Username for verification
        └─ SWAGGER_PASSWORD ────► Password for verification
```

## Browser Authentication Dialog

When accessing protected Swagger in a browser:

```
┌─────────────────────────────────────────┐
│  Authentication Required                │
│                                         │
│  The site says: "Swagger Documentation" │
│                                         │
│  Username: [____________________]       │
│  Password: [____________________]       │
│                                         │
│  [ ] Remember my credentials            │
│                                         │
│  [Cancel]  [Sign In]                    │
└─────────────────────────────────────────┘
```

## Testing Flow

```
Unit Tests → Middleware Logic → Integration Tests → Manual Testing
     │              │                   │                 │
     ▼              ▼                   ▼                 ▼
Test cases    Auth logic         E2E scenarios    Browser testing
- Dev mode    - Header parse     - API calls      - Real credentials
- Prod mode   - Credential       - Auth flow      - User experience
- Valid auth    verification     - Error cases    - Edge cases
- Invalid auth
```

## Related Documentation

- [SWAGGER_SECURITY.md](./SWAGGER_SECURITY.md) - Complete security guide
- [SWAGGER_SECURITY_QUICKSTART.md](./SWAGGER_SECURITY_QUICKSTART.md) - Quick setup
- [SWAGGER_SECURITY_EXAMPLES.md](./SWAGGER_SECURITY_EXAMPLES.md) - Usage examples

---

**Visual Summary:**

```
Development:  Request → ✅ Allow → Swagger UI
Production:   Request → 🔒 Check Auth → ✅/❌ → Swagger UI / 401
```
