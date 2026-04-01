import 'package:bloc_test/bloc_test.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/logic/favorites.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockEventRepository extends Mock implements EventRepository {}

class MockEventListCubit extends Mock implements EventListCubit {}

class MockDirectusClient extends Mock implements DirectusClient {}

/// Extends EventListCubit to suppress auto-loadEvents() in constructor.
class _SeedableEventListCubit extends EventListCubit {
  _SeedableEventListCubit(super.repo);

  void seed(EventListState state) => emit(state);

  @override
  Future<void> loadEvents() async {}
}

// ---------------------------------------------------------------------------
// Helper factory
// ---------------------------------------------------------------------------

Event _makeEvent({
  required String id,
  String title = 'Test Event',
  bool isFavorite = true,
  bool isPast = false,
}) {
  final now = DateTime.now();
  return Event(
    id: id,
    title: title,
    description: '',
    organizer: '',
    venue: const Venue(
      name: 'Test Venue',
      address: Address(
        street: 'Street 1',
        city: 'City',
        postalCode: '100 00',
        country: 'CZ',
      ),
      description: '',
      latitude: 0,
      longitude: 0,
    ),
    startTime: isPast
        ? now.subtract(const Duration(days: 2))
        : now.add(const Duration(hours: 1)),
    endTime: isPast
        ? now.subtract(const Duration(days: 1))
        : now.add(const Duration(hours: 3)),
    dances: const [],
    isFavorite: isFavorite,
    isPast: isPast,
  );
}

void main() {
  late MockEventRepository mockRepo;
  late MockEventListCubit mockListCubit;

  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() {
    mockRepo = MockEventRepository();
    mockListCubit = MockEventListCubit();

    // Stub the mock EventListCubit so getIt injections work correctly
    when(() => mockListCubit.state)
        .thenReturn(const EventListState.initial());
    when(() => mockListCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockListCubit.loadEvents()).thenAnswer((_) async {});
    when(() => mockListCubit.isClosed).thenReturn(false);

    // Register the mock EventListCubit in getIt so FavoritesCubit can resolve it
    getIt.allowReassignment = true;
    getIt.registerSingleton<EventListCubit>(mockListCubit);
  });

  tearDown(() async {
    if (getIt.isRegistered<EventListCubit>()) {
      getIt.unregister<EventListCubit>();
    }
  });

  // =========================================================================
  // TC-053: loadFavorites() emits loading → loaded with past/upcoming split
  // =========================================================================

  blocTest<FavoritesCubit, FavoritesState>(
    'TC-053: loadFavorites emits loading → loaded with past and upcoming split',
    build: () => FavoritesCubit(mockRepo),
    act: (cubit) async {
      when(() => mockRepo.getFavoriteEvents()).thenAnswer((_) async => [
            _makeEvent(id: '1', isPast: false),
            _makeEvent(id: '2', isPast: false),
            _makeEvent(id: '3', isPast: true),
          ]);
      await cubit.loadFavorites();
    },
    expect: () => [
      isA<FavoritesLoading>(),
      isA<FavoritesLoaded>().having(
        (s) => s.upcomingEvents.length,
        'upcoming count',
        2,
      ).having(
        (s) => s.pastEvents.length,
        'past count',
        1,
      ),
    ],
  );

  // =========================================================================
  // TC-054: loadFavorites() emits error on repository failure
  // =========================================================================

  blocTest<FavoritesCubit, FavoritesState>(
    'TC-054: loadFavorites emits loading → error when repository throws',
    build: () => FavoritesCubit(mockRepo),
    act: (cubit) async {
      when(() => mockRepo.getFavoriteEvents())
          .thenThrow(ApiException(message: 'Server error', statusCode: 500));
      await cubit.loadFavorites();
    },
    expect: () => [
      isA<FavoritesLoading>(),
      isA<FavoritesError>(),
    ],
  );

  // =========================================================================
  // TC-055: toggleFavorite() updates isFavorite in loaded state
  // =========================================================================

  blocTest<FavoritesCubit, FavoritesState>(
    'TC-055: toggleFavorite updates isFavorite on the event in loaded state',
    build: () => FavoritesCubit(mockRepo),
    seed: () => FavoritesState.loaded(
      upcomingEvents: [_makeEvent(id: '3', isFavorite: true, isPast: false)],
      pastEvents: const [],
    ),
    act: (cubit) async {
      when(() => mockRepo.toggleFavorite(any(), any()))
          .thenAnswer((_) async {});
      await cubit.toggleFavorite('3');
    },
    expect: () => [
      isA<FavoritesLoaded>().having(
        (s) => s.upcomingEvents.first.isFavorite,
        'isFavorite after toggle',
        isFalse,
      ),
    ],
  );

  // =========================================================================
  // TC-057: filterUnfavoritedEvents() removes events with isFavorite == false
  // =========================================================================

  blocTest<FavoritesCubit, FavoritesState>(
    'TC-057: filterUnfavoritedEvents removes events where isFavorite is false',
    build: () => FavoritesCubit(mockRepo),
    seed: () => FavoritesState.loaded(
      upcomingEvents: [
        _makeEvent(id: '1', isFavorite: true, isPast: false),
        _makeEvent(id: '2', isFavorite: false, isPast: false),
      ],
      pastEvents: [
        _makeEvent(id: '3', isFavorite: false, isPast: true),
      ],
    ),
    act: (cubit) {
      cubit.filterUnfavoritedEvents();
    },
    expect: () => [
      isA<FavoritesLoaded>()
          .having(
            (s) => s.upcomingEvents.map((e) => e.id).toList(),
            'upcoming ids after filter',
            ['1'],
          )
          .having(
            (s) => s.pastEvents,
            'past events after filter',
            isEmpty,
          ),
    ],
  );

  // =========================================================================
  // TC-058: removePastEvent() instantly removes a past event by ID
  // =========================================================================

  blocTest<FavoritesCubit, FavoritesState>(
    'TC-058: removePastEvent removes the past event and leaves upcoming unchanged',
    build: () => FavoritesCubit(mockRepo),
    seed: () => FavoritesState.loaded(
      upcomingEvents: [_makeEvent(id: 'up1', isFavorite: true, isPast: false)],
      pastEvents: [
        _makeEvent(id: '7', isFavorite: true, isPast: true),
        _makeEvent(id: '8', isFavorite: true, isPast: true),
      ],
    ),
    act: (cubit) async {
      when(() => mockRepo.toggleFavorite(any(), any()))
          .thenAnswer((_) async {});
      await cubit.removePastEvent('7');
    },
    expect: () => [
      isA<FavoritesLoaded>()
          .having(
            (s) => s.pastEvents.map((e) => e.id).toList(),
            'past events after remove',
            ['8'],
          )
          .having(
            (s) => s.upcomingEvents.map((e) => e.id).toList(),
            'upcoming unchanged',
            ['up1'],
          ),
    ],
  );

  // =========================================================================
  // TC-132: loadFavorites() emits FavoritesLoaded with empty lists when no favorites
  // =========================================================================

  blocTest<FavoritesCubit, FavoritesState>(
    'TC-132: loadFavorites emits loaded with empty lists when repository returns empty list',
    build: () => FavoritesCubit(mockRepo),
    act: (cubit) async {
      when(() => mockRepo.getFavoriteEvents()).thenAnswer((_) async => []);
      await cubit.loadFavorites();
    },
    expect: () => [
      isA<FavoritesLoading>(),
      isA<FavoritesLoaded>()
          .having((s) => s.upcomingEvents, 'upcomingEvents', isEmpty)
          .having((s) => s.pastEvents, 'pastEvents', isEmpty),
    ],
  );

  // =========================================================================
  // TC-133: toggleFavorite() emits no states when state is not FavoritesLoaded
  // =========================================================================

  blocTest<FavoritesCubit, FavoritesState>(
    'TC-133: toggleFavorite emits nothing when cubit is not in FavoritesLoaded state',
    build: () => FavoritesCubit(mockRepo),
    seed: () => const FavoritesState.loading(),
    act: (cubit) async {
      await cubit.toggleFavorite('evt-1');
    },
    expect: () => <FavoritesState>[],
    verify: (_) {
      verifyNever(() => mockRepo.toggleFavorite(any(), any()));
    },
  );

  // =========================================================================
  // TC-056: toggleFavorite() calls EventListCubit.loadEvents() once
  // =========================================================================

  test('TC-056: toggleFavorite triggers EventListCubit.loadEvents()', () async {
    final cubit = FavoritesCubit(mockRepo);

    // Seed the cubit to loaded state
    // We need to emit the state directly - use blocTest approach
    when(() => mockRepo.getFavoriteEvents()).thenAnswer((_) async => [
          _makeEvent(id: '3', isFavorite: true, isPast: false),
        ]);
    await cubit.loadFavorites();

    // Now the cubit should be in loaded state
    expect(cubit.state, isA<FavoritesLoaded>());

    when(() => mockRepo.toggleFavorite(any(), any()))
        .thenAnswer((_) async {});

    await cubit.toggleFavorite('3');

    // Verify EventListCubit.loadEvents() was called once
    verify(() => mockListCubit.loadEvents()).called(1);

    await cubit.close();
  });

  // =========================================================================
  // TC-169: Integration — toggling favorite in EventListCubit is reflected
  //         in FavoritesCubit after reload
  // =========================================================================

  test(
    'TC-169: FavoritesCubit reflects favorite toggled via EventListCubit',
    () async {
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockDirectusClient();
      final realRepo = EventRepository(mockClient);

      // Return evt-1 from every /items/events call
      when(() => mockClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => [
            {
              'id': 'evt-1',
              'start_time': '2099-12-31T20:00:00.000Z',
              'end_time': '2099-12-31T23:00:00.000Z',
              'organizer': 'Organizer',
              'dances': <String>[],
              'venue': {
                'name': 'Venue',
                'street': 'Street',
                'number': '1',
                'town': 'City',
                'postal_code': '100 00',
                'country': 'CZ',
                'latitude': 50.0,
                'longitude': 14.0,
              },
              'translations': [
                {
                  'languages_code': 'cs',
                  'title': 'Event 1',
                  'description': 'Desc',
                }
              ],
              'info': <dynamic>[],
              'parts': <dynamic>[],
            }
          ]);

      final listCubit = _SeedableEventListCubit(realRepo);

      // Seed EventListCubit with evt-1 as not favorite
      final event = _makeEvent(id: 'evt-1', isFavorite: false);
      listCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [event],
      ));

      // Register listCubit for FavoritesCubit's getIt dependency
      getIt.allowReassignment = true;
      getIt.registerSingleton<EventListCubit>(listCubit);

      final favoritesCubit = FavoritesCubit(realRepo);

      // Toggle favorite via EventListCubit — writes 'evt-1' to SharedPreferences
      await listCubit.toggleFavorite('evt-1');

      // Verify SharedPreferences now contains evt-1
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite_event_ids'), contains('evt-1'));

      // Reload favorites in FavoritesCubit — reads from SharedPreferences + API
      await favoritesCubit.loadFavorites();

      final favState = favoritesCubit.state;
      expect(favState, isA<FavoritesLoaded>());
      final loaded = favState as FavoritesLoaded;
      expect(
        loaded.upcomingEvents.any((e) => e.id == 'evt-1'),
        isTrue,
        reason: 'evt-1 should be in upcoming favorites after toggle',
      );

      await listCubit.close();
      await favoritesCubit.close();
    },
  );
}
