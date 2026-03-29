# dancee_workflow

Restate-based event processing workflow service for Dancee. Automates the pipeline: scrape Facebook events → classify via LLM → extract parts & info → translate to multiple languages → resolve venues → store in Directus CMS.

## Overview

- **Runtime**: Node.js (Bun as package manager)
- **Workflow engine**: [Restate](https://restate.dev/) for durable workflow orchestration
- **Data store**: Directus CMS (REST API)
- **LLM provider**: OpenRouter (via OpenAI SDK)
- **Geocoding**: Nominatim (OpenStreetMap)
- **Error monitoring**: Sentry

## Prerequisites

- [Bun](https://bun.sh/) >= 1.0
- [Docker](https://www.docker.com/) and Docker Compose
- A running Directus instance (external, configured via `.env`)
- A running Restate server (bundled in Docker image)

## Setup

1. Copy the example environment file and fill in your values:
   ```bash
   cp .env.example .env
   ```

2. Install dependencies:
   ```bash
   bun install
   ```

3. Run the Directus setup script to create collections and seed languages:
   ```bash
   bun scripts/setup-directus.ts
   ```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `OPENROUTER_API_KEY` | OpenRouter API key for LLM calls | — |
| `OPENROUTER_MODEL` | Model to use (e.g. `openai/gpt-4o-mini`) | — |
| `DIRECTUS_BASE_URL` | Directus instance URL | — |
| `DIRECTUS_ACCESS_TOKEN` | Directus admin access token | — |
| `SCRAPER_BASE_URL` | dancee_scraper API base URL | — |
| `NOMINATIM_BASE_URL` | Nominatim API base URL | `https://nominatim.openstreetmap.org` |
| `SENTRY_DSN` | Sentry DSN for error tracking | — |
| `CORS_ORIGINS` | Allowed CORS origins | `*` |
| `APP_PORT` | Application port | `9080` |

## Development

```bash
# Start with hot reload
bun run dev

# Run tests
bun test

# Build TypeScript
bun run build
```

## Docker

```bash
# Build and start the service (includes embedded Restate server)
docker compose up --build
```

The container exposes:
- `8080` — Restate ingress (client-facing API)
- `9070` — Restate admin interface
- `9080` — Application service (internal)

## API Endpoints

All endpoints are exposed via Restate ingress on port 8080.

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/event` | Process a single Facebook event by URL |
| `GET` | `/api/events/process` | Trigger batch processing of all groups |
| `GET` | `/api/events/list` | List published events |

### POST /api/event

```json
{ "url": "https://www.facebook.com/events/123456789" }
```

Returns the processed event object or `null` if skipped (unsupported type or duplicate).

## Testing

```bash
bun test
```

Tests use [Vitest](https://vitest.dev/) with [fast-check](https://fast-check.io/) for property-based testing. Test files are located in `src/__tests__/`.
