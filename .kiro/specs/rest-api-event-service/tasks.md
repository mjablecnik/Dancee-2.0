# Implementation Plan: REST API Event Service

## Overview

This implementation plan breaks down the REST API Event Service into discrete coding tasks. The service will be built incrementally, starting with the shared models, then the data layer, service layer, handlers, and finally the HTTP server with middleware. Each task builds on previous work, with testing integrated throughout.

## Tasks

- [x] 1. Add JSON serialization to shared models
  - Navigate to shared/dancee_shared package
  - Verify Event, Venue, Address, EventPart, EventInfo models exist
  - Add toJson() and fromJson() methods to all models if not present
  - Handle ISO 8601 date serialization
  - Handle duration as seconds (integer)
  - Handle enum serialization to strings (EventPartType, EventInfoType)
  - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.7, 1.8, 8.1, 8.2, 8.3, 8.6, 11.1, 11.2, 11.4_

- [ ]* 1.1 Write property test for Event serialization round-trip
  - **Property 1: Event Serialization Round-Trip**
  - **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 1.7, 1.8, 8.1, 8.2, 8.6**

- [ ]* 1.2 Write property test for enum serialization
  - **Property 8: Enum Serialization to Strings**
  - **Validates: Requirements 8.3**

- [x] 2. Update dancee_event_service dependencies
  - Add dancee_shared as path dependency in pubspec.yaml (path: ../../shared/dancee_shared)
  - Add dart:convert for JSON handling
  - Verify all dependencies are compatible
  - Run dart pub get
  - _Requirements: 11.5_

- [ ] 3. Implement repository layer
  - [x] 3.1 Create EventRepository with in-memory storage
    - Create lib/repositories/event_repository.dart
    - Implement List<Event> storage
    - Implement getAllEvents(), eventExists(), getEventById()
    - Pre-populate with sample dance events (5-10 events)
    - _Requirements: 7.1, 7.3_
  
  - [ ]* 3.2 Write unit tests for EventRepository
    - Test initialization populates events
    - Test getAllEvents returns all events
    - Test eventExists for existing and non-existent events
    - Test getEventById returns correct event
    - _Requirements: 7.1, 7.3_
  
  - [x] 3.3 Create FavoritesRepository with in-memory storage
    - Create lib/repositories/favorites_repository.dart
    - Implement Map<String, List<Event>> storage
    - Implement getFavorites(), addFavorite(), removeFavorite()
    - Ensure addFavorite is idempotent (no duplicates)
    - _Requirements: 7.2_
  
  - [ ]* 3.4 Write unit tests for FavoritesRepository
    - Test getFavorites returns empty list for new user
    - Test addFavorite adds event to favorites
    - Test addFavorite idempotency
    - Test removeFavorite removes event
    - Test removeFavorite idempotency
    - _Requirements: 7.2_

- [ ] 4. Implement service layer
  - [x] 4.1 Create ServiceResult class
    - Create lib/models/service_result.dart
    - Implement success and error factory constructors
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [x] 4.2 Create EventService
    - Create lib/services/event_service.dart
    - Implement getAllEvents() method
    - Wire to EventRepository
    - _Requirements: 1.1_
  
  - [ ]* 4.3 Write unit tests for EventService
    - Test getAllEvents returns all events from repository
    - _Requirements: 1.1_
  
  - [x] 4.4 Create FavoritesService
    - Create lib/services/favorites_service.dart
    - Implement getFavorites(), addFavorite(), removeFavorite()
    - Validate eventId exists before adding/removing
    - Return appropriate ServiceResult with status codes
    - _Requirements: 2.1, 3.1, 3.4, 4.1, 4.5_
  
  - [ ]* 4.5 Write unit tests for FavoritesService
    - Test getFavorites returns correct favorites
    - Test addFavorite with valid eventId succeeds
    - Test addFavorite with invalid eventId returns 404 error
    - Test removeFavorite with valid eventId succeeds
    - Test removeFavorite with invalid eventId returns 404 error
    - _Requirements: 2.1, 3.1, 3.4, 4.1, 4.5_

- [x] 5. Checkpoint - Ensure all tests pass
  - Run dart test to verify all unit and property tests pass
  - Ensure all tests pass, ask the user if questions arise

- [ ] 6. Implement API handlers
  - [x] 6.1 Create EventsHandler
    - Create lib/handlers/events_handler.dart
    - Implement listEvents() method
    - Return JSON array of events with 200 status
    - Handle errors with 500 status and error JSON
    - _Requirements: 1.1, 1.6, 6.1, 6.4, 6.5_
  
  - [ ]* 6.2 Write unit tests for EventsHandler
    - Test listEvents returns 200 with event array
    - Test error handling returns 500 with error JSON
    - _Requirements: 1.1, 1.6, 6.4, 6.5_
  
  - [x] 6.3 Create FavoritesHandler
    - Create lib/handlers/favorites_handler.dart
    - Implement listFavorites() - validate userId, return favorites array
    - Implement addFavorite() - validate body, return 201 or error
    - Implement removeFavorite() - validate userId, return 204 or error
    - Handle all error cases (400, 404, 500)
    - _Requirements: 2.1, 2.2, 3.1, 3.2, 3.5, 3.6, 4.1, 4.2, 4.4, 6.2, 6.3, 6.5, 8.5_
  
  - [ ]* 6.4 Write unit tests for FavoritesHandler
    - Test listFavorites with valid userId returns 200
    - Test listFavorites without userId returns 400
    - Test listFavorites with no favorites returns empty array
    - Test addFavorite with valid data returns 201
    - Test addFavorite without userId/eventId returns 400
    - Test addFavorite with non-existent eventId returns 404
    - Test addFavorite with invalid JSON returns 400
    - Test removeFavorite with valid data returns 204
    - Test removeFavorite without userId returns 400
    - Test removeFavorite with non-existent eventId returns 404
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2, 3.4, 3.5, 4.1, 4.2, 4.4, 6.2, 6.3, 6.5, 8.5_
  
  - [x] 6.5 Create HealthHandler
    - Create lib/handlers/health_handler.dart
    - Implement healthHandler() function
    - Return 200 with JSON containing status and service name
    - _Requirements: 9.1, 9.2, 9.3_
  
  - [ ]* 6.6 Write unit tests for HealthHandler
    - Test health endpoint returns 200 with correct JSON
    - _Requirements: 9.1, 9.2, 9.3_

- [ ] 7. Implement CORS middleware
  - [x] 7.1 Create CORS middleware
    - Create lib/middleware/cors_middleware.dart
    - Implement corsMiddleware() function
    - Handle OPTIONS preflight requests with 200
    - Add CORS headers to all responses
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ]* 7.2 Write unit tests for CORS middleware
    - Test OPTIONS request returns 200 with CORS headers
    - Test CORS headers added to all responses
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 8. Implement router and server setup
  - [x] 8.1 Create router configuration
    - Create lib/router.dart
    - Implement configureRoutes() function
    - Define all API routes (GET /api/events, GET/POST/DELETE /api/favorites, GET /health)
    - Wire handlers to routes
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 9.1_
  
  - [x] 8.2 Update bin/server.dart with complete setup
    - Initialize all repositories, services, and handlers
    - Configure router with all routes
    - Set up pipeline with logRequests and CORS middleware
    - Start server on port from environment or 8080
    - Print startup message with available endpoints
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 9. Checkpoint - Ensure all tests pass
  - Run dart test to verify all tests pass
  - Ensure all tests pass, ask the user if questions arise

- [ ]* 11. Write property-based tests for API operations
  - [ ]* 11.1 Write property test for list events
    - **Property 2: List Events Returns All Events**
    - **Validates: Requirements 1.1**
  
  - [ ]* 11.2 Write property test for add favorite then list
    - **Property 3: Add Favorite Then List Contains Event**
    - **Validates: Requirements 2.1, 3.1**
  
  - [ ]* 11.3 Write property test for add favorite idempotency
    - **Property 4: Add Favorite Idempotency**
    - **Validates: Requirements 3.3**
  
  - [ ]* 11.4 Write property test for remove favorite then list
    - **Property 5: Remove Favorite Then List Excludes Event**
    - **Validates: Requirements 4.1**
  
  - [ ]* 11.5 Write property test for remove favorite idempotency
    - **Property 6: Remove Favorite Idempotency**
    - **Validates: Requirements 4.3**
  
  - [ ]* 11.6 Write property test for CORS headers
    - **Property 7: CORS Headers Present**
    - **Validates: Requirements 5.1**

- [ ]* 12. Write integration tests
  - [ ]* 12.1 Create integration test setup
    - Create test/integration/api_integration_test.dart
    - Set up test server startup and shutdown
    - Create helper functions for HTTP requests
  
  - [ ]* 12.2 Write end-to-end API tests
    - Test complete workflow: list events, add favorite, list favorites, remove favorite
    - Test CORS with actual preflight requests
    - Test all error scenarios with real HTTP responses
    - Verify sample data is valid and complete

- [ ] 13. Final checkpoint - Verify complete system
  - Run dart test to ensure all tests pass
  - Manually test server by running it and making HTTP requests
  - Verify all endpoints work correctly
  - Verify CORS headers are present
  - Ensure all tests pass, ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties with minimum 100 iterations
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end workflows
- The dancee_shared package ensures consistency between frontend and backend
