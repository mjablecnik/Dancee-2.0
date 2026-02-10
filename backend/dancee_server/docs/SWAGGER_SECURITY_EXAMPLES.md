# Swagger Security - Usage Examples

This document provides practical examples for accessing protected Swagger documentation.

## Quick Start

### Development (No Authentication)

```bash
# Start server in development mode
task dev

# Access Swagger - no credentials needed
# Open in browser: http://localhost:3001/api
```

### Production (With Authentication)

```bash
# Set environment variables
export NODE_ENV=production
export SWAGGER_USER=myusername
export SWAGGER_PASSWORD=mySecurePassword123!

# Start server
task start

# Access Swagger - credentials required
# Open in browser: http://localhost:3001/api
# Enter username and password when prompted
```

## Browser Access Examples

### Chrome/Edge/Firefox

1. Navigate to `http://localhost:3001/api` (or your production URL)
2. Browser displays authentication dialog:
   ```
   Authentication Required
   The site says: "Swagger Documentation"
   
   Username: [          ]
   Password: [          ]
   
   [Cancel] [Sign In]
   ```
3. Enter your credentials
4. Click "Sign In"
5. Swagger UI loads

### Saving Credentials

Most browsers offer to save credentials:
- ✅ Safe for development environments
- ❌ Not recommended for production (use password manager instead)

## Command Line Examples

### Using curl

**Basic authentication:**
```bash
curl -u username:password http://localhost:3001/api
```

**With Authorization header:**
```bash
# Generate base64 encoded credentials
echo -n 'username:password' | base64
# Output: dXNlcm5hbWU6cGFzc3dvcmQ=

# Use in request
curl -H "Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" \
  http://localhost:3001/api
```

**Save response to file:**
```bash
curl -u username:password http://localhost:3001/api > swagger.html
```

### Using wget

```bash
wget --user=username --password=password http://localhost:3001/api
```

### Using httpie

```bash
http -a username:password http://localhost:3001/api
```

## API Testing Tools

### Postman

**Setup:**
1. Create new request
2. Set URL: `http://localhost:3001/api`
3. Go to "Authorization" tab
4. Select "Basic Auth" from dropdown
5. Enter username and password
6. Send request

**Environment Variables:**
```json
{
  "swagger_username": "myusername",
  "swagger_password": "mySecurePassword123!"
}
```

Use in request:
- Username: `{{swagger_username}}`
- Password: `{{swagger_password}}`

### Insomnia

**Setup:**
1. Create new request
2. Set URL: `http://localhost:3001/api`
3. Click "Auth" dropdown
4. Select "Basic Auth"
5. Enter username and password
6. Send request

### Thunder Client (VS Code)

**Setup:**
1. Create new request
2. Set URL: `http://localhost:3001/api`
3. Go to "Auth" tab
4. Select "Basic" from dropdown
5. Enter username and password
6. Send request

## Programming Examples

### JavaScript/TypeScript (Node.js)

**Using fetch:**
```javascript
const username = 'myusername';
const password = 'mySecurePassword123!';
const credentials = Buffer.from(`${username}:${password}`).toString('base64');

const response = await fetch('http://localhost:3001/api', {
  headers: {
    'Authorization': `Basic ${credentials}`
  }
});

const html = await response.text();
console.log(html);
```

**Using axios:**
```javascript
const axios = require('axios');

const response = await axios.get('http://localhost:3001/api', {
  auth: {
    username: 'myusername',
    password: 'mySecurePassword123!'
  }
});

console.log(response.data);
```

### Python

**Using requests:**
```python
import requests

response = requests.get(
    'http://localhost:3001/api',
    auth=('myusername', 'mySecurePassword123!')
)

print(response.text)
```

**Using urllib:**
```python
import urllib.request
import base64

username = 'myusername'
password = 'mySecurePassword123!'
credentials = f'{username}:{password}'
encoded = base64.b64encode(credentials.encode()).decode()

request = urllib.request.Request('http://localhost:3001/api')
request.add_header('Authorization', f'Basic {encoded}')

response = urllib.request.urlopen(request)
print(response.read().decode())
```

### Go

```go
package main

import (
    "fmt"
    "io"
    "net/http"
)

func main() {
    client := &http.Client{}
    req, _ := http.NewRequest("GET", "http://localhost:3001/api", nil)
    req.SetBasicAuth("myusername", "mySecurePassword123!")
    
    resp, err := client.Do(req)
    if err != nil {
        panic(err)
    }
    defer resp.Body.Close()
    
    body, _ := io.ReadAll(resp.Body)
    fmt.Println(string(body))
}
```

### PHP

```php
<?php
$username = 'myusername';
$password = 'mySecurePassword123!';

$context = stream_context_create([
    'http' => [
        'header' => 'Authorization: Basic ' . 
                    base64_encode("$username:$password")
    ]
]);

$response = file_get_contents(
    'http://localhost:3001/api',
    false,
    $context
);

echo $response;
?>
```

## Docker Examples

### Environment Variables in docker-compose.yml

```yaml
version: '3.8'

services:
  dancee-server:
    build: .
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - SWAGGER_USER=admin
      - SWAGGER_PASSWORD=${SWAGGER_PASSWORD}
    env_file:
      - .env.production
```

### Docker Run Command

```bash
docker run -d \
  -p 3001:3001 \
  -e NODE_ENV=production \
  -e SWAGGER_USER=admin \
  -e SWAGGER_PASSWORD=mySecurePassword123! \
  dancee-server
```

### Docker Secrets (Swarm)

```yaml
version: '3.8'

services:
  dancee-server:
    image: dancee-server
    secrets:
      - swagger_user
      - swagger_password
    environment:
      - NODE_ENV=production
      - SWAGGER_USER_FILE=/run/secrets/swagger_user
      - SWAGGER_PASSWORD_FILE=/run/secrets/swagger_password

secrets:
  swagger_user:
    external: true
  swagger_password:
    external: true
```

## CI/CD Examples

### GitHub Actions

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to production
        env:
          NODE_ENV: production
          SWAGGER_USER: ${{ secrets.SWAGGER_USER }}
          SWAGGER_PASSWORD: ${{ secrets.SWAGGER_PASSWORD }}
        run: |
          npm run build
          npm run start:prod
```

### GitLab CI

```yaml
deploy:
  stage: deploy
  script:
    - npm run build
    - npm run start:prod
  variables:
    NODE_ENV: production
    SWAGGER_USER: $SWAGGER_USER
    SWAGGER_PASSWORD: $SWAGGER_PASSWORD
  only:
    - main
```

## Testing Examples

### Integration Test with Authentication

```typescript
import * as request from 'supertest';
import { Test } from '@nestjs/testing';
import { AppModule } from '../src/app.module';
import { INestApplication } from '@nestjs/common';

describe('Swagger Authentication (e2e)', () => {
  let app: INestApplication;
  const username = 'testuser';
  const password = 'testpass';

  beforeAll(async () => {
    process.env.NODE_ENV = 'production';
    process.env.SWAGGER_USER = username;
    process.env.SWAGGER_PASSWORD = password;

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    await app.init();
  });

  it('should return 401 without credentials', () => {
    return request(app.getHttpServer())
      .get('/api')
      .expect(401);
  });

  it('should return 401 with wrong credentials', () => {
    return request(app.getHttpServer())
      .get('/api')
      .auth('wrong', 'credentials')
      .expect(401);
  });

  it('should return 200 with correct credentials', () => {
    return request(app.getHttpServer())
      .get('/api')
      .auth(username, password)
      .expect(200);
  });

  afterAll(async () => {
    await app.close();
  });
});
```

## Troubleshooting Examples

### Check if Authentication is Active

```bash
# Should return 401 in production
curl -I http://localhost:3001/api

# Expected response:
# HTTP/1.1 401 Unauthorized
# WWW-Authenticate: Basic realm="Swagger Documentation"
```

### Test Credentials

```bash
# Test with credentials
curl -u username:password -I http://localhost:3001/api

# Expected response if correct:
# HTTP/1.1 200 OK

# Expected response if incorrect:
# HTTP/1.1 401 Unauthorized
```

### Debug Environment Variables

```bash
# Check if variables are set
echo "NODE_ENV: $NODE_ENV"
echo "SWAGGER_USER: $SWAGGER_USER"
# Don't echo password in production!

# Or in Node.js
node -e "console.log('NODE_ENV:', process.env.NODE_ENV)"
node -e "console.log('SWAGGER_USER:', process.env.SWAGGER_USER)"
```

## Security Best Practices

### Generate Strong Password

```bash
# Using openssl
openssl rand -base64 32

# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"

# Using Python
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Store Credentials Securely

**Use environment variables:**
```bash
# .env.production (never commit!)
NODE_ENV=production
SWAGGER_USER=admin
SWAGGER_PASSWORD=generated_secure_password_here
```

**Use secrets manager:**
```bash
# AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id swagger-credentials

# HashiCorp Vault
vault kv get secret/swagger-credentials
```

## Related Documentation

- [SWAGGER_SECURITY.md](./SWAGGER_SECURITY.md) - Complete security guide
- [SWAGGER.md](./SWAGGER.md) - Swagger usage guide
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Deployment instructions

---

**Remember**: Never commit credentials to version control. Always use environment variables or secrets management systems.
