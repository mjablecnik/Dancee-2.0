import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/cubits/event_list/event_list_cubit.dart';
import 'package:dancee_app/cubits/event_list/event_list_state.dart';
import 'package:dancee_app/cubits/favorites/favorites_cubit.dart';
import 'package:dancee_app/repositories/event_repository.dart';
import 'package:dancee_app/core/exceptions/api_exception.dart';
import 'package:dancee_app/di/service_locator.dart';
import 'package:dancee_shared/dancee_shared.dart';

// Mock class for EventRepository
class MockEventRepository extends Mock implements EventRepository {}

// Mock class for FavoritesCubit
class MockFavoritesCubit extends Mock implements FavoritesCubit {}

void main() {
  group('EventListCubit', () {
    late MockEventRepository mockRepository;
    late MockFavoritesCubit mockFavoritesCubit;
    late EventListCubit cubit;

    // Test data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

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

    final todayEvent = Event(
      id: '1',
      title: 'Today Event',
      description: 'Event happening today',
      organizer: 'Test Organizer',
      venue: testVenue,
      startTime: today.add(const Duration(hours: 20)),
      endTime: today.add(const Duration(hours: 23)),
      duration: const Duration(hours: 3),
      dances: ['Salsa'],
      isFavorite: false,
      isPast: false,
    );

    final tomorrowEvent = Event(
      id: '2',
      title: 'Tomorrow Event',
      description: 'Event happening tomorrow',
      organizer: 'Test Organizer',
      venue: testVenue,
      startTime: tomorrow.add(const Duration(hours: 20)),
      endTime: tomorrow.add(const Duration(hours: 23)),
      duration: const Duration(hours: 3),
      dances: ['Bachata'],
      isFavorite: false,
      isPast: false,
    );

    final upcomingEvent = Event(
      id: '3',
      title: 'Upcoming Event',
      description: 'Event happening next week',
      organizer: 'Test Organizer',
      venue: testVenue,
      startTime: nextWeek.add(const Duration(hours: 20)),
      endTime: nextWeek.add(const Duration(hours: 23)),
      duration: const Duration(hours: 3),
      dances: ['Kizomba'],
      isFavorite: false,
      isPast: false,
    );

    final allEvents = [todayEvent, tomorrowEvent, upcomingEvent];

    setUp(() {
      mockRepository = MockEventRepository();
      mockFavoritesCubit = MockFavoritesCubit();
      cubit = EventListCubit(mockRepository);
      
      // Register mock FavoritesCubit in GetIt
      getIt.registerSingleton<FavoritesCubit>(mockFavoritesCubit);
      
      // Mock loadFavorites to do nothing
      when(() => mockFavoritesCubit.loadFavorites()).thenAnswer((_) async => {});
    });

    tearDown(() {
      cubit.close();
      getIt.reset();
    });

    test('initial state is EventListInitial', () {
      expect(cubit.state, isA<EventListInitial>());
    });

    group('loadEvents', () {
      blocTest<EventListCubit, EventListState>(
        'emits [loading, loaded] when loadEvents succeeds',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListLoaded>()
              .having((state) => state.allEvents.length, 'allEvents length', 3)
              .having((state) => state.todayEvents.length, 'todayEvents length', 1)
              .having((state) => state.tomorrowEvents.length, 'tomorrowEvents length', 1)
              .having((state) => state.upcomingEvents.length, 'upcomingEvents length', 1),
        ],
      );

      blocTest<EventListCubit, EventListState>(
        'groups events correctly by date',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.todayEvents.first.id, todayEvent.id);
          expect(state.tomorrowEvents.first.id, tomorrowEvent.id);
          expect(state.upcomingEvents.first.id, upcomingEvent.id);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'emits [loading, error] when loadEvents fails with ApiException',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenThrow(ApiException(message: 'API error'));
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListError>(),
        ],
      );

      blocTest<EventListCubit, EventListState>(
        'emits [loading, error] when loadEvents fails with generic exception',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenThrow(Exception('Generic error'));
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListError>(),
        ],
      );

      blocTest<EventListCubit, EventListState>(
        'handles empty event list',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, isEmpty);
          expect(state.todayEvents, isEmpty);
          expect(state.tomorrowEvents, isEmpty);
          expect(state.upcomingEvents, isEmpty);
        },
      );
    });

    group('searchEvents', () {
      blocTest<EventListCubit, EventListState>(
        'filters events locally by title',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('Today');
        },
        skip: 2, // Skip loading and initial loaded states
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents.length, 1);
          expect(state.allEvents.first.title, contains('Today'));
        },
      );

      blocTest<EventListCubit, EventListState>(
        'filters events by venue name',
        build: () {
          final venueEvent = todayEvent.copyWith(
            venue: testVenue.copyWith(name: 'Lucerna Music Bar'),
          );
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => [venueEvent]);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('Lucerna');
        },
        skip: 2,
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents.length, 1);
          expect(state.allEvents.first.venue.name, contains('Lucerna'));
        },
      );

      blocTest<EventListCubit, EventListState>(
        'is case-insensitive',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('TODAY');
        },
        skip: 2,
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents.length, 1);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'reloads all events when query is empty',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('Today');
          await cubit.searchEvents('');
        },
        verify: (_) {
          verify(() => mockRepository.getAllEvents()).called(2);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'returns empty results for non-matching query',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('NonExistent');
        },
        skip: 2,
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, isEmpty);
        },
      );
    });

    group('toggleFavorite', () {
      blocTest<EventListCubit, EventListState>(
        'toggles favorite status and updates state',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          when(() => mockRepository.toggleFavorite('1', false))
              .thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.toggleFavorite('1');
        },
        skip: 2,
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          final toggledEvent = state.allEvents.firstWhere((e) => e.id == '1');
          expect(toggledEvent.isFavorite, isTrue);
          verify(() => mockRepository.toggleFavorite('1', false)).called(1);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'updates event in all date groups',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          when(() => mockRepository.toggleFavorite('1', false))
              .thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.toggleFavorite('1');
        },
        skip: 2,
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          final toggledInToday = state.todayEvents.firstWhere((e) => e.id == '1');
          expect(toggledInToday.isFavorite, isTrue);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'emits error when toggle fails',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          when(() => mockRepository.toggleFavorite('1', false))
              .thenThrow(ApiException(message: 'Toggle error'));
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.toggleFavorite('1');
        },
        skip: 2,
        expect: () => [
          isA<EventListError>(),
        ],
      );

      blocTest<EventListCubit, EventListState>(
        'does nothing when state is not loaded',
        build: () => cubit,
        act: (cubit) => cubit.toggleFavorite('1'),
        expect: () => [],
      );
    });
  });
}
