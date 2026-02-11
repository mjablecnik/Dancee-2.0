# Fly.io Deployment Guide

Complete guide for deploying Dancee Server to Fly.io with Firestore.

## Prerequisites

- Fly.io account: https://fly.io/
- Fly CLI installed: `curl -L https://fly.io/install.sh | sh`
- Firebase project with Firestore enabled
- Service account key file

## Initial Setup

### 1. Login to Fly.io

```bash
fly auth login
```

### 2. Verify fly.toml Configuration

Your `fly.toml` should look like this:

```toml
app = 'dancee-server'
primary_region = 'fra'

[build]

[env]
  NODE_ENV = 'production'

[http_service]
  internal_port = 3001
  force_https = true
  auto_stop_machines = 'stop'
  auto_start_machines = true
  min_machines_running = 0
  processes = ['app']

[[vm]]
  memory = '512mb'
  cpus = 1
  memory_mb = 512
```

## Firebase Configuration

### Option 1: Service Account JSON (Recommended)

Store the entire service account JSON as a secret:

```bash
# Set Firebase credentials as secret
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"

# Ensure path is empty (JSON takes priority)
fly secrets set FIREBASE_SERVICE_ACCOUNT_PATH=""
```

### Option 2: Application Default Credentials

If you prefer, you can use Fly.io's Google Cloud integration (more complex setup).

## Set Other Secrets

```bash
# Swagger authentication (change these!)
fly secrets set SWAGGER_USER=admin
fly secrets set SWAGGER_PASSWORD=your-secure-password-here

# Port (optional, defaults to 3001)
fly secrets set PORT=3001
```

## Verify Secrets

```bash
fly secrets list
```

Should show:
```
NAME                              DIGEST
FIREBASE_SERVICE_ACCOUNT_JSON     xxxxx
FIREBASE_SERVICE_ACCOUNT_PATH     xxxxx
SWAGGER_USER                      xxxxx
SWAGGER_PASSWORD                  xxxxx
```

## Deploy

### First Deployment

```bash
# Deploy the application
fly deploy

# Watch logs
fly logs
```

### Subsequent Deployments

```bash
# Deploy updates
fly deploy

# Or with build logs
fly deploy --verbose
```

## Verify Deployment

### Check Status

```bash
# Check app status
fly status

# Check app info
fly info

# View logs
fly logs
```

### Test Endpoints

```bash
# Get your app URL
fly info

# Test health endpoint
curl https://dancee-server.fly.dev/

# Test events endpoint
curl https://dancee-server.fly.dev/events/list

# Open Swagger UI (requires authentication)
open https://dancee-server.fly.dev/api
```

## Expected Logs

Successful deployment should show:

```
[FirebaseService] Loading service account from environment variable
[FirebaseService] Firebase initialized with service account from environment
[FirebaseService] Firestore connection established
[EventRepository] Events collection already has 8 events
[NestApplication] Nest application successfully started
🚀 Dancee Server is running on: http://0.0.0.0:3001
```

## Troubleshooting

### "Firestore not initialized"

**Cause**: Firebase credentials not set correctly.

**Solution**:
```bash
# Check secrets
fly secrets list

# Re-set Firebase credentials
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"

# Restart app
fly apps restart dancee-server
```

### "5 NOT_FOUND" Error

**Cause**: Firestore database not created.

**Solution**:
1. Go to Firebase Console: https://console.firebase.google.com/project/dancee-b5c0d
2. Enable Firestore Database
3. Restart Fly.io app: `fly apps restart dancee-server`

### "Out of Memory"

**Cause**: 512MB might not be enough.

**Solution**:
```bash
# Scale up memory
fly scale memory 1024

# Or edit fly.toml and redeploy
```

### "Cannot parse JSON"

**Cause**: Service account JSON is malformed.

**Solution**:
```bash
# Verify JSON is valid
cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json | jq .

# Re-set secret
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"
```

## Scaling

### Auto-scaling (Default)

Your app automatically scales to 0 when idle and starts on request.

### Keep Running

To keep at least 1 instance running:

```bash
# Edit fly.toml
[http_service]
  min_machines_running = 1

# Redeploy
fly deploy
```

### Manual Scaling

```bash
# Scale to 2 instances
fly scale count 2

# Scale memory
fly scale memory 1024

# Scale VM
fly scale vm shared-cpu-2x
```

## Monitoring

### View Logs

```bash
# Real-time logs
fly logs

# Last 100 lines
fly logs --lines 100

# Filter by level
fly logs --level error
```

### Metrics

```bash
# Open metrics dashboard
fly dashboard
```

### Alerts

Set up alerts in Fly.io dashboard for:
- High memory usage
- Error rate
- Response time

## Custom Domain (Optional)

```bash
# Add custom domain
fly certs add api.yourdomain.com

# Verify DNS
fly certs show api.yourdomain.com
```

## Environment-Specific Configuration

### Development

```bash
fly secrets set NODE_ENV=development
```

### Production

```bash
fly secrets set NODE_ENV=production
```

## Backup Strategy

Firestore data is automatically backed up by Firebase. For additional safety:

1. Enable Firestore backups in Firebase Console
2. Export data regularly:
   ```bash
   gcloud firestore export gs://your-backup-bucket
   ```

## Cost Estimation

Fly.io pricing (as of 2024):
- Free tier: 3 shared-cpu-1x VMs with 256MB RAM
- Your config (512MB): ~$5-10/month with auto-scaling
- Firestore: Free tier includes 1GB storage + 50K reads/day

## Useful Commands

```bash
# SSH into running instance
fly ssh console

# Open app in browser
fly open

# View app info
fly info

# Restart app
fly apps restart dancee-server

# Destroy app (careful!)
fly apps destroy dancee-server
```

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Fly.io

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

## Security Checklist

- [ ] Change default Swagger credentials
- [ ] Set strong SWAGGER_PASSWORD
- [ ] Enable Firestore security rules
- [ ] Use HTTPS only (force_https = true)
- [ ] Rotate service account keys regularly
- [ ] Monitor logs for suspicious activity
- [ ] Set up rate limiting if needed

## Support

- Fly.io Docs: https://fly.io/docs/
- Fly.io Community: https://community.fly.io/
- Firebase Docs: https://firebase.google.com/docs

---

**Ready to deploy!** 🚀

```bash
fly deploy
```
