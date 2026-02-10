# Docker Quick Reference

Quick command reference for Docker operations with dancee_server.

## Development

```bash
# Start development server with hot reload
task docker-dev

# Stop development server
task docker-dev-down

# View development logs
docker-compose -f docker-compose.dev.yml logs -f
```

**Features:**
- ✅ Hot reload enabled
- ✅ Source code mounted
- ✅ Debug port exposed (9229)
- ✅ Instant code changes

**Access:**
- API: http://localhost:3001
- Swagger: http://localhost:3001/api
- Debug: localhost:9229

## Production

```bash
# Build and start production server
task docker-prod

# Stop production server
task docker-prod-down

# View production logs
task docker-prod-logs
```

**Features:**
- ✅ Optimized image size
- ✅ Multi-stage build
- ✅ Non-root user
- ✅ Health checks
- ✅ Auto-restart

**Access:**
- API: http://localhost:3001
- Swagger: http://localhost:3001/api

## Maintenance

```bash
# Remove all Docker artifacts
task docker-clean

# Rebuild without cache
docker-compose -f docker-compose.dev.yml build --no-cache
docker-compose -f docker-compose.prod.yml build --no-cache

# View container status
docker ps

# Execute command in container
docker exec -it dancee-server-dev sh
docker exec -it dancee-server-prod sh
```

## Troubleshooting

```bash
# Check logs
docker-compose -f docker-compose.dev.yml logs
docker-compose -f docker-compose.prod.yml logs

# Restart container
task docker-dev-down && task docker-dev
task docker-prod-down && task docker-prod

# Check container health
docker inspect dancee-server-prod | grep -A 10 Health

# Remove specific container
docker rm -f dancee-server-dev
docker rm -f dancee-server-prod
```

## File Structure

```
backend/dancee_server/
├── Dockerfile.dev              # Development Dockerfile
├── Dockerfile.prod             # Production Dockerfile
├── docker-compose.dev.yml      # Development compose config
├── docker-compose.prod.yml     # Production compose config
├── .dockerignore               # Files to exclude from build
└── docs/
    ├── DOCKER.md               # Complete Docker guide
    └── DOCKER_QUICK_REFERENCE.md  # This file
```

## Environment Variables

Add to docker-compose files:

```yaml
environment:
  - NODE_ENV=production
  - PORT=3001
  - DATABASE_URL=postgresql://...
  - API_KEY=your-secret-key
```

## Port Mapping

Change host port if 3001 is in use:

```yaml
ports:
  - "3002:3001"  # Host:Container
```

## Volume Mounts (Development)

Mounted for hot reload:
- `./src` → `/app/src`
- `./test` → `/app/test`
- Config files

Not mounted (stays in container):
- `node_modules`

## Common Issues

**Port already in use:**
```bash
# Find process using port 3001
lsof -i :3001
# Kill process
kill -9 <PID>
```

**Permission denied:**
```bash
# Fix file permissions (Linux/WSL)
sudo chown -R $USER:$USER .
```

**Hot reload not working:**
```bash
# Restart container
task docker-dev-down
task docker-dev
```

**Out of disk space:**
```bash
# Clean Docker system
docker system prune -a --volumes
```

## Best Practices

✅ Use `task docker-dev` for development
✅ Use `task docker-prod` for production testing
✅ Keep sensitive data in `.env` files
✅ Don't commit `.env` files
✅ Use `.dockerignore` to exclude files
✅ Run `task docker-clean` periodically
✅ Monitor logs with `task docker-prod-logs`
✅ Test production build before deployment

## Next Steps

- Configure environment variables
- Set up CI/CD pipeline
- Add reverse proxy (nginx)
- Configure SSL/TLS
- Set up monitoring
- Configure database

For detailed information, see [DOCKER.md](./DOCKER.md)
