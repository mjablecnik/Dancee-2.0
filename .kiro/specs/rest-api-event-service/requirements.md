# Requirements Document

## Introduction

This document specifies the requirements for a REST API service that provides dance event data and favorite management functionality for the Dancee mobile and web application. The service will be implemented in Dart using the shelf framework and will initially use in-memory storage for events and user favorites.

The API serves as the backend for the Flutter frontend application, providing endpoints for listing events, managing user favorites, and supporting future features like event search and filtering.

## Glossary

- **Event_Service**: The Dart backend REST API service that manages dance event data
- **Event**: A dance event with details including venue, timing, dance styles, and event parts
- **Favorite**: A user's saved preference for a specific event
- **User_ID**: A string identifier for a user (initially simple, to be replaced with authentication)
- **Event_ID**: A unique string identifier for an event
- **In_Memory_Storage**: Dart collections (List, Map, Set) used for temporary data storage
- **CORS**: Cross-Origin Resource Sharing headers required for web frontend access
- **Event_Part**: A segment of an event (e.g., workshop, party) with its own schedule
- **Venue**: The physical location where an event takes place
- **Address**: The physical address of a venue
- **Dancee_Shared**: A shared Dart package containing common code (models, utilities) used by both frontend and backend

## Requirements

### Requirement 1: List All Events

**User Story:** As a mobile app user, I want to retrieve all available dance events, so that I can browse and discover events to attend.

#### Acceptance Criteria

1. WHEN a GET request is made to /api/events, THE Event_Service SHALL return a JSON array of all events
2. WHEN returning events, THE Event_Service SHALL include complete event details (id, title, description, organizer, venue, timing, dances, info, parts)
3. WHEN returning events, THE Event_Service SHALL include nested venue information (name, address, description, coordinates)
4. WHEN returning events, THE Event_Service SHALL include nested address information (street, city, postal code, country)
5. WHEN returning events, THE Event_Service SHALL include all event parts with their schedules, instructors, and DJs
6. WHEN the request is successful, THE Event_Service SHALL return HTTP status code 200
7. WHEN returning events, THE Event_Service SHALL format dates and times as ISO 8601 strings
8. WHEN returning events, THE Event_Service SHALL format durations as total seconds (integer)

### Requirement 2: List User Favorite Events

**User Story:** As a mobile app user, I want to retrieve my favorite events, so that I can quickly access events I'm interested in.

#### Acceptance Criteria

1. WHEN a GET request is made to /api/favorites with a userId query parameter, THE Event_Service SHALL return a JSON array of the user's favorite events (full event objects)
2. WHEN a userId is not provided, THE Event_Service SHALL return HTTP status code 400 with an error message
3. WHEN a userId has no favorites, THE Event_Service SHALL return an empty JSON array with HTTP status code 200
4. WHEN the request is successful, THE Event_Service SHALL return HTTP status code 200

### Requirement 3: Add Event to Favorites

**User Story:** As a mobile app user, I want to add an event to my favorites, so that I can save events I'm interested in attending.

#### Acceptance Criteria

1. WHEN a POST request is made to /api/favorites with userId and eventId in the request body, THE Event_Service SHALL add the event to the user's favorites
2. WHEN the request body is missing userId or eventId, THE Event_Service SHALL return HTTP status code 400 with an error message
3. WHEN an event is already in the user's favorites, THE Event_Service SHALL treat it as idempotent and return success
4. WHEN the eventId does not exist, THE Event_Service SHALL return HTTP status code 404 with an error message
5. WHEN the favorite is successfully added, THE Event_Service SHALL return HTTP status code 201
6. WHEN the favorite is successfully added, THE Event_Service SHALL return a JSON response confirming the action

### Requirement 4: Remove Event from Favorites

**User Story:** As a mobile app user, I want to remove an event from my favorites, so that I can manage my list of saved events.

#### Acceptance Criteria

1. WHEN a DELETE request is made to /api/favorites/:eventId with a userId query parameter, THE Event_Service SHALL remove the event from the user's favorites
2. WHEN the userId query parameter is missing, THE Event_Service SHALL return HTTP status code 400 with an error message
3. WHEN the event is not in the user's favorites, THE Event_Service SHALL treat it as idempotent and return success
4. WHEN the favorite is successfully removed, THE Event_Service SHALL return HTTP status code 204 with no content
5. WHEN the eventId does not exist, THE Event_Service SHALL return HTTP status code 404 with an error message

### Requirement 5: CORS Support for Web Frontend

**User Story:** As a web application, I want the API to support CORS, so that I can make requests from the browser without security restrictions.

#### Acceptance Criteria

1. WHEN any request is made to the Event_Service, THE Event_Service SHALL include Access-Control-Allow-Origin header in the response
2. WHEN a preflight OPTIONS request is made, THE Event_Service SHALL return HTTP status code 200 with appropriate CORS headers
3. WHEN a preflight OPTIONS request is made, THE Event_Service SHALL include Access-Control-Allow-Methods header listing supported HTTP methods
4. WHEN a preflight OPTIONS request is made, THE Event_Service SHALL include Access-Control-Allow-Headers header listing supported request headers
5. THE Event_Service SHALL support requests from any origin (wildcard * for development)

### Requirement 6: HTTP Status Codes and Error Handling

**User Story:** As a frontend developer, I want consistent HTTP status codes and error messages, so that I can handle API responses appropriately.

#### Acceptance Criteria

1. WHEN a request is successful, THE Event_Service SHALL return appropriate 2xx status codes (200, 201, 204)
2. WHEN a request has invalid parameters, THE Event_Service SHALL return HTTP status code 400 with a descriptive error message
3. WHEN a requested resource does not exist, THE Event_Service SHALL return HTTP status code 404 with a descriptive error message
4. WHEN an internal error occurs, THE Event_Service SHALL return HTTP status code 500 with a generic error message
5. WHEN returning error responses, THE Event_Service SHALL include a JSON body with an "error" field containing the error message
6. WHEN returning error responses, THE Event_Service SHALL log the error details for debugging

### Requirement 7: In-Memory Data Storage

**User Story:** As a developer, I want the service to use in-memory storage initially, so that I can develop and test the API without external dependencies.

#### Acceptance Criteria

1. THE Event_Service SHALL store events in a Dart List collection
2. THE Event_Service SHALL store user favorites in a Dart Map collection mapping userId to List of favorite Events
3. WHEN the service starts, THE Event_Service SHALL pre-populate the event list with sample dance events
4. WHEN the service restarts, THE Event_Service SHALL reset all data to the initial sample state
5. THE Event_Service SHALL support concurrent access to in-memory collections safely

### Requirement 8: JSON Serialization and Deserialization

**User Story:** As a system component, I want proper JSON serialization, so that data can be transmitted between frontend and backend correctly.

#### Acceptance Criteria

1. WHEN serializing events to JSON, THE Event_Service SHALL convert all Dart objects to JSON-compatible maps
2. WHEN serializing dates, THE Event_Service SHALL use ISO 8601 format strings
3. WHEN serializing enums, THE Event_Service SHALL use string representations
4. WHEN deserializing request bodies, THE Event_Service SHALL parse JSON strings to Dart objects
5. WHEN deserialization fails, THE Event_Service SHALL return HTTP status code 400 with an error message
6. WHEN serializing nested objects (Venue, Address, EventPart, EventInfo), THE Event_Service SHALL recursively convert all fields

### Requirement 9: Service Health Check

**User Story:** As a DevOps engineer, I want a health check endpoint, so that I can monitor the service status.

#### Acceptance Criteria

1. WHEN a GET request is made to /health, THE Event_Service SHALL return HTTP status code 200
2. WHEN a GET request is made to /health, THE Event_Service SHALL return a JSON response with status "ok"
3. WHEN a GET request is made to /health, THE Event_Service SHALL include the service name in the response
4. THE Event_Service SHALL respond to health checks within 100 milliseconds

### Requirement 10: Request Logging

**User Story:** As a developer, I want all API requests to be logged, so that I can debug issues and monitor usage.

#### Acceptance Criteria

1. WHEN any request is received, THE Event_Service SHALL log the HTTP method and path
2. WHEN any request is received, THE Event_Service SHALL log the response status code
3. WHEN any request is received, THE Event_Service SHALL log the request processing time
4. THE Event_Service SHALL use the shelf logRequests middleware for request logging
5. THE Event_Service SHALL output logs to standard output for container compatibility

### Requirement 11: Shared Code Organization

**User Story:** As a developer, I want shared code between frontend and backend to be in a common package, so that I can maintain consistency and avoid code duplication.

#### Acceptance Criteria

1. WHEN defining data models used by both frontend and backend, THE Event_Service SHALL use models from the dancee_shared package
2. WHEN the dancee_shared package is updated, THE Event_Service SHALL use the updated models without modification
3. THE Event_Service SHALL NOT duplicate model definitions that exist in dancee_shared
4. THE Event_Service SHALL import Event, Venue, Address, EventPart, EventInfo, and EventPartType from dancee_shared
5. THE Event_Service SHALL add dancee_shared as a dependency in pubspec.yaml
