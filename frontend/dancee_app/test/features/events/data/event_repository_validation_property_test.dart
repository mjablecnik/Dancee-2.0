import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';

/// Feature: flutter-architecture-refactor
/// Property 5: Repository Data Validation
/// **Validates: Requirements 7.6**
///
/// For any invalid data received from the API (missing required fields, invalid
/// formats, wrong types), the repository should reject it and throw an exception
/// before returning.

// ============================================================================
// Mock
// ============================================================================

class MockApiClient extends Mock implements ApiClient {}

// ============================================================================
// Generators — produce invalid API responses
// ============================================================================

/// A valid event JSON map used as a baseline for generating invalid variants.
Map<String, dynamic> _validEventJson() => {
      'id': 'evt-1',
      'title': 'Test Event',
      'description': 'A test event',
      'organizer': 'Test Org',
      'venue': {
        'name': 'Test Venue',
        'address': {
          'street': '123 Main St',
          'city': 'Prague',
          'postalCode': '11000',
          'country': 'Czech Republic',
        },
        'description': 'A nice venue',
        'latitude': 50.08,
        'longitude': 14.42,
      },
      'startTime': '2025-01-15T19:00:00.000Z',
      'endTime': '2025-01-15T23:00:00.000Z',
      'duration': 14400,
      'dances': ['salsa', 'bachata'],
      'info': <dynamic>[],
      'parts': <dynamic>[],
      'isFavorite': false,
      'isPast': false,
    };

/// Responses that are not a List — the repository should reject these.
final List<dynamic> _nonListResponses = [
  {'events': []}, // Map
  'not a list', // String
  42, // int
  3.14, // double
  true, // bool
  null, // null
];

/// List items that are not Maps — the repository should reject these.
final List<dynamic> _nonMapItems = [
  'a string',
  42,
  3.14,
  true,
  null,
  ['nested', 'list'],
];

/// Required top-level fields on an Event JSON map.
final List<String> _requiredEventFields = [
  'id',
  'title',
  'description',
  'organizer',
  'venue',
  'startTime',
  'endTime',
  'duration',
  'dances',
  'info',
  'parts',
];

/// Generates event JSON maps each missing one required field.
List<Map<String, dynamic>> _generateMissingFieldVariants() {
  return _requiredEventFields.map((field) {
    final json = _validEventJson();
    json.remove(field);
    return json;
  }).toList();
}

/// Generates event JSON maps with wrong types for required fields.
List<Map<String, dynamic>> _generateWrongTypeVariants() {
  final variants = <Map<String, dynamic>>[];

  // String fields given int values
  for (final field in ['id', 'title', 'description', 'organizer']) {
    final json = _validEventJson();
    json[field] = 12345;
    variants.add(json);
  }

  // venue should be a Map, give it a String
  final venueWrong = _validEventJson();
  venueWrong['venue'] = 'not a map';
  variants.add(venueWrong);

  // startTime / endTime should be parseable date strings, give them ints
  for (final field in ['startTime', 'endTime']) {
    final json = _validEventJson();
    json[field] = 99999;
    variants.add(json);
  }

  // duration should be an int, give it a String
  final durationWrong = _validEventJson();
  durationWrong['duration'] = 'not a number';
  variants.add(durationWrong);

  // dances should be a List, give it a String
  final dancesWrong = _validEventJson();
  dancesWrong['dances'] = 'not a list';
  variants.add(dancesWrong);

  // info should be a List, give it a String
  final infoWrong = _validEventJson();
  infoWrong['info'] = 'not a list';
  variants.add(infoWrong);

  // parts should be a List, give it a String
  final partsWrong = _validEventJson();
  partsWrong['parts'] = 'not a list';
  variants.add(partsWrong);

  return variants;
}

/// Generates event JSON maps with invalid nested venue data.
List<Map<String, dynamic>> _generateInvalidVenueVariants() {
  final variants = <Map<String, dynamic>>[];

  // Missing required venue fields
  for (final field in ['name', 'address', 'description', 'latitude', 'longitude']) {
    final json = _validEventJson();
    (json['venue'] as Map<String, dynamic>).remove(field);
    variants.add(json);
  }

  // Wrong types in venue
  final venueNameWrong = _validEventJson();
  (venueNameWrong['venue'] as Map<String, dynamic>)['name'] = 123;
  variants.add(venueNameWrong);

  final venueAddressWrong = _validEventJson();
  (venueAddressWrong['venue'] as Map<String, dynamic>)['address'] = 'not a map';
  variants.add(venueAddressWrong);

  return variants;
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

  group('Property 5: Repository Data Validation', () {
    // ------------------------------------------------------------------
    // 1. Non-List responses
    // ------------------------------------------------------------------
    group('getAllEvents rejects non-List responses', () {
      for (final response in _nonListResponses) {
        test('rejects ${response.runtimeType} response', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => response);

          expect(
            () => repository.getAllEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    group('getFavoriteEvents rejects non-List responses', () {
      for (final response in _nonListResponses) {
        test('rejects ${response.runtimeType} response', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => response);

          expect(
            () => repository.getFavoriteEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    // ------------------------------------------------------------------
    // 2. List items that are not Maps
    // ------------------------------------------------------------------
    group('getAllEvents rejects non-Map list items', () {
      for (final item in _nonMapItems) {
        test('rejects list containing ${item.runtimeType}', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => [item]);

          expect(
            () => repository.getAllEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    group('getFavoriteEvents rejects non-Map list items', () {
      for (final item in _nonMapItems) {
        test('rejects list containing ${item.runtimeType}', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => [item]);

          expect(
            () => repository.getFavoriteEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    // ------------------------------------------------------------------
    // 3. Maps missing required fields
    // ------------------------------------------------------------------
    group('getAllEvents rejects maps missing required fields', () {
      final variants = _generateMissingFieldVariants();
      for (var i = 0; i < variants.length; i++) {
        test('rejects map missing "${_requiredEventFields[i]}"', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => [variants[i]]);

          expect(
            () => repository.getAllEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    group('getFavoriteEvents rejects maps missing required fields', () {
      final variants = _generateMissingFieldVariants();
      for (var i = 0; i < variants.length; i++) {
        test('rejects map missing "${_requiredEventFields[i]}"', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => [variants[i]]);

          expect(
            () => repository.getFavoriteEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    // ------------------------------------------------------------------
    // 4. Maps with wrong types for fields
    // ------------------------------------------------------------------
    group('getAllEvents rejects maps with wrong field types', () {
      final variants = _generateWrongTypeVariants();
      for (var i = 0; i < variants.length; i++) {
        test('rejects wrong-type variant $i', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => [variants[i]]);

          expect(
            () => repository.getAllEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    group('getFavoriteEvents rejects maps with wrong field types', () {
      final variants = _generateWrongTypeVariants();
      for (var i = 0; i < variants.length; i++) {
        test('rejects wrong-type variant $i', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => [variants[i]]);

          expect(
            () => repository.getFavoriteEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    // ------------------------------------------------------------------
    // 5. Invalid nested venue data
    // ------------------------------------------------------------------
    group('getAllEvents rejects invalid nested venue data', () {
      final variants = _generateInvalidVenueVariants();
      for (var i = 0; i < variants.length; i++) {
        test('rejects invalid venue variant $i', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => [variants[i]]);

          expect(
            () => repository.getAllEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    group('getFavoriteEvents rejects invalid nested venue data', () {
      final variants = _generateInvalidVenueVariants();
      for (var i = 0; i < variants.length; i++) {
        test('rejects invalid venue variant $i', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => [variants[i]]);

          expect(
            () => repository.getFavoriteEvents(),
            throwsA(isA<ApiException>()),
          );
        });
      }
    });

    // ------------------------------------------------------------------
    // 6. Randomized invalid data (property-based style)
    // ------------------------------------------------------------------
    test('getAllEvents rejects 100 randomly corrupted event maps', () async {
      final random = Random(42);

      for (var i = 0; i < 100; i++) {
        final json = _validEventJson();
        _corruptRandomField(json, random);

        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => [json]);

        expect(
          () => repository.getAllEvents(),
          throwsA(isA<ApiException>()),
          reason: 'Iteration $i with corrupted json: $json',
        );
      }
    });

    test('getFavoriteEvents rejects 100 randomly corrupted event maps',
        () async {
      final random = Random(42);

      for (var i = 0; i < 100; i++) {
        final json = _validEventJson();
        _corruptRandomField(json, random);

        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => [json]);

        expect(
          () => repository.getFavoriteEvents(),
          throwsA(isA<ApiException>()),
          reason: 'Iteration $i with corrupted json: $json',
        );
      }
    });
  });
}

// ============================================================================
// Helpers
// ============================================================================

/// Corrupts a random required field in the event JSON map by either removing
/// it or replacing it with an incompatible type.
void _corruptRandomField(Map<String, dynamic> json, Random random) {
  final corruptibleFields = [
    'id',
    'title',
    'description',
    'organizer',
    'venue',
    'startTime',
    'endTime',
    'duration',
    'dances',
    'info',
    'parts',
  ];

  final field = corruptibleFields[random.nextInt(corruptibleFields.length)];
  final action = random.nextInt(3); // 0 = remove, 1 = wrong type, 2 = null

  switch (action) {
    case 0:
      json.remove(field);
      break;
    case 1:
      // Replace with an incompatible type
      switch (field) {
        case 'id':
        case 'title':
        case 'description':
        case 'organizer':
          json[field] = random.nextInt(10000); // int instead of String
          break;
        case 'venue':
          json[field] = 'not a map'; // String instead of Map
          break;
        case 'startTime':
        case 'endTime':
          json[field] = random.nextInt(10000); // int instead of date String
          break;
        case 'duration':
          json[field] = 'not a number'; // String instead of int
          break;
        case 'dances':
        case 'info':
        case 'parts':
          json[field] = 'not a list'; // String instead of List
          break;
      }
      break;
    case 2:
      json[field] = null;
      break;
  }
}
