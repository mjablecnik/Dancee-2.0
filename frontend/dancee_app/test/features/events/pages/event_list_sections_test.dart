import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/pages/event_list/sections.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

class _SeedableEventListCubit extends EventListCubit {
  final List<String> searchedTerms = [];

  _SeedableEventListCubit(super.repo);

  void seed(EventListState state) => emit(state);

  @override
  Future<void> loadEvents() async {}

  @override
  Future<void> searchEvents(String query) async {
    searchedTerms.add(query);
    // Emit empty results for simplicity
    emit(const EventListState.loaded(
      allEvents: [],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [],
    ));
  }
}

Widget _wrapSliver(Widget sliver) {
  return TranslationProvider(
    child: MaterialApp(
      home: Scaffold(
        body: CustomScrollView(slivers: [sliver]),
      ),
    ),
  );
}

Event _makeEvent({required String id, String title = 'Test Event'}) {
  return Event(
    id: id,
    title: title,
    description: '',
    organizer: '',
    venue: const Venue(
      name: 'Club Test',
      address: Address(
        street: 'Test St 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'CZ',
      ),
      description: '',
      latitude: 50.0,
      longitude: 14.0,
    ),
    startTime: DateTime(2026, 6, 1, 20, 0),
    dances: const [],
  );
}

void main() {
  late MockEventRepository mockRepo;
  late _SeedableEventListCubit cubit;

  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() {
    mockRepo = MockEventRepository();
    cubit = _SeedableEventListCubit(mockRepo);
    getIt.allowReassignment = true;
    getIt.registerSingleton<EventListCubit>(cubit);
  });

  tearDown(() async {
    await cubit.close();
    if (getIt.isRegistered<EventListCubit>()) {
      getIt.unregister<EventListCubit>();
    }
  });

  // =========================================================================
  // Task 22: EventListHeaderSection renders "Dancee" brand title
  // =========================================================================

  testWidgets(
    'TC-T22: EventListHeaderSection renders "Dancee" brand title',
    (tester) async {
      await tester.pumpWidget(
        _wrapSliver(const EventListHeaderSection()),
      );
      await tester.pump();

      expect(find.text('Dancee'), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 23: SearchAndFiltersSection renders a TextField for search input
  // =========================================================================

  testWidgets(
    'TC-T23: SearchAndFiltersSection renders at least one TextField',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Mount SearchAndFiltersSection directly (not in sliver context)
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: const SearchAndFiltersSection(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    },
  );

  // =========================================================================
  // Task 24: SearchAndFiltersSection typing text fires searchEvents on cubit
  // =========================================================================

  testWidgets(
    'TC-T24: SearchAndFiltersSection typing "salsa" calls cubit.searchEvents("salsa")',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: const Scaffold(
              body: SearchAndFiltersSection(),
            ),
          ),
        ),
      );
      await tester.pump();

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'salsa');
      await tester.pump();

      expect(cubit.searchedTerms, contains('salsa'));
    },
  );

  // =========================================================================
  // Task 25: EventsByDateSection renders Today/Tomorrow/Upcoming headers
  // =========================================================================

  testWidgets(
    'TC-T25: EventsByDateSection renders Today, Tomorrow, and "This week" headers',
    (tester) async {
      final event1 = _makeEvent(id: '1', title: 'Today Event');
      final event2 = _makeEvent(id: '2', title: 'Tomorrow Event');
      final event3 = _makeEvent(id: '3', title: 'Upcoming Event');

      await tester.pumpWidget(
        _wrapSliver(EventsByDateSection(
          todayEvents: [event1],
          tomorrowEvents: [event2],
          upcomingEvents: [event3],
        )),
      );
      await tester.pump();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 26: EventsByDateSection omits header for empty event groups
  // =========================================================================

  testWidgets(
    'TC-T26: EventsByDateSection omits header when event group is empty',
    (tester) async {
      final event2 = _makeEvent(id: '2', title: 'Tomorrow Event');

      await tester.pumpWidget(
        _wrapSliver(EventsByDateSection(
          todayEvents: const [],
          tomorrowEvents: [event2],
          upcomingEvents: const [],
        )),
      );
      await tester.pump();

      expect(find.text('Today'), findsNothing);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('This week'), findsNothing);
    },
  );
}
