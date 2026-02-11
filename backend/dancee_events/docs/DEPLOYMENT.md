# Deployment Guide - Dancee Events API

Complete guide for deploying the Dancee Events API to production.

## Prerequisites

- Go 1.21+ installed
- Firebase project with Firestore enabled
- Firebase service account credentials
- Deployment platform account (Fly.io, Cloud Run, etc.)

## Environment Variables

The following environment variables are required for deployment:

### Required Variables

```env
# Server port (use 8080 for most cloud platforms)
PORT=8080

# Environment (production/development)
ENV=production

# CRITICAL: Google Cloud Project ID (always required)
GOOGLE_CLOUD_PROJECT=dancee-b5c0d

# Firebase credentials (choose one method)
# Method 1: JSON string (recommended for cloud deployment)
FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'

# Method 2: File path (for local/VM deployment)
FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/credentials.json
```

### Important Notes

1. **GOOGLE_CLOUD_PROJECT is REQUIRED** - Without this, Firebase initialization will fail
2. **Choose ONE credential method** - Either JSON string OR file path, not both
3. **JSON string takes priority** - If both are set, JSON string is used

## Deployment Options

### Option 1: Fly.io (Recommended)

Fly.io offers simple deployment with automatic scaling.

#### Initial Setup

1. Install Fly CLI:
```bash
curl -L https://fly.io/install.sh | sh
```

2. Login to Fly.io:
```bash
fly auth login
```

3. Create the app (first time only):
```bash
fly apps create dancee-events --org personal
```

4. Set secrets:
```bash
# Set Firebase credentials
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)" --app dancee-events

# Verify secrets are set
fly secrets list --app dancee-events
```

#### Deploy

**Linux/WSL:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Windows:**
```bash
deploy.bat
```

**Manual deployment:**
```bash
fly deploy --app dancee-events
```

#### Verify Deployment

```bash
# Check status
fly status --app dancee-events

# View logs
fly logs --app dancee-events

# Test the API
curl https://dancee-events.fly.dev/health
curl https://dancee-events.fly.dev/api/events/list
```

#### Fly.io Configuration

The `fly.toml` file contains:
- App name: `dancee-events`
- Region: `ams` (Amsterdam)
- Memory: 256MB
- Auto-scaling: Enabled
- HTTPS: Forced

### Option 2: Google Cloud Run

Deploy to Google Cloud Run for serverless deployment.

#### Setup

1. Install Google Cloud SDK:
```bash
curl https://sdk.cloud.google.com | bash
```

2. Login and set project:
```bash
gcloud auth login
gcloud config set project dancee-b5c0d
```

3. Build and push Docker image:
```bash
# Build image
docker build -t gcr.io/dancee-b5c0d/dancee-events:latest .

# Push to Google Container Registry
docker push gcr.io/dancee-b5c0d/dancee-events:latest
```

4. Deploy to Cloud Run:
```bash
gcloud run deploy dancee-events \
  --image gcr.io/dancee-b5c0d/dancee-events:latest \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars="ENV=production,GOOGLE_CLOUD_PROJECT=dancee-b5c0d" \
  --memory 256Mi \
  --cpu 1
```

Note: Cloud Run can use application default credentials, so you may not need to set FIREBASE_SERVICE_ACCOUNT_JSON.

### Option 3: Docker Compose

For self-hosted deployment.

#### docker-compose.yml

```yaml
version: '3.8'

services:
  dancee-events:
    build: .
    ports:
      - "8080:8080"
    environment:
      - PORT=8080
      - ENV=production
      - GOOGLE_CLOUD_PROJECT=dancee-b5c0d
      - FIREBASE_SERVICE_ACCOUNT_JSON=${FIREBASE_SERVICE_ACCOUNT_JSON}
    restart: unless-stopped
```

#### Deploy

```bash
# Set Firebase credentials
export FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"

# Start service
docker-compose up -d

# View logs
docker-compose logs -f
```

### Option 4: Traditional Server (VPS/VM)

Deploy to a traditional server or VM.

#### Setup

1. Copy files to server:
```bash
scp -r . user@server:/opt/dancee-events
```

2. SSH into server:
```bash
ssh user@server
cd /opt/dancee-events
```

3. Build the application:
```bash
go build -o dancee_events main.go
```

4. Create systemd service:
```bash
sudo nano /etc/systemd/system/dancee-events.service
```

```ini
[Unit]
Description=Dancee Events API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/dancee-events
ExecStart=/opt/dancee-events/dancee_events
Restart=always
Environment="PORT=8080"
Environment="ENV=production"
Environment="GOOGLE_CLOUD_PROJECT=dancee-b5c0d"
Environment="FIREBASE_SERVICE_ACCOUNT_PATH=/opt/dancee-events/secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json"

[Install]
WantedBy=multi-user.target
```

5. Start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable dancee-events
sudo systemctl start dancee-events
sudo systemctl status dancee-events
```

6. Setup Nginx reverse proxy:
```nginx
server {
    listen 80;
    server_name api.dancee.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Post-Deployment

### Health Check

```bash
curl https://your-domain.com/health
```

Expected response:
```json
{"status":"ok"}
```

### Test API Endpoints

```bash
# List events
curl https://your-domain.com/api/events/list

# List favorites
curl "https://your-domain.com/api/events/favorites?userId=user123"

# Add favorite
curl -X POST https://your-domain.com/api/events/favorites \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","eventId":"event-001"}'
```

### Monitor Logs

**Fly.io:**
```bash
fly logs --app dancee-events
```

**Cloud Run:**
```bash
gcloud run services logs read dancee-events --region europe-west1
```

**Docker:**
```bash
docker logs -f dancee-events
```

**Systemd:**
```bash
sudo journalctl -u dancee-events -f
```

## Troubleshooting

### Firebase Connection Error

**Error:** `project id is required to access Firestore`

**Solution:** Ensure `GOOGLE_CLOUD_PROJECT` environment variable is set:
```bash
# Fly.io
fly secrets set GOOGLE_CLOUD_PROJECT=dancee-b5c0d --app dancee-events

# Cloud Run
gcloud run services update dancee-events \
  --set-env-vars="GOOGLE_CLOUD_PROJECT=dancee-b5c0d"

# Docker
# Add to docker-compose.yml or .env file
```

### Credentials Not Found

**Error:** `Failed to initialize Firebase`

**Solution:** Verify credentials are set correctly:
```bash
# Check if secret is set (Fly.io)
fly secrets list --app dancee-events

# Should show: FIREBASE_SERVICE_ACCOUNT_JSON

# If not set, set it:
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"
```

### Port Binding Error

**Error:** `bind: address already in use`

**Solution:** Change the PORT environment variable:
```bash
export PORT=3003
```

### Memory Issues

If the service crashes due to memory:

**Fly.io:**
```bash
# Increase memory in fly.toml
[[vm]]
  memory_mb = 512  # Increase from 256

fly deploy
```

**Cloud Run:**
```bash
gcloud run services update dancee-events --memory 512Mi
```

## Security Checklist

- [ ] Firebase credentials are stored as secrets (not in code)
- [ ] HTTPS is enabled
- [ ] CORS is configured for specific origins (not `*` in production)
- [ ] Environment is set to `production`
- [ ] Firestore security rules are configured
- [ ] API rate limiting is implemented (if needed)
- [ ] Monitoring and alerting are set up

## Rollback

If deployment fails:

**Fly.io:**
```bash
# List releases
fly releases --app dancee-events

# Rollback to previous version
fly releases rollback <version> --app dancee-events
```

**Cloud Run:**
```bash
# List revisions
gcloud run revisions list --service dancee-events

# Route traffic to previous revision
gcloud run services update-traffic dancee-events \
  --to-revisions=<previous-revision>=100
```

## Scaling

**Fly.io:**
```bash
# Scale to multiple regions
fly scale count 2 --app dancee-events

# Scale memory
fly scale memory 512 --app dancee-events
```

**Cloud Run:**
```bash
# Set max instances
gcloud run services update dancee-events \
  --max-instances 10 \
  --min-instances 1
```

## Cost Optimization

**Fly.io:**
- Use auto-stop/auto-start for low traffic
- Start with 256MB memory
- Use shared CPU

**Cloud Run:**
- Set min instances to 0
- Use CPU throttling
- Set request timeout

**Estimated Costs:**
- Fly.io: $2-5/month (with auto-scaling)
- Cloud Run: $3-8/month (pay per use)
- VPS: $5-10/month (fixed cost)

## Next Steps

1. Set up monitoring (Sentry, Datadog, etc.)
2. Configure custom domain
3. Set up CI/CD pipeline
4. Implement rate limiting
5. Add API authentication
6. Set up backup strategy
