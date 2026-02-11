# Dancee Events API

REST API service for managing dance events, built with Go and Firebase Firestore.

## Features

- List all dance events
- Manage user favorite events
- Firebase Firestore integration
- RESTful API with JSON responses
- CORS enabled for frontend communication

## Tech Stack

- **Language**: Go 1.21+
- **Web Framework**: Gin
- **Database**: Firebase Firestore
- **Configuration**: Environment variables with godotenv

## Project Structure

```
dancee_events/
├── internal/
│   ├── config/          # Configuration management
│   ├── firebase/        # Firebase client initialization
│   ├── handlers/        # HTTP request handlers
│   ├── models/          # Data models
│   ├── repositories/    # Data access layer
│   └── services/        # Business logic layer
├── main.go              # Application entry point
├── go.mod               # Go module dependencies
├── .env.example         # Environment variables template
└── README.md            # This file
```

## Setup

### API Endpoints

The API supports both URL formats for backward compatibility:

**Recommended (with /api prefix):**
```
GET  /api/events/list
GET  /api/events/favorites
POST /api/events/favorites
DELETE /api/events/favorites/:eventId
```

**Legacy (without /api prefix):**
```
GET  /events/list
GET  /events/favorites
POST /events/favorites
DELETE /events/favorites/:eventId
```

Both formats work identically. Use `/api` prefix for new integrations.

### Prerequisites

- Go 1.21 or higher
- Firebase project with Firestore enabled
- Firebase service account credentials

### Installation

1. Clone the repository and navigate to the project:
```bash
cd backend/dancee_events
```

2. Copy environment variables:
```bash
cp .env.example .env
```

3. Configure Firebase credentials in `.env`:
```env
FIREBASE_SERVICE_ACCOUNT_PATH=./secrets/serviceAccountKey.json
```

4. Place your Firebase service account JSON file in `secrets/` directory

5. Install dependencies:
```bash
go mod download
```

## Running the Application

### Development

```bash
go run main.go
```

### Production Build

```bash
go build -o dancee_events
./dancee_events
```

### Using Task (if taskfile is configured)

```bash
task run
task build
```

## API Endpoints

### List All Events
```
GET /api/events/list?userId={userId}
```
Returns all events. If `userId` is provided, marks favorite events.

### List Favorite Events
```
GET /api/events/favorites?userId={userId}
```
Returns all favorite events for a specific user. `userId` is required.

### Add Favorite
```
POST /api/events/favorites
Content-Type: application/json

{
  "userId": "user123",
  "eventId": "event-001"
}
```
Adds an event to user's favorites.

### Remove Favorite
```
DELETE /api/events/favorites/{eventId}?userId={userId}
```
Removes an event from user's favorites.

### Health Check
```
GET /health
```
Returns server health status.

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `PORT` | Server port | No | `8080` |
| `ENV` | Environment (development/production) | No | `development` |
| `GOOGLE_CLOUD_PROJECT` | Google Cloud project ID | **YES** | `dancee-b5c0d` |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | Path to Firebase credentials file | No* | - |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase credentials as JSON string | No* | - |

**Important Notes:**
- `GOOGLE_CLOUD_PROJECT` is **REQUIRED** for Firebase to work properly
- Either `FIREBASE_SERVICE_ACCOUNT_PATH` or `FIREBASE_SERVICE_ACCOUNT_JSON` must be set
- If both are set, `FIREBASE_SERVICE_ACCOUNT_JSON` takes priority

## Firebase Configuration

### Required Configuration

**CRITICAL:** You must set `GOOGLE_CLOUD_PROJECT` environment variable:
```env
GOOGLE_CLOUD_PROJECT=dancee-b5c0d
```

Without this, you'll get the error: `project id is required to access Firestore`

### Authentication Methods

The service supports two methods for Firebase authentication:

1. **Service Account File** (for local development):
   - Set `FIREBASE_SERVICE_ACCOUNT_PATH` to the path of your JSON file
   - Example: `./secrets/serviceAccountKey.json`

2. **Service Account JSON String** (for cloud deployment):
   - Set `FIREBASE_SERVICE_ACCOUNT_JSON` with the entire JSON content
   - Useful for Fly.io, Cloud Run, etc.
   - Example:
     ```bash
     export FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/serviceAccountKey.json)"
     ```

If both are empty, the service will use application default credentials (requires `GOOGLE_CLOUD_PROJECT` to be set).

## Documentation

For more detailed information, see the `docs/` folder:
- **[API Documentation](./docs/API.md)** - Complete endpoint reference
- **[Deployment Guide](./docs/DEPLOYMENT.md)** - Production deployment
- **[Troubleshooting](./docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Quick Deployment

### Fly.io (Recommended)

```bash
# Set Firebase credentials as secret
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)" --app dancee-events

# Deploy
./deploy.sh
```

### Docker

```bash
# Set environment variable
export FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)"

# Run with docker-compose
docker-compose up -d
```

See [Deployment Guide](./docs/DEPLOYMENT.md) for detailed instructions.

## License

MIT
