# Dancee Server

A simple NestJS REST API server for the Dancee application.

## Prerequisites

- Node.js (v18 or higher)
- npm

## Installation

```bash
task install
# or
npm install
```

## Running the Application

### Development Mode (with hot reload)
```bash
task dev
# or
npm run start:dev
```

The server will start on `http://localhost:3001`

### Production Mode
```bash
task build
task start
# or
npm run build
npm run start:prod
```

## Available Tasks

- `task install` - Install dependencies
- `task dev` - Start development server with hot reload
- `task start` - Start production server
- `task build` - Build the application
- `task lint` - Run linter
- `task format` - Format code with prettier
- `task test` - Run tests
- `task test-watch` - Run tests in watch mode
- `task test-e2e` - Run end-to-end tests
- `task clean` - Clean build artifacts

## API Endpoints

### GET /
Returns a simple "Hello World!" message.

**Response:**
```
Hello World!
```

## Project Structure

```
src/
├── app.controller.ts    # Main controller with routes
├── app.module.ts        # Root module
├── app.service.ts       # Business logic
└── main.ts             # Application entry point
```

## Features

- ✅ CORS enabled for frontend communication
- ✅ Hot reload in development mode
- ✅ TypeScript support
- ✅ ESLint and Prettier configured
- ✅ Jest testing setup
- ✅ Task automation with Taskfile

## Development

The server runs on port 3001 by default (configurable via PORT environment variable).

CORS is enabled to allow requests from the Flutter frontend application.
