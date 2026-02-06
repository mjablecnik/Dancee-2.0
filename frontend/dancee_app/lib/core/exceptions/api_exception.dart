/// Custom exception for API-related errors
/// 
/// This exception is thrown when API calls fail due to network errors,
/// timeouts, HTTP errors, or parsing errors. It provides a user-friendly
/// message and optional error details for debugging.
class ApiException implements Exception {
  /// User-friendly error message
  final String message;

  /// Optional error details for debugging
  final dynamic error;

  /// Optional stack trace for debugging
  final StackTrace? stackTrace;

  /// HTTP status code (if applicable)
  final int? statusCode;

  ApiException({
    required this.message,
    this.error,
    this.stackTrace,
    this.statusCode,
  });

  @override
  String toString() {
    if (error != null) {
      return 'ApiException: $message (Error: $error)';
    }
    return 'ApiException: $message';
  }
}
