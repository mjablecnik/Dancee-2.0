import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/repositories/event_repository.dart';
import 'package:dancee_app/core/clients/api_client.dart';
import 'package:dancee_app/core/exceptions/api_exception.dart';
import 'package:dancee_app/models/event.dart';
import 'package:dancee_app/models/venue.dart';
import 'package:dancee_app/models/address.dart';

// Mock class for ApiClient
class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('EventRepository', () {
    late MockApiClient mockApiClient;
    late EventRepository repository;

    final testVenue = Venue(
      name: 'Test Venue',
      address: Address(
        street: 'Test Street 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      ),
      description: 'Test venue description',
      latitude: 50.0,
      longitude: 14.0,
    );

    final testEvent = Event(
      id: '1',
      title: 'Test Event',
      description: 'Test description',
      organizer: 'Test Organizer',
      venue: testVenue,
      startTime: DateTime.now().add(const Duration(days: 1)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      duration: const Duration(hours: 3),
      dances: ['Salsa'],
      isFavorite: false,
      isPast: false,
    );

    setUp(() {
      mockApiClient = MockApiClient();
      repository = EventRepository(mockApiClient);
    });

    group('getAllEvents', () {
      test('returns list of events from API', () async {
        when(() => mockApiClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => [testEvent.toJson()]);

        final events = await repository.getAllEvents();

        expect(events, isNotEmpty);
        expect(events.length, 1);
        expect(events.first.id, testEvent.id);
        verify(() => mockApiClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('throws ApiException when API returns invalid format', () async {
        when(() => mockApiClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => 'invalid');

        expect(
          () => repository.getAllEvents(),
          throwsA(isA<ApiException>()),
        );
      });

      test('throws ApiException when API call fails', () async {
        when(() => mockApiClient.get(
              '/api/events/list',
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(Exception('Network error'));

        expect(
          () => repository.getAllEvents(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getFavoriteEvents', () {
      test('returns list of favorite events from API', () async {
        final favoriteEvent = testEvent.copyWith(isFavorite: true);
        when(() => mockApiClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => [favoriteEvent.toJson()]);

        final events = await repository.getFavoriteEvents();

        expect(events, isNotEmpty);
        expect(events.length, 1);
        expect(events.first.isFavorite, isTrue);
        verify(() => mockApiClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('returns empty list when no favorites', () async {
        when(() => mockApiClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => []);

        final events = await repository.getFavoriteEvents();

        expect(events, isEmpty);
      });

      test('throws ApiException when API returns invalid format', () async {
        when(() => mockApiClient.get(
              '/api/events/favorites',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => 'invalid');

        expect(
          () => repository.getFavoriteEvents(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('addFavorite', () {
      test('calls API to add favorite', () async {
        when(() => mockApiClient.post(
              '/api/events/favorites',
              data: any(named: 'data'),
            )).thenAnswer((_) async => {});

        await repository.addFavorite('1');

        verify(() => mockApiClient.post(
              '/api/events/favorites',
              data: any(named: 'data'),
            )).called(1);
      });

      test('throws ApiException when API call fails', () async {
        when(() => mockApiClient.post(
              '/api/events/favorites',
              data: any(named: 'data'),
            )).thenThrow(Exception('Network error'));

        expect(
          () => repository.addFavorite('1'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('removeFavorite', () {
      test('calls API to remove favorite', () async {
        when(() => mockApiClient.delete(
              '/api/events/favorites/1',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => {});

        await repository.removeFavorite('1');

        verify(() => mockApiClient.delete(
              '/api/events/favorites/1',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('throws ApiException when API call fails', () async {
        when(() => mockApiClient.delete(
              '/api/events/favorites/1',
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(Exception('Network error'));

        expect(
          () => repository.removeFavorite('1'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('toggleFavorite', () {
      test('calls removeFavorite when currentIsFavorite is true', () async {
        when(() => mockApiClient.delete(
              '/api/events/favorites/1',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => {});

        await repository.toggleFavorite('1', true);

        verify(() => mockApiClient.delete(
              '/api/events/favorites/1',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('calls addFavorite when currentIsFavorite is false', () async {
        when(() => mockApiClient.post(
              '/api/events/favorites',
              data: any(named: 'data'),
            )).thenAnswer((_) async => {});

        await repository.toggleFavorite('1', false);

        verify(() => mockApiClient.post(
              '/api/events/favorites',
              data: any(named: 'data'),
            )).called(1);
      });
    });
  });
}
