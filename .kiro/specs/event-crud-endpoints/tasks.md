# Implementation Plan: Event CRUD Endpoints

## Overview

This plan implements full CRUD operations for dance events in the `dancee_events` Go backend service. The implementation follows the existing three-layer architecture (handlers → services → repositories) and uses Go with Gin framework and Firestore.

## Tasks

- [ ] 1. Add CreateEventRequest model and validation
  - [ ] 1.1 Add CreateEventRequest struct to `internal/models/event.go`
    - Add struct with Gin binding tags for required field validation
    - Add `ToEvent()` method to convert request to Event model
    - _Requirements: 2.2, 3.3_

- [ ] 2. Implement repository layer CRUD operations
  - [ ] 2.1 Add CreateEvent method to `internal/repositories/event_repository.go`
    - Create event with Firestore auto-generated document ID
    - Return the generated ID
    - _Requirements: 2.1, 2.3_
  - [ ] 2.2 Add UpdateEvent method to `internal/repositories/event_repository.go`
    - Overwrite existing event document by ID
    - _Requirements: 3.1_
  - [ ] 2.3 Add DeleteEvent method to `internal/repositories/event_repository.go`
    - Delete event document by ID
    - _Requirements: 4.1_
  - [ ] 2.4 Remove initializeSampleData from `internal/repositories/event_repository.go`
    - Remove the method and its call in NewEventRepository
    - _Requirements: 5.2_
  - [ ] 2.5 Add RemoveFavoritesByEventID method to `internal/repositories/favorites_repository.go`
    - Query all user documents in favorites collection
    - Delete matching event sub-document for each user
    - _Requirements: 4.3_

- [ ] 3. Implement service layer CRUD operations
  - [ ] 3.1 Add GetEventByID method to `internal/services/event_service.go`
    - Retrieve single event by ID
    - Mark isFavorite if userId provided
    - Mark isPast status
    - Return "event not found" error for non-existent IDs
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  - [ ] 3.2 Add CreateEvent method to `internal/services/event_service.go`
    - Create event via repository
    - Return created event with generated ID
    - _Requirements: 2.1_
  - [ ] 3.3 Add UpdateEvent method to `internal/services/event_service.go`
    - Check event exists, return error if not
    - Update event via repository
    - Return updated event
    - _Requirements: 3.1, 3.2_
  - [ ] 3.4 Add DeleteEvent method to `internal/services/event_service.go`
    - Check event exists, return error if not
    - Delete event via repository
    - Cascade delete favorites via RemoveFavoritesByEventID
    - _Requirements: 4.1, 4.2, 4.3_
  - [ ] 3.5 Remove SeedEvents method from `internal/services/event_service.go`
    - Remove the entire SeedEvents method
    - _Requirements: 5.2_

- [ ] 4. Checkpoint - Verify repository and service layers
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement handler layer CRUD operations
  - [ ] 5.1 Add GetEvent handler to `internal/handlers/event_handler.go`
    - Parse event ID from path parameter
    - Parse optional userId from query parameter
    - Return 200 with event or 404 if not found
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  - [ ] 5.2 Add CreateEvent handler to `internal/handlers/event_handler.go`
    - Bind and validate CreateEventRequest
    - Return 400 for validation errors
    - Return 201 with created event
    - _Requirements: 2.1, 2.2_
  - [ ] 5.3 Add UpdateEvent handler to `internal/handlers/event_handler.go`
    - Parse event ID from path parameter
    - Bind and validate CreateEventRequest
    - Return 400 for validation errors, 404 if not found
    - Return 200 with updated event
    - _Requirements: 3.1, 3.2, 3.3_
  - [ ] 5.4 Add DeleteEvent handler to `internal/handlers/event_handler.go`
    - Parse event ID from path parameter
    - Return 404 if not found
    - Return 204 on success
    - _Requirements: 4.1, 4.2_
  - [ ] 5.5 Remove SeedEvents handler from `internal/handlers/event_handler.go`
    - Remove the entire SeedEvents method
    - _Requirements: 5.1_

- [ ] 6. Update route registration and CORS
  - [ ] 6.1 Update route registration in `main.go`
    - Add GET /:id route (after /list and /favorites routes)
    - Add POST / route for create
    - Add PUT /:id route for update
    - Add DELETE /:id route for delete
    - Remove POST /seed route
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1_
  - [ ] 6.2 Update CORS middleware in `main.go`
    - Add PUT to Access-Control-Allow-Methods header
    - _Requirements: 3.1_

- [ ] 7. Checkpoint - Verify all endpoints work
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Update OpenAPI specification
  - [ ] 8.1 Add GET /api/events/{id} path to `backend/dancee_api/specs/events.openapi.yaml`
    - Add path with id parameter and userId query parameter
    - Add 200 and 404 responses
    - _Requirements: 6.1_
  - [ ] 8.2 Add POST /api/events path to `backend/dancee_api/specs/events.openapi.yaml`
    - Add path with CreateEventRequest body
    - Add 201 and 400 responses
    - _Requirements: 6.1, 6.3_
  - [ ] 8.3 Add PUT /api/events/{id} path to `backend/dancee_api/specs/events.openapi.yaml`
    - Add path with id parameter and CreateEventRequest body
    - Add 200, 400, and 404 responses
    - _Requirements: 6.1, 6.3_
  - [ ] 8.4 Add DELETE /api/events/{id} path to `backend/dancee_api/specs/events.openapi.yaml`
    - Add path with id parameter
    - Add 204 and 404 responses
    - _Requirements: 6.1_
  - [ ] 8.5 Add CreateEventRequest schema to `backend/dancee_api/specs/events.openapi.yaml`
    - Document required fields: title, organizer, venue, startTime, dances
    - Document optional fields: description, endTime, duration, info, parts
    - _Requirements: 6.3_
  - [ ] 8.6 Remove seed endpoint and schema from `backend/dancee_api/specs/events.openapi.yaml`
    - Remove POST /api/events/seed path
    - Remove SeedEventsResponse schema
    - _Requirements: 6.2_

- [ ] 9. Implement property-based tests
  - [ ]* 9.1 Set up rapid library and test infrastructure
    - Add rapid to go.mod
    - Create test file structure
    - _Requirements: Testing_
  - [ ]* 9.2 Write property test for GET event returns correct data with isFavorite
    - **Property 1: GET event returns correct data with correct isFavorite**
    - **Validates: Requirements 1.1, 1.2**
  - [ ]* 9.3 Write property test for isPast computation
    - **Property 2: isPast is correctly computed**
    - **Validates: Requirements 1.4**
  - [ ]* 9.4 Write property test for non-existent ID returns 404
    - **Property 3: Non-existent ID returns 404**
    - **Validates: Requirements 1.3, 3.2, 4.2**
  - [ ]* 9.5 Write property test for create event round-trip
    - **Property 4: Create event round-trip**
    - **Validates: Requirements 2.1**
  - [ ]* 9.6 Write property test for missing required fields returns 400
    - **Property 5: Missing required fields returns 400**
    - **Validates: Requirements 2.2, 3.3**
  - [ ]* 9.7 Write property test for created event IDs are unique
    - **Property 6: Created event IDs are unique**
    - **Validates: Requirements 2.3**
  - [ ]* 9.8 Write property test for update event round-trip
    - **Property 7: Update event round-trip**
    - **Validates: Requirements 3.1**
  - [ ]* 9.9 Write property test for delete removes event
    - **Property 8: Delete removes event**
    - **Validates: Requirements 4.1**
  - [ ]* 9.10 Write property test for delete cascades to favorites
    - **Property 9: Delete cascades to favorites**
    - **Validates: Requirements 4.3**

- [ ] 10. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties using the `rapid` library
- Route ordering is critical: named routes (`/list`, `/favorites`) must be registered before parameterized `/:id` route
