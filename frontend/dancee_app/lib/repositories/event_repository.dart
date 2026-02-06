import 'package:dancee_shared/dancee_shared.dart';
import '../core/clients/api_client.dart';
import '../core/config/api_config.dart';
import '../core/exceptions/api_exception.dart';

/// Repository for managing event data.
///
/// This repository provides pure data access to the backend REST API.
/// It does NOT cache data - caching is handled by Cubits in their state.
/// It validates responses and adds error context for better error handling.
class EventRepository {
  final ApiClient _apiClient;

  /// Creates an EventRepository with the provided API client.
  EventRepository(this._apiClient);

  /// Returns all events from the backend API.
  ///
  /// Makes a GET request to /api/events and parses the response.
  /// Throws [ApiException] on error.
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _apiClient.get(ApiConfig.eventsEndpoint);

      // Validate response is a List
      if (response is! List) {
        throw ApiException(
          message: 'Invalid response format: expected List, got ${response.runtimeType}',
        );
      }

      // Parse JSON response into List<Event>
      try {
        return response
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
      } on FormatException catch (e, stackTrace) {
        throw ApiException(
          message: 'Failed to parse event data',
          error: e,
          stackTrace: stackTrace,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApiException(
        message: 'Failed to fetch events',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Returns favorite events for the current user from the backend API.
  ///
  /// Makes a GET request to /api/favorites with userId query parameter.
  /// Throws [ApiException] on error.
  Future<List<Event>> getFavoriteEvents() async {
    try {
      final response = await _apiClient.get(
        ApiConfig.favoritesEndpoint,
        queryParameters: {'userId': ApiConfig.userId},
      );

      // Validate response is a List
      if (response is! List) {
        throw ApiException(
          message: 'Invalid response format: expected List, got ${response.runtimeType}',
        );
      }

      // Handle empty array
      if (response.isEmpty) {
        return [];
      }

      // Parse JSON response into List<Event>
      try {
        return response
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
      } on FormatException catch (e, stackTrace) {
        throw ApiException(
          message: 'Failed to parse favorite event data',
          error: e,
          stackTrace: stackTrace,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApiException(
        message: 'Failed to fetch favorite events',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Adds an event to the user's favorites.
  ///
  /// Makes a POST request to /api/favorites with userId and eventId.
  /// Throws [ApiException] on error.
  Future<void> addFavorite(String eventId) async {
    try {
      await _apiClient.post(
        ApiConfig.favoritesEndpoint,
        data: {
          'userId': ApiConfig.userId,
          'eventId': eventId,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApiException(
        message: 'Failed to add event to favorites',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Removes an event from the user's favorites.
  ///
  /// Makes a DELETE request to /api/favorites/:eventId with userId query parameter.
  /// Throws [ApiException] on error.
  Future<void> removeFavorite(String eventId) async {
    try {
      await _apiClient.delete(
        '${ApiConfig.favoritesEndpoint}/$eventId',
        queryParameters: {'userId': ApiConfig.userId},
      );
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApiException(
        message: 'Failed to remove event from favorites',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Toggles the favorite status of an event.
  ///
  /// This is a helper method that decides whether to add or remove
  /// the event from favorites based on the current favorite status.
  ///
  /// [eventId] - The ID of the event to toggle
  /// [currentIsFavorite] - The current favorite status of the event
  ///
  /// Throws [ApiException] on error.
  Future<void> toggleFavorite(String eventId, bool currentIsFavorite) async {
    if (currentIsFavorite) {
      await removeFavorite(eventId);
    } else {
      await addFavorite(eventId);
    }
  }
}
