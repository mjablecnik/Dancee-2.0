# Implementation Plan: Frontend REST API Integration

## Overview

This implementation plan outlines the tasks for integrating the dancee_event_service backend REST API with the dancee_app frontend Flutter application using the Dio HTTP client package. The implementation follows a phased approach with clean architecture: ApiClient → EventRepository (pure data access) → FavoritesService (shared business logic) → Cubits (state management + caching).

## Tasks

- [ ] 1. Add Dio dependency and create core infrastructure
  - Add dio package (^5.4.0) to pubspec.yaml dependencies
  - Run `task get-deps` to install dependencies
  - Create lib/core/config/api_config.dart with base URL and timeout constants
  - Create lib/core/exceptions/api_exception.dart with custom exception class
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 10.1, 10.2_

- [ ] 2. Implement ApiClient wrapper for Dio
  - [ ] 2.1 Create ApiClient class with Dio configuration
    - Create lib/core/clients/api_client.dart
    - Configure Dio with base URL, timeouts, and headers
    - Add logging interceptor for request/response logging
    - Add error interceptor for consistent error handling
    - _Requirements: 1.4, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_
  
  - [ ] 2.2 Implement HTTP methods (GET, POST, DELETE)
    - Implement get() method with query parameters support
    - Implement post() method with request body support
    - Implement delete() method with query parameters support
    - Convert DioException to ApiException in all methods
    - _Requirements: 3.1, 5.1, 6.1_
  
  - [ ] 2.3 Implement health check method
    - Add checkHealth() method that calls /health endpoint
    - Return boolean indicating backend availability
    - _Requirements: 17.1, 17.2, 17.3_
  
  - [ ]* 2.4 Write unit tests for ApiClient
    - Test GET request with query parameters
    - Test POST request with body data
    - Test DELETE request with query parameters
    - Test timeout error conversion to ApiException
    - Test network error conversion to ApiException
    - Test HTTP error response parsing
    - Test health check method
    - _Requirements: 16.1_

- [ ] 3. Add translation keys for API errors
  - Add error translation keys to lib/i18n/strings.i18n.json (English)
  - Add error translation keys to lib/i18n/strings_cs.i18n.json (Czech)
  - Add error translation keys to lib/i18n/strings_es.i18n.json (Spanish)
  - Run `task slang` to generate translations
  - Verify translations are accessible via global `t` variable
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7_

- [ ] 4. Implement EventRepository (Pure Data Access Layer)
  - [ ] 4.1 Create EventRepository class
    - Create lib/repositories/event_repository.dart
    - Add ApiClient parameter to constructor
    - NO cache field (Cubits will cache)
    - NO business logic methods (toggleFavorite, search, filter)
    - _Requirements: 12.2, 12.3_
  
  - [ ] 4.2 Implement getAllEvents() with API call
    - Make GET request to /api/events using ApiClient
    - Validate response is List
    - Parse JSON response into List<Event> using Event.fromJson()
    - Catch ApiException and rethrow
    - Catch FormatException and convert to ApiException
    - Catch other exceptions and convert to ApiException with context
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  
  - [ ] 4.3 Implement getFavoriteEvents() with API call
    - Make GET request to /api/favorites with userId query parameter
    - Use hardcoded userId "user123" from ApiConfig
    - Validate response is List
    - Parse JSON response into List<Event>
    - Handle empty array response
    - Proper error handling with context
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_
  
  - [ ] 4.4 Implement addFavorite() with API call
    - Make POST request to /api/favorites
    - Send JSON body with userId and eventId
    - NO cache update (Cubit handles that)
    - Proper error handling with context
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_
  
  - [ ] 4.5 Implement removeFavorite() with API call
    - Make DELETE request to /api/favorites/:eventId
    - Include userId as query parameter
    - NO cache update (Cubit handles that)
    - Proper error handling with context
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [ ] 4.6 Implement toggleFavorite() helper method
    - Add toggleFavorite(eventId, currentIsFavorite) method
    - If currentIsFavorite is true, call removeFavorite(eventId)
    - If currentIsFavorite is false, call addFavorite(eventId)
    - Propagate ApiException from add/remove methods
    - _Requirements: 7.1, 7.2, 7.3, 7.5_
  
  - [ ]* 4.7 Write unit tests for EventRepository
    - Test getAllEvents makes correct API call and parses response
    - Test getAllEvents validates response format
    - Test getAllEvents throws ApiException on failure
    - Test getAllEvents converts FormatException to ApiException
    - Test getFavoriteEvents with correct query parameters
    - Test getFavoriteEvents returns empty list for empty response
    - Test addFavorite makes correct API call
    - Test removeFavorite makes correct API call
    - Test toggleFavorite calls removeFavorite when currentIsFavorite is true
    - Test toggleFavorite calls addFavorite when currentIsFavorite is false
    - _Requirements: 16.2_

- [ ] 5. Checkpoint - Verify API integration works
  - Ensure all tests pass
  - Manually test API calls with mock server or real backend
  - Verify error handling works correctly
  - Ask the user if questions arise

- [ ] 6. Update EventListCubit with business logic
  - [ ] 6.1 Update EventListCubit constructor
    - Keep EventRepository parameter (no changes needed)
    - _Requirements: 12.2, 12.3_
  
  - [ ] 6.2 Update loadEvents() method
    - Call repository.getAllEvents()
    - Cache events in state (allEvents, todayEvents, tomorrowEvents, upcomingEvents)
    - Group events by date in Cubit
    - Catch ApiException and emit EventListError
    - _Requirements: 3.1, 9.1, 9.3_
  
  - [ ] 6.3 Implement searchEvents() method
    - Search in state.allEvents (local, no API call)
    - Case-insensitive search on title, venue name, description
    - Group filtered results by date
    - Emit EventListLoaded with filtered results
    - _Requirements: 18.1, 18.3_
  
  - [ ] 6.4 Update toggleFavorite() method
    - Get event from state.allEvents to determine currentIsFavorite
    - Call repository.toggleFavorite(eventId, currentIsFavorite)
    - Update state locally (map over allEvents and update isFavorite)
    - Emit EventListLoaded with updated state
    - Catch ApiException and emit EventListError
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4_
  
  - [ ]* 6.5 Write unit tests for EventListCubit
    - Test loadEvents emits Loading then Loaded on success
    - Test loadEvents emits Loading then Error on API failure
    - Test loadEvents groups events by date correctly
    - Test searchEvents filters events locally
    - Test toggleFavorite calls repository.toggleFavorite
    - Test toggleFavorite updates state locally
    - Test toggleFavorite emits Error on failure
    - _Requirements: 16.3_

- [ ] 7. Update FavoritesCubit with business logic
  - [ ] 7.1 Update FavoritesCubit constructor
    - Keep EventRepository parameter (no changes needed)
    - _Requirements: 12.2, 12.3_
  
  - [ ] 7.2 Update loadFavorites() method
    - Call repository.getFavoriteEvents()
    - Cache favorites in state (upcomingEvents, pastEvents)
    - Separate upcoming and past events in Cubit
    - Emit FavoritesEmpty if no favorites
    - Catch ApiException and emit FavoritesError
    - _Requirements: 4.1, 9.2, 9.4_
  
  - [ ] 7.3 Update toggleFavorite() method
    - Get event from state to determine currentIsFavorite
    - Call repository.toggleFavorite(eventId, currentIsFavorite)
    - Reload favorites from API (call loadFavorites())
    - Catch ApiException and emit FavoritesError
    - _Requirements: 7.1, 7.2, 7.3, 7.5, 8.1, 8.2, 8.3, 8.4_
  
  - [ ]* 7.4 Write unit tests for FavoritesCubit
    - Test loadFavorites emits Loading then Loaded on success
    - Test loadFavorites emits Loading then Empty for empty list
    - Test loadFavorites emits Loading then Error on API failure
    - Test loadFavorites separates upcoming and past events
    - Test toggleFavorite calls repository.toggleFavorite
    - Test toggleFavorite reloads favorites
    - Test toggleFavorite emits Error on failure
    - _Requirements: 16.3_

- [ ] 8. Update dependency injection
  - Register ApiClient as lazy singleton in service locator
  - Register EventRepository with ApiClient dependency
  - Update EventListCubit registration to inject EventRepository
  - Update FavoritesCubit registration to inject EventRepository
  - Test that same instances are returned on multiple getIt calls
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 9. Update UI screens for error display
  - [ ] 9.1 Update EventListScreen error handling
    - Display error icon and translated error message
    - Add retry button that calls loadEvents()
    - Use translated button text from slang
    - _Requirements: 8.7, 9.5, 9.6_
  
  - [ ] 9.2 Update FavoritesScreen error handling
    - Display error icon and translated error message
    - Add retry button that calls loadFavorites()
    - Use translated button text from slang
    - _Requirements: 8.7, 9.5, 9.6_

- [ ] 10. Checkpoint - Test complete integration
  - Ensure all tests pass
  - Test with real backend service (if available)
  - Test error scenarios (network off, timeout, server errors)
  - Test retry functionality
  - Test favorite toggle across both screens
  - Verify EventListCubit and FavoritesCubit stay in sync
  - Ask the user if questions arise

- [ ]* 11. Write property-based tests
  - [ ]* 11.1 Write property test for event serialization round-trip
    - **Property 1: Event Serialization Round-Trip**
    - **Validates: Requirements 3.2, 4.3, 11.1, 11.2, 11.4, 11.5, 11.6, 11.7**
    - Generate random Event JSON objects
    - Test Event.fromJson() then Event.toJson() produces equivalent JSON
    - Test with nested objects, dates, durations, enums
    - Run minimum 100 iterations
  
  - [ ]* 11.2 Write property test for API error handling
    - **Property 2: API Failures Throw ApiException**
    - **Validates: Requirements 3.4, 4.6, 7.5**
    - Generate random API failure scenarios
    - Test all repository methods throw ApiException on failure
    - Run minimum 100 iterations
  
  - [ ]* 11.3 Write property test for Cubit state transitions
    - **Property 3: Cubit State Transitions**
    - **Validates: Requirements 9.1, 9.2, 9.3, 9.4**
    - Generate random success/failure scenarios
    - Test state transitions follow Loading → (Loaded | Error) pattern
    - Run minimum 100 iterations
  
  - [ ]* 11.4 Write property test for toggleFavorite logic
    - **Property 4: Repository toggleFavorite Logic**
    - **Validates: Requirements 7.1, 7.2, 7.3**
    - Generate random favorite states (true/false)
    - Test toggleFavorite calls correct method (add vs remove)
    - Run minimum 100 iterations

- [ ]* 12. Write integration tests
  - Set up mock HTTP server for testing
  - Test complete flow: load events → display → toggle favorite → reload
  - Test error scenarios with mock server errors
  - Test retry functionality after errors
  - Test favorite toggle updates both EventListCubit and FavoritesCubit
  - Test search functionality in EventListCubit
  - _Requirements: 16.4, 16.5, 16.6, 16.7_

- [ ] 13. Final checkpoint and cleanup
  - Run all tests and ensure they pass
  - Remove any remaining hardcoded event data from EventRepository
  - Update documentation and comments
  - Code review and refactoring
  - Ensure all code follows English-only standards
  - Ensure all user-facing strings use slang translations
  - Verify no cache in EventRepository
  - Verify toggleFavorite is in EventRepository and used by both Cubits
  - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end flows
- All user-facing strings must use slang translations (never hardcode)
- All code must be in English (variables, functions, comments)
- Run `task slang` after modifying translation files
- Run `task get-deps` after modifying pubspec.yaml

## Architecture Summary

### EventRepository (Data Access + Simple Helper)
- NO cache
- API calls: getAllEvents(), getFavoriteEvents(), addFavorite(), removeFavorite()
- Helper method: toggleFavorite(eventId, currentIsFavorite) - decides add vs remove
- Validates responses and adds error context

### EventListCubit (State Management + Caching)
- Caches all events in state
- searchEvents() - local search in cached events
- toggleFavorite() - calls repository.toggleFavorite, updates state locally

### FavoritesCubit (State Management + Caching)
- Caches favorite events in state
- toggleFavorite() - calls repository.toggleFavorite, reloads from API

## File Structure

The implementation follows this structure:
- `lib/core/config/` - Configuration files (API config, app settings, feature flags)
- `lib/core/exceptions/` - Custom exception types (API exceptions, validation, business logic)
- `lib/core/clients/` - HTTP/API client wrappers
- `lib/repositories/` - Data access layer (EventRepository)
- `lib/cubits/` - State management + caching
- `lib/screens/` - UI screens
- `lib/i18n/` - Translations

