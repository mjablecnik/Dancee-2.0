import 'package:dancee_shared/dancee_shared.dart';

/// Repository for managing user favorites using in-memory storage.
class FavoritesRepository {
  final Map<String, List<Event>> _favorites = {};

  /// Returns all favorite events for a given user.
  Future<List<Event>> getFavorites(String userId) async {
    return List.from(_favorites[userId] ?? []);
  }

  /// Adds an event to a user's favorites (idempotent operation).
  Future<void> addFavorite(String userId, Event event) async {
    _favorites.putIfAbsent(userId, () => <Event>[]);

    final alreadyExists = _favorites[userId]!.any((e) => e.id == event.id);
    if (!alreadyExists) {
      _favorites[userId]!.add(event);
    }
  }

  /// Removes an event from a user's favorites (idempotent operation).
  Future<void> removeFavorite(String userId, String eventId) async {
    _favorites[userId]?.removeWhere((event) => event.id == eventId);
  }
}
