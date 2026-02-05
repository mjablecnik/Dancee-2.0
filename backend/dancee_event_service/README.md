# Dancee Event Service

A REST API service for the Dancee App, built with Dart and Shelf.

## Getting Started

### Prerequisites

- Dart SDK 3.10.4 or higher
- Task (for running commands)

### Installation

Install dependencies:

```bash
task get-deps
```

### Running the Server

Start the development server:

```bash
task run
```

The server will start on port 8080 by default. You can override this with the `PORT` environment variable.

### Available Endpoints

- `GET /` - Hello World endpoint
- `GET /health` - Health check endpoint

### Testing

Test the endpoints:

```bash
# Hello World
curl http://localhost:8080/

# Health check
curl http://localhost:8080/health
```

### Available Tasks

- `task run` - Run the server in development mode
- `task run-watch` - Run the server with hot reload
- `task get-deps` - Install dependencies
- `task test` - Run tests
- `task clean` - Clean the project
- `task build` - Compile to native executable
- `task docker-build` - Build Docker image
- `task docker-run` - Run Docker container

## Project Structure

```
dancee_event_service/
├── bin/
│   └── server.dart          # Main server entry point
├── test/
│   └── server_test.dart     # Server tests
├── pubspec.yaml             # Dependencies
├── taskfile.yaml            # Task automation
└── README.md                # This file
```

## Development

The service uses shelf_plus for routing and middleware. All code follows English-only conventions for international collaboration.

## Docker

Build and run with Docker:

```bash
task docker-build
task docker-run
```

## License

Part of the Dancee App project.
