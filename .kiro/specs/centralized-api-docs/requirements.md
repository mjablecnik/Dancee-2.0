# Requirements Document: Centralized API Documentation Service

## Introduction

The Centralized API Documentation Service is a standalone Node.js/TypeScript service that serves as the Single Source of Truth for all API documentation in the Dancee project. It provides a unified Swagger UI interface where developers can explore and test APIs from multiple backend services through a single entry point on port 3003.

## Glossary

- **API_Documentation_Service**: The centralized Node.js/TypeScript service running on port 3003 that serves OpenAPI specifications and Swagger UI
- **Spec_Aggregator**: Component responsible for loading, validating, and serving OpenAPI specifications from the file system
- **OpenAPI_Spec**: OpenAPI 3.0 compliant YAML or JSON file describing a backend service's API
- **Swagger_UI**: Interactive web interface for exploring and testing API endpoints
- **Backend_Service**: Individual microservices (dancee_events, dancee_scraper) that implement business logic
- **Service_ID**: Unique kebab-case identifier for a backend service (e.g., "dancee-events")
- **Spec_Storage**: Directory at `backend/dancee_api/specs/` containing all OpenAPI specifications

## Requirements

### Requirement 1: Service Initialization and Configuration

**User Story:** As a developer, I want the API documentation service to start up reliably and load all specifications, so that I can access API documentation immediately.

#### Acceptance Criteria

1. WHEN the API_Documentation_Service starts, THE system SHALL load all OpenAPI_Specs from Spec_Storage into memory
2. WHEN the API_Documentation_Service starts, THE system SHALL validate each OpenAPI_Spec against OpenAPI 3.0 schema
3. IF an OpenAPI_Spec fails validation, THEN THE system SHALL log the error and exclude that service from the available services list
4. WHEN all valid OpenAPI_Specs are loaded, THE system SHALL bind to port 3003 and accept HTTP connections
5. WHEN the API_Documentation_Service receives a shutdown signal, THE system SHALL gracefully close all connections and exit

### Requirement 2: Service Discovery and Listing

**User Story:** As a developer, I want to see a list of all available backend services, so that I can choose which API documentation to view.

#### Acceptance Criteria

1. WHEN a GET request is made to `/api/services`, THE API_Documentation_Service SHALL return a JSON array of all enabled services
2. FOR each service in the list, THE API_Documentation_Service SHALL include service ID, name, version, description, base URL, and spec path
3. WHEN no services are available, THE API_Documentation_Service SHALL return an empty array with HTTP status 200
4. THE API_Documentation_Service SHALL respond to service list requests within 100 milliseconds

### Requirement 3: OpenAPI Specification Retrieval

**User Story:** As a developer, I want to retrieve OpenAPI specifications for specific services, so that I can view detailed API documentation.

#### Acceptance Criteria

1. WHEN a GET request is made to `/api/spec/:serviceId` with a valid Service_ID, THE API_Documentation_Service SHALL return the corresponding OpenAPI_Spec as JSON
2. WHEN a GET request is made to `/api/spec/:serviceId` with an invalid Service_ID, THE API_Documentation_Service SHALL return HTTP status 404 with an error message
3. THE OpenAPI_Spec SHALL include both development (localhost) and production (fly.dev) server URLs
4. THE API_Documentation_Service SHALL serve cached OpenAPI_Specs from memory without file system access
5. THE API_Documentation_Service SHALL respond to spec retrieval requests within 100 milliseconds

### Requirement 4: Swagger UI Interface

**User Story:** As a developer, I want to access an interactive Swagger UI, so that I can explore and test API endpoints visually.

#### Acceptance Criteria

1. WHEN a GET request is made to `/`, THE API_Documentation_Service SHALL serve the Swagger_UI HTML interface
2. THE Swagger_UI SHALL display a service selector with all available Backend_Services
3. WHEN a developer selects a service from the selector, THE Swagger_UI SHALL load and display that service's OpenAPI_Spec
4. THE Swagger_UI SHALL allow developers to execute API requests directly from the interface
5. THE Swagger_UI SHALL display request parameters, request bodies, and response schemas for each endpoint

### Requirement 5: Health Monitoring

**User Story:** As a system administrator, I want to check the health status of the documentation service, so that I can monitor its availability.

#### Acceptance Criteria

1. WHEN a GET request is made to `/health`, THE API_Documentation_Service SHALL return HTTP status 200 with a JSON health status object
2. THE health status object SHALL include overall service status and individual spec loading status for each Backend_Service
3. WHEN all OpenAPI_Specs are loaded successfully, THE health status SHALL indicate "ok"
4. THE API_Documentation_Service SHALL respond to health check requests within 50 milliseconds

### Requirement 6: CORS Configuration

**User Story:** As a frontend developer, I want to make API requests from the browser, so that I can test endpoints from the Swagger UI.

#### Acceptance Criteria

1. THE API_Documentation_Service SHALL include CORS headers in all HTTP responses
2. WHILE in development mode, THE API_Documentation_Service SHALL allow requests from all origins
3. THE API_Documentation_Service SHALL allow the following HTTP methods: GET, POST, PUT, DELETE, PATCH, OPTIONS
4. THE API_Documentation_Service SHALL allow standard headers including Content-Type and Authorization

### Requirement 7: Error Handling and Validation

**User Story:** As a developer, I want clear error messages when something goes wrong, so that I can troubleshoot issues quickly.

#### Acceptance Criteria

1. WHEN an invalid Service_ID is requested, THE API_Documentation_Service SHALL return a 404 error with the invalid Service_ID in the response
2. WHEN an internal error occurs, THE API_Documentation_Service SHALL return a 500 error with a generic error message
3. WHEN an OpenAPI_Spec file is missing, THE API_Documentation_Service SHALL log the error and continue loading other specs
4. THE API_Documentation_Service SHALL validate Service_ID parameters to prevent path traversal attacks
5. THE API_Documentation_Service SHALL not expose sensitive information in error messages

### Requirement 8: OpenAPI Specification Storage

**User Story:** As a technical lead, I want all OpenAPI specifications stored in a single location, so that API documentation is centralized and easy to maintain.

#### Acceptance Criteria

1. THE system SHALL store all OpenAPI_Specs exclusively in `backend/dancee_api/specs/` directory
2. THE system SHALL support OpenAPI_Specs in both YAML and JSON formats
3. WHEN a Backend_Service API changes, THE corresponding OpenAPI_Spec SHALL be updated in Spec_Storage only
4. THE Backend_Services SHALL NOT contain their own OpenAPI specifications or Swagger UI implementations
5. THE system SHALL maintain separate OpenAPI_Spec files for dancee_events and dancee_scraper services

### Requirement 9: Service Configuration

**User Story:** As a developer, I want to configure service URLs for different environments, so that documentation works in both development and production.

#### Acceptance Criteria

1. THE API_Documentation_Service SHALL read service URLs from environment variables
2. THE OpenAPI_Specs SHALL include server definitions for both development (localhost) and production (fly.dev) environments
3. FOR dancee_events, THE development URL SHALL be `http://localhost:8080` and production URL SHALL be `https://dancee-events.fly.dev`
4. FOR dancee_scraper, THE development URL SHALL be `http://localhost:3002` and production URL SHALL be `https://dancee-scraper.fly.dev`
5. THE API_Documentation_Service SHALL allow configuration of port, host, and CORS origins via environment variables

### Requirement 10: Performance and Caching

**User Story:** As a developer, I want fast access to API documentation, so that I don't waste time waiting for specs to load.

#### Acceptance Criteria

1. THE API_Documentation_Service SHALL cache all OpenAPI_Specs in memory after initial load
2. THE API_Documentation_Service SHALL serve spec retrieval requests within 100 milliseconds
3. THE API_Documentation_Service SHALL serve service list requests within 100 milliseconds
4. THE API_Documentation_Service SHALL support at least 10 concurrent spec retrieval requests
5. THE API_Documentation_Service SHALL serve Swagger_UI static assets efficiently without blocking other requests

### Requirement 11: Documentation and Developer Experience

**User Story:** As a new developer, I want clear setup instructions and usage documentation, so that I can start using the service quickly.

#### Acceptance Criteria

1. THE system SHALL include a README.md file in the project root with overview and quick start instructions
2. THE system SHALL include setup documentation in `docs/SETUP.md` with detailed installation steps
3. THE system SHALL include usage documentation in `docs/USAGE.md` with examples of accessing the API
4. THE system SHALL include a `.env.example` file with all required environment variables
5. THE system SHALL include a taskfile.yaml with common development tasks (install, dev, build, test)

### Requirement 12: OpenAPI Specification Standards

**User Story:** As an API consumer, I want consistent and complete API documentation, so that I understand how to use each endpoint.

#### Acceptance Criteria

1. THE OpenAPI_Specs SHALL comply with OpenAPI 3.0 specification format
2. FOR each API endpoint, THE OpenAPI_Spec SHALL include operation summary, description, parameters, request body schema, and response schemas
3. FOR each parameter, THE OpenAPI_Spec SHALL include name, location (path/query/header), data type, and whether it is required
4. FOR each response, THE OpenAPI_Spec SHALL include HTTP status code, description, and content schema
5. THE OpenAPI_Specs SHALL include example values for request and response payloads where applicable

