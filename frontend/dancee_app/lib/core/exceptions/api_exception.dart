/// Exception thrown when API calls fail.
///
/// This is part of the core exceptions module.
/// Future exception types (ValidationException, BusinessLogicException, etc.)
/// can be added to the core/exceptions/ directory.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });
  
  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
