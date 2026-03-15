import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/i18n/translations.g.dart';

class MockEventRepository extends Mock implements EventRepository {}

/// Creates a test Event with the given parameters.
/// Defaults produce a valid, non-past event starting today.
Event _createEvent({
  String id = '1',
  String title = 'Test Event',
  String description = 'A test event',
  String venueName = 'Test Venue',
  required DateTime startTime,
  bool isFavorite = false,
  bool isPast = false,
}) {
  return Event(
    id: id,
    title: title,
    description: description,
    organizer: 'Test Organizer',
    venue: Venue(
      name: venueName,
      address: const Address(
        street: 'Test Street 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      ),
      description: 'A test venue',
      latitude: 50.08,
      longitude: 14.42,
    ),
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 4)),
    duration: const Duration(hours: 4),
    dances: const ['salsa', 'bachata'],
    info: const [],
    parts: const [],
    isFavorite: isFavorite,
    isPast: isPast,
  );
}

void main() {
  late MockEventRepository mockRepository;

  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  group('EventListCubit', () {
    setUp(() {
      mockRepository = MockEventRepository();
    });

    // =========================================================================
    // State transitions
    // =========================================================================
    group('state transitions', () {
      test('initial state is EventListInitial', () {
        final cubit = EventListCubit(mockRepository);
        expect(cubit.state, isA<EventListInitial>());
        cubit.close();
      });

      blocTest<EventListCubit, EventListState>(
        'emits [loading, loaded] when loadEvents succeeds',
        setUp: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => <Event>[]);
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListLoaded>(),
        ],
      );

      blocTest<EventListCubit, EventListState>(
        'emits [loading, error] when loadEvents throws ApiException',
        setUp: () {
          when(() => mockRepository.getAllEvents())
              .thenThrow(ApiException(message: 'Server error'));
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListError>(),
        ],
        verify: (cubit) {
          final state = cubit.state as EventListError;
          expect(state.message, t.errors.loadEventsError);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'emits [loading, error] with genericError when loadEvents throws non-ApiException',
        setUp: () {
          when(() => mockRepository.getAllEvents())
              .thenThrow(Exception('unexpected'));
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListError>(),
        ],
        verify: (cubit) {
          final state = cubit.state as EventListError;
          expect(state.message, t.errors.genericError);
        },
      );
    });

    // =========================================================================
    // Event grouping by date
    // =========================================================================
    group('event grouping by date', () {
      blocTest<EventListCubit, EventListState>(
        'groups events into today, tomorrow, and upcoming',
        setUp: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day, 20, 0);
          final tomorrow = today.add(const Duration(days: 1));
          final nextWeek = today.add(const Duration(days: 5));

          final events = [
            _createEvent(id: 'today1', title: 'Today Event', startTime: today),
            _createEvent(id: 'tmrw1', title: 'Tomorrow Event', startTime: tomorrow),
            _createEvent(id: 'up1', title: 'Upcoming Event', startTime: nextWeek),
          ];

          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => events);
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          isA<EventListLoading>(),
          isA<EventListLoaded>(),
        ],
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, hasLength(3));
          expect(state.todayEvents, hasLength(1));
          expect(state.todayEvents.first.id, 'today1');
          expect(state.tomorrowEvents, hasLength(1));
          expect(state.tomorrowEvents.first.id, 'tmrw1');
          expect(state.upcomingEvents, hasLength(1));
          expect(state.upcomingEvents.first.id, 'up1');
        },
      );

      blocTest<EventListCubit, EventListState>(
        'excludes past events from grouped lists',
        setUp: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day, 20, 0);

          final events = [
            _createEvent(id: 'active', title: 'Active', startTime: today),
            _createEvent(id: 'past', title: 'Past', startTime: today, isPast: true),
          ];

          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => events);
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) => cubit.loadEvents(),
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, hasLength(2));
          expect(state.todayEvents, hasLength(1));
          expect(state.todayEvents.first.id, 'active');
        },
      );
    });

    // =========================================================================
    // Search filtering
    // =========================================================================
    group('searchEvents', () {
      blocTest<EventListCubit, EventListState>(
        'filters events by title and re-groups by date',
        setUp: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day, 20, 0);

          final events = [
            _createEvent(id: '1', title: 'Salsa Night', startTime: today),
            _createEvent(id: '2', title: 'Bachata Party', startTime: today),
            _createEvent(id: '3', title: 'Kizomba Jam', startTime: today),
          ];

          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => events);
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('salsa');
        },
        skip: 2, // skip loading + first loaded
        expect: () => [
          isA<EventListLoaded>(),
        ],
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, hasLength(1));
          expect(state.allEvents.first.title, 'Salsa Night');
        },
      );

      blocTest<EventListCubit, EventListState>(
        'filters events by venue name (case-insensitive)',
        setUp: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day, 20, 0);

          final events = [
            _createEvent(id: '1', title: 'Event A', venueName: 'Jazz Club', startTime: today),
            _createEvent(id: '2', title: 'Event B', venueName: 'Dance Hall', startTime: today),
          ];

          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => events);
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('jazz');
        },
        skip: 2,
        expect: () => [
          isA<EventListLoaded>(),
        ],
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, hasLength(1));
          expect(state.allEvents.first.id, '1');
        },
      );

      blocTest<EventListCubit, EventListState>(
        'filters events by description',
        setUp: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day, 20, 0);

          final events = [
            _createEvent(id: '1', title: 'Event A', description: 'Great salsa party', startTime: today),
            _createEvent(id: '2', title: 'Event B', description: 'Bachata workshop', startTime: today),
          ];

          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => events);
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('workshop');
        },
        skip: 2,
        expect: () => [
          isA<EventListLoaded>(),
        ],
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, hasLength(1));
          expect(state.allEvents.first.id, '2');
        },
      );

      blocTest<EventListCubit, EventListState>(
        'empty query reloads all events from API',
        setUp: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day, 20, 0);

          final events = [
            _createEvent(id: '1', title: 'Event A', startTime: today),
            _createEvent(id: '2', title: 'Event B', startTime: today),
          ];

          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => events);
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.searchEvents('Event A');
          await cubit.searchEvents('');
        },
        verify: (cubit) {
          // loadEvents called once initially, once when empty query triggers reload
          verify(() => mockRepository.getAllEvents()).called(2);
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents, hasLength(2));
        },
      );

      test('searchEvents does nothing when state is not loaded', () async {
        final cubit = EventListCubit(mockRepository);
        // State is initial, search should be a no-op
        await cubit.searchEvents('test');
        expect(cubit.state, isA<EventListInitial>());
        await cubit.close();
      });
    });

    // =========================================================================
    // toggleFavorite local state update
    // =========================================================================
    group('toggleFavorite', () {
      blocTest<EventListCubit, EventListState>(
        'toggles isFavorite locally in all grouped lists',
        setUp: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day, 20, 0);

          final events = [
            _createEvent(id: 'evt1', title: 'Event 1', startTime: today, isFavorite: false),
          ];

          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => events);
          when(() => mockRepository.toggleFavorite('evt1', false))
              .thenAnswer((_) async {});
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.toggleFavorite('evt1');
        },
        skip: 2, // skip loading + first loaded
        expect: () => [
          isA<EventListLoaded>(),
        ],
        verify: (cubit) {
          final state = cubit.state as EventListLoaded;
          expect(state.allEvents.first.isFavorite, isTrue);
          expect(state.todayEvents.first.isFavorite, isTrue);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'emits error when toggleFavorite throws ApiException',
        setUp: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day, 20, 0);

          final events = [
            _createEvent(id: 'evt1', title: 'Event 1', startTime: today, isFavorite: true),
          ];

          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => events);
          when(() => mockRepository.toggleFavorite('evt1', true))
              .thenThrow(ApiException(message: 'Failed'));
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.toggleFavorite('evt1');
        },
        skip: 2,
        expect: () => [
          isA<EventListError>(),
        ],
        verify: (cubit) {
          final state = cubit.state as EventListError;
          expect(state.message, t.errors.toggleFavoriteError);
        },
      );

      blocTest<EventListCubit, EventListState>(
        'emits error when event not found in current state',
        setUp: () {
          when(() => mockRepository.getAllEvents())
              .thenAnswer((_) async => <Event>[]);
        },
        build: () => EventListCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.toggleFavorite('nonexistent');
        },
        skip: 2,
        expect: () => [
          isA<EventListError>(),
        ],
      );

      test('toggleFavorite does nothing when state is not loaded', () async {
        final cubit = EventListCubit(mockRepository);
        await cubit.toggleFavorite('evt1');
        expect(cubit.state, isA<EventListInitial>());
        await cubit.close();
      });
    });
  });
}
