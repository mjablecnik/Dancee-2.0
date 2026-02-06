# Design Document: REST API Event Service

## Overview

The REST API Event Service is a Dart-based HTTP server that provides dance event data and favorite management functionality for the Dancee mobile and web application. The service uses the shelf framework for HTTP routing and middleware, and initially stores data in-memory using Dart collections.

The service exposes RESTful endpoints for:
- Listing all dance events
- Managing user favorites (list, add, remove)
- Health monitoring

The design emphasizes simplicity, type safety, and compatibility with the existing Flutter frontend models. All data models are shared between frontend and backend through the `dancee_shared` package to ensure consistency and avoid duplication.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Frontend                          │
│              (dancee_app - Mobile & Web)                     │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/JSON
                         │ (REST API)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  Event Service (Dart)                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              HTTP Layer (shelf)                      │   │
│  │  - Router (shelf_router)                             │   │
│  │  - CORS Middleware                                   │   │
│  │  - Logging Middleware                                │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼─────────────────────────────────┐   │
│  │              API Handlers                            │   │
│  │  - EventsHandler                                     │   │
│  │  - FavoritesHandler                                  │   │
│  │  - HealthHandler                                     │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼─────────────────────────────────┐   │
│  │              Services Layer                          │   │
│  │  - EventService                                      │   │
│  │  - FavoritesService                                  │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                      │
│  ┌────────────────────▼─────────────────────────────────┐   │
│  │           In-Memory Storage                          │   │
│  │  - EventRepository (List<Event>)                     │   │
│  │  - FavoritesRepository (Map<String, List<Event>>)    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                         │
                         │ imports
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  dancee_shared Package                       │
│  - Event, Venue, Address, EventPart, EventInfo models       │
│  - EventPartType, EventInfoType enums                       │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Language**: Dart 3.10.4+
- **HTTP Framework**: shelf 1.4.2+
- **Routing**: shelf_router 1.1.2+
- **Data Storage**: In-memory (Dart collections)
- **Shared Models**: dancee_shared package

### Design Principles

1. **Separation of Concerns**: Clear separation between HTTP layer, business logic, and data storage
2. **Type Safety**: Leverage Dart's type system for compile-time safety
3. **RESTful Design**: Follow REST conventions for resource naming and HTTP methods
4. **Shared Models**: Use dancee_shared package for all data models to ensure consistency
5. **Testability**: Design for easy unit and integration testing
6. **Future-Proof**: Structure allows easy replacement of in-memory storage with database

## Components and Interfaces

### 1. HTTP Layer (shelf)

**Purpose**: Handle HTTP requests, routing, middleware, and responses.

**Components**:

#### Router Configuration
```dart
Router configureRoutes(EventsHandler eventsHandler, FavoritesHandler favoritesHandler) {
  final router = Router();
  
  // Health check
  router.get('/health', (Request request) => healthHandler(request));
  
  // Events endpoints
  router.get('/api/events', eventsHandler.listEvents);
  
  // Favorites endpoints
  router.get('/api/favorites', favoritesHandler.listFavorites);
  router.post('/api/favorites', favoritesHandler.addFavorite);
  router.delete('/api/favorites/<eventId>', favoritesHandler.removeFavorite);
  
  return router;
}
```

#### CORS Middleware
```dart
Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Handle preflight OPTIONS requests
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders());
      }
      
      // Add CORS headers to all responses
      final response = await handler(request);
      return response.change(headers: _corsHeaders());
    };
  };
}

Map<String, String> _corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };
}
```

#### Server Setup
```dart
void main() async {
  // Initialize repositories
  final eventRepository = EventRepository();
  final favoritesRepository = FavoritesRepository();
  
  // Initialize services
  final eventService = EventService(eventRepository);
  final favoritesService = FavoritesService(favoritesRepository, eventRepository);
  
  // Initialize handlers
  final eventsHandler = EventsHandler(eventService);
  final favoritesHandler = FavoritesHandler(favoritesService);
  
  // Configure router
  final router = configureRoutes(eventsHandler, favoritesHandler);
  
  // Configure pipeline with middleware
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router.call);
  
  // Start server
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  
  print('Server listening on port ${server.port}');
}
```

### 2. API Handlers

**Purpose**: Handle HTTP requests, validate input, call services, and format responses.

#### EventsHandler
```dart
class EventsHandler {
  final EventService _eventService;
  
  EventsHandler(this._eventService);
  
  Future<Response> listEvents(Request request) async {
    try {
      final events = await _eventService.getAllEvents();
      final jsonEvents = events.map((e) => e.toJson()).toList();
      
      return Response.ok(
        jsonEncode(jsonEvents),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(500, 'Internal server error');
    }
  }
  
  Response _errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
```

#### FavoritesHandler
```dart
class FavoritesHandler {
  final FavoritesService _favoritesService;
  
  FavoritesHandler(this._favoritesService);
  
  Future<Response> listFavorites(Request request) async {
    final userId = request.url.queryParameters['userId'];
    
    if (userId == null || userId.isEmpty) {
      return _errorResponse(400, 'userId query parameter is required');
    }
    
    try {
      final favoriteEvents = await _favoritesService.getFavorites(userId);
      final jsonEvents = favoriteEvents.map((e) => e.toJson()).toList();
      
      return Response.ok(
        jsonEncode(jsonEvents),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(500, 'Internal server error');
    }
  }
  
  Future<Response> addFavorite(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final userId = data['userId'] as String?;
      final eventId = data['eventId'] as String?;
      
      if (userId == null || userId.isEmpty || eventId == null || eventId.isEmpty) {
        return _errorResponse(400, 'userId and eventId are required');
      }
      
      final result = await _favoritesService.addFavorite(userId, eventId);
      
      if (!result.success) {
        return _errorResponse(result.statusCode, result.message);
      }
      
      return Response(
        201,
        body: jsonEncode({'message': 'Favorite added successfully', 'userId': userId, 'eventId': eventId}),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException {
      return _errorResponse(400, 'Invalid JSON in request body');
    } catch (e) {
      return _errorResponse(500, 'Internal server error');
    }
  }
  
  Future<Response> removeFavorite(Request request, String eventId) async {
    final userId = request.url.queryParameters['userId'];
    
    if (userId == null || userId.isEmpty) {
      return _errorResponse(400, 'userId query parameter is required');
    }
    
    try {
      final result = await _favoritesService.removeFavorite(userId, eventId);
      
      if (!result.success) {
        return _errorResponse(result.statusCode, result.message);
      }
      
      return Response(204);
    } catch (e) {
      return _errorResponse(500, 'Internal server error');
    }
  }
  
  Response _errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
```

#### HealthHandler
```dart
Response healthHandler(Request request) {
  return Response.ok(
    jsonEncode({'status': 'ok', 'service': 'dancee_event_service'}),
    headers: {'Content-Type': 'application/json'},
  );
}
```

### 3. Services Layer

**Purpose**: Implement business logic, coordinate between handlers and repositories.

#### ServiceResult
```dart
class ServiceResult {
  final bool success;
  final int statusCode;
  final String message;
  
  ServiceResult.success({this.statusCode = 200, this.message = 'Success'}) : success = true;
  ServiceResult.error({required this.statusCode, required this.message}) : success = false;
}
```

#### EventService
```dart
class EventService {
  final EventRepository _repository;
  
  EventService(this._repository);
  
  Future<List<Event>> getAllEvents() async {
    return _repository.getAllEvents();
  }
}
```

#### FavoritesService
```dart
class FavoritesService {
  final FavoritesRepository _favoritesRepository;
  final EventRepository _eventRepository;
  
  FavoritesService(this._favoritesRepository, this._eventRepository);
  
  Future<List<Event>> getFavorites(String userId) async {
    return _favoritesRepository.getFavorites(userId);
  }
  
  Future<ServiceResult> addFavorite(String userId, String eventId) async {
    // Verify event exists and get it
    final event = await _eventRepository.getEventById(eventId);
    if (event == null) {
      return ServiceResult.error(
        statusCode: 404,
        message: 'Event not found',
      );
    }
    
    await _favoritesRepository.addFavorite(userId, event);
    return ServiceResult.success(statusCode: 201);
  }
  
  Future<ServiceResult> removeFavorite(String userId, String eventId) async {
    // Verify event exists
    final eventExists = await _eventRepository.eventExists(eventId);
    if (!eventExists) {
      return ServiceResult.error(
        statusCode: 404,
        message: 'Event not found',
      );
    }
    
    await _favoritesRepository.removeFavorite(userId, eventId);
    return ServiceResult.success(statusCode: 204);
  }
}
```

### 4. Repository Layer

**Purpose**: Manage data storage and retrieval using in-memory collections.

#### EventRepository
```dart
class EventRepository {
  final List<Event> _events = [];
  
  EventRepository() {
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    // Pre-populate with sample events
    // (Sample data initialization code)
  }
  
  Future<List<Event>> getAllEvents() async {
    return List.unmodifiable(_events);
  }
  
  Future<bool> eventExists(String eventId) async {
    return _events.any((event) => event.id == eventId);
  }
  
  Future<Event?> getEventById(String eventId) async {
    try {
      return _events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }
}
```

#### FavoritesRepository
```dart
class FavoritesRepository {
  // Map of userId to List of favorite Events
  final Map<String, List<Event>> _favorites = {};
  
  Future<List<Event>> getFavorites(String userId) async {
    return _favorites[userId] ?? [];
  }
  
  Future<void> addFavorite(String userId, Event event) async {
    _favorites.putIfAbsent(userId, () => <Event>[]);
    
    // Check if already in favorites (idempotent)
    final alreadyExists = _favorites[userId]!.any((e) => e.id == event.id);
    if (!alreadyExists) {
      _favorites[userId]!.add(event);
    }
  }
  
  Future<void> removeFavorite(String userId, String eventId) async {
    _favorites[userId]?.removeWhere((event) => event.id == eventId);
  }
}
```

## Data Models

All data models are imported from the `dancee_shared` package to ensure consistency between frontend and backend:

```dart
import 'package:dancee_shared/models/event.dart';
import 'package:dancee_shared/models/venue.dart';
import 'package:dancee_shared/models/address.dart';
import 'package:dancee_shared/models/event_part.dart';
import 'package:dancee_shared/models/event_info.dart';
```

### JSON Serialization

Each model in `dancee_shared` must provide `toJson()` and `fromJson()` methods:

#### Event JSON Structure
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "organizer": "string",
  "venue": {
    "name": "string",
    "address": {
      "street": "string",
      "city": "string",
      "postalCode": "string",
      "country": "string"
    },
    "description": "string",
    "latitude": 0.0,
    "longitude": 0.0
  },
  "startTime": "2024-01-15T20:00:00.000Z",
  "endTime": "2024-01-16T02:00:00.000Z",
  "duration": 21600,
  "dances": ["Salsa", "Bachata"],
  "info": [
    {
      "type": "price",
      "key": "Entry Fee",
      "value": "150 Kč"
    }
  ],
  "parts": [
    {
      "name": "Social Dancing",
      "description": "Open social dancing",
      "type": "party",
      "startTime": "2024-01-15T20:00:00.000Z",
      "endTime": "2024-01-16T02:00:00.000Z",
      "lectors": null,
      "djs": ["DJ Carlos"]
    }
  ],
  "isFavorite": false,
  "isPast": false,
  "badge": null
}
```

### Serialization Extensions

The backend will need to add serialization extensions to the shared models:

```dart
extension EventJson on Event {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'organizer': organizer,
      'venue': venue.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration.inSeconds,
      'dances': dances,
      'info': info.map((i) => i.toJson()).toList(),
      'parts': parts.map((p) => p.toJson()).toList(),
      'isFavorite': isFavorite,
      'isPast': isPast,
      'badge': badge,
    };
  }
  
  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      organizer: json['organizer'] as String,
      venue: VenueJson.fromJson(json['venue'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: Duration(seconds: json['duration'] as int),
      dances: (json['dances'] as List).cast<String>(),
      info: (json['info'] as List).map((i) => EventInfoJson.fromJson(i as Map<String, dynamic>)).toList(),
      parts: (json['parts'] as List).map((p) => EventPartJson.fromJson(p as Map<String, dynamic>)).toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPast: json['isPast'] as bool? ?? false,
      badge: json['badge'] as String?,
    );
  }
}

// Similar extensions for Venue, Address, EventPart, EventInfo
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: Event Serialization Round-Trip

*For any* valid Event object, serializing it to JSON and then deserializing it back should produce an equivalent Event object with all fields preserved (id, title, description, organizer, venue with nested address, startTime, endTime, duration, dances, info, parts with nested fields).

**Validates: Requirements 1.2, 1.3, 1.4, 1.5, 1.7, 1.8, 8.1, 8.2, 8.6**

### Property 2: List Events Returns All Events

*For any* state of the EventRepository, calling the GET /api/events endpoint should return a JSON array containing exactly all events stored in the repository, with no events missing or duplicated.

**Validates: Requirements 1.1**

### Property 3: Add Favorite Then List Contains Event

*For any* valid userId and eventId, after successfully adding the event to favorites via POST /api/favorites, calling GET /api/favorites with that userId should return a list containing the full Event object with that eventId.

**Validates: Requirements 2.1, 3.1**

### Property 4: Add Favorite Idempotency

*For any* valid userId and eventId, adding the same favorite multiple times should always succeed with HTTP 201 and result in the event appearing exactly once in the user's favorites list.

**Validates: Requirements 3.3**

### Property 5: Remove Favorite Then List Excludes Event

*For any* valid userId and eventId that exists in the user's favorites, after successfully removing the event via DELETE /api/favorites/:eventId, calling GET /api/favorites with that userId should return a list of Event objects that does not contain any event with that eventId.

**Validates: Requirements 4.1**

### Property 6: Remove Favorite Idempotency

*For any* valid userId and eventId, removing a favorite that doesn't exist in the user's favorites should succeed with HTTP 204 and leave the favorites list unchanged.

**Validates: Requirements 4.3**

### Property 7: CORS Headers Present

*For any* HTTP request to any endpoint, the response should include the Access-Control-Allow-Origin header.

**Validates: Requirements 5.1**

### Property 8: Enum Serialization to Strings

*For any* Event containing EventPartType or EventInfoType enums, serializing the event to JSON should convert all enum values to their string representations (e.g., EventPartType.party becomes "party").

**Validates: Requirements 8.3**

## Error Handling

### Error Response Format

All error responses follow a consistent JSON format:

```json
{
  "error": "Descriptive error message"
}
```

### HTTP Status Codes

- **200 OK**: Successful GET request
- **201 Created**: Successful POST request (favorite added)
- **204 No Content**: Successful DELETE request (favorite removed)
- **400 Bad Request**: Missing or invalid parameters, malformed JSON
- **404 Not Found**: Requested event does not exist
- **500 Internal Server Error**: Unexpected server error

### Error Scenarios

1. **Missing Query Parameters**
   - Endpoint: GET /api/favorites, DELETE /api/favorites/:eventId
   - Missing: userId
   - Response: 400 with message "userId query parameter is required"

2. **Missing Request Body Fields**
   - Endpoint: POST /api/favorites
   - Missing: userId or eventId
   - Response: 400 with message "userId and eventId are required"

3. **Invalid JSON**
   - Endpoint: POST /api/favorites
   - Issue: Malformed JSON in request body
   - Response: 400 with message "Invalid JSON in request body"

4. **Event Not Found**
   - Endpoint: POST /api/favorites, DELETE /api/favorites/:eventId
   - Issue: eventId does not exist in repository
   - Response: 404 with message "Event not found"

5. **Internal Server Error**
   - Any endpoint
   - Issue: Unexpected exception
   - Response: 500 with message "Internal server error"
   - Action: Log error details to stdout

### Error Logging

All errors should be logged to stdout with:
- Timestamp
- Request method and path
- Error message
- Stack trace (for 500 errors)

## Testing Strategy

### Dual Testing Approach

The testing strategy combines unit tests and property-based tests to ensure comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs

Both approaches are complementary and necessary for comprehensive coverage. Unit tests catch concrete bugs in specific scenarios, while property tests verify general correctness across a wide range of inputs.

### Property-Based Testing

**Library**: Use the `test` package with custom property test helpers, or consider `dart_check` for property-based testing.

**Configuration**:
- Minimum 100 iterations per property test
- Each property test must reference its design document property
- Tag format: `@Tags(['Feature: rest-api-event-service', 'Property N: {property_text}'])`

**Property Test Coverage**:

1. **Property 1: Event Serialization Round-Trip**
   - Generate random Event objects with all fields populated
   - Serialize to JSON, deserialize back, verify equality
   - Test with various date ranges, durations, nested objects
   - Verify ISO 8601 date format and duration in seconds

2. **Property 2: List Events Returns All Events**
   - Generate random sets of events
   - Add to repository, call endpoint, verify all returned
   - Test with empty repository, single event, many events

3. **Property 3: Add Favorite Then List Contains Event**
   - Generate random userId and eventId combinations
   - Add favorite, list favorites, verify presence
   - Test with new users, existing users with favorites

4. **Property 4: Add Favorite Idempotency**
   - Generate random userId and eventId
   - Add same favorite 2-5 times
   - Verify always succeeds and appears once in list

5. **Property 5: Remove Favorite Then List Excludes Event**
   - Generate random userId and eventId
   - Add favorite, remove it, list favorites
   - Verify eventId not in list

6. **Property 6: Remove Favorite Idempotency**
   - Generate random userId and eventId
   - Remove favorite that doesn't exist 2-5 times
   - Verify always succeeds with 204

7. **Property 7: CORS Headers Present**
   - Generate random valid requests to all endpoints
   - Verify Access-Control-Allow-Origin header present

8. **Property 8: Enum Serialization to Strings**
   - Generate events with all enum variants
   - Serialize to JSON, verify enums are strings

### Unit Testing

**Unit Test Coverage**:

1. **EventsHandler Tests**
   - Test GET /api/events returns 200 with event array
   - Test error handling for service exceptions

2. **FavoritesHandler Tests**
   - Test GET /api/favorites with valid userId
   - Test GET /api/favorites without userId (400 error)
   - Test GET /api/favorites with userId that has no favorites (empty array)
   - Test POST /api/favorites with valid data (201 response)
   - Test POST /api/favorites without userId or eventId (400 error)
   - Test POST /api/favorites with non-existent eventId (404 error)
   - Test POST /api/favorites with invalid JSON (400 error)
   - Test DELETE /api/favorites/:eventId with valid userId (204 response)
   - Test DELETE /api/favorites/:eventId without userId (400 error)
   - Test DELETE /api/favorites/:eventId with non-existent eventId (404 error)

3. **HealthHandler Tests**
   - Test GET /health returns 200 with correct JSON

4. **CORS Middleware Tests**
   - Test OPTIONS request returns 200 with CORS headers
   - Test CORS headers added to all responses

5. **EventService Tests**
   - Test getAllEvents returns all events from repository

6. **FavoritesService Tests**
   - Test getFavorites returns correct favorites
   - Test addFavorite with valid eventId succeeds
   - Test addFavorite with invalid eventId returns error
   - Test removeFavorite with valid eventId succeeds
   - Test removeFavorite with invalid eventId returns error

7. **EventRepository Tests**
   - Test initialization populates sample events
   - Test getAllEvents returns all events
   - Test eventExists returns true for existing events
   - Test eventExists returns false for non-existent events
   - Test getEventById returns correct event

8. **FavoritesRepository Tests**
   - Test getFavorites returns empty list for new user
   - Test addFavorite adds event to user's favorites
   - Test addFavorite is idempotent
   - Test removeFavorite removes event from favorites
   - Test removeFavorite is idempotent

### Integration Testing

**Integration Test Coverage**:

1. **End-to-End API Tests**
   - Start server, make real HTTP requests
   - Test complete workflows (add favorite, list, remove)
   - Test CORS with actual preflight requests
   - Test error scenarios with real HTTP responses

2. **Sample Data Validation**
   - Verify sample events are valid and complete
   - Verify sample events match frontend expectations

### Test Organization

```
test/
├── unit/
│   ├── handlers/
│   │   ├── events_handler_test.dart
│   │   ├── favorites_handler_test.dart
│   │   └── health_handler_test.dart
│   ├── services/
│   │   ├── event_service_test.dart
│   │   └── favorites_service_test.dart
│   ├── repositories/
│   │   ├── event_repository_test.dart
│   │   └── favorites_repository_test.dart
│   └── middleware/
│       └── cors_middleware_test.dart
├── property/
│   ├── event_serialization_test.dart
│   ├── favorites_operations_test.dart
│   └── cors_headers_test.dart
└── integration/
    └── api_integration_test.dart
```

### Running Tests

```bash
# Run all tests
dart test

# Run unit tests only
dart test test/unit

# Run property tests only
dart test test/property

# Run integration tests only
dart test test/integration

# Run with coverage
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```
