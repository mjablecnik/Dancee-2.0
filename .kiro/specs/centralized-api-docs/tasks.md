# Implementation Plan: Centralized API Documentation Service

## Overview

This plan implements a standalone Node.js/TypeScript service that serves as the Single Source of Truth for all API documentation in the Dancee project. The service will run on port 3003 and provide a unified Swagger UI interface for exploring and testing APIs from dancee_events (port 8080) and dancee_scraper (port 3002).

## Tasks

- [x] 1. Initialize project structure and dependencies
  - Create `backend/dancee_api/` directory
  - Initialize Node.js project with TypeScript configuration
  - Install runtime dependencies (express, swagger-ui-express, js-yaml, cors, dotenv)
  - Install development dependencies (typescript, ts-node, nodemon, jest, eslint, prettier)
  - Create `.gitignore` file
  - Create `.env.example` with all required environment variables
  - Create `taskfile.yaml` with common development tasks
  - _Requirements: 11.4, 11.5_

- [x] 2. Set up TypeScript configuration and project structure
  - Create `tsconfig.json` with strict type checking
  - Create directory structure: `src/`, `src/config/`, `src/aggregator/`, `src/routes/`, `src/middleware/`, `specs/`, `docs/`
  - Create `src/index.ts` as application entry point
  - _Requirements: 1.1_

- [x] 3. Implement configuration management
  - [x] 3.1 Create `src/config/app.config.ts` for environment-based configuration
    - Define ServerConfig interface
    - Load PORT, HOST, NODE_ENV from environment variables
    - Load service URLs (EVENTS_SERVICE_URL, SCRAPER_SERVICE_URL)
    - Load CORS origins configuration
    - _Requirements: 9.1, 9.5_
  
  - [x] 3.2 Create `src/config/services.config.ts` for service definitions
    - Define ServiceDefinition and ServiceConfig interfaces
    - Configure dancee_events service (id, name, version, description, baseUrl, specFile)
    - Configure dancee_scraper service (id, name, version, description, baseUrl, specFile)
    - Define UI configuration (title, description, defaultService, theme)
    - _Requirements: 9.3, 9.4_

- [-] 4. Implement OpenAPI specification aggregator
  - [-] 4.1 Create `src/aggregator/spec-validator.ts` for OpenAPI validation
    - Implement validateSpec function to check OpenAPI 3.0 compliance
    - Validate required fields (openapi, info, paths)
    - Return ValidationResult with errors if validation fails
    - _Requirements: 1.2, 12.1_
  
  - [x] 4.2 Create `src/aggregator/spec-aggregator.ts` for spec management
    - Implement SpecAggregator class with loadSpecs, getServiceList, getSpec methods
    - Load YAML and JSON specs from `specs/` directory using js-yaml
    - Validate each spec using spec-validator
    - Cache valid specs in memory
    - Log errors for invalid specs and exclude from service list
    - _Requirements: 1.1, 1.3, 7.3, 8.1, 8.2, 10.1_
  
  - [ ]* 4.3 Write unit tests for spec-aggregator
    - Test loading valid YAML and JSON specs
    - Test handling of invalid specs
    - Test handling of missing spec files
    - Test getServiceList returns all enabled services
    - Test getSpec returns cached specs
    - _Requirements: 1.3, 7.3, 8.2_

- [ ] 5. Implement Express server and middleware
  - [x] 5.1 Create `src/middleware/cors.middleware.ts` for CORS configuration
    - Configure CORS to allow all origins in development
    - Allow GET, POST, PUT, DELETE, PATCH, OPTIONS methods
    - Allow Content-Type and Authorization headers
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  
  - [x] 5.2 Create `src/middleware/error.middleware.ts` for error handling
    - Implement global error handler middleware
    - Return 500 status with generic error message for internal errors
    - Ensure no sensitive information is exposed in error messages
    - Log errors for debugging
    - _Requirements: 7.2, 7.5_
  
  - [x] 5.3 Create `src/server.ts` for Express server setup
    - Initialize Express application
    - Apply CORS middleware
    - Apply JSON body parser
    - Mount routes
    - Apply error handling middleware
    - Implement start() and stop() methods
    - Implement graceful shutdown on SIGTERM/SIGINT
    - _Requirements: 1.4, 1.5_
  
  - [ ]* 5.4 Write unit tests for middleware
    - Test CORS headers are present in responses
    - Test error handler returns 500 for internal errors
    - Test error handler doesn't expose sensitive data
    - _Requirements: 6.1, 7.2, 7.5_

- [ ] 6. Implement API routes
  - [x] 6.1 Create `src/routes/services.routes.ts` for service listing
    - Implement GET `/api/services` endpoint
    - Return JSON array of all enabled services with id, name, version, description, baseUrl, specPath
    - Return empty array with 200 status when no services available
    - Ensure response time < 100ms
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  
  - [x] 6.2 Create `src/routes/spec.routes.ts` for spec retrieval
    - Implement GET `/api/spec/:serviceId` endpoint
    - Validate serviceId parameter to prevent path traversal
    - Return OpenAPI spec as JSON for valid serviceId
    - Return 404 with error message for invalid serviceId
    - Serve specs from memory cache (no file system access)
    - Ensure response time < 100ms
    - _Requirements: 3.1, 3.2, 3.4, 3.5, 7.1, 7.4_
  
  - [x] 6.3 Implement health check endpoint
    - Create GET `/health` endpoint
    - Return overall service status and individual spec loading status
    - Return 200 status with "ok" when all specs loaded successfully
    - Ensure response time < 50ms
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  
  - [ ]* 6.4 Write integration tests for API routes
    - Test GET `/api/services` returns service list
    - Test GET `/api/spec/:serviceId` returns spec for valid ID
    - Test GET `/api/spec/:serviceId` returns 404 for invalid ID
    - Test GET `/health` returns health status
    - Test path traversal prevention in serviceId parameter
    - _Requirements: 2.1, 3.1, 3.2, 5.1, 7.4_

- [ ] 7. Integrate Swagger UI
  - [x] 7.1 Configure swagger-ui-express in server
    - Mount Swagger UI at root path `/`
    - Configure multi-spec support with service selector
    - Set up URLs for dancee-events and dancee-scraper specs
    - Enable explorer mode
    - _Requirements: 4.1, 4.2_
  
  - [x] 7.2 Configure Swagger UI options
    - Display service selector with all available services
    - Set default service to dancee-events
    - Enable "Try it out" functionality for API testing
    - _Requirements: 4.2, 4.3, 4.4_

- [x] 8. Checkpoint - Ensure server starts and basic endpoints work
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Generate OpenAPI specifications
  - [x] 9.1 Create `specs/events.openapi.yaml` for dancee_events API
    - Parse `backend/dancee_events/docs/API.md` documentation
    - Create OpenAPI 3.0 spec with info, servers, paths, components
    - Include development server (http://localhost:8080) and production server (https://dancee-events.fly.dev)
    - Document all endpoints with summary, description, parameters, request/response schemas
    - Include examples for request and response payloads
    - Document data models in components/schemas section
    - _Requirements: 3.3, 8.1, 8.3, 9.2, 9.3, 12.1, 12.2, 12.3, 12.4, 12.5_
  
  - [x] 9.2 Create `specs/scraper.openapi.yaml` for dancee_scraper API
    - Parse `backend/dancee_scraper/README.md` and code
    - Create OpenAPI 3.0 spec with info, servers, paths, components
    - Include development server (http://localhost:3002) and production server (https://dancee-scraper.fly.dev)
    - Document all endpoints with summary, description, parameters, request/response schemas
    - Include examples for request and response payloads
    - Document DTOs in components/schemas section
    - _Requirements: 3.3, 8.1, 8.3, 9.2, 9.4, 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 10. Create documentation files
  - [x] 10.1 Create `README.md` with project overview
    - Write overview of the centralized API documentation service
    - Include quick start instructions
    - Document available endpoints
    - Explain Single Source of Truth principle
    - _Requirements: 11.1_
  
  - [x] 10.2 Create `docs/SETUP.md` with detailed setup instructions
    - Document prerequisites (Node.js version, dependencies)
    - Provide step-by-step installation instructions
    - Explain environment variable configuration
    - Include troubleshooting section
    - _Requirements: 11.2_
  
  - [x] 10.3 Create `docs/USAGE.md` with usage examples
    - Document how to access Swagger UI
    - Explain how to switch between services
    - Provide examples of using the API endpoints
    - Show how to test APIs from Swagger UI
    - _Requirements: 11.3_
  
  - [x] 10.4 Create `docs/CONTRIBUTING.md` with contribution guidelines
    - Explain how to add new service specifications
    - Document OpenAPI spec standards and best practices
    - Provide guidelines for updating existing specs
    - Include code style and testing requirements

- [ ] 11. Implement application entry point
  - [x] 11.1 Complete `src/index.ts` implementation
    - Load configuration from app.config
    - Initialize SpecAggregator and load all specs
    - Create and configure Express server
    - Start server on configured port
    - Set up graceful shutdown handlers
    - Log startup information (port, loaded services)
    - _Requirements: 1.1, 1.4, 1.5_
  
  - [ ]* 11.2 Write integration tests for full application startup
    - Test server starts successfully
    - Test all specs are loaded on startup
    - Test graceful shutdown works correctly
    - Test server responds to requests after startup
    - _Requirements: 1.1, 1.4, 1.5_

- [x] 12. Add task automation commands
  - Update `taskfile.yaml` with all development tasks
  - Add `task install` - Install dependencies
  - Add `task dev` - Start development server with hot reload (nodemon)
  - Add `task build` - Build TypeScript to JavaScript
  - Add `task start` - Start production server
  - Add `task test` - Run all tests
  - Add `task test-watch` - Run tests in watch mode
  - Add `task lint` - Run ESLint
  - Add `task format` - Format code with Prettier
  - Add `task clean` - Clean build artifacts
  - _Requirements: 11.5_

- [x] 13. Final checkpoint - Complete testing and validation
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- OpenAPI specs are stored ONLY in `backend/dancee_api/specs/` - individual services do NOT have their own specs
- The service uses TypeScript with strict type checking for better code quality
- All documentation follows Dancee project conventions (English only, docs/ folder structure)
- Environment variables allow configuration for different deployment environments
- Swagger UI provides interactive testing without needing separate API client tools
