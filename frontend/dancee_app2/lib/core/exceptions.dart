/// Typed exception thrown when a CMS API request fails.
///
/// Contains the HTTP [statusCode] (null for network/connection errors)
/// and a human-readable [message] describing the failure.
class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode != null
      ? 'ApiException($statusCode): $message'
      : 'ApiException: $message';
}
