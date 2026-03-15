import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';

import '../../../helpers/property_test_helpers.dart';

/// Feature: flutter-architecture-refactor
/// Property 2: Repository Return Type Consistency
/// **Validates: Requirements 2.7, 6.4**
///
/// For any valid JSON response from the API, the repository should always
/// return List<Event> (for getAllEvents/getFavoriteEvents) where every element
/// is an Event instance. The return types should be consistent regardless of
/// the input data.

// ============================================================================
// Mock
// ============================================================================

class MockApiClient extends Mock implements ApiClient {}

// ============================================================================
// Generators
// ============================================================================

/// Generates a random valid event JSON map suitable for repository parsing.
Map<String, dynamic> _randomEventJson(Random rng) {
  final start = randomDateTime(rng);
  final durationMinutes = 30 + rng.nextInt(480);
  final end = start.add(Duration(minutes: durationMinutes));
  final infoCount = rng.nextInt(4);
  final partsCount = rng.nextInt(4);

  return {
    'id': randomString(rng),
    'title': randomString(rng),
    'description': randomString(rng),
    'organizer': randomString(rng),
    'venue': {
      'name': randomString(rng),
      'address': {
        'street': randomString(rng),
        'city': randomString(rng),
        'postalCode': randomString(rng, maxLength: 10),
        'country': randomString(rng),
      },
      'description': randomString(rng),
      'latitude': randomLatitude(rng),
      'longitude': randomLongitude(rng),
    },
    'startTime': start.toIso8601String(),
    'endTime': end.toIso8601String(),
    'duration': durationMinutes * 60,
    'dances': randomStringList(rng, maxLength: 6),
    'info': List.generate(infoCount, (_) {
      final type = EventInfoType.values[rng.nextInt(EventInfoType.values.length)];
      return {
        'type': type.name,
        'key': randomString(rng),
        'value': randomString(rng),
      };
    }),
    'parts': List.generate(partsCount, (_) {
      final partStart = randomDateTime(rng);
      final partEnd = partStart.add(Duration(minutes: 30 + rng.nextInt(180)));
      final partType =
          EventPartType.values[rng.nextInt(EventPartType.values.length)];
      return {
        'name': randomString(rng),
        if (rng.nextBool()) 'description': randomString(rng),
        'type': partType.name,
        'startTime': partStart.toIso8601String(),
        'endTime': partEnd.toIso8601String(),
        if (rng.nextBool())
          'lectors': randomStringList(rng, maxLength: 3),
        if (rng.nextBool())
          'djs': randomStringList(rng, maxLength: 3),
      };
    }),
    'isFavorite': rng.nextBool(),
    'isPast': rng.nextBool(),
    if (rng.nextBool()) 'badge': randomString(rng, maxLength: 10),
  };
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  late MockApiClient mockApiClient;
  late EventRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = EventRepository(mockApiClient);
  });

  group('Property 2: Repository Return Type Consistency', () {
    test(
      'getAllEvents always returns List<Event> for 200 random valid JSON lists',
      () async {
        final rng = Random(42);

        for (var i = 0; i < 200; i++) {
          final listSize = rng.nextInt(10); // 0..9 events per response
          final jsonList = List.generate(listSize, (_) => _randomEventJson(rng));

          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => jsonList);

          final result = await repository.getAllEvents();

          expect(result, isA<List<Event>>(),
              reason: 'Iteration $i: result should be List<Event>');
          expect(result.length, equals(listSize),
              reason: 'Iteration $i: length mismatch');
          for (var j = 0; j < result.length; j++) {
            expect(result[j], isA<Event>(),
                reason: 'Iteration $i: element $j should be Event');
          }
        }
      },
    );

    test(
      'getFavoriteEvents always returns List<Event> for 200 random valid JSON lists',
      () async {
        final rng = Random(99);

        for (var i = 0; i < 200; i++) {
          final listSize = rng.nextInt(10);
          final jsonList = List.generate(listSize, (_) => _randomEventJson(rng));

          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => jsonList);

          final result = await repository.getFavoriteEvents();

          expect(result, isA<List<Event>>(),
              reason: 'Iteration $i: result should be List<Event>');
          expect(result.length, equals(listSize),
              reason: 'Iteration $i: length mismatch');
          for (var j = 0; j < result.length; j++) {
            expect(result[j], isA<Event>(),
                reason: 'Iteration $i: element $j should be Event');
          }
        }
      },
    );

    test(
      'getAllEvents returns empty List<Event> when API returns empty list',
      () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => <dynamic>[]);

        final result = await repository.getAllEvents();

        expect(result, isA<List<Event>>());
        expect(result, isEmpty);
      },
    );

    test(
      'getFavoriteEvents returns empty List<Event> when API returns empty list',
      () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => <dynamic>[]);

        final result = await repository.getFavoriteEvents();

        expect(result, isA<List<Event>>());
        expect(result, isEmpty);
      },
    );
  });
}
