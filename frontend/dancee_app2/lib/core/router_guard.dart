import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'service_locator.dart';
import '../logic/cubits/auth_cubit.dart';

/// Protected routes that require authentication.
const _protectedPrefixes = ['/events', '/courses', '/profile', '/saved'];

/// Auth-only screens that authenticated+verified users should be redirected away from.
const _authOnlyScreens = ['/login', '/register', '/forgot-password'];

bool _isProtectedRoute(String path) =>
    _protectedPrefixes.any((prefix) => path.startsWith(prefix));

/// GoRouter redirect callback. Reads [AuthCubit] state from the service locator
/// and returns the appropriate redirect path, or null for no redirect.
String? routerGuard(BuildContext context, GoRouterState state) {
  final authState = sl<AuthCubit>().state;
  final location = state.uri.path;

  return authState.map(
    unauthenticated: (_) {
      if (_isProtectedRoute(location) ||
          location == '/onboarding' ||
          location == '/verify-email') {
        return '/login';
      }
      return null;
    },
    loading: (_) => null,
    authenticated: (s) {
      if (!s.emailVerified) {
        if (location == '/verify-email') return null;
        // Redirect all other routes to email verification
        return '/verify-email';
      }
      // Email is verified — redirect away from auth screens
      if (_authOnlyScreens.contains(location) || location == '/verify-email') {
        return '/events';
      }
      return null;
    },
    error: (_) => null,
  );
}
