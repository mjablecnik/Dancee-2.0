# Design Document: Frontend REST API Integration

## Overview

This document describes the technical design for integrating the dancee_event_service backend REST API with the dancee_app frontend Flutter application. The integration replaces hardcoded event data in EventRepository with real HTTP API calls using the Dio package, while maintaining the existing repository pattern and Cubit state management architecture.

The design emphasizes clean separation of concerns, proper error handling, and maintainability. All user-facing strings use the slang translation system, and all code follows English-only standards for international development teams.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  ┌──────────────────────┐      ┌──────────────────────┐    │
│  │ EventListScreen      │      │ FavoritesScreen      │    │
│  │ (BlocBuilder)        │      │ (BlocBuilder)        │    │
│  └──────────┬───────────┘      └──────────┬───────────┘    │
└─────────────┼──────────────────────────────┼────────────────┘
              │                              │
┌─────────────┼──────────────────────────────┼────────────────┐
│             │    State Management Layer    │                │
│  ┌──────────▼───────────┐      ┌──────────▼───────────┐    │
│  │ EventListCubit       │      │ FavoritesCubit       │    │
│  └──────────┬───────────┘      └──────────┬───────────┘    │
└─────────────┼──────────────────────────────┼────────────────┘
              │                              │
              └──────────────┬───────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                    Data Layer                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ EventRepository                                      │   │
│  │ - getAllEvents()                                     │   │
│  │ - getFavoriteEvents()                                │   │
│  │ - addFavorite()                                      │   │
│  │ - removeFavorite()                                   │   │
│  │ - toggleFavorite()                                   │   │
│  └────────────────────┬─────────────────────────────────┘   │
└───────────────────────┼─────────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                    HTTP Client Layer                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ApiClient (Dio wrapper)                              │   │
│  │ - get()                                              │   │
│  │ - post()                                             │   │
│  │ - delete()                                           │   │
│  │ - Interceptors (logging, error handling)            │   │
│  └────────────────────┬─────────────────────────────────┘   │
└───────────────────────┼─────────────────────────────────────┘
                        │ HTTP/JSON
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              Backend REST API (dancee_event_service)         │
│  - GET /api/events                                           │
│  - GET /api/favorites?userId=xxx                             │
│  - POST /api/favorites                                       │
│  - DELETE /api/favorites/:eventId?userId=xxx                 │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **HTTP Client**: Dio 5.4.0+
- **State Management**: flutter_bloc 8.1.3+
- **Dependency Injection**: get_it 7.6.0+
- **Shared Models**: dancee_shared package
- **Translations**: slang_flutter 3.31.0+


## Components and Interfaces

### 1. API Configuration

#### API Constants

**File: lib/core/config/api_config.dart**

```dart
/// API configuration constants.
///
/// This file contains all API-related configuration.
/// Future configurations (app settings, feature flags, etc.) can be added
/// to the core/config/ directory.
class ApiConfig {
  /// Base URL for the backend API service.
  /// 
  /// Change this value for different environments:
  /// - Development: http://localhost:8080
  /// - Staging: https://staging-api.dancee.app
  /// - Production: https://api.dancee.app
  static const String baseUrl = 'http://localhost:8080';
  
  /// Hardcoded user ID for initial implementation.
  /// 
  /// This will be replaced with actual authentication in the future.
  static const String userId = 'user123';
  
  /// Connection timeout in milliseconds.
  static const int connectTimeout = 10000;
  
  /// Receive timeout in milliseconds.
  static const int receiveTimeout = 10000;
  
  /// Send timeout in milliseconds.
  static const int sendTimeout = 10000;
}
```

**Design Decisions:**
- Centralized configuration for easy environment switching
- Hardcoded userId for initial implementation (future: authentication)
- Timeout values prevent hanging requests
- Clear documentation for changing base URL


### 2. API Client

#### ApiException

**File: lib/core/exceptions/api_exception.dart**

```dart
/// Exception thrown when API calls fail.
///
/// This is part of the core exceptions module.
/// Future exception types (ValidationException, BusinessLogicException, etc.)
/// can be added to the core/exceptions/ directory.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });
  
  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
```

**Design Decisions:**
- Custom exception for API-specific errors
- Includes HTTP status code for error handling
- Preserves original error for debugging
- Clear toString() for logging

#### ApiClient

**File: lib/core/clients/api_client.dart**

```dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../exceptions/api_exception.dart';

/// HTTP client wrapper for making API calls to the backend service.
///
/// This class wraps Dio functionality and provides a clean interface
/// for making HTTP requests with proper error handling, logging, and
/// configuration.
class ApiClient {
  final Dio _dio;
  
  /// Creates an ApiClient with the specified base URL.
  ///
  /// Configures Dio with timeouts, interceptors, and default headers.
  ApiClient({required String baseUrl}) : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: ApiConfig.connectTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: ApiConfig.receiveTimeout);
    _dio.options.sendTimeout = Duration(milliseconds: ApiConfig.sendTimeout);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
    
    // Add error interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }
  
  /// Makes a GET request to the specified path.
  ///
  /// Returns the response data on success.
  /// Throws ApiException on failure.
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }
  
  /// Makes a POST request to the specified path.
  ///
  /// Returns the response data on success.
  /// Throws ApiException on failure.
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }
  
  /// Makes a DELETE request to the specified path.
  ///
  /// Returns the response data on success.
  /// Throws ApiException on failure.
  Future<dynamic> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }
  
  /// Checks if the backend service is available.
  ///
  /// Returns true if the health check succeeds, false otherwise.
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Handles Dio errors and logs them.
  void _handleError(DioException error) {
    print('[API Error] ${error.type}: ${error.message}');
    if (error.response != null) {
      print('[API Error] Status: ${error.response?.statusCode}');
      print('[API Error] Data: ${error.response?.data}');
    }
  }
  
  /// Converts DioException to ApiException.
  ApiException _convertDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timeout. Please check your connection.',
          originalError: e,
        );
      
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Connection error. Please check your internet connection.',
          originalError: e,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data?['error'] ?? 'Server error occurred';
        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          originalError: e,
        );
      
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          originalError: e,
        );
      
      default:
        return ApiException(
          message: 'An unexpected error occurred',
          originalError: e,
        );
    }
  }
}
```

**Design Decisions:**
- Wraps Dio for clean interface and testability
- Configures timeouts to prevent hanging requests
- Logging interceptor for debugging
- Error interceptor for consistent error handling
- Converts DioException to ApiException for abstraction
- Health check method for backend availability
- Extracts error messages from API responses


### 3. EventRepository (Pure Data Access Layer)

```dart
import 'package:dancee_shared/dancee_shared.dart';
import '../core/clients/api_client.dart';
import '../core/config/api_config.dart';
import '../core/exceptions/api_exception.dart';

/// Repository for managing event data.
///
/// This repository is a pure data access layer that only calls the REST API.
/// It does NOT contain business logic, caching, or data manipulation.
/// All methods return Future types for async API calls.
class EventRepository {
  final ApiClient _apiClient;
  
  /// Creates an EventRepository with the specified API client.
  EventRepository(this._apiClient);
  
  /// Returns all events from the backend API.
  ///
  /// Makes a GET request to /api/events and parses the response.
  /// Updates the local cache on success.
  /// Throws ApiException on failure.
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _apiClient.get('/api/events');
      
      if (response is! List) {
        throw ApiException(message: 'Invalid response format');
      }
      
      _cachedEvents = (response as List)
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return List.unmodifiable(_cachedEvents);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to load events',
        originalError: e,
      );
    }
  }
  
  /// Returns only favorite events from the backend API.
  ///
  /// Makes a GET request to /api/favorites with userId query parameter.
  /// Throws ApiException on failure.
  Future<List<Event>> getFavoriteEvents() async {
    try {
      final response = await _apiClient.get(
        '/api/favorites',
        queryParameters: {'userId': ApiConfig.userId},
      );
      
      if (response is! List) {
        throw ApiException(message: 'Invalid response format');
      }
      
      return (response as List)
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to load favorite events',
        originalError: e,
      );
    }
  }
  
  /// Adds an event to the user's favorites.
  ///
  /// Makes a POST request to /api/favorites with userId and eventId.
  /// Throws ApiException on failure.
  Future<void> addFavorite(String eventId) async {
    try {
      await _apiClient.post(
        '/api/favorites',
        data: {
          'userId': ApiConfig.userId,
          'eventId': eventId,
        },
      );
      
      // Update local cache
      _updateCachedEventFavorite(eventId, true);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to add favorite',
        originalError: e,
      );
    }
  }
  
  /// Removes an event from the user's favorites.
  ///
  /// Makes a DELETE request to /api/favorites/:eventId with userId query parameter.
  /// Throws ApiException on failure.
  Future<void> removeFavorite(String eventId) async {
    try {
      await _apiClient.delete(
        '/api/favorites/$eventId',
        queryParameters: {'userId': ApiConfig.userId},
      );
      
      // Update local cache
      _updateCachedEventFavorite(eventId, false);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to remove favorite',
        originalError: e,
      );
    }
  }
  
  /// Toggles the favorite status of an event.
  ///
  /// Determines current status from cache and calls addFavorite or removeFavorite.
  /// Throws ApiException on failure.
  Future<void> toggleFavorite(String eventId) async {
    // Find event in cache to determine current status
    final event = _cachedEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => throw ApiException(message: 'Event not found in cache'),
    );
    
    if (event.isFavorite) {
      await removeFavorite(eventId);
    } else {
      await addFavorite(eventId);
    }
  }
  
  /// Updates the favorite status of an event in the local cache.
  void _updateCachedEventFavorite(String eventId, bool isFavorite) {
    final index = _cachedEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _cachedEvents[index] = _cachedEvents[index].copyWith(
        isFavorite: isFavorite,
      );
    }
  }
  
  /// Searches events by query string (local implementation).
  ///
  /// Performs case-insensitive search on event title, venue name, and description.
  /// Uses cached events for search.
  /// 
  /// Note: This is a local implementation. In the future, this could be
  /// replaced with a backend API endpoint for server-side search.
  Future<List<Event>> searchEvents(String query) async {
    if (query.isEmpty) {
      return List.unmodifiable(_cachedEvents);
    }
    
    final lowerQuery = query.toLowerCase();
    return _cachedEvents.where((event) =>
      event.title.toLowerCase().contains(lowerQuery) ||
      event.venue.name.toLowerCase().contains(lowerQuery) ||
      event.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  /// Filters events by criteria (local implementation).
  ///
  /// Supports filtering by:
  /// - dances: List<String> - filters events that include any of the specified dances
  /// - isPast: bool - filters events by past status
  /// - dateRange: Map<String, DateTime> with 'start' and 'end' keys
  ///
  /// Uses cached events for filtering.
  /// 
  /// Note: This is a local implementation. In the future, this could be
  /// replaced with a backend API endpoint for server-side filtering.
  Future<List<Event>> filterEvents(Map<String, dynamic> criteria) async {
    var filtered = _cachedEvents;
    
    if (criteria.containsKey('dances')) {
      final dances = criteria['dances'] as List<String>;
      filtered = filtered.where((event) =>
        event.dances.any((dance) => dances.contains(dance))
      ).toList();
    }
    
    if (criteria.containsKey('isPast')) {
      final isPast = criteria['isPast'] as bool;
      filtered = filtered.where((event) => event.isPast == isPast).toList();
    }
    
    if (criteria.containsKey('dateRange')) {
      final range = criteria['dateRange'] as Map<String, DateTime>;
      final start = range['start'];
      final end = range['end'];
      if (start != null && end != null) {
        filtered = filtered.where((event) =>
          event.startTime.isAfter(start) && event.startTime.isBefore(end)
        ).toList();
      }
    }
    
    return filtered;
  }
  
  /// Returns events for a specific date (local implementation).
  ///
  /// Compares the date portion of event startTime with the provided date.
  /// Uses cached events.
  Future<List<Event>> getEventsByDate(DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _cachedEvents.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }
}
```

**Design Decisions:**
- Requires ApiClient injection for testability
- Maintains local cache for quick access and offline support
- Updates cache after API calls for consistency
- toggleFavorite uses cache to determine current status
- Search and filter use local cache (future: API endpoints)
- Throws ApiException for consistent error handling
- Preserves existing method signatures for compatibility
- Clear documentation for future API migration


### 4. Updated Cubits

The Cubits remain largely unchanged, but error handling is updated to handle ApiException:

#### EventListCubit Updates

```dart
class EventListCubit extends Cubit<EventListState> {
  final EventRepository repository;
  
  EventListCubit(this.repository) : super(EventListInitial());

  Future<void> loadEvents() async {
    emit(EventListLoading());
    try {
      final events = await repository.getAllEvents();
      
      // Group events by date (existing logic)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final dayAfterTomorrow = today.add(const Duration(days: 2));
      
      final todayEvents = events.where((e) => 
        e.startTime.isAfter(today) && e.startTime.isBefore(tomorrow)
      ).toList();
      
      final tomorrowEvents = events.where((e) => 
        e.startTime.isAfter(tomorrow) && e.startTime.isBefore(dayAfterTomorrow)
      ).toList();
      
      final upcomingEvents = events.where((e) => 
        e.startTime.isAfter(dayAfterTomorrow)
      ).toList();
      
      emit(EventListLoaded(
        allEvents: events,
        todayEvents: todayEvents,
        tomorrowEvents: tomorrowEvents,
        upcomingEvents: upcomingEvents,
      ));
    } on ApiException catch (e) {
      emit(EventListError(e.message));
    } catch (e) {
      emit(EventListError('An unexpected error occurred'));
    }
  }

  Future<void> toggleFavorite(String eventId) async {
    try {
      await repository.toggleFavorite(eventId);
      await loadEvents(); // Reload to reflect changes
    } on ApiException catch (e) {
      emit(EventListError(e.message));
    } catch (e) {
      emit(EventListError('Failed to update favorite'));
    }
  }
  
  // searchEvents and filterEvents remain unchanged
}
```

**Design Decisions:**
- Catches ApiException specifically for better error messages
- Falls back to generic error for unexpected exceptions
- Reloads events after favorite toggle to reflect changes
- Maintains existing state structure

#### FavoritesCubit Updates

```dart
class FavoritesCubit extends Cubit<FavoritesState> {
  final EventRepository repository;
  
  FavoritesCubit(this.repository) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavoriteEvents();
      
      if (favorites.isEmpty) {
        emit(FavoritesEmpty());
        return;
      }
      
      final upcoming = favorites.where((e) => !e.isPast).toList();
      final past = favorites.where((e) => e.isPast).toList();
      
      emit(FavoritesLoaded(
        upcomingEvents: upcoming,
        pastEvents: past,
      ));
    } on ApiException catch (e) {
      emit(FavoritesError(e.message));
    } catch (e) {
      emit(FavoritesError('An unexpected error occurred'));
    }
  }

  Future<void> toggleFavorite(String eventId) async {
    try {
      await repository.toggleFavorite(eventId);
      await loadFavorites(); // Reload to reflect changes
    } on ApiException catch (e) {
      emit(FavoritesError(e.message));
    } catch (e) {
      emit(FavoritesError('Failed to update favorite'));
    }
  }
}
```

**Design Decisions:**
- Catches ApiException for better error messages
- Falls back to generic error for unexpected exceptions
- Reloads favorites after toggle to reflect changes
- Maintains existing state structure


### 5. Dependency Injection Updates

```dart
import 'package:get_it/get_it.dart';
import 'core/clients/api_client.dart';
import 'core/config/api_config.dart';
import 'repositories/event_repository.dart';
import 'cubits/event_list/event_list_cubit.dart';
import 'cubits/favorites/favorites_cubit.dart';

final getIt = GetIt.instance;

/// Sets up dependency injection for the application.
///
/// Registers all services, repositories, and cubits as singletons.
/// Must be called before runApp().
void setupDependencies() {
  // Register API client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: ApiConfig.baseUrl),
  );
  
  // Register repository with API client dependency
  getIt.registerLazySingleton<EventRepository>(
    () => EventRepository(getIt<ApiClient>()),
  );
  
  // Register cubits with automatic data loading
  getIt.registerLazySingleton<EventListCubit>(
    () => EventListCubit(getIt<EventRepository>())..loadEvents(),
  );
  
  getIt.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(getIt<EventRepository>())..loadFavorites(),
  );
}
```

**Design Decisions:**
- ApiClient registered first (no dependencies)
- EventRepository depends on ApiClient
- Cubits depend on EventRepository
- Lazy singletons for efficient memory usage
- Automatic data loading on cubit creation
- Clear documentation for setup order

### 6. Translation Keys

Add these translation keys to all language files (en, cs, es):

#### strings.i18n.json (English)
```json
{
  "errors": {
    "networkError": "Connection error. Please check your internet connection.",
    "timeoutError": "Request timeout. Please try again.",
    "serverError": "Server error occurred. Please try again later.",
    "parsingError": "Failed to process server response.",
    "genericError": "An unexpected error occurred.",
    "loadEventsError": "Failed to load events.",
    "loadFavoritesError": "Failed to load favorites.",
    "toggleFavoriteError": "Failed to update favorite."
  }
}
```

#### strings_cs.i18n.json (Czech)
```json
{
  "errors": {
    "networkError": "Chyba připojení. Zkontrolujte prosím své internetové připojení.",
    "timeoutError": "Vypršel časový limit požadavku. Zkuste to prosím znovu.",
    "serverError": "Došlo k chybě serveru. Zkuste to prosím později.",
    "parsingError": "Nepodařilo se zpracovat odpověď serveru.",
    "genericError": "Došlo k neočekávané chybě.",
    "loadEventsError": "Nepodařilo se načíst události.",
    "loadFavoritesError": "Nepodařilo se načíst oblíbené.",
    "toggleFavoriteError": "Nepodařilo se aktualizovat oblíbené."
  }
}
```

#### strings_es.i18n.json (Spanish)
```json
{
  "errors": {
    "networkError": "Error de conexión. Por favor, verifica tu conexión a internet.",
    "timeoutError": "Tiempo de espera agotado. Por favor, inténtalo de nuevo.",
    "serverError": "Error del servidor. Por favor, inténtalo más tarde.",
    "parsingError": "Error al procesar la respuesta del servidor.",
    "genericError": "Ocurrió un error inesperado.",
    "loadEventsError": "Error al cargar eventos.",
    "loadFavoritesError": "Error al cargar favoritos.",
    "toggleFavoriteError": "Error al actualizar favorito."
  }
}
```

**Usage in Code:**
```dart
import '../i18n/translations.g.dart';

// In error handling
emit(EventListError(t.errors.loadEventsError));
emit(FavoritesError(t.errors.toggleFavoriteError));
```

**Design Decisions:**
- Nested structure for organization
- Consistent naming across languages
- Covers all error scenarios
- Uses global `t` variable for access
- Must run `task slang` after adding keys


## Data Models

All data models are imported from the `dancee_shared` package to ensure consistency between frontend and backend:

```dart
import 'package:dancee_shared/dancee_shared.dart';
```

### JSON Serialization

The shared models provide `fromJson()` and `toJson()` methods:

#### Event Deserialization Example
```dart
final json = {
  "id": "1",
  "title": "Salsa Social Night",
  "description": "Join us for an amazing night...",
  "organizer": "Prague Dance Events",
  "venue": {
    "name": "Lucerna Music Bar",
    "address": {
      "street": "Vodičkova 36",
      "city": "Prague",
      "postalCode": "110 00",
      "country": "Czech Republic"
    },
    "description": "Historic music venue...",
    "latitude": 50.0813,
    "longitude": 14.4253
  },
  "startTime": "2024-01-15T20:00:00.000Z",
  "endTime": "2024-01-16T02:00:00.000Z",
  "duration": 21600,
  "dances": ["Salsa", "Bachata", "Kizomba"],
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
      "djs": ["DJ Carlos", "DJ Maria"]
    }
  ],
  "isFavorite": false,
  "isPast": false,
  "badge": null
};

final event = Event.fromJson(json);
```

**Design Decisions:**
- Uses shared models for consistency
- Handles nested objects (Venue, Address, EventPart, EventInfo)
- Parses ISO 8601 date strings to DateTime
- Parses duration as seconds to Duration
- Parses enum strings to EventPartType and EventInfoType

## Error Handling Strategy

### Error Types

1. **Network Errors**: No internet connection, DNS failure
   - User Message: "Connection error. Please check your internet connection."
   - Action: Show retry button

2. **Timeout Errors**: Request takes too long
   - User Message: "Request timeout. Please try again."
   - Action: Show retry button

3. **HTTP Errors**: 4xx, 5xx status codes
   - User Message: Error message from API response
   - Action: Show retry button or specific action

4. **Parsing Errors**: Invalid JSON or unexpected format
   - User Message: "Failed to process server response."
   - Action: Show retry button, log details

5. **Generic Errors**: Unexpected exceptions
   - User Message: "An unexpected error occurred."
   - Action: Show retry button, log details

### Error Flow

```
API Call
   │
   ├─ Success → Update State → UI Shows Data
   │
   └─ Failure → Catch Exception
                    │
                    ├─ ApiException → Extract Message → Emit Error State
                    │
                    └─ Other Exception → Generic Message → Emit Error State
                                                              │
                                                              └─ UI Shows Error + Retry Button
```

### Error Handling in UI

```dart
if (state is EventListError) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        SizedBox(height: 16),
        Text(
          state.message,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => getIt<EventListCubit>().loadEvents(),
          child: Text(t.common.retry),
        ),
      ],
    ),
  );
}
```

**Design Decisions:**
- Clear visual feedback for errors
- Retry button for user action
- Translated error messages
- Logs technical details for debugging
- Doesn't expose technical details to users


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, I've identified the following testable properties. After reflection, I've eliminated redundant properties and combined related ones:

### Property Reflection

**Redundancy Analysis:**
- Properties 3.2, 4.3 (JSON parsing for different endpoints) can be combined into one comprehensive serialization property
- Properties 3.4, 4.6, 7.5 (throwing ApiException on failure) are redundant - one property covers all API failures
- Properties 5.5, 5.6, 6.5, 6.6 (specific HTTP error codes) are examples, not properties
- Property 7.4 (cache update) is subsumed by the broader cache consistency property

### Property 1: Event Serialization Round-Trip

*For any* valid Event JSON object returned by the API, deserializing it with Event.fromJson() and then serializing it back with Event.toJson() should produce an equivalent JSON structure with all fields preserved (including nested Venue, Address, EventPart, EventInfo objects, ISO 8601 dates, duration in seconds, and enum strings).

**Validates: Requirements 3.2, 4.3, 11.1, 11.2, 11.4, 11.5, 11.6, 11.7**

### Property 2: API Failures Throw ApiException

*For any* API call method (getAllEvents, getFavoriteEvents, addFavorite, removeFavorite, toggleFavorite), when the underlying HTTP request fails for any reason (network error, timeout, HTTP error, parsing error), the method should throw an ApiException with a descriptive message.

**Validates: Requirements 3.4, 4.6, 7.5**

### Property 3: Cache Consistency After Favorite Operations

*For any* event in the cached events list, after successfully calling addFavorite(eventId) or removeFavorite(eventId), the cached event with that eventId should have its isFavorite field updated to match the operation performed (true for add, false for remove).

**Validates: Requirements 7.4**

### Property 4: Cubit State Transitions

*For any* Cubit (EventListCubit or FavoritesCubit), when loadEvents() or loadFavorites() is called, the state transitions should follow the pattern: Loading → (Loaded | Error), never emitting multiple Loading states in sequence or skipping the Loading state.

**Validates: Requirements 9.1, 9.2, 9.3, 9.4**


## Testing Strategy

### Dual Testing Approach

The testing strategy combines unit tests and property-based tests to ensure comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs

Both approaches are complementary and necessary for comprehensive coverage. Unit tests catch concrete bugs in specific scenarios, while property tests verify general correctness across a wide range of inputs.

### Property-Based Testing

**Library**: Use the `test` package with custom property test helpers. Consider using a property-based testing library for Dart if available.

**Configuration**:
- Minimum 100 iterations per property test
- Each property test must reference its design document property
- Tag format: `@Tags(['Feature: frontend-api-integration', 'Property N: {property_text}'])`

**Property Test Coverage**:

1. **Property 1: Event Serialization Round-Trip**
   - Generate random Event JSON objects with all fields populated
   - Include nested objects (Venue, Address, EventPart, EventInfo)
   - Include various date formats, durations, enum values
   - Deserialize with Event.fromJson(), serialize with Event.toJson()
   - Verify the resulting JSON is equivalent to the original

2. **Property 2: API Failures Throw ApiException**
   - Generate random API failure scenarios (network errors, timeouts, HTTP errors)
   - Mock HTTP client to return failures
   - Call each repository method (getAllEvents, getFavoriteEvents, etc.)
   - Verify ApiException is thrown with appropriate message

3. **Property 3: Cache Consistency After Favorite Operations**
   - Generate random event lists and cache them
   - Randomly select events and call addFavorite or removeFavorite
   - Mock successful API responses
   - Verify cached event's isFavorite field matches the operation

4. **Property 4: Cubit State Transitions**
   - Generate random success/failure scenarios
   - Mock repository responses
   - Call load methods on Cubits
   - Verify state transitions follow Loading → (Loaded | Error) pattern

### Unit Testing

**Unit Test Coverage**:

1. **ApiClient Tests**
   - Test GET request with query parameters
   - Test POST request with body data
   - Test DELETE request with query parameters
   - Test health check endpoint
   - Test timeout error conversion to ApiException
   - Test network error conversion to ApiException
   - Test HTTP error response parsing
   - Test logging interceptor logs requests
   - Test error interceptor handles errors

2. **EventRepository Tests**
   - Test getAllEvents makes GET request to /api/events
   - Test getAllEvents parses response into Event list
   - Test getAllEvents updates cache on success
   - Test getAllEvents throws ApiException on failure
   - Test getFavoriteEvents makes GET request with userId parameter
   - Test getFavoriteEvents returns empty list for empty response
   - Test getFavoriteEvents throws ApiException on 400 error
   - Test addFavorite makes POST request with correct body
   - Test addFavorite updates cache on success
   - Test addFavorite throws ApiException on 404 error
   - Test removeFavorite makes DELETE request with userId parameter
   - Test removeFavorite updates cache on success
   - Test removeFavorite throws ApiException on 404 error
   - Test toggleFavorite calls addFavorite when not favorite
   - Test toggleFavorite calls removeFavorite when favorite
   - Test searchEvents filters by query (local implementation)
   - Test filterEvents filters by criteria (local implementation)

3. **EventListCubit Tests**
   - Test loadEvents emits Loading then Loaded on success
   - Test loadEvents emits Loading then Error on failure
   - Test loadEvents groups events by date correctly
   - Test toggleFavorite calls repository and reloads
   - Test toggleFavorite emits Error on failure

4. **FavoritesCubit Tests**
   - Test loadFavorites emits Loading then Loaded on success
   - Test loadFavorites emits Loading then Empty for empty list
   - Test loadFavorites emits Loading then Error on failure
   - Test loadFavorites separates upcoming and past events
   - Test toggleFavorite calls repository and reloads
   - Test toggleFavorite emits Error on failure

5. **Dependency Injection Tests**
   - Test ApiClient is registered as singleton
   - Test EventRepository is registered with ApiClient dependency
   - Test Cubits are registered with EventRepository dependency
   - Test same instance is returned on multiple getIt calls

6. **Translation Tests**
   - Test all error translation keys exist in all languages (en, cs, es)
   - Test translation keys can be accessed via global `t` variable

### Integration Testing

**Integration Test Coverage**:

1. **End-to-End API Tests**
   - Start mock HTTP server
   - Test complete flow: load events → display → toggle favorite → reload
   - Test error scenarios with mock server errors
   - Test retry functionality after errors

2. **Cubit Integration Tests**
   - Test EventListCubit with real EventRepository (mocked HTTP)
   - Test FavoritesCubit with real EventRepository (mocked HTTP)
   - Test favorite toggle updates both Cubits

### Test Organization

```
test/
├── unit/
│   ├── api/
│   │   ├── api_client_test.dart
│   │   └── api_exception_test.dart
│   ├── repositories/
│   │   └── event_repository_test.dart
│   ├── cubits/
│   │   ├── event_list_cubit_test.dart
│   │   └── favorites_cubit_test.dart
│   └── di/
│       └── service_locator_test.dart
├── property/
│   ├── event_serialization_test.dart
│   ├── api_error_handling_test.dart
│   ├── cache_consistency_test.dart
│   └── cubit_state_transitions_test.dart
└── integration/
    └── api_integration_test.dart
```

### Running Tests

```bash
# Run all tests
flutter test

# Run unit tests only
flutter test test/unit

# Run property tests only
flutter test test/property

# Run integration tests only
flutter test test/integration

# Run with coverage
flutter test --coverage
```

### Mocking Strategy

**Use mocktail for mocking:**
- Mock Dio for ApiClient tests
- Mock ApiClient for EventRepository tests
- Mock EventRepository for Cubit tests
- Mock HTTP responses with realistic JSON data

**Example Mock Setup:**
```dart
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}
class MockApiClient extends Mock implements ApiClient {}
class MockEventRepository extends Mock implements EventRepository {}

// In tests
final mockDio = MockDio();
when(() => mockDio.get(any())).thenAnswer((_) async => Response(
  data: [/* event JSON */],
  statusCode: 200,
  requestOptions: RequestOptions(path: '/api/events'),
));
```


## Migration Strategy

### Phase 1: Add Dependencies and API Client

1. Add Dio package to pubspec.yaml
2. Run `task get-deps` to install dependencies
3. Create ApiConfig class with constants
4. Create ApiException class
5. Create ApiClient class with Dio wrapper
6. Add unit tests for ApiClient

### Phase 2: Update EventRepository

1. Update EventRepository constructor to accept ApiClient
2. Implement getAllEvents() with API call
3. Implement getFavoriteEvents() with API call
4. Implement addFavorite() with API call
5. Implement removeFavorite() with API call
6. Update toggleFavorite() to use new methods
7. Keep search and filter as local implementations
8. Add unit tests for updated repository

### Phase 3: Update Dependency Injection

1. Register ApiClient in service locator
2. Update EventRepository registration with ApiClient dependency
3. Update Cubit registrations (no changes needed)
4. Test dependency injection setup

### Phase 4: Update Error Handling

1. Add translation keys for errors to all language files (en, cs, es)
2. Run `task slang` to generate translations
3. Update Cubits to catch ApiException
4. Update UI to display translated error messages
5. Add retry buttons to error states

### Phase 5: Testing and Validation

1. Write property tests for serialization and error handling
2. Write unit tests for all components
3. Write integration tests for end-to-end flows
4. Test with mock backend server
5. Test with real backend server (if available)
6. Test error scenarios (network off, timeout, server errors)

### Phase 6: Cleanup

1. Remove hardcoded event data from EventRepository
2. Remove unused imports
3. Update documentation
4. Code review and refactoring

### Rollback Plan

If issues arise during migration:
1. Keep hardcoded data as fallback
2. Add feature flag to switch between hardcoded and API data
3. Revert to previous version if critical bugs found
4. Fix issues and re-deploy

## Performance Considerations

1. **Caching**: Local cache reduces API calls and improves responsiveness
2. **Timeouts**: Prevent hanging requests with 10-second timeouts
3. **Lazy Loading**: Cubits load data on first access, not app startup
4. **Error Recovery**: Retry functionality allows users to recover from errors
5. **Offline Support**: Cache provides data when offline (until app restart)

## Security Considerations

1. **HTTPS**: Use HTTPS in production for encrypted communication
2. **API Keys**: Future: Add API key authentication
3. **User Authentication**: Future: Replace hardcoded userId with real auth
4. **Input Validation**: Validate all user inputs before sending to API
5. **Error Messages**: Don't expose sensitive information in error messages

## Future Enhancements

1. **Authentication**: Replace hardcoded userId with OAuth or JWT authentication
2. **Offline Support**: Add local database for persistent offline storage
3. **Search API**: Move search to backend for better performance and features
4. **Filter API**: Move filtering to backend for complex queries
5. **Pagination**: Add pagination for large event lists
6. **Real-time Updates**: Add WebSocket support for live event updates
7. **Image Caching**: Cache event images for faster loading
8. **Analytics**: Track API usage and errors for monitoring

## Dependencies

```yaml
dependencies:
  dio: ^5.4.0
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.0
  slang_flutter: ^3.31.0
  dancee_shared:
    path: ../../shared/dancee_shared

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.4
  mocktail: ^1.0.0
  build_runner: ^2.4.13
```

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── api_config.dart
│   ├── exceptions/
│   │   └── api_exception.dart
│   └── clients/
│       └── api_client.dart
├── di/
│   └── service_locator.dart
├── models/
│   └── (imported from dancee_shared)
├── repositories/
│   └── event_repository.dart
├── cubits/
│   ├── event_list/
│   │   ├── event_list_cubit.dart
│   │   └── event_list_state.dart
│   └── favorites/
│       ├── favorites_cubit.dart
│       └── favorites_state.dart
├── screens/
│   ├── event_list_screen.dart
│   └── favorites_screen.dart
└── i18n/
    ├── strings.i18n.json
    ├── strings_cs.i18n.json
    ├── strings_es.i18n.json
    └── translations.g.dart (generated)
```

**Design Decisions:**
- `core/` directory for fundamental app infrastructure (config, exceptions, clients)
- `core/config/` for all configuration files (API, app settings, feature flags, etc.)
- `core/exceptions/` for all custom exception types (API, validation, business logic, etc.)
- `core/clients/` for HTTP/API client wrappers
- Scalable structure that supports future additions without reorganization

## Conclusion

This design provides a clean integration of the backend REST API with the frontend Flutter application while maintaining the existing architecture. The use of Dio for HTTP communication, proper error handling with translated messages, and comprehensive testing ensures a reliable and maintainable solution.

Key benefits:
- **Clean Architecture**: Separation of concerns with API client, repository, and state management layers
- **Error Handling**: Comprehensive error handling with user-friendly translated messages
- **Testability**: Dependency injection and mocking support for thorough testing
- **Maintainability**: Clear code structure and documentation for future development
- **Internationalization**: All user-facing strings use slang translations
- **Future-Proof**: Architecture supports future enhancements like authentication and offline support
