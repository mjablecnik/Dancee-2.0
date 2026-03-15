import 'dart:developer' as developer;

import '../../../core/clients.dart';
import '../../../core/config.dart';
import '../../../core/exceptions.dart';
import 'entities.dart';

/// Repository for managing event data.
///
/// This repository provides pure data access to the backend REST API.
/// It does NOT cache data - caching is handled by Cubits in their state.
/// It validates responses and adds error context for better error handling.
///
/// Responsibilities:
/// - Fetch data from API (receives Map<String, dynamic>)
/// - Convert JSON to entities via Entity.fromJson()
/// - Validate data
/// - Throw custom exceptions on errors
/// - ALWAYS return entities
class EventRepository {
  final ApiClient _apiClient;

  /// Creates an EventRepository with the provided API client.
  EventRepository(this._apiClient);

  /// Returns all events from the backend API.
  ///
  /// Makes a GET request to /api/events/list with userId query parameter
  /// to mark favorite events. Validates the response format and converts
  /// JSON maps directly to Event entities.
  /// Throws [ApiException] on failure.
  Future<List<Event>> getAllEvents() async {
    try {
      developer.log('Fetching events from /api/events/list', name: 'EventRepository');
      final response = await _apiClient.get(
        '/api/events/list',
        queryParameters: {'userId': AppConfig.userId},
      );

      developer.log('Response type: ${response.runtimeType}', name: 'EventRepository');

      if (response is! List) {
        developer.log('Invalid response format: expected List, got ${response.runtimeType}', name: 'EventRepository');
        throw ApiException(message: 'Invalid response format');
      }

      developer.log('Received ${response.length} events, parsing...', name: 'EventRepository');

      final events = <Event>[];
      for (var i = 0; i < response.length; i++) {
        try {
          final json = response[i] as Map<String, dynamic>;
          events.add(Event.fromJson(json));
        } catch (e) {
          developer.log(
            'Failed to parse event at index $i: $e\nJSON: ${response[i]}',
            name: 'EventRepository',
            level: 900,
          );
          rethrow;
        }
      }

      developer.log('Successfully parsed ${events.length} events', name: 'EventRepository');
      return events;
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ApiException(
        message: 'Failed to parse events response',
        originalError: e,
      );
    } catch (e) {
      throw ApiException(
        message: 'Failed to load events',
        originalError: e,
      );
    }
  }

  /// Returns only favorite events from the backend API.
  ///
  /// Makes a GET request to /api/events/favorites with userId query parameter.
  /// Returns an empty list if the API returns an empty array.
  /// Throws [ApiException] on failure.
  Future<List<Event>> getFavoriteEvents() async {
    try {
      final response = await _apiClient.get(
        '/api/events/favorites',
        queryParameters: {'userId': AppConfig.userId},
      );

      if (response is! List) {
        throw ApiException(message: 'Invalid response format');
      }

      return response
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ApiException(
        message: 'Failed to parse favorite events response',
        originalError: e,
      );
    } catch (e) {
      throw ApiException(
        message: 'Failed to load favorite events',
        originalError: e,
      );
    }
  }

  /// Adds an event to the user's favorites.
  ///
  /// Makes a POST request to /api/events/favorites with userId and eventId.
  /// The Cubit is responsible for updating the cache after this call.
  /// Throws [ApiException] on failure.
  Future<void> addFavorite(String eventId) async {
    try {
      await _apiClient.post(
        '/api/events/favorites',
        data: {
          'userId': AppConfig.userId,
          'eventId': eventId,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to add favorite',
        originalError: e,
      );
    }
  }

  /// Removes an event from the user's favorites.
  ///
  /// Makes a DELETE request to /api/events/favorites/:eventId with userId query parameter.
  /// The Cubit is responsible for updating the cache after this call.
  /// Throws [ApiException] on failure.
  Future<void> removeFavorite(String eventId) async {
    try {
      await _apiClient.delete(
        '/api/events/favorites/$eventId',
        queryParameters: {'userId': AppConfig.userId},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to remove favorite',
        originalError: e,
      );
    }
  }

  /// Toggles the favorite status of an event.
  ///
  /// If currentIsFavorite is true, removes the event from favorites.
  /// If currentIsFavorite is false, adds the event to favorites.
  /// The Cubit passes the current favorite status from its cached state.
  /// Throws [ApiException] on failure.
  Future<void> toggleFavorite(String eventId, bool currentIsFavorite) async {
    if (currentIsFavorite) {
      await removeFavorite(eventId);
    } else {
      await addFavorite(eventId);
    }
  }
}
