# Deployment Scripts Guide

Automated deployment scripts for Fly.io with intelligent setup.

## Available Scripts

### 1. Automated Deploy (Recommended)

**Linux/Mac/WSL:**
```bash
./deploy.sh
```

**Windows:**
```cmd
deploy.bat
```

**Using Task:**
```bash
task deploy
```

**Features:**
- ✅ Automatically checks prerequisites
- ✅ Auto-creates app if it doesn't exist
- ✅ Auto-configures Firebase credentials if not set
- ✅ Prompts for Swagger password only if not set
- ✅ Shows deployment progress with clear steps
- ✅ Displays URLs and useful commands after deployment
- ✅ Minimal user interaction required

**What it does automatically:**
1. Checks Fly CLI installation
2. Verifies/initiates login
3. Checks service account file
4. Creates app if missing
5. Sets Firebase credentials if missing
6. Prompts for Swagger credentials if missing
7. Deploys application
8. Shows success message with URLs

**What it asks:**
- Swagger username (if not set) - defaults to "admin"
- Swagger password (if not set) - required for security
- Password confirmation
- View logs after deployment? (optional)

### 2. Quick Deploy (No Prompts)

**Linux/Mac/WSL:**
```bash
./deploy-quick.sh
```

**Using Task:**
```bash
task deploy-quick
```

**Features:**
- ⚡ Fast deployment without any prompts
- ⚡ Uses existing configuration
- ⚡ Perfect for updates after initial setup

## Prerequisites

Before running any deploy script:

1. **Install Fly CLI:**
   ```bash
   # Linux/Mac/WSL
   curl -L https://fly.io/install.sh | sh
   
   # Windows
   # Download from: https://fly.io/docs/hands-on/install-flyctl/
   ```

2. **Login to Fly.io:**
   ```bash
   fly auth login
   ```

3. **Ensure service account exists:**
   ```bash
   ls secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json
   ```

## First Time Deployment

### Step 1: Run Automated Deploy

```bash
task deploy
```

### Step 2: Provide Swagger Password

The script will automatically:
1. ✅ Check prerequisites
2. ✅ Login if needed
3. ✅ Create app if missing
4. ✅ Set Firebase credentials

You only need to provide:
- Swagger username (or press Enter for "admin")
- Swagger password (required)
- Password confirmation

### Step 3: Wait for Deployment

The script deploys automatically and shows:
- Deployment progress
- Success message
- Your app URLs
- Useful commands

### Step 4: Verify Deployment

```bash
# Check status
task deploy-status

# View logs
task deploy-logs

# Open in browser
task deploy-open
```

## Subsequent Deployments

After initial setup, use quick deploy:

```bash
task deploy-quick
```

Or full deploy if you need to update secrets:

```bash
task deploy
```

## Task Commands

All available deployment tasks:

```bash
task deploy              # Interactive deployment
task deploy-quick        # Quick deployment (no prompts)
task deploy-logs         # View logs
task deploy-status       # Check status
task deploy-open         # Open in browser
task deploy-ssh          # SSH into instance
task deploy-restart      # Restart app
task deploy-secrets      # List secrets
```

## Script Workflow

### Automated Deploy (`deploy.sh` / `deploy.bat`)

```
[1/8] Check Fly CLI installed
      → Auto-fail if not installed (with install instructions)

[2/8] Check logged in to Fly.io
      → Auto-login if not logged in

[3/8] Check service account file exists
      → Auto-fail if missing (with instructions)

[4/8] Check/create app
      → Auto-create if doesn't exist

[5/8] Configure Firebase credentials
      → Auto-set if not already configured
      → Skip if already configured

[6/8] Configure Swagger authentication
      → Prompt for credentials if not set
      → Skip if already configured

[7/8] Show current configuration
      → Display all secrets

[8/8] Deploy to Fly.io
      → Run deployment
      → Show success/failure message
      → Display URLs and commands
      → Optional: View logs
```

### Quick Deploy (`deploy-quick.sh`)

```
1. Check prerequisites
2. Run fly deploy
3. Show success message
```

## Environment Variables Set by Scripts

The scripts automatically set these secrets on Fly.io:

| Secret | Description | Source |
|--------|-------------|--------|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase credentials | `secrets/*.json` |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | Path (empty for Fly.io) | Set to `""` |
| `SWAGGER_USER` | Swagger username | User input |
| `SWAGGER_PASSWORD` | Swagger password | User input |

## Troubleshooting

### "Fly CLI not installed"

**Solution:**
```bash
curl -L https://fly.io/install.sh | sh
```

### "Not logged in to Fly.io"

**Solution:**
```bash
fly auth login
```

### "Service account file not found"

**Solution:**
```bash
# Ensure file exists
ls secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json

# If missing, download from Firebase Console
```

### "Permission denied" (Linux/Mac)

**Solution:**
```bash
chmod +x deploy.sh
chmod +x deploy-quick.sh
```

### Deployment fails

**Solution:**
```bash
# Check logs
fly logs --app dancee-server

# Check status
fly status --app dancee-server

# Try manual deploy
fly deploy --app dancee-server --verbose
```

## Manual Deployment (Without Scripts)

If you prefer manual deployment:

```bash
# 1. Set secrets
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)" --app dancee-server
fly secrets set FIREBASE_SERVICE_ACCOUNT_PATH="" --app dancee-server
fly secrets set SWAGGER_USER=admin --app dancee-server
fly secrets set SWAGGER_PASSWORD=your-password --app dancee-server

# 2. Deploy
fly deploy --app dancee-server

# 3. Check logs
fly logs --app dancee-server
```

## CI/CD Integration

For automated deployments in CI/CD:

```bash
# Use quick deploy script
./deploy-quick.sh

# Or direct fly command
fly deploy --app dancee-server --remote-only
```

See [FLY_IO_DEPLOYMENT.md](./FLY_IO_DEPLOYMENT.md) for GitHub Actions example.

## Security Notes

- ⚠️ Scripts read service account from `secrets/` folder
- ⚠️ Service account is uploaded as Fly.io secret (encrypted)
- ⚠️ Never commit `secrets/` folder to git
- ⚠️ Change default Swagger password
- ⚠️ Use strong passwords for production

## Script Customization

### Change App Name

Edit scripts and replace `dancee-server` with your app name:

```bash
# In deploy.sh
APP_NAME="your-app-name"

# In taskfile.yaml
--app your-app-name
```

### Change Service Account Path

Edit scripts and replace the path:

```bash
# In deploy.sh
SERVICE_ACCOUNT_FILE="secrets/your-service-account.json"
```

### Add Custom Secrets

Add to the scripts after Swagger credentials:

```bash
# In deploy.sh
fly secrets set YOUR_SECRET="value" --app "$APP_NAME"
```

## Support

- Fly.io Docs: https://fly.io/docs/
- Deployment Guide: [FLY_IO_DEPLOYMENT.md](./FLY_IO_DEPLOYMENT.md)
- Quick Deploy: [FLY_IO_QUICK_DEPLOY.md](./FLY_IO_QUICK_DEPLOY.md)

---

**Happy Deploying! 🚀**
