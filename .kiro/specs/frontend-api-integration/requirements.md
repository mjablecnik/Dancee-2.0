# Requirements Document

## Introduction

This document specifies the requirements for integrating the dancee_event_service backend REST API with the dancee_app frontend Flutter application. The integration will replace the current hardcoded data in EventRepository with real HTTP API calls using the Dio package, enabling the frontend to fetch and manage event data from the backend service.

The system will maintain the existing repository pattern and Cubit state management architecture while adding an HTTP client layer for API communication. All user-facing strings will use the slang translation system, and all code will follow English-only standards for international development teams.

## Glossary

- **Dio**: A powerful HTTP client for Dart/Flutter that supports interceptors, global configuration, and request cancellation
- **API_Client**: The HTTP client wrapper that handles communication with the backend REST API
- **Event_Service**: The backend Dart REST API service (dancee_event_service) that provides event data
- **Event_Repository**: The frontend data access layer that abstracts the data source
- **Base_URL**: The root URL of the backend API service (e.g., http://localhost:8080)
- **HTTP_Interceptor**: Middleware that processes requests and responses (logging, error handling, headers)
- **API_Error**: A structured error response from the backend API
- **User_ID**: A string identifier for a user (currently hardcoded, future authentication)
- **Dancee_Shared**: The shared Dart package containing common models used by both frontend and backend
- **Service_Locator**: The get_it dependency injection container
- **CORS**: Cross-Origin Resource Sharing headers required for web frontend access

## Requirements

### Requirement 1: Dio Package Integration

**User Story:** As a developer, I want to use the Dio HTTP client package, so that I can make reliable REST API calls with proper error handling and configuration.

#### Acceptance Criteria

1. THE System SHALL add dio package to pubspec.yaml dependencies
2. THE System SHALL add dio version ^5.4.0 or later
3. WHEN dependencies are added, THE System SHALL run task get-deps to install them
4. THE System SHALL create an ApiClient class that wraps Dio functionality
5. THE ApiClient SHALL be registered in the service locator as a lazy singleton
6. THE ApiClient SHALL be configured with a base URL for the backend service

### Requirement 2: API Client Configuration

**User Story:** As a developer, I want a configured API client, so that all HTTP requests use consistent settings and error handling.

#### Acceptance Criteria

1. THE ApiClient SHALL accept a base URL parameter in its constructor
2. THE ApiClient SHALL configure Dio with a connection timeout of 10 seconds
3. THE ApiClient SHALL configure Dio with a receive timeout of 10 seconds
4. THE ApiClient SHALL configure Dio with a send timeout of 10 seconds
5. THE ApiClient SHALL add a logging interceptor that logs all requests and responses
6. THE ApiClient SHALL add an error interceptor that handles HTTP errors consistently
7. THE ApiClient SHALL set Content-Type header to application/json for all requests
8. THE ApiClient SHALL set Accept header to application/json for all requests

### Requirement 3: Fetch All Events from API

**User Story:** As a user, I want the app to load events from the backend API, so that I see up-to-date event information.

#### Acceptance Criteria

1. WHEN EventRepository.getAllEvents() is called, THE System SHALL make a GET request to /api/events
2. WHEN the API returns HTTP 200, THE System SHALL parse the JSON response into a list of Event objects
3. WHEN the API returns event data, THE System SHALL use Event.fromJson() from dancee_shared models
4. WHEN the API request fails, THE System SHALL throw an ApiException with error details
5. THE System SHALL handle network errors (no connection, timeout) with descriptive error messages
6. THE System SHALL handle JSON parsing errors with descriptive error messages
7. THE System SHALL NOT use hardcoded event data when API integration is complete

### Requirement 4: Fetch User Favorites from API

**User Story:** As a user, I want the app to load my favorite events from the backend, so that my favorites are synchronized across devices.

#### Acceptance Criteria

1. WHEN EventRepository.getFavoriteEvents() is called, THE System SHALL make a GET request to /api/favorites with userId query parameter
2. THE System SHALL use a hardcoded userId value "user123" for initial implementation
3. WHEN the API returns HTTP 200, THE System SHALL parse the JSON response into a list of Event objects
4. WHEN the API returns an empty array, THE System SHALL return an empty list
5. WHEN the API returns HTTP 400 (missing userId), THE System SHALL throw an ApiException
6. WHEN the API request fails, THE System SHALL throw an ApiException with error details

### Requirement 5: Add Event to Favorites via API

**User Story:** As a user, I want to add events to my favorites, so that the backend stores my preferences.

#### Acceptance Criteria

1. WHEN EventRepository.addFavorite(eventId) is called, THE System SHALL make a POST request to /api/favorites
2. THE System SHALL send a JSON body with userId and eventId fields
3. THE System SHALL use a hardcoded userId value "user123" for initial implementation
4. WHEN the API returns HTTP 201, THE System SHALL consider the operation successful
5. WHEN the API returns HTTP 404 (event not found), THE System SHALL throw an ApiException
6. WHEN the API returns HTTP 400 (invalid request), THE System SHALL throw an ApiException
7. THE System SHALL handle the idempotent nature of adding favorites (adding twice is safe)

### Requirement 6: Remove Event from Favorites via API

**User Story:** As a user, I want to remove events from my favorites, so that the backend updates my preferences.

#### Acceptance Criteria

1. WHEN EventRepository.removeFavorite(eventId) is called, THE System SHALL make a DELETE request to /api/favorites/:eventId
2. THE System SHALL include userId as a query parameter
3. THE System SHALL use a hardcoded userId value "user123" for initial implementation
4. WHEN the API returns HTTP 204, THE System SHALL consider the operation successful
5. WHEN the API returns HTTP 404 (event not found), THE System SHALL throw an ApiException
6. WHEN the API returns HTTP 400 (missing userId), THE System SHALL throw an ApiException
7. THE System SHALL handle the idempotent nature of removing favorites (removing twice is safe)

### Requirement 7: Toggle Favorite Implementation

**User Story:** As a user, I want to toggle event favorites with a single action, so that I can quickly manage my preferences.

#### Acceptance Criteria

1. WHEN EventRepository.toggleFavorite(eventId, currentIsFavorite) is called, THE System SHALL determine which operation to perform based on currentIsFavorite parameter
2. IF currentIsFavorite is true, THE System SHALL call removeFavorite(eventId)
3. IF currentIsFavorite is false, THE System SHALL call addFavorite(eventId)
4. THE Cubit SHALL pass the current favorite status from its cached state
5. THE Cubit SHALL update its local state after successful API call
6. THE System SHALL throw an ApiException if the API call fails

### Requirement 8: Error Handling and User Feedback

**User Story:** As a user, I want clear error messages when API calls fail, so that I understand what went wrong.

#### Acceptance Criteria

1. WHEN a network error occurs (no connection), THE System SHALL display a translated error message using slang
2. WHEN a timeout occurs, THE System SHALL display a translated error message using slang
3. WHEN the API returns an error response, THE System SHALL display the error message from the API
4. WHEN JSON parsing fails, THE System SHALL display a translated error message using slang
5. THE System SHALL log all API errors for debugging purposes
6. THE System SHALL NOT display technical error details to users (stack traces, URLs)
7. THE System SHALL provide retry functionality when errors occur

### Requirement 9: Loading States and UI Feedback

**User Story:** As a user, I want to see loading indicators during API calls, so that I know the app is working.

#### Acceptance Criteria

1. WHEN an API call is in progress, THE EventListCubit SHALL emit EventListLoading state
2. WHEN an API call is in progress, THE FavoritesCubit SHALL emit FavoritesLoading state
3. WHEN an API call completes successfully, THE Cubit SHALL emit the appropriate loaded state
4. WHEN an API call fails, THE Cubit SHALL emit the appropriate error state
5. THE UI SHALL display a loading indicator when in loading state
6. THE UI SHALL hide the loading indicator when data is loaded or an error occurs

### Requirement 10: API Base URL Configuration

**User Story:** As a developer, I want to configure the API base URL, so that I can switch between development, staging, and production environments.

#### Acceptance Criteria

1. THE System SHALL define the API base URL as a constant in a configuration file
2. THE System SHALL use http://localhost:8080 as the default base URL for development
3. THE System SHALL allow the base URL to be changed without modifying multiple files
4. THE System SHALL document how to change the base URL for different environments
5. THE System SHALL support both HTTP and HTTPS protocols

### Requirement 11: Shared Model Serialization

**User Story:** As a developer, I want to use shared models from dancee_shared, so that frontend and backend use consistent data structures.

#### Acceptance Criteria

1. THE System SHALL use Event.fromJson() from dancee_shared for deserializing events
2. THE System SHALL use Event.toJson() from dancee_shared for serializing events
3. THE System SHALL use the same JSON structure as the backend API
4. THE System SHALL handle all nested objects (Venue, Address, EventPart, EventInfo) correctly
5. THE System SHALL parse ISO 8601 date strings into DateTime objects
6. THE System SHALL parse duration as seconds (integer) into Duration objects
7. THE System SHALL parse enum strings into EventPartType and EventInfoType enums

### Requirement 12: Dependency Injection Updates

**User Story:** As a developer, I want the API client properly injected, so that the repository can use it without tight coupling.

#### Acceptance Criteria

1. THE System SHALL register ApiClient as a lazy singleton in the service locator
2. THE System SHALL inject ApiClient into EventRepository constructor
3. THE System SHALL update EventRepository registration to include ApiClient dependency
4. THE System SHALL maintain the existing singleton pattern for EventRepository
5. THE System SHALL initialize dependencies before app starts

### Requirement 13: Backward Compatibility During Migration

**User Story:** As a developer, I want to migrate gradually from hardcoded data to API calls, so that I can test incrementally.

#### Acceptance Criteria

1. THE System SHALL allow EventRepository to be configured with or without ApiClient
2. WHEN ApiClient is not provided, THE System SHALL use hardcoded data (existing behavior)
3. WHEN ApiClient is provided, THE System SHALL use API calls
4. THE System SHALL maintain the same method signatures in EventRepository
5. THE System SHALL NOT break existing UI code during migration

### Requirement 14: Code Quality and Standards

**User Story:** As a developer working on an international team, I want all code to follow English-only standards, so that any developer can understand and maintain the code.

#### Acceptance Criteria

1. THE System SHALL use English for all variable names
2. THE System SHALL use English for all function names
3. THE System SHALL use English for all class names
4. THE System SHALL use English for all comments
5. THE System SHALL use slang translations for all user-facing strings
6. THE System SHALL NEVER hardcode user-facing strings in English or any other language
7. THE System SHALL follow Flutter and Dart best practices
8. THE System SHALL follow proper Dart naming conventions (camelCase for variables, PascalCase for classes)

### Requirement 15: Translation Keys for API Errors

**User Story:** As a user, I want error messages in my preferred language, so that I can understand what went wrong.

#### Acceptance Criteria

1. THE System SHALL add translation keys for network errors to all language files (en, cs, es)
2. THE System SHALL add translation keys for timeout errors to all language files
3. THE System SHALL add translation keys for server errors to all language files
4. THE System SHALL add translation keys for parsing errors to all language files
5. THE System SHALL add translation keys for generic errors to all language files
6. WHEN adding translation keys, THE System SHALL run task slang to generate translations
7. THE System SHALL use the global `t` variable to access translations

### Requirement 16: Testing Strategy

**User Story:** As a developer, I want comprehensive tests for API integration, so that I can ensure reliability and catch regressions.

#### Acceptance Criteria

1. THE System SHALL include unit tests for ApiClient methods
2. THE System SHALL include unit tests for EventRepository API methods
3. THE System SHALL use mock HTTP responses for testing
4. THE System SHALL test error scenarios (network errors, timeouts, HTTP errors)
5. THE System SHALL test successful API responses with valid data
6. THE System SHALL test JSON parsing with valid and invalid data
7. THE System SHALL use mocktail for mocking dependencies

### Requirement 17: API Health Check

**User Story:** As a developer, I want to verify the backend is available, so that I can provide better error messages to users.

#### Acceptance Criteria

1. THE ApiClient SHALL provide a method to check backend health
2. THE health check SHALL make a GET request to /health endpoint
3. WHEN the health check succeeds, THE System SHALL consider the backend available
4. WHEN the health check fails, THE System SHALL consider the backend unavailable
5. THE System MAY use the health check before making other API calls
6. THE System SHALL NOT block the UI while performing health checks

### Requirement 18: Search and Filter Implementation (Local)

**User Story:** As a developer, I want search and filter functionality implemented locally in Cubits, so that users get fast results without API calls.

#### Acceptance Criteria

1. THE EventListCubit SHALL implement searchEvents() method that searches in cached state.allEvents
2. THE EventListCubit SHALL implement filterEvents() method that filters cached state.allEvents
3. THE System SHALL perform case-insensitive search on event title, venue name, and description
4. THE System SHALL support filtering by dances, isPast, and dateRange
5. THE System SHALL be designed to easily replace local search/filter with API calls in the future
6. THE System SHALL document the plan for future API-based search and filter
