import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/clients.dart';
import '../../../core/exceptions.dart';
import 'entities.dart';

/// Repository for managing event data from Directus CMS.
///
/// Fetches events via the Directus REST API (`/items/events`) with
/// expanded venue and translations relations. Favorites are stored
/// locally using SharedPreferences since Directus has no per-user
/// favorites concept.
class EventRepository {
  final DirectusClient _client;

  static const _favoritesKey = 'favorite_event_ids';

  EventRepository(this._client);

  /// Returns all published events from Directus.
  ///
  /// Fetches events with expanded venue and translations, filters
  /// by `status=published`, and sorts by `start_time`.
  /// Marks events as favorites based on local storage.
  Future<List<Event>> getAllEvents() async {
    try {
      developer.log('Fetching events from Directus', name: 'EventRepository');

      final response = await _client.get(
        '/items/events',
        queryParameters: {
          'fields': '*,venue.*,translations.*',
          'filter[status][_eq]': 'published',
          'sort': 'start_time',
          'limit': '-1',
        },
      );

      if (response is! List) {
        developer.log(
          'Invalid response format: expected List, got ${response.runtimeType}',
          name: 'EventRepository',
        );
        throw ApiException(message: 'Invalid response format');
      }

      developer.log(
        'Received ${response.length} events, parsing...',
        name: 'EventRepository',
      );

      final favoriteIds = await _loadFavoriteIds();

      final events = <Event>[];
      for (var i = 0; i < response.length; i++) {
        try {
          final json = response[i] as Map<String, dynamic>;
          events.add(Event.fromDirectus(json, favoriteIds: favoriteIds));
        } catch (e) {
          developer.log(
            'Failed to parse event at index $i: $e',
            name: 'EventRepository',
            level: 900,
          );
          // Skip malformed events instead of failing entirely
        }
      }

      developer.log(
        'Successfully parsed ${events.length} events',
        name: 'EventRepository',
      );
      return events;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to load events',
        originalError: e,
      );
    }
  }

  /// Returns only favorite events.
  ///
  /// Fetches all published events and filters to those whose IDs
  /// are in the local favorites set.
  Future<List<Event>> getFavoriteEvents() async {
    try {
      final favoriteIds = await _loadFavoriteIds();
      if (favoriteIds.isEmpty) return [];

      final response = await _client.get(
        '/items/events',
        queryParameters: {
          'fields': '*,venue.*,translations.*',
          'filter[status][_eq]': 'published',
          'filter[id][_in]': favoriteIds.join(','),
          'sort': 'start_time',
          'limit': '-1',
        },
      );

      if (response is! List) {
        throw ApiException(message: 'Invalid response format');
      }

      return response
          .map((json) => Event.fromDirectus(
                json as Map<String, dynamic>,
                favoriteIds: favoriteIds,
              ))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to load favorite events',
        originalError: e,
      );
    }
  }

  /// Adds an event to local favorites.
  Future<void> addFavorite(String eventId) async {
    final ids = await _loadFavoriteIds();
    ids.add(eventId);
    await _saveFavoriteIds(ids);
  }

  /// Removes an event from local favorites.
  Future<void> removeFavorite(String eventId) async {
    final ids = await _loadFavoriteIds();
    ids.remove(eventId);
    await _saveFavoriteIds(ids);
  }

  /// Toggles the favorite status of an event.
  Future<void> toggleFavorite(String eventId, bool currentIsFavorite) async {
    if (currentIsFavorite) {
      await removeFavorite(eventId);
    } else {
      await addFavorite(eventId);
    }
  }

  // -- Local favorites storage --

  Future<Set<String>> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  Future<void> _saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList());
  }
}
