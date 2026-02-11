# Deployment Summary

Complete deployment setup for Dancee Server on Fly.io.

## 🎯 Quick Start

```bash
# One command deployment
task deploy
```

That's it! The script handles everything.

## 📦 What's Included

### Deployment Scripts

1. **`deploy.sh`** - Interactive deployment (Linux/Mac/WSL)
2. **`deploy.bat`** - Interactive deployment (Windows)
3. **`deploy-quick.sh`** - Fast deployment without prompts

### Task Commands

```bash
task deploy              # Interactive deployment
task deploy-quick        # Quick deployment
task deploy-logs         # View logs
task deploy-status       # Check status
task deploy-open         # Open in browser
task deploy-ssh          # SSH into instance
task deploy-restart      # Restart app
task deploy-secrets      # List secrets
```

### Documentation

1. **[DEPLOY_SCRIPTS.md](./docs/DEPLOY_SCRIPTS.md)** - Script usage guide
2. **[FLY_IO_QUICK_DEPLOY.md](./docs/FLY_IO_QUICK_DEPLOY.md)** - 5-minute manual deploy
3. **[FLY_IO_DEPLOYMENT.md](./docs/FLY_IO_DEPLOYMENT.md)** - Complete deployment guide

## 🚀 First Time Deployment

### Step 1: Prerequisites

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Verify service account exists
ls secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json
```

### Step 2: Deploy

```bash
task deploy
```

The script will:
1. ✅ Check prerequisites
2. ✅ Create app if needed
3. ✅ Set Firebase credentials
4. ✅ Set Swagger credentials
5. ✅ Deploy to Fly.io
6. ✅ Show URLs and commands

### Step 3: Verify

```bash
# Check status
task deploy-status

# View logs
task deploy-logs

# Open in browser
task deploy-open
```

## 🔄 Updating Deployment

After initial setup, use quick deploy:

```bash
task deploy-quick
```

Or full deploy to update secrets:

```bash
task deploy
```

## 🌐 Your Deployed URLs

After deployment, your app will be available at:

- **API**: https://dancee-server.fly.dev/
- **Swagger**: https://dancee-server.fly.dev/api
- **Events**: https://dancee-server.fly.dev/events/list

## 🔧 Configuration

### Secrets Set by Scripts

| Secret | Description | Value |
|--------|-------------|-------|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase credentials | From `secrets/*.json` |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | Path (empty for Fly.io) | `""` |
| `SWAGGER_USER` | Swagger username | User input |
| `SWAGGER_PASSWORD` | Swagger password | User input |

### View Current Secrets

```bash
task deploy-secrets
```

### Update Secrets

```bash
# Run full deploy and answer "yes" to update secrets
task deploy

# Or manually
fly secrets set SWAGGER_PASSWORD=new-password --app dancee-server
```

## 📊 Monitoring

### View Logs

```bash
# Real-time logs
task deploy-logs

# Or directly
fly logs --app dancee-server
```

### Check Status

```bash
task deploy-status
```

### Open Dashboard

```bash
fly dashboard
```

## 🛠️ Troubleshooting

### Deployment Fails

```bash
# Check logs
task deploy-logs

# Check status
task deploy-status

# Restart app
task deploy-restart
```

### Update Firebase Credentials

```bash
# Run deploy script and update credentials
task deploy
# Answer "yes" to Firebase credentials prompt
```

### SSH into Instance

```bash
task deploy-ssh
```

## 📝 Manual Deployment

If you prefer manual deployment:

```bash
# Set secrets
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)" --app dancee-server
fly secrets set FIREBASE_SERVICE_ACCOUNT_PATH="" --app dancee-server
fly secrets set SWAGGER_USER=admin --app dancee-server
fly secrets set SWAGGER_PASSWORD=your-password --app dancee-server

# Deploy
fly deploy --app dancee-server
```

## 🔐 Security Checklist

- [x] Service account stored in `secrets/` (gitignored)
- [x] Secrets uploaded to Fly.io (encrypted)
- [x] HTTPS enforced (force_https = true)
- [x] Swagger protected with authentication
- [ ] Change default Swagger password
- [ ] Set up Firestore security rules
- [ ] Enable monitoring and alerts

## 📚 Additional Resources

- [Deploy Scripts Guide](./docs/DEPLOY_SCRIPTS.md)
- [Fly.io Quick Deploy](./docs/FLY_IO_QUICK_DEPLOY.md)
- [Complete Deployment Guide](./docs/FLY_IO_DEPLOYMENT.md)
- [Firestore Setup](./docs/FIRESTORE_SETUP.md)
- [Fly.io Documentation](https://fly.io/docs/)

## 🎉 Success Criteria

After successful deployment:

✅ App is accessible at https://dancee-server.fly.dev/
✅ Swagger UI works at https://dancee-server.fly.dev/api
✅ Events endpoint returns data
✅ Firestore connection established
✅ Sample data initialized (8 events)
✅ Logs show no errors

---

**Ready to deploy? Run `task deploy` and follow the prompts!** 🚀
