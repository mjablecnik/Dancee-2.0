import 'package:test/test.dart';
import 'package:dancee_event_service/repositories/event_repository.dart';
import 'package:dancee_event_service/repositories/favorites_repository.dart';
import 'package:dancee_event_service/services/favorites_service.dart';

void main() {
  group('FavoritesService', () {
    late EventRepository eventRepository;
    late FavoritesRepository favoritesRepository;
    late FavoritesService favoritesService;

    setUp(() {
      eventRepository = EventRepository();
      favoritesRepository = FavoritesRepository();
      favoritesService = FavoritesService(favoritesRepository, eventRepository);
    });

    group('getFavorites', () {
      test('returns empty list for user with no favorites', () async {
        final favorites = await favoritesService.getFavorites('user123');
        expect(favorites, isEmpty);
      });

      test('returns favorites after adding them', () async {
        // Add a favorite
        await favoritesService.addFavorite('user123', 'event-001');

        // Get favorites
        final favorites = await favoritesService.getFavorites('user123');
        expect(favorites, hasLength(1));
        expect(favorites.first.id, equals('event-001'));
      });
    });

    group('addFavorite', () {
      test('succeeds with valid eventId', () async {
        final result = await favoritesService.addFavorite('user123', 'event-001');
        expect(result.success, isTrue);
        expect(result.statusCode, equals(201));
      });

      test('returns 404 error with non-existent eventId', () async {
        final result = await favoritesService.addFavorite('user123', 'non-existent');
        expect(result.success, isFalse);
        expect(result.statusCode, equals(404));
        expect(result.message, equals('Event not found'));
      });

      test('is idempotent - adding same favorite twice succeeds', () async {
        // Add favorite first time
        final result1 = await favoritesService.addFavorite('user123', 'event-001');
        expect(result1.success, isTrue);

        // Add same favorite second time
        final result2 = await favoritesService.addFavorite('user123', 'event-001');
        expect(result2.success, isTrue);

        // Verify it appears only once
        final favorites = await favoritesService.getFavorites('user123');
        expect(favorites, hasLength(1));
      });
    });

    group('removeFavorite', () {
      test('succeeds with valid eventId', () async {
        // Add a favorite first
        await favoritesService.addFavorite('user123', 'event-001');

        // Remove it
        final result = await favoritesService.removeFavorite('user123', 'event-001');
        expect(result.success, isTrue);
        expect(result.statusCode, equals(204));

        // Verify it's removed
        final favorites = await favoritesService.getFavorites('user123');
        expect(favorites, isEmpty);
      });

      test('returns 404 error with non-existent eventId', () async {
        final result = await favoritesService.removeFavorite('user123', 'non-existent');
        expect(result.success, isFalse);
        expect(result.statusCode, equals(404));
        expect(result.message, equals('Event not found'));
      });

      test('is idempotent - removing non-existent favorite succeeds', () async {
        // Add and remove a favorite
        await favoritesService.addFavorite('user123', 'event-001');
        final result1 = await favoritesService.removeFavorite('user123', 'event-001');
        expect(result1.success, isTrue);

        // Try to remove it again (it's already gone)
        final result2 = await favoritesService.removeFavorite('user123', 'event-001');
        expect(result2.success, isTrue);
        expect(result2.statusCode, equals(204));
      });
    });

    group('integration scenarios', () {
      test('multiple users can have different favorites', () async {
        // User 1 adds event-001
        await favoritesService.addFavorite('user1', 'event-001');

        // User 2 adds event-002
        await favoritesService.addFavorite('user2', 'event-002');

        // Verify each user has their own favorites
        final user1Favorites = await favoritesService.getFavorites('user1');
        expect(user1Favorites, hasLength(1));
        expect(user1Favorites.first.id, equals('event-001'));

        final user2Favorites = await favoritesService.getFavorites('user2');
        expect(user2Favorites, hasLength(1));
        expect(user2Favorites.first.id, equals('event-002'));
      });

      test('user can have multiple favorites', () async {
        // Add multiple favorites
        await favoritesService.addFavorite('user123', 'event-001');
        await favoritesService.addFavorite('user123', 'event-002');
        await favoritesService.addFavorite('user123', 'event-003');

        // Verify all are present
        final favorites = await favoritesService.getFavorites('user123');
        expect(favorites, hasLength(3));
        expect(favorites.map((e) => e.id), containsAll(['event-001', 'event-002', 'event-003']));
      });
    });
  });
}
