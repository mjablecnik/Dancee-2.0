import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/cubits/favorites/favorites_cubit.dart';
import 'package:dancee_app/cubits/favorites/favorites_state.dart';
import 'package:dancee_app/repositories/event_repository.dart';
import 'package:dancee_app/core/exceptions/api_exception.dart';
import 'package:dancee_shared/dancee_shared.dart';

// Mock class for EventRepository
class MockEventRepository extends Mock implements EventRepository {}

void main() {
  group('FavoritesCubit', () {
    late MockEventRepository mockRepository;
    late FavoritesCubit cubit;

    // Test data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

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

    final upcomingEvent1 = Event(
      id: '1',
      title: 'Upcoming Favorite Event 1',
      description: 'First upcoming favorite event',
      organizer: 'Test Organizer',
      venue: testVenue,
      startTime: today.add(const Duration(hours: 20)),
      endTime: today.add(const Duration(hours: 23)),
      duration: const Duration(hours: 3),
      dances: ['Salsa'],
      isFavorite: true,
      isPast: false,
    );

    final upcomingEvent2 = Event(
      id: '2',
      title: 'Upcoming Favorite Event 2',
      description: 'Second upcoming favorite event',
      organizer: 'Test Organizer',
      venue: testVenue,
      startTime: tomorrow.add(const Duration(hours: 20)),
      endTime: tomorrow.add(const Duration(hours: 23)),
      duration: const Duration(hours: 3),
      dances: ['Bachata'],
      isFavorite: true,
      isPast: false,
    );

    final pastEvent1 = Event(
      id: '3',
      title: 'Past Favorite Event 1',
      description: 'First past favorite event',
      organizer: 'Test Organizer',
      venue: testVenue,
      startTime: yesterday.add(const Duration(hours: 20)),
      endTime: yesterday.add(const Duration(hours: 23)),
      duration: const Duration(hours: 3),
      dances: ['Kizomba'],
      isFavorite: true,
      isPast: true,
    );

    final pastEvent2 = Event(
      id: '4',
      title: 'Past Favorite Event 2',
      description: 'Second past favorite event',
      organizer: 'Test Organizer',
      venue: testVenue,
      startTime: yesterday.subtract(const Duration(days: 7)),
      endTime: yesterday.subtract(const Duration(days: 7, hours: -3)),
      duration: const Duration(hours: 3),
      dances: ['Zouk'],
      isFavorite: true,
      isPast: true,
    );

    final allFavorites = [upcomingEvent1, upcomingEvent2, pastEvent1, pastEvent2];
    final upcomingFavorites = [upcomingEvent1, upcomingEvent2];
    final pastFavorites = [pastEvent1, pastEvent2];

    setUp(() {
      mockRepository = MockEventRepository();
      cubit = FavoritesCubit(mockRepository);
      
      // Register fallback values for mocktail
      registerFallbackValue('');
      registerFallbackValue(false);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is FavoritesInitial', () {
      expect(cubit.state, isA<FavoritesInitial>());
    });

    group('loadFavorites', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'emits [loading, loaded] when loadFavorites succeeds with favorites',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>()
              .having((state) => state.upcomingEvents.length, 'upcomingEvents length', 2)
              .having((state) => state.pastEvents.length, 'pastEvents length', 2),
        ],
        verify: (_) {
          verify(() => mockRepository.getFavoriteEvents()).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'separates upcoming and past events correctly',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          
          // Verify upcoming events
          expect(state.upcomingEvents.length, 2);
          expect(state.upcomingEvents.every((e) => !e.isPast), true);
          expect(state.upcomingEvents.any((e) => e.id == '1'), true);
          expect(state.upcomingEvents.any((e) => e.id == '2'), true);
          
          // Verify past events
          expect(state.pastEvents.length, 2);
          expect(state.pastEvents.every((e) => e.isPast), true);
          expect(state.pastEvents.any((e) => e.id == '3'), true);
          expect(state.pastEvents.any((e) => e.id == '4'), true);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits [loading, empty] when no favorites exist',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesEmpty>(),
        ],
        verify: (_) {
          verify(() => mockRepository.getFavoriteEvents()).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits [loading, error] when loadFavorites fails',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenThrow(ApiException(message: 'Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesError>()
              .having((state) => state.message, 'message', contains('Failed to load favorites')),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'handles only upcoming favorites',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => upcomingFavorites);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents.length, 2);
          expect(state.pastEvents.length, 0);
          expect(state.pastEvents, isEmpty);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'handles only past favorites',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => pastFavorites);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents.length, 0);
          expect(state.upcomingEvents, isEmpty);
          expect(state.pastEvents.length, 2);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'verifies all favorite events have isFavorite true',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          
          // All upcoming events should be favorites
          expect(state.upcomingEvents.every((e) => e.isFavorite), true);
          
          // All past events should be favorites
          expect(state.pastEvents.every((e) => e.isFavorite), true);
        },
      );
    });

    group('toggleFavorite', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'calls repository toggleFavorite and reloads favorites',
        build: () {
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          return cubit;
        },
        seed: () => FavoritesLoaded(
          upcomingEvents: upcomingFavorites,
          pastEvents: pastFavorites,
        ),
        act: (cubit) => cubit.toggleFavorite('1'),
        verify: (_) {
          verify(() => mockRepository.toggleFavorite('1', true)).called(1);
          verify(() => mockRepository.getFavoriteEvents()).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits loaded state after successful toggle',
        build: () {
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          return cubit;
        },
        seed: () => FavoritesLoaded(
          upcomingEvents: upcomingFavorites,
          pastEvents: pastFavorites,
        ),
        act: (cubit) => cubit.toggleFavorite('1'),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits empty state when last favorite is removed',
        build: () {
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => []);
          return cubit;
        },
        seed: () => FavoritesLoaded(
          upcomingEvents: [upcomingEvent1],
          pastEvents: [],
        ),
        act: (cubit) => cubit.toggleFavorite('1'),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesEmpty>(),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits error when toggleFavorite fails',
        build: () {
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenThrow(ApiException(message: 'Toggle error'));
          return cubit;
        },
        seed: () => FavoritesLoaded(
          upcomingEvents: upcomingFavorites,
          pastEvents: pastFavorites,
        ),
        act: (cubit) => cubit.toggleFavorite('1'),
        expect: () => [
          isA<FavoritesError>()
              .having((state) => state.message, 'message', contains('Failed to update favorite')),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'handles toggle for non-existent event gracefully',
        build: () {
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          return cubit;
        },
        seed: () => FavoritesLoaded(
          upcomingEvents: upcomingFavorites,
          pastEvents: pastFavorites,
        ),
        act: (cubit) => cubit.toggleFavorite('999'),
        expect: () => [
          isA<FavoritesError>(),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'updates state correctly after toggling upcoming event',
        build: () {
          // First call returns all favorites, second call returns without the toggled event
          var callCount = 0;
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getFavoriteEvents()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return allFavorites;
            }
            return [upcomingEvent2, pastEvent1, pastEvent2];
          });
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('1');
        },
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents.length, 1);
          expect(state.upcomingEvents.any((e) => e.id == '1'), false);
          expect(state.upcomingEvents.any((e) => e.id == '2'), true);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'updates state correctly after toggling past event',
        build: () {
          // First call returns all favorites, second call returns without the toggled event
          var callCount = 0;
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getFavoriteEvents()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return allFavorites;
            }
            return [upcomingEvent1, upcomingEvent2, pastEvent2];
          });
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('3');
        },
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.pastEvents.length, 1);
          expect(state.pastEvents.any((e) => e.id == '3'), false);
          expect(state.pastEvents.any((e) => e.id == '4'), true);
        },
      );
    });

    group('state transitions', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'maintains state after error until next action',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenThrow(ApiException(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          expect(cubit.state, isA<FavoritesError>());
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'can recover from error state',
        build: () {
          var callCount = 0;
          when(() => mockRepository.getFavoriteEvents()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              throw ApiException(message: 'Error');
            }
            return allFavorites;
          });
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.loadFavorites();
        },
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesError>(),
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'transitions from empty to loaded when favorite is added',
        build: () {
          var callCount = 0;
          when(() => mockRepository.getFavoriteEvents()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return [];
            }
            return [upcomingEvent1];
          });
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.loadFavorites();
        },
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesEmpty>(),
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'transitions from loaded to empty when all favorites are removed',
        build: () {
          var callCount = 0;
          when(() => mockRepository.getFavoriteEvents()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return [upcomingEvent1];
            }
            return [];
          });
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.loadFavorites();
        },
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
          isA<FavoritesLoading>(),
          isA<FavoritesEmpty>(),
        ],
      );
    });

    group('edge cases', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'handles single upcoming favorite',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => [upcomingEvent1]);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents.length, 1);
          expect(state.pastEvents.length, 0);
          expect(state.upcomingEvents.first.id, '1');
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'handles single past favorite',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => [pastEvent1]);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents.length, 0);
          expect(state.pastEvents.length, 1);
          expect(state.pastEvents.first.id, '3');
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'handles large number of favorites',
        build: () {
          final manyFavorites = List.generate(
            100,
            (index) => Event(
              id: 'event_$index',
              title: 'Event $index',
              description: 'Description $index',
              organizer: 'Organizer',
              venue: testVenue,
              startTime: index < 50
                  ? today.add(Duration(days: index))
                  : yesterday.subtract(Duration(days: index - 50)),
              endTime: index < 50
                  ? today.add(Duration(days: index, hours: 3))
                  : yesterday.subtract(Duration(days: index - 50, hours: -3)),
              duration: const Duration(hours: 3),
              dances: ['Salsa'],
              isFavorite: true,
              isPast: index >= 50,
            ),
          );
          
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => manyFavorites);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents.length, 50);
          expect(state.pastEvents.length, 50);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'correctly separates events with same date but different isPast flag',
        build: () {
          final sameTimeUpcoming = Event(
            id: '5',
            title: 'Same Time Upcoming',
            description: 'Event at same time but upcoming',
            organizer: 'Test Organizer',
            venue: testVenue,
            startTime: today.add(const Duration(hours: 20)),
            endTime: today.add(const Duration(hours: 23)),
            duration: const Duration(hours: 3),
            dances: ['Salsa'],
            isFavorite: true,
            isPast: false,
          );
          
          final sameTimePast = Event(
            id: '6',
            title: 'Same Time Past',
            description: 'Event at same time but past',
            organizer: 'Test Organizer',
            venue: testVenue,
            startTime: today.add(const Duration(hours: 20)),
            endTime: today.add(const Duration(hours: 23)),
            duration: const Duration(hours: 3),
            dances: ['Salsa'],
            isFavorite: true,
            isPast: true,
          );
          
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => [sameTimeUpcoming, sameTimePast]);
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents.length, 1);
          expect(state.pastEvents.length, 1);
          expect(state.upcomingEvents.first.id, '5');
          expect(state.pastEvents.first.id, '6');
        },
      );
    });
  });
}
