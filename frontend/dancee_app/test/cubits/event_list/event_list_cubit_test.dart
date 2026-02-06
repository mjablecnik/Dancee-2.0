import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/cubits/event_list/event_list_cubit.dart';
import 'package:dancee_app/cubits/event_list/event_list_state.dart';
import 'package:dancee_app/repositories/event_repository.dart';
import 'package:dancee_shared/dancee_shared.dart';

// Mock class for EventRepository
class MockEventRepository extends Mock implements EventRepository {}

void main() {
  group('EventListCubit', () {
    late MockEventRepository mockRepository;
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
      isFavorite: true,
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
      cubit = EventListCubit(mockRepository);
    });

    tearDown(() {
      cubit.close();
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
              .having((state) => state.todayEvents.length, 'todayEvents length', 1)
              .having((state) => state.tomorrowEvents.length, 'tomorrowEvents length', 1)
              .having((state) => state.upcomingEvents.length, 'upcomingEvents length', 1)
              .having((state) => state.allEvents.length, 'allEvents length', 3),
        ],
        verify: (_) {
          verify(() => mockRepository.getAllEvents()).called(1);
        },
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
          
          // Verify today events
          expect(state.todayEvents.length, 1);
          expect(state.todayEvents.first.id, '1');
          expect(state.todayEvents.first.title, 'Today Event');
          
          // Verify tomorrow events
          expect(state.tomorrowEvents.length, 1);
          expect(state.tomorrowEvents.first.id, '2');
          expect(state.tomorrowEvents.first.title, 'Tomorrow Event');
          
          // Verify upcoming events
          expect(state.upcomingEvents.length, 1);
          expect(state.upcomingEvents.first.id, '3');
          expect(state.upcomingEvents.first.title, 'Upcoming Event');
        },
      );

      blocTest<EventListCubit, EventListState>(
        'filters out past events from grouping',
        build: () {
          final pastEvent = Event(
            id: '4',
            title: 'Past Event',
            description: 'Event that already happened',
            organizer: 'Test Organizer',
            venue: testVenue,
            startTime: today.subtract(const Duration(days: 7)),
            endTime: today.subtract(const Duration(days: 7, hours: -3)),
            duration: const Duration(hours: 3),
            dances: ['Salsa'],
            isFavorite: false,
            isPast: true,
          );
          
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => [...allEvents, pastEvent]);
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          
          // Past event should be in allEvents but not in grouped lists
          expect(state.allEvents.length, 4);
          expect(state.todayEvents.length, 1);
          expect(state.tomorrowEvents.length, 1);
          expect(state.upcomingEvents.length, 1);
          
          // Verify past event is not in any group
          expect(state.todayEvents.any((e) => e.isPast), false);
          expect(state.tomorrowEvents.any((e) => e.isPast), false);
          expect(state.upcomingEvents.any((e) => e.isPast), false);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'emits [loading, error] when loadEvents fails',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListError>()
              .having((state) => state.message, 'message', contains('Failed to load events')),
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
        'emits [loading, loaded] when searchEvents succeeds',
        build: () {
          when(() => mockRepository.searchEvents('Salsa'))
              .thenAnswer((_) async => [todayEvent]);
          return cubit;
        },
        act: (cubit) => cubit.searchEvents('Salsa'),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListLoaded>()
              .having((state) => state.allEvents.length, 'allEvents length', 1)
              .having((state) => state.todayEvents.length, 'todayEvents length', 1),
        ],
        verify: (_) {
          verify(() => mockRepository.searchEvents('Salsa')).called(1);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'groups search results correctly by date',
        build: () {
          when(() => mockRepository.searchEvents('Event'))
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) => cubit.searchEvents('Event'),
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.todayEvents.length, 1);
          expect(state.tomorrowEvents.length, 1);
          expect(state.upcomingEvents.length, 1);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'calls loadEvents when query is empty',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) => cubit.searchEvents(''),
        verify: (_) {
          verify(() => mockRepository.getAllEvents()).called(1);
          verifyNever(() => mockRepository.searchEvents(any()));
        },
      );

      blocTest<EventListCubit, EventListState>(
        'emits [loading, error] when searchEvents fails',
        build: () {
          when(() => mockRepository.searchEvents('Salsa'))
              .thenThrow(Exception('Search error'));
          return cubit;
        },
        act: (cubit) => cubit.searchEvents('Salsa'),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListError>()
              .having((state) => state.message, 'message', contains('Search failed')),
        ],
      );

      blocTest<EventListCubit, EventListState>(
        'handles empty search results',
        build: () {
          when(() => mockRepository.searchEvents('NonExistent'))
              .thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.searchEvents('NonExistent'),
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, isEmpty);
          expect(state.todayEvents, isEmpty);
          expect(state.tomorrowEvents, isEmpty);
          expect(state.upcomingEvents, isEmpty);
        },
      );
    });

    group('toggleFavorite', () {
      blocTest<EventListCubit, EventListState>(
        'calls repository toggleFavorite and reloads events',
        build: () {
          when(() => mockRepository.toggleFavorite('1'))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) => cubit.toggleFavorite('1'),
        verify: (_) {
          verify(() => mockRepository.toggleFavorite('1')).called(1);
          verify(() => mockRepository.getAllEvents()).called(1);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'emits loaded state after successful toggle',
        build: () {
          when(() => mockRepository.toggleFavorite('1'))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) => cubit.toggleFavorite('1'),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListLoaded>(),
        ],
      );

      blocTest<EventListCubit, EventListState>(
        'emits error when toggleFavorite fails',
        build: () {
          when(() => mockRepository.toggleFavorite('1'))
              .thenThrow(Exception('Toggle error'));
          return cubit;
        },
        act: (cubit) => cubit.toggleFavorite('1'),
        expect: () => [
          isA<EventListError>()
              .having((state) => state.message, 'message', contains('Failed to toggle favorite')),
        ],
      );

      blocTest<EventListCubit, EventListState>(
        'handles toggle for non-existent event gracefully',
        build: () {
          when(() => mockRepository.toggleFavorite('999'))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => allEvents);
          return cubit;
        },
        act: (cubit) => cubit.toggleFavorite('999'),
        verify: (_) {
          verify(() => mockRepository.toggleFavorite('999')).called(1);
          verify(() => mockRepository.getAllEvents()).called(1);
        },
      );
    });

    group('state transitions', () {
      blocTest<EventListCubit, EventListState>(
        'maintains state after error until next action',
        build: () {
          when(() => mockRepository.getAllEvents())
              .thenThrow(Exception('Error'));
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        verify: (cubit) {
          expect(cubit.state, isA<EventListError>());
        },
      );

      blocTest<EventListCubit, EventListState>(
        'can recover from error state',
        build: () {
          var callCount = 0;
          when(() => mockRepository.getAllEvents()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('Error');
            }
            return allEvents;
          });
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.loadEvents();
        },
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListError>(),
          isA<EventListLoading>(),
          isA<EventListLoaded>(),
        ],
      );
    });

    group('edge cases', () {
      blocTest<EventListCubit, EventListState>(
        'handles events at midnight correctly',
        build: () {
          final midnightEvent = Event(
            id: '5',
            title: 'Midnight Event',
            description: 'Event at midnight',
            organizer: 'Test Organizer',
            venue: testVenue,
            startTime: today,
            endTime: today.add(const Duration(hours: 3)),
            duration: const Duration(hours: 3),
            dances: ['Salsa'],
            isFavorite: false,
            isPast: false,
          );
          
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => [midnightEvent]);
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.todayEvents.length, 1);
          expect(state.todayEvents.first.title, 'Midnight Event');
        },
      );

      blocTest<EventListCubit, EventListState>(
        'handles multiple events on same day',
        build: () {
          final event1 = todayEvent;
          final event2 = Event(
            id: '6',
            title: 'Another Today Event',
            description: 'Another event today',
            organizer: 'Test Organizer',
            venue: testVenue,
            startTime: today.add(const Duration(hours: 18)),
            endTime: today.add(const Duration(hours: 21)),
            duration: const Duration(hours: 3),
            dances: ['Bachata'],
            isFavorite: false,
            isPast: false,
          );
          
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => [event1, event2]);
          return cubit;
        },
        act: (cubit) => cubit.loadEvents(),
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.todayEvents.length, 2);
        },
      );
    });
  });
}
