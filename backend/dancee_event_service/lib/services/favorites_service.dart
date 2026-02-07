import 'package:dancee_shared/dancee_shared.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/event_repository.dart';
import '../models/service_result.dart';

/// Service layer for managing user favorites.
class FavoritesService {
  final FavoritesRepository _favoritesRepository;
  final EventRepository _eventRepository;

  FavoritesService(this._favoritesRepository, this._eventRepository);

  /// Retrieves all favorite events for a given user.
  Future<List<Event>> getFavorites(String userId) async {
    return _favoritesRepository.getFavorites(userId);
  }

  /// Adds an event to a user's favorites.
  /// Validates that the event exists before adding.
  Future<ServiceResult> addFavorite(String userId, String eventId) async {
    final event = await _eventRepository.getEventById(eventId);
    if (event == null) {
      return ServiceResult.error(
        statusCode: 404,
        message: 'Event not found',
      );
    }

    // Mark event as favorite before storing
    final favoriteEvent = event.copyWith(isFavorite: true);
    await _favoritesRepository.addFavorite(userId, favoriteEvent);
    return ServiceResult.success(statusCode: 201);
  }

  /// Removes an event from a user's favorites.
  /// Validates that the event exists before removing.
  Future<ServiceResult> removeFavorite(String userId, String eventId) async {
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
