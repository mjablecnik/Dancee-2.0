---
inclusion: always
---

# Dancee App - Project Structure

## Project Overview

Dancee App is a Flutter-based mobile and web application for dance enthusiasts. The project is structured as a multi-platform application supporting Android, iOS, and web platforms.

## Project Structure

```
├── .design/                 # HTML design mockups
├── frontend/
│   └── dancee_app/          # Main Flutter application
│       ├── lib/             # Dart source code
│       │   ├── core/        # Shared utilities, DI, routing
│       │   ├── design/      # Shared design system
│       │   ├── features/    # Feature modules
│       │   └── i18n/        # Localization (slang)
│       ├── test/            # Test files
│       ├── android/         # Android-specific files
│       ├── ios/             # iOS-specific files
│       ├── web/             # Web-specific files
│       ├── docs/            # Documentation
│       ├── taskfile.yaml    # Task automation
│       └── pubspec.yaml     # Flutter dependencies
├── backend/
│   ├── dancee_api/          # TypeScript API Gateway (Express)
│   ├── dancee_events/       # Go events service (Gin + Firebase)
│   ├── dancee_workflow/     # TypeScript workflow service (Restate)
│   └── dancee_cms/          # Directus CMS (headless)
└── shared/                  # Shared resources (currently empty)
```

## Backend Services

### � dancee_api (TypeScript/Express)
- **Technology**: Node.js with Express framework (TypeScript)
- **Purpose**: API Gateway — centralized routing, OpenAPI spec aggregation, and single source of truth for all API documentation
- **Location**: `backend/dancee_api/`
- **Key Features**:
  - OpenAPI spec aggregation and validation
  - Swagger UI for API documentation
  - Health check and service discovery endpoints
  - CORS middleware

#### dancee_api Structure:
```
backend/dancee_api/
├── src/
│   ├── aggregator/        # OpenAPI spec aggregation & validation
│   ├── config/            # App and services configuration
│   ├── middleware/         # CORS, error handling
│   ├── routes/            # Health, services, spec routes
│   ├── index.ts           # Entry point
│   └── server.ts          # Express server setup
├── specs/                 # OpenAPI specs for all services
│   ├── combined.openapi.yaml
│   ├── events.openapi.yaml
│   └── workflow.openapi.yaml
├── docs/                  # Documentation
└── package.json
```

### 🎪 dancee_events (Go)
- **Technology**: Go with Gin framework + Firebase/Firestore
- **Purpose**: Event data service — CRUD operations for dance events, favorites management
- **Location**: `backend/dancee_events/`
- **Port**: 8080
- **Deployment**: Fly.io (Amsterdam region)

#### dancee_events Structure:
```
backend/dancee_events/
├── internal/
│   ├── config/            # Environment configuration
│   ├── firebase/          # Firebase client initialization
│   ├── handlers/          # HTTP handlers (Gin)
│   ├── models/            # Data models
│   ├── repositories/      # Firestore data access (events, favorites)
│   └── services/          # Business logic
├── docs/                  # API, changelog, deployment, troubleshooting
├── main.go                # Entry point
├── Dockerfile
└── fly.toml
```

### ⚙️ dancee_workflow (TypeScript/Restate)
- **Technology**: Node.js with TypeScript, Restate SDK, OpenAI, Zod
- **Purpose**: Event processing workflow — scraping, AI-powered parsing/translation, geocoding, batch processing
- **Location**: `backend/dancee_workflow/`
- **Port**: 9080
- **Deployment**: Fly.io (Frankfurt region)
- **Key Features**:
  - Facebook event scraping
  - LLM-based event description parsing and translation (OpenAI)
  - Venue geocoding via Nominatim
  - Directus CMS integration for event storage
  - Restate durable execution for reliable workflows
  - Sentry error monitoring

#### dancee_workflow Structure:
```
backend/dancee_workflow/
├── src/
│   ├── clients/           # External service clients
│   │   ├── directus-client.ts
│   │   ├── nominatim-client.ts
│   │   └── scraper-client.ts
│   ├── core/              # Configuration, schemas, prompts, utilities
│   │   ├── config.ts
│   │   ├── logger.ts
│   │   ├── openai.ts
│   │   ├── prompts.ts
│   │   ├── schemas.ts
│   │   └── utils.ts
│   ├── services/          # Business logic and workflow handlers
│   │   ├── api.ts
│   │   ├── batch.ts
│   │   ├── event-parser.ts
│   │   ├── event-translator.ts
│   │   ├── scraper.ts
│   │   ├── venue-resolver.ts
│   │   └── workflow.ts
│   ├── __tests__/         # Tests (mirrors src structure)
│   └── index.ts           # Entry point
├── scripts/               # Setup and seed scripts
├── docs/                  # Documentation
├── Dockerfile
├── docker-compose.yml
└── fly.toml
```

### 📦 dancee_cms (Directus)
- **Technology**: Directus (headless CMS) + PostgreSQL (Supabase) + S3 Storage (Supabase)
- **Purpose**: Content management — event data storage, admin interface
- **Location**: `backend/dancee_cms/`
- **Port**: 8055
- **Deployment**: Fly.io (Frankfurt region)
- **Note**: No custom source code — uses official Directus Docker image with configuration scripts

#### dancee_cms Structure:
```
backend/dancee_cms/
├── fly-secrets.sh         # Push secrets to Fly.io
├── get-token.sh           # Get Directus access token
├── start-directus.sh      # Local development startup
├── fly.toml               # Fly.io deployment config
├── .env.example           # Environment template
└── README.md
```

## Platform Support

The app supports three platforms:
1. **Web** — Progressive web app
2. **Android** — Native Android application
3. **iOS** — Native iOS application
