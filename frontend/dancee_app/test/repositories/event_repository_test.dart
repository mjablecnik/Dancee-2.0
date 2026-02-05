import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/repositories/event_repository.dart';

void main() {
  group('EventRepository', () {
    late EventRepository repository;

    setUp(() {
      repository = EventRepository();
    });

    group('getAllEvents', () {
      test('returns all events', () async {
        final events = await repository.getAllEvents();
        
        expect(events, isNotEmpty);
        expect(events.length, greaterThan(0));
      });

      test('returns unmodifiable list', () async {
        final events = await repository.getAllEvents();
        
        expect(() => events.add(events.first), throwsUnsupportedError);
      });

      test('includes events from EventListScreen', () async {
        final events = await repository.getAllEvents();
        
        final titles = events.map((e) => e.title).toList();
        expect(titles, contains('Salsa Social Night'));
        expect(titles, contains('Bachata Tuesdays'));
        expect(titles, contains('Zouk Workshop & Party'));
        expect(titles, contains('Kizomba Wednesday'));
        expect(titles, contains('Tango Practica'));
        expect(titles, contains('Latin Mix Party'));
      });

      test('includes favorite events from FavoritesScreen', () async {
        final events = await repository.getAllEvents();
        
        final titles = events.map((e) => e.title).toList();
        expect(titles, contains('Salsa & Bachata Night Prague'));
        expect(titles, contains('Bachata Sensual Workshop'));
        expect(titles, contains('Kizomba Fusion Party'));
        expect(titles, contains('Salsa Cubana Workshop'));
        expect(titles, contains('Kizomba Ladies Styling'));
      });
    });

    group('getFavoriteEvents', () {
      test('returns only favorite events', () async {
        final favorites = await repository.getFavoriteEvents();
        
        expect(favorites, isNotEmpty);
        for (final event in favorites) {
          expect(event.isFavorite, isTrue);
        }
      });

      test('includes Bachata Tuesdays as favorite', () async {
        final favorites = await repository.getFavoriteEvents();
        
        final titles = favorites.map((e) => e.title).toList();
        expect(titles, contains('Bachata Tuesdays'));
      });

      test('includes Tango Practica as favorite', () async {
        final favorites = await repository.getFavoriteEvents();
        
        final titles = favorites.map((e) => e.title).toList();
        expect(titles, contains('Tango Practica'));
      });

      test('includes past favorite events', () async {
        final favorites = await repository.getFavoriteEvents();
        
        final pastFavorites = favorites.where((e) => e.isPast).toList();
        expect(pastFavorites, isNotEmpty);
      });
    });

    group('getEventsByDate', () {
      test('returns events for specific date', () async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final todayEvents = await repository.getEventsByDate(today);
        
        for (final event in todayEvents) {
          final eventDate = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          );
          expect(eventDate, equals(today));
        }
      });

      test('returns empty list for date with no events', () async {
        final futureDate = DateTime.now().add(const Duration(days: 365));
        
        final events = await repository.getEventsByDate(futureDate);
        
        expect(events, isEmpty);
      });

      test('returns multiple events for same date', () async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final todayEvents = await repository.getEventsByDate(today);
        
        // Today should have multiple events
        expect(todayEvents.length, greaterThan(1));
      });
    });

    group('toggleFavorite', () {
      test('toggles favorite status from false to true', () async {
        final events = await repository.getAllEvents();
        final nonFavorite = events.firstWhere((e) => !e.isFavorite);
        
        await repository.toggleFavorite(nonFavorite.id);
        
        final updatedEvents = await repository.getAllEvents();
        final updatedEvent = updatedEvents.firstWhere((e) => e.id == nonFavorite.id);
        expect(updatedEvent.isFavorite, isTrue);
      });

      test('toggles favorite status from true to false', () async {
        final events = await repository.getAllEvents();
        final favorite = events.firstWhere((e) => e.isFavorite);
        
        await repository.toggleFavorite(favorite.id);
        
        final updatedEvents = await repository.getAllEvents();
        final updatedEvent = updatedEvents.firstWhere((e) => e.id == favorite.id);
        expect(updatedEvent.isFavorite, isFalse);
      });

      test('maintains state across multiple calls', () async {
        final events = await repository.getAllEvents();
        final event = events.first;
        final initialStatus = event.isFavorite;
        
        // Toggle twice
        await repository.toggleFavorite(event.id);
        await repository.toggleFavorite(event.id);
        
        final updatedEvents = await repository.getAllEvents();
        final updatedEvent = updatedEvents.firstWhere((e) => e.id == event.id);
        expect(updatedEvent.isFavorite, equals(initialStatus));
      });

      test('does nothing for non-existent event ID', () async {
        final eventsBefore = await repository.getAllEvents();
        
        await repository.toggleFavorite('non-existent-id');
        
        final eventsAfter = await repository.getAllEvents();
        expect(eventsAfter.length, equals(eventsBefore.length));
      });
    });

    group('searchEvents', () {
      test('returns all events for empty query', () async {
        final allEvents = await repository.getAllEvents();
        
        final searchResults = await repository.searchEvents('');
        
        expect(searchResults.length, equals(allEvents.length));
      });

      test('searches by event title', () async {
        final results = await repository.searchEvents('Salsa');
        
        expect(results, isNotEmpty);
        for (final event in results) {
          final matchesTitle = event.title.toLowerCase().contains('salsa');
          final matchesVenue = event.venue.name.toLowerCase().contains('salsa');
          final matchesDescription = event.description.toLowerCase().contains('salsa');
          expect(
            matchesTitle || matchesVenue || matchesDescription,
            isTrue,
          );
        }
      });

      test('searches by venue name', () async {
        final results = await repository.searchEvents('Lucerna');
        
        expect(results, isNotEmpty);
        for (final event in results) {
          expect(
            event.venue.name.toLowerCase().contains('lucerna'),
            isTrue,
          );
        }
      });

      test('searches by description', () async {
        final results = await repository.searchEvents('workshop');
        
        expect(results, isNotEmpty);
        for (final event in results) {
          final matchesTitle = event.title.toLowerCase().contains('workshop');
          final matchesVenue = event.venue.name.toLowerCase().contains('workshop');
          final matchesDescription = event.description.toLowerCase().contains('workshop');
          expect(
            matchesTitle || matchesVenue || matchesDescription,
            isTrue,
          );
        }
      });

      test('is case-insensitive', () async {
        final lowerResults = await repository.searchEvents('salsa');
        final upperResults = await repository.searchEvents('SALSA');
        final mixedResults = await repository.searchEvents('SaLsA');
        
        expect(lowerResults.length, equals(upperResults.length));
        expect(lowerResults.length, equals(mixedResults.length));
      });

      test('returns empty list for non-matching query', () async {
        final results = await repository.searchEvents('NonExistentEvent12345');
        
        expect(results, isEmpty);
      });
    });

    group('filterEvents', () {
      test('filters by dance style', () async {
        final results = await repository.filterEvents({
          'dances': ['Bachata'],
        });
        
        expect(results, isNotEmpty);
        for (final event in results) {
          expect(event.dances, contains('Bachata'));
        }
      });

      test('filters by multiple dance styles', () async {
        final results = await repository.filterEvents({
          'dances': ['Salsa', 'Kizomba'],
        });
        
        expect(results, isNotEmpty);
        for (final event in results) {
          final hasSalsa = event.dances.contains('Salsa');
          final hasKizomba = event.dances.contains('Kizomba');
          expect(hasSalsa || hasKizomba, isTrue);
        }
      });

      test('filters by isPast status', () async {
        final pastEvents = await repository.filterEvents({
          'isPast': true,
        });
        
        expect(pastEvents, isNotEmpty);
        for (final event in pastEvents) {
          expect(event.isPast, isTrue);
        }
      });

      test('filters upcoming events', () async {
        final upcomingEvents = await repository.filterEvents({
          'isPast': false,
        });
        
        expect(upcomingEvents, isNotEmpty);
        for (final event in upcomingEvents) {
          expect(event.isPast, isFalse);
        }
      });

      test('filters by date range', () async {
        final now = DateTime.now();
        final start = now.subtract(const Duration(days: 1));
        final end = now.add(const Duration(days: 2));
        
        final results = await repository.filterEvents({
          'dateRange': {'start': start, 'end': end},
        });
        
        for (final event in results) {
          expect(event.startTime.isAfter(start), isTrue);
          expect(event.startTime.isBefore(end), isTrue);
        }
      });

      test('combines multiple filter criteria', () async {
        final now = DateTime.now();
        final start = now.subtract(const Duration(days: 1));
        final end = now.add(const Duration(days: 30));
        
        final results = await repository.filterEvents({
          'dances': ['Bachata'],
          'isPast': false,
          'dateRange': {'start': start, 'end': end},
        });
        
        for (final event in results) {
          expect(event.dances, contains('Bachata'));
          expect(event.isPast, isFalse);
          expect(event.startTime.isAfter(start), isTrue);
          expect(event.startTime.isBefore(end), isTrue);
        }
      });

      test('returns all events for empty criteria', () async {
        final allEvents = await repository.getAllEvents();
        
        final results = await repository.filterEvents({});
        
        expect(results.length, equals(allEvents.length));
      });
    });
  });
}
