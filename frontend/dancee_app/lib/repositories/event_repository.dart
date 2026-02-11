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
  /// Makes a GET request to /events/list with userId query parameter
  /// to mark favorite events. Parses the response.
  /// Throws ApiException on failure.
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _apiClient.get(
        '/events/list',
        queryParameters: {'userId': ApiConfig.userId},
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
  /// Makes a GET request to /events/favorites with userId query parameter.
  /// Returns an empty list if the API returns an empty array.
  /// Throws ApiException on failure.
  Future<List<Event>> getFavoriteEvents() async {
    try {
      final response = await _apiClient.get(
        '/events/favorites',
        queryParameters: {'userId': ApiConfig.userId},
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
  /// Makes a POST request to /events/favorites with userId and eventId.
  /// The Cubit is responsible for updating the cache after this call.
  /// Throws ApiException on failure.
  Future<void> addFavorite(String eventId) async {
    try {
      await _apiClient.post(
        '/events/favorites',
        data: {
          'userId': ApiConfig.userId,
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
  /// Makes a DELETE request to /events/favorites/:eventId with userId query parameter.
  /// The Cubit is responsible for updating the cache after this call.
  /// Throws ApiException on failure.
  Future<void> removeFavorite(String eventId) async {
    try {
      await _apiClient.delete(
        '/events/favorites/$eventId',
        queryParameters: {'userId': ApiConfig.userId},
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
  /// Throws ApiException on failure.
  Future<void> toggleFavorite(String eventId, bool currentIsFavorite) async {
    if (currentIsFavorite) {
      await removeFavorite(eventId);
    } else {
      await addFavorite(eventId);
    }
  }
}
