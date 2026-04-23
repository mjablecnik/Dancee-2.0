import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dancee_app2/core/service_locator.dart';
import 'package:dancee_app2/i18n/strings.g.dart';
import 'package:dancee_app2/logic/cubits/auth_cubit.dart';
import 'package:dancee_app2/logic/cubits/settings_cubit.dart';
import 'package:dancee_app2/main.dart';

void main() {
  setUp(() {
    if (!sl.isRegistered<SettingsCubit>()) {
      setupServiceLocator();
    }
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('App smoke test - renders without crashing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    LocaleSettings.setLocale(AppLocale.en);
    final settingsCubit = sl<SettingsCubit>();
    final authCubit = sl<AuthCubit>();
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(),
        ),
      ],
    );

    // Use runAsync to step outside fakeAsync so Dio network timers (connect/
    // receive timeouts) are treated as real async operations and do not leave
    // "pending timers" at the end of the test.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        TranslationProvider(
          child: DanceeApp(
            settingsCubit: settingsCubit,
            authCubit: authCubit,
            router: router,
          ),
        ),
      );
      await tester.pump();
    });

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
