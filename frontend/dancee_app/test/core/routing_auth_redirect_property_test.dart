import 'dart:math';

import 'package:dancee_app/core/routing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Feature: flutter-architecture-refactor
/// Property 6: Authentication Redirect
/// **Validates: Requirements 10.8**

// ============================================================================
// Random generators
// ============================================================================

/// Generates a random route path. Includes both protected and public routes
/// to exercise both branches of the redirect logic.
String _randomRoutePath(Random rng) {
  const publicRoutes = [
    '/',
    '/events',
    '/events/123',
    '/favorites',
    '/login',
    '/register',
    '/about',
    '/events/abc-def',
  ];

  const protectedPrefixes = [
    '/settings',
    '/settings/profile',
    '/settings/preferences',
    '/settings/account',
  ];

  // ~40% chance of generating a protected route to ensure good coverage
  if (rng.nextDouble() < 0.4) {
    return protectedPrefixes[rng.nextInt(protectedPrefixes.length)];
  }
  return publicRoutes[rng.nextInt(publicRoutes.length)];
}

bool _isProtected(String path) {
  return protectedRoutes.any((route) => path.startsWith(route));
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('Property 6: Authentication Redirect', () {
    test(
      'unauthenticated user accessing a protected route is redirected to /login',
      () {
        for (var i = 0; i < 200; i++) {
          final rng = Random(i);
          final path = _randomRoutePath(rng);

          final result = authRedirect(
            matchedLocation: path,
            isAuthenticated: false,
          );

          if (_isProtected(path)) {
            expect(
              result,
              equals('/login'),
              reason:
                  'Unauthenticated user at protected route "$path" should be '
                  'redirected to /login (seed $i)',
            );
          } else {
            expect(
              result,
              isNull,
              reason:
                  'Unauthenticated user at public route "$path" should not be '
                  'redirected (seed $i)',
            );
          }
        }
      },
    );

    test(
      'authenticated user is never redirected regardless of route',
      () {
        for (var i = 0; i < 200; i++) {
          final rng = Random(i);
          final path = _randomRoutePath(rng);

          final result = authRedirect(
            matchedLocation: path,
            isAuthenticated: true,
          );

          expect(
            result,
            isNull,
            reason:
                'Authenticated user at "$path" should never be redirected '
                '(seed $i)',
          );
        }
      },
    );

    test(
      'for any route and auth state: redirect is /login or null, never anything else',
      () {
        for (var i = 0; i < 200; i++) {
          final rng = Random(i);
          final path = _randomRoutePath(rng);
          final isAuthenticated = rng.nextBool();

          final result = authRedirect(
            matchedLocation: path,
            isAuthenticated: isAuthenticated,
          );

          expect(
            result == null || result == '/login',
            isTrue,
            reason:
                'Redirect for path "$path" (auth=$isAuthenticated) returned '
                '"$result" — expected null or "/login" (seed $i)',
          );
        }
      },
    );
  });
}
