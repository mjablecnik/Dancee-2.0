# Docker Setup Guide

This guide explains how to run the dancee_server application using Docker for both development and production environments.

## Prerequisites

- Docker installed (version 20.10 or higher)
- Docker Compose installed (version 2.0 or higher)
- Task (taskfile) installed

## Quick Start

### Development Environment

Start the development server with hot reload:

```bash
task docker-dev
```

This will:
- Build the development Docker image
- Start the container with hot reload enabled
- Mount your source code for instant updates
- Expose port 3001 for the API
- Expose port 9229 for debugging

Access the application:
- API: http://localhost:3001
- Swagger UI: http://localhost:3001/api

Stop the development container:

```bash
task docker-dev-down
```

### Production Environment

Build and start the production server:

```bash
task docker-prod
```

This will:
- Build an optimized production Docker image
- Start the container in detached mode
- Run with minimal dependencies
- Include health checks
- Run as non-root user for security

View production logs:

```bash
task docker-prod-logs
```

Stop the production container:

```bash
task docker-prod-down
```

## Docker Files Overview

### Development Setup

**Dockerfile.dev**
- Based on Node.js 20 Alpine
- Includes all dependencies (dev + production)
- Mounts source code for hot reload
- Exposes debugging port (9229)
- Runs `npm run start:dev`

**docker-compose.dev.yml**
- Configures development container
- Volume mounts for hot reload:
  - `./src` - Source code
  - `./test` - Test files
  - Configuration files
- Preserves `node_modules` in container
- Exposes ports 3001 (API) and 9229 (debug)

### Production Setup

**Dockerfile.prod**
- Multi-stage build for optimization
- Stage 1: Build application
- Stage 2: Production runtime
- Only production dependencies
- Runs as non-root user (security)
- Includes health checks
- Optimized image size

**docker-compose.prod.yml**
- Configures production container
- Runs in detached mode
- Auto-restart on failure
- Health check monitoring
- Exposes port 3001

## Available Task Commands

| Command | Description |
|---------|-------------|
| `task docker-dev` | Start development server with hot reload |
| `task docker-dev-down` | Stop development container |
| `task docker-prod` | Build and start production container |
| `task docker-prod-down` | Stop production container |
| `task docker-prod-logs` | View production logs |
| `task docker-clean` | Remove all containers, images, and volumes |

## Development Workflow

### Hot Reload

When running in development mode, any changes to files in the `src/` directory will automatically trigger a rebuild and restart of the application.

**Supported hot reload files:**
- `src/**/*.ts` - All TypeScript source files
- `test/**/*.ts` - Test files
- `nest-cli.json` - NestJS configuration
- `tsconfig.json` - TypeScript configuration

**Not hot-reloaded (requires restart):**
- `package.json` - Dependencies
- `package-lock.json` - Lock file

If you modify dependencies, restart the container:

```bash
task docker-dev-down
task docker-dev
```

### Debugging

The development container exposes port 9229 for debugging. You can attach your IDE debugger to this port.

**VS Code launch.json example:**

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "attach",
      "name": "Docker: Attach to Node",
      "port": 9229,
      "address": "localhost",
      "localRoot": "${workspaceFolder}/backend/dancee_server",
      "remoteRoot": "/app",
      "protocol": "inspector",
      "restart": true
    }
  ]
}
```

## Production Deployment

### Building for Production

The production Dockerfile uses multi-stage builds to create an optimized image:

1. **Builder stage**: Installs all dependencies and builds the application
2. **Production stage**: Copies only built files and production dependencies

This results in a smaller, more secure image.

### Security Features

- Runs as non-root user (`nestjs:nodejs`)
- Only production dependencies included
- Minimal base image (Alpine Linux)
- Health checks for monitoring
- No development tools in production image

### Health Checks

The production container includes automatic health checks:

- **Interval**: 30 seconds
- **Timeout**: 3 seconds
- **Retries**: 3 attempts
- **Start period**: 5 seconds

Health check endpoint: `GET /health`

## Environment Variables

You can customize the application using environment variables in the docker-compose files:

```yaml
environment:
  - NODE_ENV=production
  - PORT=3001
  - DATABASE_URL=postgresql://...
  - API_KEY=your-api-key
```

For sensitive values, consider using Docker secrets or `.env` files.

## Troubleshooting

### Container won't start

Check logs:

```bash
# Development
docker-compose -f docker-compose.dev.yml logs

# Production
task docker-prod-logs
```

### Hot reload not working

Ensure volumes are properly mounted:

```bash
docker-compose -f docker-compose.dev.yml config
```

Restart the container:

```bash
task docker-dev-down
task docker-dev
```

### Port already in use

If port 3001 is already in use, modify the port mapping in the docker-compose file:

```yaml
ports:
  - "3002:3001"  # Map to different host port
```

### Permission issues

If you encounter permission issues with mounted volumes, ensure your user has proper permissions:

```bash
# Linux/WSL
sudo chown -R $USER:$USER .
```

### Clean everything

Remove all Docker artifacts:

```bash
task docker-clean
```

This removes:
- All containers
- All images
- All volumes
- All networks

## Performance Tips

### Development

- Use volume mounts for hot reload
- Keep `node_modules` in container (don't mount)
- Use `.dockerignore` to exclude unnecessary files

### Production

- Multi-stage builds reduce image size
- Only production dependencies
- Use Alpine base image
- Enable health checks for monitoring
- Run as non-root user

## Docker Ignore

Ensure you have a `.dockerignore` file to exclude unnecessary files:

```
node_modules
npm-debug.log
dist
.git
.gitignore
.env
.env.local
.vscode
.idea
*.md
test
coverage
.eslintrc.js
.prettierrc
```

## Next Steps

- Configure environment variables for your deployment
- Set up CI/CD pipeline for automated builds
- Configure reverse proxy (nginx) for production
- Set up monitoring and logging
- Configure database connections
- Add SSL/TLS certificates

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NestJS Docker Guide](https://docs.nestjs.com/recipes/docker)
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)
