import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/pages/event_detail/sections.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapSliver(Widget sliver) {
  return TranslationProvider(
    child: MaterialApp(
      home: Scaffold(
        body: CustomScrollView(slivers: [sliver]),
      ),
    ),
  );
}

Widget _wrap(Widget child) {
  return TranslationProvider(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

const _testAddress = Address(
  street: 'Main St 1',
  city: 'Prague',
  postalCode: '110 00',
  country: 'CZ',
);

const _testVenue = Venue(
  name: 'Club Dance',
  address: _testAddress,
  description: '',
  latitude: 50.0,
  longitude: 14.0,
);

Event _makeEvent({
  String id = 'test-id',
  String title = 'Salsa Festival',
  String? badge,
  List<String> dances = const [],
  String description = '',
  Venue venue = _testVenue,
  String organizer = 'Test Organizer',
}) {
  return Event(
    id: id,
    title: title,
    description: description,
    organizer: organizer,
    venue: venue,
    startTime: DateTime(2026, 6, 1, 20, 0),
    dances: dances,
    badge: badge,
  );
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  // =========================================================================
  // Task 1: EventDetailHeaderSection: renders title text and back-button icon
  // =========================================================================

  testWidgets(
    'TC-T01: EventDetailHeaderSection renders title and back-button icon',
    (tester) async {
      await tester.pumpWidget(
        _wrapSliver(EventDetailHeaderSection(onBackPressed: () {})),
      );
      await tester.pump();

      expect(find.text('Event Detail'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 2: EventDetailHeaderSection: tapping back button fires onBackPressed
  // =========================================================================

  testWidgets(
    'TC-T02: EventDetailHeaderSection tapping back button fires onBackPressed',
    (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        _wrapSliver(
          EventDetailHeaderSection(onBackPressed: () => callCount++),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(callCount, 1);
    },
  );

  // =========================================================================
  // Task 3: QuickActionsSection: renders icons and toggles on isFavorite
  // =========================================================================

  testWidgets(
    'TC-T03a: QuickActionsSection renders favorite_border and map when isFavorite=false',
    (tester) async {
      await tester.pumpWidget(
        _wrap(QuickActionsSection(
          isFavorite: false,
          onFavoritePressed: () {},
          onMapPressed: () {},
        )),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
    },
  );

  testWidgets(
    'TC-T03b: QuickActionsSection shows filled heart when isFavorite=true',
    (tester) async {
      await tester.pumpWidget(
        _wrap(QuickActionsSection(
          isFavorite: true,
          onFavoritePressed: () {},
          onMapPressed: () {},
        )),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.byIcon(Icons.map), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 4: QuickActionsSection: tapping favorite button fires onFavoritePressed
  // =========================================================================

  testWidgets(
    'TC-T04: QuickActionsSection tapping favorite button fires onFavoritePressed',
    (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        _wrap(QuickActionsSection(
          isFavorite: false,
          onFavoritePressed: () => callCount++,
          onMapPressed: () {},
        )),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(callCount, 1);
    },
  );

  // =========================================================================
  // Task 5: QuickActionsSection: tapping map button fires onMapPressed
  // =========================================================================

  testWidgets(
    'TC-T05: QuickActionsSection tapping map button fires onMapPressed',
    (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        _wrap(QuickActionsSection(
          isFavorite: false,
          onFavoritePressed: () {},
          onMapPressed: () => callCount++,
        )),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.map));
      await tester.pump();

      expect(callCount, 1);
    },
  );

  // =========================================================================
  // Task 6: EventTitleSection: renders event title and venue name
  // =========================================================================

  testWidgets(
    'TC-T06: EventTitleSection renders event title and venue name',
    (tester) async {
      final event = _makeEvent(title: 'Salsa Festival', venue: _testVenue);
      await tester.pumpWidget(_wrap(EventTitleSection(event: event)));
      await tester.pump();

      expect(find.text('Salsa Festival'), findsOneWidget);
      expect(find.text('Club Dance'), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 7: EventTitleSection: renders badge when non-null; omits when null
  // =========================================================================

  testWidgets(
    'TC-T07a: EventTitleSection renders badge text when badge is non-null',
    (tester) async {
      final event = _makeEvent(badge: 'HOT');
      await tester.pumpWidget(_wrap(EventTitleSection(event: event)));
      await tester.pump();

      expect(find.text('HOT'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-T07b: EventTitleSection omits badge when badge is null',
    (tester) async {
      final event = _makeEvent(badge: null);
      await tester.pumpWidget(_wrap(EventTitleSection(event: event)));
      await tester.pump();

      // EventBadge should not be present
      expect(find.text('HOT'), findsNothing);
    },
  );

  // =========================================================================
  // Task 8: DanceStylesSection: renders chips; empty list renders nothing
  // =========================================================================

  testWidgets(
    'TC-T08a: DanceStylesSection renders a chip for each dance style',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const DanceStylesSection(dances: ['Salsa', 'Bachata'])),
      );
      await tester.pump();

      expect(find.text('Salsa'), findsOneWidget);
      expect(find.text('Bachata'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-T08b: DanceStylesSection renders nothing when list is empty',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const DanceStylesSection(dances: [])),
      );
      await tester.pump();

      expect(find.text('Salsa'), findsNothing);
      expect(find.byType(Chip), findsNothing);
    },
  );

  // =========================================================================
  // Task 9: EventVenueSection: renders venue name and street address
  // =========================================================================

  testWidgets(
    'TC-T09: EventVenueSection renders venue name and street address',
    (tester) async {
      const venue = Venue(
        name: 'Dance Hall',
        address: Address(
          street: 'Main St 1',
          city: 'Prague',
          postalCode: '110 00',
          country: 'CZ',
        ),
        description: '',
        latitude: 50.0,
        longitude: 14.0,
      );
      await tester.pumpWidget(
        _wrap(EventVenueSection(venue: venue, onNavigatePressed: () {})),
      );
      await tester.pump();

      expect(find.text('Dance Hall'), findsOneWidget);
      expect(find.text('Main St 1'), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 10: EventVenueSection: tapping Navigate button fires onNavigatePressed
  // =========================================================================

  testWidgets(
    'TC-T10: EventVenueSection tapping Navigate button fires onNavigatePressed',
    (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        _wrap(EventVenueSection(
          venue: _testVenue,
          onNavigatePressed: () => callCount++,
        )),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.directions));
      await tester.pump();

      expect(callCount, 1);
    },
  );
}
