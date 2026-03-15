import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';

/// Feature: flutter-architecture-refactor
/// Property 4: Repository Error Handling
/// **Validates: Requirements 7.5**
///
/// For any error condition encountered by a repository (network error, parse
/// error, validation error), the repository should throw a custom ApiException
/// with a descriptive message rather than propagating raw exceptions.

// ============================================================================
// Mock
// ============================================================================

class MockApiClient extends Mock implements ApiClient {}

// ============================================================================
// Exception generators — diverse error types the API layer could produce
// ============================================================================

final List<Object> _errorVariants = [
  Exception('generic network failure'),
  FormatException('unexpected character at position 0'),
  TypeError(),
  StateError('bad state'),
  RangeError('index out of range'),
  UnsupportedError('unsupported operation'),
  ArgumentError('invalid argument'),
  ConcurrentModificationError('modified during iteration'),
];

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

  group('Property 4: Repository Error Handling', () {
    group('getAllEvents wraps all exceptions in ApiException', () {
      for (var i = 0; i < _errorVariants.length; i++) {
        final error = _errorVariants[i];
        test('wraps ${error.runtimeType} in ApiException', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenThrow(error);

          expect(
            () => repository.getAllEvents(),
            throwsA(isA<ApiException>().having(
              (e) => e.message.isNotEmpty,
              'has non-empty message',
              isTrue,
            )),
          );
        });
      }
    });

    group('getFavoriteEvents wraps all exceptions in ApiException', () {
      for (var i = 0; i < _errorVariants.length; i++) {
        final error = _errorVariants[i];
        test('wraps ${error.runtimeType} in ApiException', () async {
          when(() => mockApiClient.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenThrow(error);

          expect(
            () => repository.getFavoriteEvents(),
            throwsA(isA<ApiException>().having(
              (e) => e.message.isNotEmpty,
              'has non-empty message',
              isTrue,
            )),
          );
        });
      }
    });

    group('addFavorite wraps all exceptions in ApiException', () {
      for (var i = 0; i < _errorVariants.length; i++) {
        final error = _errorVariants[i];
        test('wraps ${error.runtimeType} in ApiException', () async {
          when(() => mockApiClient.post(
                any(),
                data: any(named: 'data'),
              )).thenThrow(error);

          expect(
            () => repository.addFavorite('event-123'),
            throwsA(isA<ApiException>().having(
              (e) => e.message.isNotEmpty,
              'has non-empty message',
              isTrue,
            )),
          );
        });
      }
    });

    group('removeFavorite wraps all exceptions in ApiException', () {
      for (var i = 0; i < _errorVariants.length; i++) {
        final error = _errorVariants[i];
        test('wraps ${error.runtimeType} in ApiException', () async {
          when(() => mockApiClient.delete(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenThrow(error);

          expect(
            () => repository.removeFavorite('event-123'),
            throwsA(isA<ApiException>().having(
              (e) => e.message.isNotEmpty,
              'has non-empty message',
              isTrue,
            )),
          );
        });
      }
    });

    test('ApiException is rethrown as-is (not double-wrapped)', () async {
      final original = ApiException(message: 'original error', statusCode: 500);

      when(() => mockApiClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(original);

      expect(
        () => repository.getAllEvents(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'original error')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });
}
