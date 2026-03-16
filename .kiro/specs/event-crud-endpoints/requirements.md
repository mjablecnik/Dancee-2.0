# Requirements Document

## Introduction

This feature adds full CRUD (Create, Read, Update, Delete) operations for individual dance events to the `dancee_events` Go backend service. Currently, the service only supports listing all events via `GET /api/events/list`. This feature introduces endpoints to create, retrieve, update, and delete a single event by its ID. Additionally, the existing seed endpoint (`POST /api/events/seed`) and its associated logic will be removed, as it is no longer needed.

## Glossary

- **Events_API**: The `dancee_events` Go backend service that manages dance event data via REST endpoints, backed by Firebase/Firestore.
- **Event**: A dance event entity stored in Firestore, containing fields such as title, organizer, venue, startTime, dances, and optional fields like description, endTime, duration, info, and parts.
- **Event_ID**: A unique string identifier for an Event, corresponding to the Firestore document ID.
- **OpenAPI_Spec**: The centralized API documentation file located at `backend/dancee_api/specs/events.openapi.yaml`.

## Requirements

### Requirement 1: Get Single Event by ID

**User Story:** As an API consumer, I want to retrieve a single event by its ID, so that I can display detailed information about a specific event.

#### Acceptance Criteria

1. WHEN a GET request is received at `/api/events/{id}` with a valid Event_ID, THE Events_API SHALL return the corresponding Event as a JSON object with HTTP status 200.
2. WHEN a GET request is received at `/api/events/{id}` with a `userId` query parameter, THE Events_API SHALL include the `isFavorite` field indicating whether the Event is in the specified user's favorites.
3. WHEN a GET request is received at `/api/events/{id}` with an Event_ID that does not exist in Firestore, THE Events_API SHALL return an error response with HTTP status 404 and a JSON body containing an `error` field with the message "Event not found".
4. THE Events_API SHALL include the computed `isPast` field in the returned Event, calculated based on the Event's endTime or startTime.

### Requirement 2: Create a New Event

**User Story:** As an API consumer, I want to create a new event, so that I can add dance events to the system.

#### Acceptance Criteria

1. WHEN a POST request is received at `/api/events` with a valid Event JSON body, THE Events_API SHALL create the Event in Firestore and return the created Event (including its generated Event_ID) with HTTP status 201.
2. WHEN a POST request is received at `/api/events` with a JSON body missing required fields (title, organizer, venue, startTime, dances), THE Events_API SHALL return an error response with HTTP status 400 and a JSON body describing the validation error.
3. THE Events_API SHALL generate a unique Event_ID for each newly created Event using Firestore's auto-generated document ID.

### Requirement 3: Update an Existing Event

**User Story:** As an API consumer, I want to update an existing event, so that I can correct or modify event details.

#### Acceptance Criteria

1. WHEN a PUT request is received at `/api/events/{id}` with a valid Event_ID and a valid Event JSON body, THE Events_API SHALL update the Event in Firestore and return the updated Event with HTTP status 200.
2. WHEN a PUT request is received at `/api/events/{id}` with an Event_ID that does not exist in Firestore, THE Events_API SHALL return an error response with HTTP status 404 and a JSON body containing an `error` field with the message "Event not found".
3. WHEN a PUT request is received at `/api/events/{id}` with a JSON body missing required fields (title, organizer, venue, startTime, dances), THE Events_API SHALL return an error response with HTTP status 400 and a JSON body describing the validation error.

### Requirement 4: Delete an Event

**User Story:** As an API consumer, I want to delete an event, so that I can remove events that are no longer relevant.

#### Acceptance Criteria

1. WHEN a DELETE request is received at `/api/events/{id}` with a valid Event_ID that exists in Firestore, THE Events_API SHALL delete the Event from Firestore and return HTTP status 204 with no body.
2. WHEN a DELETE request is received at `/api/events/{id}` with an Event_ID that does not exist in Firestore, THE Events_API SHALL return an error response with HTTP status 404 and a JSON body containing an `error` field with the message "Event not found".
3. WHEN an Event is deleted, THE Events_API SHALL also remove all favorite references to that Event across all users.

### Requirement 5: Remove Seed Endpoint

**User Story:** As a developer, I want to remove the seed endpoint, so that the API surface is clean and does not expose development-only functionality in production.

#### Acceptance Criteria

1. THE Events_API SHALL remove the `POST /api/events/seed` endpoint and return HTTP status 404 for requests to that path.
2. THE Events_API SHALL remove all seed-related logic from the service layer, including the `SeedEvents` method and its sample data generation code.
3. THE Events_API SHALL remove the `SeedEventsResponse` schema and the seed endpoint definition from the OpenAPI_Spec.

### Requirement 6: OpenAPI Specification Synchronization

**User Story:** As a developer, I want the centralized API documentation to reflect the new CRUD endpoints, so that API consumers have accurate and up-to-date documentation.

#### Acceptance Criteria

1. WHEN a new CRUD endpoint is added to the Events_API, THE OpenAPI_Spec SHALL include the endpoint definition with path, method, parameters, request body schema, and response schemas.
2. WHEN the seed endpoint is removed from the Events_API, THE OpenAPI_Spec SHALL remove the corresponding path definition and any schemas used exclusively by the seed endpoint.
3. THE OpenAPI_Spec SHALL include request body schemas for the create and update operations, documenting all required and optional fields.
