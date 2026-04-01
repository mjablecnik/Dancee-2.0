import 'package:dancee_app/features/auth/pages/login/login_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  GoRouter _makeRouter() => GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (_, __) => const LoginPage(),
          ),
          GoRoute(
            path: '/register',
            builder: (_, __) => const Scaffold(body: Text('Register')),
          ),
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
        ],
      );

  // =========================================================================
  // TC-L01: LoginPage smoke test — email/password fields and login button render
  // =========================================================================

  testWidgets(
    'TC-L01: LoginPage renders email field, password field, and login button',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: _makeRouter()),
        ),
      );
      await tester.pumpAndSettle();

      // Email field and password field (two TextFields in LoginFormSection)
      expect(
        find.byType(TextField),
        findsNWidgets(2),
        reason: 'Email and password TextFields should both be present',
      );

      // Login button (GradientActionButton uses MaterialButton)
      expect(
        find.byType(MaterialButton),
        findsOneWidget,
        reason: 'Login submit button should be rendered',
      );
    },
  );

  // =========================================================================
  // TC-L02: LoginPage form — tapping login button with empty fields does not
  //         crash (placeholder has no validation; documents current behavior)
  // =========================================================================

  testWidgets(
    'TC-L02: LoginPage login button tap with empty fields does not crash '
    '(placeholder — no form validation implemented)',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: _makeRouter()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the login button without filling any fields
      await tester.tap(find.byType(MaterialButton));
      await tester.pumpAndSettle();

      // LoginPage is still displayed; no exception was thrown
      expect(find.byType(LoginPage), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-M09: LoginPage register link navigates to /register
  // =========================================================================

  testWidgets(
    'TC-M09: Tapping the Register link navigates to /register',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: _makeRouter()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and scroll to the "Register" text link before tapping
      final registerLink = find.text('Register');
      expect(registerLink, findsOneWidget);
      await tester.ensureVisible(registerLink);
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // After navigation, the register destination is shown
      expect(find.text('Register'), findsWidgets);
      expect(find.byType(LoginPage), findsNothing);
    },
  );
}
