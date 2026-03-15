import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/logic/favorites.dart';
import 'package:dancee_app/i18n/translations.g.dart';

/// Feature: flutter-architecture-refactor
/// Property 7: Cubit Exception Handling
/// **Validates: Requirements 11.4, 11.5**
///
/// For any exception thrown by a repository, the cubit should catch it and
/// emit an error state with a translated, user-friendly message (not a raw
/// exception string).

// ============================================================================
// Mock
// ============================================================================

class MockEventRepository extends Mock implements EventRepository {}

// ============================================================================
// Exception variants — diverse error types the repository could throw
// ============================================================================

final List<Object> _exceptionVariants = [
  ApiException(message: 'API error'),
  ApiException(message: 'Server error', statusCode: 500),
  ApiException(message: 'Not found', statusCode: 404),
  ApiException(message: 'Unauthorized', statusCode: 401),
  Exception('generic network failure'),
  FormatException('unexpected character at position 0'),
  TypeError(),
  StateError('bad state'),
  RangeError('index out of range'),
  UnsupportedError('unsupported operation'),
  ArgumentError('invalid argument'),
];

// ============================================================================
// Known translated error messages (from slang translations)
// ============================================================================

/// Returns the set of known translated error messages for the current locale.
/// These are the only valid error messages a cubit should emit.
Set<String> _knownTranslatedErrors() => {
      t.errors.networkError,
      t.errors.timeoutError,
      t.errors.serverError,
      t.errors.parsingError,
      t.errors.genericError,
      t.errors.loadEventsError,
      t.errors.loadFavoritesError,
      t.errors.toggleFavoriteError,
    };

// ============================================================================
// Tests
// ============================================================================

void main() {
  late MockEventRepository mockRepository;

  setUp(() {
    // Ensure English locale for predictable translated messages
    LocaleSettings.setLocale(AppLocale.en);
  });

  group('Property 7: Cubit Exception Handling', () {
    // ------------------------------------------------------------------
    // EventListCubit.loadEvents
    // ------------------------------------------------------------------
    group('EventListCubit.loadEvents catches all exceptions', () {
      for (final exception in _exceptionVariants) {
        final label = exception.runtimeType.toString();

        blocTest<EventListCubit, EventListState>(
          'catches $label and emits error with translated message',
          setUp: () {
            mockRepository = MockEventRepository();
            when(() => mockRepository.getAllEvents()).thenThrow(exception);
          },
          build: () => EventListCubit(mockRepository),
          act: (cubit) => cubit.loadEvents(),
          expect: () => [
            isA<EventListLoading>(),
            isA<EventListError>(),
          ],
          verify: (cubit) {
            final errorState = cubit.state as EventListError;

            // Error message must be non-empty
            expect(errorState.message, isNotEmpty,
                reason: '$label: error message should not be empty');

            // Error message must be a known translated string
            expect(
              _knownTranslatedErrors().contains(errorState.message),
              isTrue,
              reason:
                  '$label: error message "${errorState.message}" is not a '
                  'known translated error string',
            );

            // Error message must NOT contain raw exception class names
            expect(errorState.message, isNot(contains('Exception')),
                reason: '$label: error message should not contain "Exception"');
            expect(errorState.message, isNot(contains('Error:')),
                reason: '$label: error message should not contain "Error:"');
          },
        );
      }
    });

    // ------------------------------------------------------------------
    // FavoritesCubit.loadFavorites
    // ------------------------------------------------------------------
    group('FavoritesCubit.loadFavorites catches all exceptions', () {
      for (final exception in _exceptionVariants) {
        final label = exception.runtimeType.toString();

        blocTest<FavoritesCubit, FavoritesState>(
          'catches $label and emits error with translated message',
          setUp: () {
            mockRepository = MockEventRepository();
            when(() => mockRepository.getFavoriteEvents())
                .thenThrow(exception);
          },
          build: () => FavoritesCubit(mockRepository),
          act: (cubit) => cubit.loadFavorites(),
          expect: () => [
            isA<FavoritesLoading>(),
            isA<FavoritesError>(),
          ],
          verify: (cubit) {
            final errorState = cubit.state as FavoritesError;

            // Error message must be non-empty
            expect(errorState.message, isNotEmpty,
                reason: '$label: error message should not be empty');

            // Error message must be a known translated string
            expect(
              _knownTranslatedErrors().contains(errorState.message),
              isTrue,
              reason:
                  '$label: error message "${errorState.message}" is not a '
                  'known translated error string',
            );

            // Error message must NOT contain raw exception class names
            expect(errorState.message, isNot(contains('Exception')),
                reason: '$label: error message should not contain "Exception"');
            expect(errorState.message, isNot(contains('Error:')),
                reason: '$label: error message should not contain "Error:"');
          },
        );
      }
    });

    // ------------------------------------------------------------------
    // Cross-cubit: error messages are always user-friendly
    // ------------------------------------------------------------------
    test(
        'all cubit error messages come from translations, not raw exceptions',
        () async {
      final knownErrors = _knownTranslatedErrors();

      for (final exception in _exceptionVariants) {
        // EventListCubit
        final eventMock = MockEventRepository();
        when(() => eventMock.getAllEvents()).thenThrow(exception);
        final eventCubit = EventListCubit(eventMock);
        await eventCubit.loadEvents();

        final eventState = eventCubit.state;
        expect(eventState, isA<EventListError>());
        final eventError = (eventState as EventListError).message;
        expect(knownErrors, contains(eventError),
            reason:
                '${exception.runtimeType}: EventListCubit emitted "$eventError" '
                'which is not a known translation');

        await eventCubit.close();

        // FavoritesCubit
        final favMock = MockEventRepository();
        when(() => favMock.getFavoriteEvents()).thenThrow(exception);
        final favCubit = FavoritesCubit(favMock);
        await favCubit.loadFavorites();

        final favState = favCubit.state;
        expect(favState, isA<FavoritesError>());
        final favError = (favState as FavoritesError).message;
        expect(knownErrors, contains(favError),
            reason:
                '${exception.runtimeType}: FavoritesCubit emitted "$favError" '
                'which is not a known translation');

        await favCubit.close();
      }
    });
  });
}
