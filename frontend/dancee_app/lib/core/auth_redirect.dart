/// Protected routes that require authentication.
const protectedRoutes = ['/settings'];

/// Pure redirect logic extracted for testability.
///
/// Returns `'/login'` when [matchedLocation] starts with any protected route
/// and [isAuthenticated] is `false`. Returns `null` otherwise (no redirect).
String? authRedirect({
  required String matchedLocation,
  required bool isAuthenticated,
}) {
  final isProtectedRoute = protectedRoutes.any(
    (route) => matchedLocation.startsWith(route),
  );

  if (!isAuthenticated && isProtectedRoute) {
    return '/login';
  }

  return null;
}
