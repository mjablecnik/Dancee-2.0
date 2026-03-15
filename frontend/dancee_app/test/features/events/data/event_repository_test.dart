import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/core/exceptions.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Helper to generate a valid event JSON map for test cases.
Map<String, dynamic> createEventJson({
  String id = '1',
  String title = 'Test Event',
  bool isFavorite = false,
  bool isPast = false,
}) {
  return {
    'id': id,
    'title': title,
    'description': 'A test event description',
    'organizer': 'Test Organizer',
    'venue': {
      'name': 'Test Venue',
      'address': {
        'street': 'Test Street 1',
        'city': 'Prague',
        'postalCode': '110 00',
        'country': 'Czech Republic',
      },
      'description': 'A test venue',
      'latitude': 50.08,
      'longitude': 14.42,
    },
    'startTime': '2025-03-01T19:00:00.000Z',
    'endTime': '2025-03-01T23:00:00.000Z',
    'duration': 14400,
    'dances': ['salsa', 'bachata'],
    'info': [
      {'type': 'price', 'key': 'Entry', 'value': '150 CZK'},
    ],
    'parts': [
      {
        'name': 'Workshop',
        'type': 'workshop',
        'startTime': '2025-03-01T19:00:00.000Z',
        'endTime': '2025-03-01T20:00:00.000Z',
        'lectors': ['Instructor A'],
      },
    ],
    'isFavorite': isFavorite,
    'isPast': isPast,
  };
}

void main() {
  group('EventRepository', () {
    late MockApiClient mockClient;
    late EventRepository repository;

    setUp(() {
      mockClient = MockApiClient();
      repository = EventRepository(mockClient);
    });

    // =========================================================================
    // getAllEvents
    // =========================================================================
    group('getAllEvents', () {
      test('returns list of Event entities when API call succeeds', () async {
        final json1 = createEventJson(id: '1', title: 'Salsa Night');
        final json2 = createEventJson(id: '2', title: 'Bachata Party');

        when(() => mockClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => [json1, json2]);

        final result = await repository.getAllEvents();

        expect(result, hasLength(2));
        expect(result.first, isA<Event>());
        expect(result[0].id, '1');
        expect(result[0].title, 'Salsa Night');
        expect(result[1].id, '2');
        expect(result[1].title, 'Bachata Party');

        verify(() => mockClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('returns empty list when API returns empty array', () async {
        when(() => mockClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => []);

        final result = await repository.getAllEvents();

        expect(result, isEmpty);
      });

      test('throws ApiException when response is not a list', () async {
        when(() => mockClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => {'error': 'not a list'});

        expect(
          () => repository.getAllEvents(),
          throwsA(isA<ApiException>()),
        );
      });

      test('throws ApiException when API client throws', () async {
        when(() => mockClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(Exception('Network failure'));

        expect(
          () => repository.getAllEvents(),
          throwsA(isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Failed to load events',
          )),
        );
      });

      test('rethrows ApiException from API client', () async {
        final original = ApiException(message: 'Server error', statusCode: 500);

        when(() => mockClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(original);

        expect(
          () => repository.getAllEvents(),
          throwsA(same(original)),
        );
      });
    });

    // =========================================================================
    // getFavoriteEvents
    // =========================================================================
    group('getFavoriteEvents', () {
      test('returns favorite events when API call succeeds', () async {
        final json = createEventJson(id: 'fav1', isFavorite: true);

        when(() => mockClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => [json]);

        final result = await repository.getFavoriteEvents();

        expect(result, hasLength(1));
        expect(result.first, isA<Event>());
        expect(result.first.id, 'fav1');
        expect(result.first.isFavorite, isTrue);

        verify(() => mockClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('returns empty list when no favorites', () async {
        when(() => mockClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => []);

        final result = await repository.getFavoriteEvents();

        expect(result, isEmpty);
      });

      test('throws ApiException when response is not a list', () async {
        when(() => mockClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => 'invalid');

        expect(
          () => repository.getFavoriteEvents(),
          throwsA(isA<ApiException>()),
        );
      });

      test('throws ApiException on error', () async {
        when(() => mockClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(Exception('Network failure'));

        expect(
          () => repository.getFavoriteEvents(),
          throwsA(isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Failed to load favorite events',
          )),
        );
      });

      test('rethrows ApiException from API client', () async {
        final original = ApiException(message: 'Unauthorized', statusCode: 401);

        when(() => mockClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(original);

        expect(
          () => repository.getFavoriteEvents(),
          throwsA(same(original)),
        );
      });
    });

    // =========================================================================
    // toggleFavorite
    // =========================================================================
    group('toggleFavorite', () {
      test('calls addFavorite (POST) when currentIsFavorite is false', () async {
        when(() => mockClient.post(
              '/api/events/favorites',
              data: any(named: 'data'),
            )).thenAnswer((_) async => {});

        await repository.toggleFavorite('evt1', false);

        verify(() => mockClient.post(
              '/api/events/favorites',
              data: any(named: 'data'),
            )).called(1);
        verifyNever(() => mockClient.delete(
              any(),
              queryParameters: any(named: 'queryParameters'),
            ));
      });

      test('calls removeFavorite (DELETE) when currentIsFavorite is true', () async {
        when(() => mockClient.delete(
              '/api/events/favorites/evt1',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => {});

        await repository.toggleFavorite('evt1', true);

        verify(() => mockClient.delete(
              '/api/events/favorites/evt1',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
        verifyNever(() => mockClient.post(
              any(),
              data: any(named: 'data'),
            ));
      });

      test('throws ApiException on add failure', () async {
        when(() => mockClient.post(
              '/api/events/favorites',
              data: any(named: 'data'),
            )).thenThrow(Exception('Network failure'));

        expect(
          () => repository.toggleFavorite('evt1', false),
          throwsA(isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Failed to add favorite',
          )),
        );
      });

      test('throws ApiException on remove failure', () async {
        when(() => mockClient.delete(
              '/api/events/favorites/evt1',
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(Exception('Network failure'));

        expect(
          () => repository.toggleFavorite('evt1', true),
          throwsA(isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Failed to remove favorite',
          )),
        );
      });
    });
  });
}
