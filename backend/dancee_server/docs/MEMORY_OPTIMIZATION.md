# Memory Optimization Guide

Guide for managing memory usage on Fly.io deployment.

## Problem: Out of Memory Errors

If you see logs like:
```
Mark-Compact (reduce) 253.1 (257.0) -> 252.5 (256.0) MB
allocation failure; scavenge might not succeed
```

This means Node.js is running out of memory.

## Solution 1: Increase VM Memory (Recommended)

### Current Configuration

Your `fly.toml` is now set to **1024MB (1GB)**:

```toml
[[vm]]
  memory = '1024mb'
  cpus = 1
  memory_mb = 1024
```

### Memory Options

| Memory | Cost/Month | Use Case |
|--------|------------|----------|
| 256MB  | Free tier  | Very light apps |
| 512MB  | ~$5        | Light apps (too small for NestJS + Firebase) |
| 1024MB | ~$10       | **Recommended for this app** |
| 2048MB | ~$20       | Heavy apps with many connections |

### Change Memory

Edit `fly.toml`:

```toml
[[vm]]
  memory = '1024mb'  # Change this value
  cpus = 1
  memory_mb = 1024   # Change this value too
```

Then redeploy:
```bash
task deploy-quick
```

Or use Fly CLI:
```bash
fly scale memory 1024 --app dancee-server
```

## Solution 2: Node.js Memory Limit

The `Dockerfile` now includes:

```dockerfile
ENV NODE_OPTIONS="--max-old-space-size=896"
```

This tells Node.js to use max **896MB** of the 1024MB available (leaving ~128MB for system).

### Adjust for Different VM Sizes

| VM Memory | NODE_OPTIONS Value | Calculation |
|-----------|-------------------|-------------|
| 512MB     | `--max-old-space-size=384` | 512 - 128 = 384 |
| 1024MB    | `--max-old-space-size=896` | 1024 - 128 = 896 |
| 2048MB    | `--max-old-space-size=1920` | 2048 - 128 = 1920 |

Edit `Dockerfile`:
```dockerfile
ENV NODE_OPTIONS="--max-old-space-size=896"
```

## Solution 3: Optimize Application

### Reduce Memory Usage

1. **Limit sample data** (if too many events):
   ```typescript
   // In event.repository.ts
   // Reduce number of sample events from 8 to 3-4
   ```

2. **Use Firestore pagination**:
   ```typescript
   // Instead of loading all events
   const snapshot = await firestore
     .collection('events')
     .limit(50)  // Add limit
     .get();
   ```

3. **Clear unused imports**:
   ```bash
   npm run lint
   ```

## Monitoring Memory Usage

### View Current Memory

```bash
# Check app status
fly status --app dancee-server

# View metrics
fly dashboard
```

### Watch Logs for Memory Issues

```bash
# Real-time logs
fly logs --app dancee-server

# Filter for memory warnings
fly logs --app dancee-server | grep -i "memory\|heap\|allocation"
```

### Memory Warning Signs

Look for these in logs:
- ❌ `allocation failure`
- ❌ `Mark-Compact`
- ❌ `scavenge might not succeed`
- ❌ `JavaScript heap out of memory`

## Recommended Configuration

For this app (NestJS + Firebase + Firestore):

**Minimum:**
- Memory: 1024MB
- Node limit: 896MB

**Optimal:**
- Memory: 1024MB
- Node limit: 896MB
- Auto-scaling: enabled (default)

**Heavy load:**
- Memory: 2048MB
- Node limit: 1920MB
- Min instances: 1

## Cost Considerations

### Free Tier
- 3 shared-cpu-1x VMs with 256MB RAM
- **Not enough for this app**

### Paid Tier
- 512MB: ~$5/month (too small)
- **1024MB: ~$10/month (recommended)**
- 2048MB: ~$20/month (if needed)

### Auto-scaling Saves Money

Your `fly.toml` has:
```toml
[http_service]
  auto_stop_machines = 'stop'
  auto_start_machines = true
  min_machines_running = 0
```

This means:
- ✅ App stops when idle (no cost)
- ✅ App starts on first request
- ✅ You only pay when app is running

## Troubleshooting

### Still getting memory errors?

1. **Increase to 2GB:**
   ```bash
   fly scale memory 2048 --app dancee-server
   ```

2. **Check for memory leaks:**
   ```bash
   # SSH into instance
   fly ssh console --app dancee-server
   
   # Check memory usage
   free -m
   top
   ```

3. **Review Firebase connections:**
   - Ensure Firestore connections are properly closed
   - Check for hanging promises

### App crashes immediately?

Memory might be too low. Increase to 1024MB minimum.

### Slow startup?

This is normal with limited memory. Consider:
- Increasing memory
- Keeping min_machines_running = 1

## Quick Fix Commands

```bash
# Increase memory to 1GB
fly scale memory 1024 --app dancee-server

# Increase memory to 2GB
fly scale memory 2048 --app dancee-server

# Restart app
fly apps restart dancee-server

# Check status
fly status --app dancee-server

# View logs
fly logs --app dancee-server
```

## Summary

✅ **Current setup (after fix):**
- VM Memory: 1024MB
- Node.js limit: 896MB
- Should work smoothly

⚠️ **If issues persist:**
- Scale to 2048MB
- Check for memory leaks
- Optimize Firestore queries

---

**Your app should now run without memory issues!** 🎉
