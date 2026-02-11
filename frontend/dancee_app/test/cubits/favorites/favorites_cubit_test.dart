import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/cubits/favorites/favorites_cubit.dart';
import 'package:dancee_app/cubits/favorites/favorites_state.dart';
import 'package:dancee_app/cubits/event_list/event_list_cubit.dart';
import 'package:dancee_app/repositories/event_repository.dart';
import 'package:dancee_app/core/exceptions/api_exception.dart';
import 'package:dancee_app/di/service_locator.dart';
import 'package:dancee_app/models/event.dart';
import 'package:dancee_app/models/venue.dart';
import 'package:dancee_app/models/address.dart';

// Mock class for EventRepository
class MockEventRepository extends Mock implements EventRepository {}

// Mock class for EventListCubit
class MockEventListCubit extends Mock implements EventListCubit {}

void main() {
  group('FavoritesCubit', () {
    late MockEventRepository mockRepository;
    late MockEventListCubit mockEventListCubit;
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

    setUp(() {
      mockRepository = MockEventRepository();
      mockEventListCubit = MockEventListCubit();
      cubit = FavoritesCubit(mockRepository);
      
      // Register mock EventListCubit in GetIt
      getIt.registerSingleton<EventListCubit>(mockEventListCubit);
      
      // Mock loadEvents to do nothing
      when(() => mockEventListCubit.loadEvents()).thenAnswer((_) async => {});
    });

    tearDown(() {
      cubit.close();
      getIt.reset();
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
              .having((state) => state.upcomingEvents.length, 'upcoming length', 2)
              .having((state) => state.pastEvents.length, 'past length', 2),
        ],
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
          expect(state.upcomingEvents.every((e) => !e.isPast), isTrue);
          expect(state.pastEvents.every((e) => e.isPast), isTrue);
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
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits [loading, error] when loadFavorites fails',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenThrow(ApiException(message: 'API error'));
          return cubit;
        },
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesError>(),
        ],
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
          final allEvents = [...state.upcomingEvents, ...state.pastEvents];
          expect(allEvents.every((e) => e.isFavorite), isTrue);
        },
      );
    });

    group('toggleFavorite', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'updates favorite status locally',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          when(() => mockRepository.toggleFavorite('1', true))
              .thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('1');
        },
        skip: 2,
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          final toggledEvent = state.upcomingEvents.firstWhere((e) => e.id == '1');
          expect(toggledEvent.isFavorite, isFalse);
          verify(() => mockRepository.toggleFavorite('1', true)).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits error when event not found',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('999');
        },
        skip: 2,
        expect: () => [
          isA<FavoritesError>(),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'does nothing when state is not loaded',
        build: () => cubit,
        act: (cubit) => cubit.toggleFavorite('1'),
        expect: () => [],
      );
    });

    group('filterUnfavoritedEvents', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'removes unfavorited events from state',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          when(() => mockRepository.toggleFavorite('1', true))
              .thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('1');
          cubit.filterUnfavoritedEvents();
        },
        skip: 3,
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents.length, 1);
          expect(state.upcomingEvents.every((e) => e.isFavorite), isTrue);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits empty when all events are unfavorited',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => [upcomingEvent1]);
          when(() => mockRepository.toggleFavorite('1', true))
              .thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('1');
          cubit.filterUnfavoritedEvents();
        },
        skip: 3,
        expect: () => [
          isA<FavoritesEmpty>(),
        ],
      );
    });

    group('removePastEvent', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'removes past event immediately',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          when(() => mockRepository.toggleFavorite('3', true))
              .thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.removePastEvent('3');
        },
        skip: 2,
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.pastEvents.length, 1);
          expect(state.pastEvents.every((e) => e.id != '3'), isTrue);
          verify(() => mockRepository.toggleFavorite('3', true)).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits empty when last event is removed',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => [pastEvent1]);
          when(() => mockRepository.toggleFavorite('3', true))
              .thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.removePastEvent('3');
        },
        skip: 2,
        expect: () => [
          isA<FavoritesEmpty>(),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits error when event not found',
        build: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => allFavorites);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.removePastEvent('999');
        },
        skip: 2,
        expect: () => [
          isA<FavoritesError>(),
        ],
      );
    });
  });
}
