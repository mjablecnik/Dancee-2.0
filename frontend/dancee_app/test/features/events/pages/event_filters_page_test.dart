import 'package:dancee_app/features/events/pages/event_filters_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  // =========================================================================
  // TC-160: EventFiltersPage mounts without error (smoke test)
  // =========================================================================

  testWidgets('TC-160: EventFiltersPage mounts without error', (tester) async {
    // EventFiltersPage uses context.pop() in its back button, so it needs
    // a GoRouter context.
    final router = GoRouter(
      initialLocation: '/events/filters',
      routes: [
        GoRoute(
          path: '/events',
          builder: (_, __) => const Scaffold(body: Text('Events')),
          routes: [
            GoRoute(
              path: 'filters',
              builder: (_, __) => const EventFiltersPage(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EventFiltersPage), findsOneWidget);
  });

  // =========================================================================
  // Task 69: EventFiltersPage renders at least one dance-type option chip/tile
  // =========================================================================

  testWidgets(
    'TC-T69: EventFiltersPage renders at least one DanceTypeOption below the dance section header',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/events/filters',
        routes: [
          GoRoute(
            path: '/events',
            builder: (_, __) => const Scaffold(body: Text('Events')),
            routes: [
              GoRoute(
                path: 'filters',
                builder: (_, __) => const EventFiltersPage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DanceTypeOption), findsWidgets);
    },
  );

  // =========================================================================
  // TC-M11: EventFiltersPage back button navigates away from the filters page
  // =========================================================================

  testWidgets(
    'TC-M11: Tapping the back button pops the filters page and shows Events',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/events/filters',
        routes: [
          GoRoute(
            path: '/events',
            builder: (_, __) => const Scaffold(body: Text('Events')),
            routes: [
              GoRoute(
                path: 'filters',
                builder: (_, __) => const EventFiltersPage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EventFiltersPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(EventFiltersPage), findsNothing);
      expect(find.text('Events'), findsOneWidget);
    },
  );
}
