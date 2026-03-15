import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/logic/favorites.dart';
import 'package:dancee_app/i18n/translations.g.dart';

class MockEventRepository extends Mock implements EventRepository {}

class MockEventListCubit extends Mock implements EventListCubit {}

/// Creates a test Event with the given parameters.
Event _createEvent({
  String id = '1',
  String title = 'Test Event',
  bool isFavorite = true,
  bool isPast = false,
}) {
  final now = DateTime.now();
  return Event(
    id: id,
    title: title,
    description: 'A test event',
    organizer: 'Test Organizer',
    venue: const Venue(
      name: 'Test Venue',
      address: Address(
        street: 'Test Street 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      ),
      description: 'A test venue',
      latitude: 50.08,
      longitude: 14.42,
    ),
    startTime: now.add(const Duration(hours: 2)),
    endTime: now.add(const Duration(hours: 6)),
    duration: const Duration(hours: 4),
    dances: const ['salsa'],
    info: const [],
    parts: const [],
    isFavorite: isFavorite,
    isPast: isPast,
  );
}

void main() {
  late MockEventRepository mockRepository;
  late MockEventListCubit mockEventListCubit;
  final getIt = GetIt.instance;

  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
    mockRepository = MockEventRepository();
    mockEventListCubit = MockEventListCubit();

    // Register mock EventListCubit in GetIt so FavoritesCubit.toggleFavorite
    // can call getIt<EventListCubit>().loadEvents()
    if (getIt.isRegistered<EventListCubit>()) {
      getIt.unregister<EventListCubit>();
    }
    getIt.registerSingleton<EventListCubit>(mockEventListCubit);
    when(() => mockEventListCubit.loadEvents()).thenAnswer((_) async {});
  });

  tearDown(() {
    if (getIt.isRegistered<EventListCubit>()) {
      getIt.unregister<EventListCubit>();
    }
  });

  group('FavoritesCubit', () {
    // =========================================================================
    // State transitions
    // =========================================================================
    group('state transitions', () {
      test('initial state is FavoritesInitial', () {
        final cubit = FavoritesCubit(mockRepository);
        expect(cubit.state, isA<FavoritesInitial>());
        cubit.close();
      });

      blocTest<FavoritesCubit, FavoritesState>(
        'emits [loading, loaded] when loadFavorites succeeds',
        setUp: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => <Event>[]);
        },
        build: () => FavoritesCubit(mockRepository),
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
        ],
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits [loading, error] when loadFavorites throws ApiException',
        setUp: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenThrow(ApiException(message: 'Server error'));
        },
        build: () => FavoritesCubit(mockRepository),
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesError>(),
        ],
        verify: (cubit) {
          final state = cubit.state as FavoritesError;
          expect(state.message, t.errors.loadFavoritesError);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits [loading, error] with genericError when loadFavorites throws non-ApiException',
        setUp: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenThrow(Exception('unexpected'));
        },
        build: () => FavoritesCubit(mockRepository),
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesError>(),
        ],
        verify: (cubit) {
          final state = cubit.state as FavoritesError;
          expect(state.message, t.errors.genericError);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'separates favorites into upcoming and past events',
        setUp: () {
          final favorites = [
            _createEvent(id: 'up1', title: 'Upcoming Fav', isPast: false),
            _createEvent(id: 'past1', title: 'Past Fav', isPast: true),
            _createEvent(id: 'up2', title: 'Upcoming Fav 2', isPast: false),
          ];
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => favorites);
        },
        build: () => FavoritesCubit(mockRepository),
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>(),
        ],
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          expect(state.upcomingEvents, hasLength(2));
          expect(state.pastEvents, hasLength(1));
          expect(state.pastEvents.first.id, 'past1');
        },
      );
    });

    // =========================================================================
    // toggleFavorite
    // =========================================================================
    group('toggleFavorite', () {
      blocTest<FavoritesCubit, FavoritesState>(
        'toggles isFavorite locally without removing event from view',
        setUp: () {
          final favorites = [
            _createEvent(id: 'evt1', title: 'Fav Event', isFavorite: true),
          ];
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => favorites);
          when(() => mockRepository.toggleFavorite('evt1', true))
              .thenAnswer((_) async {});
        },
        build: () => FavoritesCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('evt1');
        },
        skip: 2, // skip loading + first loaded
        expect: () => [
          isA<FavoritesLoaded>(),
        ],
        verify: (cubit) {
          final state = cubit.state as FavoritesLoaded;
          // Event stays in the list but isFavorite is toggled
          expect(state.upcomingEvents, hasLength(1));
          expect(state.upcomingEvents.first.isFavorite, isFalse);
          // Verify EventListCubit was notified
          verify(() => mockEventListCubit.loadEvents()).called(1);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits error when toggleFavorite throws ApiException',
        setUp: () {
          final favorites = [
            _createEvent(id: 'evt1', title: 'Fav Event', isFavorite: true),
          ];
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => favorites);
          when(() => mockRepository.toggleFavorite('evt1', true))
              .thenThrow(ApiException(message: 'Failed'));
        },
        build: () => FavoritesCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('evt1');
        },
        skip: 2,
        expect: () => [
          isA<FavoritesError>(),
        ],
        verify: (cubit) {
          final state = cubit.state as FavoritesError;
          expect(state.message, t.errors.toggleFavoriteError);
        },
      );

      blocTest<FavoritesCubit, FavoritesState>(
        'emits error when event not found in current state',
        setUp: () {
          when(() => mockRepository.getFavoriteEvents())
              .thenAnswer((_) async => <Event>[]);
        },
        build: () => FavoritesCubit(mockRepository),
        act: (cubit) async {
          await cubit.loadFavorites();
          await cubit.toggleFavorite('nonexistent');
        },
        skip: 2,
        expect: () => [
          isA<FavoritesError>(),
        ],
      );

      test('toggleFavorite does nothing when state is not loaded', () async {
        final cubit = FavoritesCubit(mockRepository);
        await cubit.toggleFavorite('evt1');
        expect(cubit.state, isA<FavoritesInitial>());
        await cubit.close();
      });
    });
  });
}
