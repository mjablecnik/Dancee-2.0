# Middleware Testing Guide

## SwaggerAuthMiddleware Testing

### Running Tests

```bash
# Run all middleware tests
npm test -- swagger-auth.middleware.spec.ts

# Run with coverage
npm test -- swagger-auth.middleware.spec.ts --coverage

# Run in watch mode during development
npm test -- swagger-auth.middleware.spec.ts --watch
```

### Test Structure

The middleware tests are organized into three main sections:

#### 1. Development Environment Tests
- Verifies authentication is bypassed in development mode
- Tests behavior when `NODE_ENV` is not set

#### 2. Production Environment Tests
- Validates 401 responses for missing/invalid credentials
- Tests correct credential acceptance
- Verifies default credentials fallback

#### 3. Path Detection Tests
- Ensures `/api` and `/api/*` routes are protected
- Verifies `/events/*` routes remain public
- Tests query string handling
- Validates fallback to `req.url` when needed

### Test Coverage

Current test coverage: **16 tests, all passing**

```
✓ Development Environment (2 tests)
✓ Production Environment (5 tests)
✓ Path Detection (9 tests)
```

### Manual Testing

#### Development Mode

```bash
# Start server in development
npm run dev

# Test Swagger (should be accessible)
curl http://localhost:3001/api

# Test events endpoint (should be accessible)
curl http://localhost:3001/events/list
```

#### Production Mode

```bash
# Start server in production
NODE_ENV=production npm run start

# Test Swagger without auth (should return 401)
curl -i http://localhost:3001/api

# Test Swagger with auth (should work)
curl -u admin:changeme http://localhost:3001/api

# Test events endpoint (should work without auth)
curl http://localhost:3001/events/list
```

### Expected Responses

#### Protected Route (Production, No Auth)
```
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Swagger Documentation"
Authentication required
```

#### Protected Route (Production, Valid Auth)
```
HTTP/1.1 200 OK
[Swagger UI HTML]
```

#### Public Route (Always)
```
HTTP/1.1 200 OK
[API Response]
```

## Adding New Middleware Tests

When adding new middleware or modifying existing ones:

1. **Create test file**: `middleware-name.spec.ts`
2. **Mock Express objects**: Request, Response, NextFunction
3. **Test all paths**: Success, failure, edge cases
4. **Test environment variations**: Development vs Production
5. **Test path detection**: Ensure correct routes are affected
6. **Run tests**: Verify all pass before committing

### Example Test Template

```typescript
import { YourMiddleware } from './your-middleware';
import { Request, Response } from 'express';

describe('YourMiddleware', () => {
  let middleware: YourMiddleware;
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let nextFunction: jest.Mock;

  beforeEach(() => {
    middleware = new YourMiddleware();
    mockRequest = {
      originalUrl: '/test',
      url: '/test',
      headers: {},
    };
    mockResponse = {
      status: jest.fn().mockReturnThis(),
      send: jest.fn().mockReturnThis(),
    };
    nextFunction = jest.fn();
  });

  it('should do something', () => {
    middleware.use(
      mockRequest as Request,
      mockResponse as Response,
      nextFunction,
    );

    expect(nextFunction).toHaveBeenCalled();
  });
});
```

## Continuous Integration

Tests are automatically run on:
- Pre-commit hooks (if configured)
- Pull request creation
- Deployment pipeline

Ensure all tests pass before merging to main branch.

## Troubleshooting

### Tests Failing Locally

1. **Clear Jest cache**: `npm test -- --clearCache`
2. **Reinstall dependencies**: `rm -rf node_modules && npm install`
3. **Check Node version**: Ensure compatible version (18+)

### Mock Issues

If mocks aren't working:
- Verify all required properties are mocked
- Check TypeScript types match Express types
- Use `Partial<Type>` for partial mocks

### Path Detection Issues

If path detection tests fail:
- Ensure `originalUrl` and `url` are both set in mocks
- Verify query string handling with `split('?')[0]`
- Check for trailing slashes in path comparisons

## Related Documentation

- [Swagger Authentication Fix](./SWAGGER_AUTH_FIX.md)
- [NestJS Middleware Guide](https://docs.nestjs.com/middleware)
- [Jest Testing Guide](https://jestjs.io/docs/getting-started)
