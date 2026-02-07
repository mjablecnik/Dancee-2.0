import 'package:dancee_shared/dancee_shared.dart';
import '../repositories/event_repository.dart';
import '../repositories/favorites_repository.dart';

/// Service layer for managing dance events.
class EventService {
  final EventRepository _eventRepository;
  final FavoritesRepository _favoritesRepository;

  EventService(this._eventRepository, this._favoritesRepository);

  /// Retrieves all available dance events.
  /// If userId is provided, marks events as favorite if they are in user's favorites.
  Future<List<Event>> getAllEvents({String? userId}) async {
    final events = await _eventRepository.getAllEvents();
    
    // If no userId provided, return events as-is
    if (userId == null || userId.isEmpty) {
      return events;
    }
    
    // Get user's favorite event IDs
    final favorites = await _favoritesRepository.getFavorites(userId);
    final favoriteIds = favorites.map((e) => e.id).toSet();
    
    // Mark events as favorite if they are in user's favorites
    return events.map((event) {
      if (favoriteIds.contains(event.id)) {
        return event.copyWith(isFavorite: true);
      }
      return event;
    }).toList();
  }
}
