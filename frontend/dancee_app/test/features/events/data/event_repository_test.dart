import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDirectusClient extends Mock implements DirectusClient {}

// ---------------------------------------------------------------------------
// Sample Directus JSON helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _eventJson(String id) => {
      'id': id,
      'start_time': '2099-12-31T20:00:00.000Z',
      'end_time': '2099-12-31T23:00:00.000Z',
      'organizer': 'Organizer',
      'dances': <String>[],
      'venue': {
        'name': 'Venue $id',
        'street': 'Street',
        'number': '1',
        'town': 'City',
        'postal_code': '100 00',
        'country': 'CZ',
        'latitude': 50.0,
        'longitude': 14.0,
      },
      'translations': [
        {
          'languages_code': 'cs',
          'title': 'Event $id',
          'description': 'Desc',
        }
      ],
      'info': <dynamic>[],
      'parts': <dynamic>[],
    };

void main() {
  late MockDirectusClient mockClient;
  late EventRepository repository;

  setUp(() {
    mockClient = MockDirectusClient();
    repository = EventRepository(mockClient);
    SharedPreferences.setMockInitialValues({});
  });

  // =========================================================================
  // getAllEvents()
  // =========================================================================

  group('getAllEvents()', () {
    // -----------------------------------------------------------------------
    // TC-028: Returns list of parsed events on success
    // -----------------------------------------------------------------------
    test('TC-028: returns parsed list of events on success', () async {
      when(() => mockClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => [_eventJson('1'), _eventJson('2'), _eventJson('3')],
      );

      final events = await repository.getAllEvents();

      expect(events.length, equals(3));
      expect(events.map((e) => e.id), containsAll(['1', '2', '3']));
    });

    // -----------------------------------------------------------------------
    // TC-029: Propagates ApiException on client failure
    // -----------------------------------------------------------------------
    test('TC-029: rethrows ApiException from client', () async {
      when(() => mockClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(ApiException(message: 'Server error', statusCode: 500));

      expect(
        () => repository.getAllEvents(),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    // -----------------------------------------------------------------------
    // TC-036: Handles empty data array from API
    // -----------------------------------------------------------------------
    test('TC-036: returns empty list when API returns empty array', () async {
      when(() => mockClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => <dynamic>[]);

      final events = await repository.getAllEvents();
      expect(events, isEmpty);
    });
  });

  // =========================================================================
  // getFavoriteEvents()
  // =========================================================================

  group('getFavoriteEvents()', () {
    // -----------------------------------------------------------------------
    // TC-030: Returns only events whose IDs are in SharedPreferences
    // -----------------------------------------------------------------------
    test('TC-030: returns only events matching saved favorite IDs', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_event_ids': ['1', '3'],
      });

      when(() => mockClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => [_eventJson('1'), _eventJson('3')],
      );

      final favorites = await repository.getFavoriteEvents();

      expect(favorites.length, equals(2));
      expect(favorites.map((e) => e.id), containsAll(['1', '3']));
    });

    // -----------------------------------------------------------------------
    // TC-031: Returns empty list when no favorites saved
    // -----------------------------------------------------------------------
    test('TC-031: returns empty list when SharedPreferences has no favorites',
        () async {
      SharedPreferences.setMockInitialValues({});
      final favorites = await repository.getFavoriteEvents();
      expect(favorites, isEmpty);
      // Client should NOT be called when there are no favorite IDs
      verifyNever(() => mockClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ));
    });
  });

  // =========================================================================
  // addFavorite() / removeFavorite()
  // =========================================================================

  group('addFavorite() / removeFavorite()', () {
    // -----------------------------------------------------------------------
    // TC-032: addFavorite() persists ID to SharedPreferences
    // -----------------------------------------------------------------------
    test('TC-032: addFavorite persists new ID to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      await repository.addFavorite('42');

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('favorite_event_ids') ?? [];
      expect(saved, contains('42'));
    });

    // -----------------------------------------------------------------------
    // TC-033: removeFavorite() removes ID from SharedPreferences
    // -----------------------------------------------------------------------
    test('TC-033: removeFavorite removes ID from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_event_ids': ['42', '99'],
      });

      await repository.removeFavorite('42');

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('favorite_event_ids') ?? [];
      expect(saved, isNot(contains('42')));
      expect(saved, contains('99'));
    });
  });

  // =========================================================================
  // TC-122: getAllEvents() marks favorites using SharedPreferences IDs
  // =========================================================================

  test('TC-122: getAllEvents marks events as favorites based on SharedPreferences',
      () async {
    SharedPreferences.setMockInitialValues({
      'favorite_event_ids': ['evt-1'],
    });

    when(() => mockClient.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => [_eventJson('evt-1'), _eventJson('evt-2')],
    );

    final events = await repository.getAllEvents();

    expect(events.length, equals(2));
    final evt1 = events.firstWhere((e) => e.id == 'evt-1');
    final evt2 = events.firstWhere((e) => e.id == 'evt-2');
    expect(evt1.isFavorite, isTrue,
        reason: 'evt-1 is in SharedPreferences favorites');
    expect(evt2.isFavorite, isFalse,
        reason: 'evt-2 is not in SharedPreferences favorites');
  });

  // =========================================================================
  // TC-123: getAllEvents() silently skips malformed events
  // =========================================================================

  test('TC-123: getAllEvents silently skips events that fail JSON parsing',
      () async {
    when(() => mockClient.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => [
        _eventJson('1'),
        // Malformed: missing required fields (id is null, no translations)
        <String, dynamic>{'id': null},
        _eventJson('3'),
      ],
    );

    final events = await repository.getAllEvents();

    expect(events.length, equals(2),
        reason: 'Malformed entry should be skipped silently');
    expect(events.map((e) => e.id), containsAll(['1', '3']));
  });

  // =========================================================================
  // TC-172: getAllEvents() skips null entries in API response list
  // =========================================================================

  test('TC-172: getAllEvents silently skips null entries in API response',
      () async {
    when(() => mockClient.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => [
        _eventJson('1'),
        null,
        _eventJson('3'),
      ],
    );

    final events = await repository.getAllEvents();

    expect(events.length, equals(2),
        reason: 'Null entry should be silently skipped');
    expect(events.map((e) => e.id), containsAll(['1', '3']));
  });

  // =========================================================================
  // toggleFavorite()
  // =========================================================================

  group('toggleFavorite()', () {
    // -----------------------------------------------------------------------
    // TC-034: Adds when not yet favorite
    // -----------------------------------------------------------------------
    test('TC-034: toggleFavorite adds ID when currentIsFavorite is false',
        () async {
      SharedPreferences.setMockInitialValues({
        'favorite_event_ids': ['1'],
      });

      await repository.toggleFavorite('2', false);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('favorite_event_ids') ?? [];
      expect(saved, containsAll(['1', '2']));
    });

    // -----------------------------------------------------------------------
    // TC-035: Removes when already favorite
    // -----------------------------------------------------------------------
    test('TC-035: toggleFavorite removes ID when currentIsFavorite is true',
        () async {
      SharedPreferences.setMockInitialValues({
        'favorite_event_ids': ['1', '2'],
      });

      await repository.toggleFavorite('1', true);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('favorite_event_ids') ?? [];
      expect(saved, isNot(contains('1')));
      expect(saved, contains('2'));
    });
  });
}
