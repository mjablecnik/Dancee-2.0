import 'package:dancee_app/features/settings/pages/settings_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  GoRouter _makeRouter() => GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
        ],
      );

  // =========================================================================
  // TC-L04: SettingsPage smoke test — page mounts without error
  // =========================================================================

  testWidgets(
    'TC-L04: SettingsPage mounts without error',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: _makeRouter()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    },
  );
}
