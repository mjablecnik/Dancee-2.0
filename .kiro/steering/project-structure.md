---
inclusion: always
---

# Dancee App - Project Structure

## Project Overview

Dancee App is a Flutter-based mobile and web application for dance enthusiasts. The project is structured as a multi-platform application supporting Android, iOS, and web platforms.

## Project Structure

```
├── frontend/
│   └── dancee_app/          # Main Flutter application
│       ├── lib/             # Dart source code
│       ├── android/         # Android-specific files
│       ├── ios/             # iOS-specific files
│       ├── web/             # Web-specific files
│       ├── test/            # Test files
│       ├── taskfile.yaml    # Task automation file
│       └── pubspec.yaml     # Flutter dependencies
└── backend/
    ├── dancee_api/          # TypeScript API Gateway (Express)
    ├── dancee_events/       # Go events service
    ├── dancee_scraper/      # TypeScript scraping service
    ├── dancee_event_service/ # Dart backend service (REST API)
    └── dancee_server/       # NestJS backend service (Node.js/TypeScript)
        ├── src/             # TypeScript source code
        ├── docs/            # Documentation files
        ├── test/            # Test files
        ├── taskfile.yaml    # Task automation file
        └── package.json     # Node.js dependencies
```

## Backend Services

The project includes multiple backend services:

### 🎯 dancee_event_service (Dart)
- **Technology**: Dart with shelf framework
- **Purpose**: REST API for event data management
- **Location**: `backend/dancee_event_service/`
- **Port**: Configurable (typically 8080)

### 🚀 dancee_server (NestJS)
- **Technology**: Node.js with NestJS framework (TypeScript)
- **Purpose**: Web scraping and data collection service
- **Location**: `backend/dancee_server/`
- **Port**: 3001 (default)
- **Key Features**:
  - Facebook event scraping
  - RESTful API endpoints
  - Swagger/OpenAPI documentation
  - CORS enabled for frontend communication

#### dancee_server Structure:
```
backend/dancee_server/
├── src/
│   ├── scraper/           # Scraper module
│   │   ├── dto/          # Data Transfer Objects
│   │   ├── scraper.controller.ts
│   │   ├── scraper.service.ts
│   │   └── scraper.module.ts
│   ├── app.controller.ts  # Main controller
│   ├── app.module.ts      # Root module
│   ├── app.service.ts     # Business logic
│   └── main.ts           # Application entry point
├── docs/                  # Documentation files (REQUIRED)
├── test/                  # Test files
├── taskfile.yaml         # Task automation
└── package.json          # Dependencies
```

### 🌐 dancee_api (TypeScript/Express)
- **Technology**: Node.js with Express framework (TypeScript)
- **Purpose**: API Gateway for routing requests to microservices
- **Location**: `backend/dancee_api/`

### 🎪 dancee_events (Go)
- **Technology**: Go
- **Purpose**: Event data service
- **Location**: `backend/dancee_events/`

### 🔍 dancee_scraper (TypeScript)
- **Technology**: Node.js with TypeScript
- **Purpose**: Web scraping service
- **Location**: `backend/dancee_scraper/`

## Platform Support

The app supports three platforms:
1. **Web** - Progressive web app
2. **Android** - Native Android application
3. **iOS** - Native iOS application
