/// Result wrapper for service operations.
class ServiceResult {
  final bool success;
  final int statusCode;
  final String message;

  ServiceResult._({
    required this.success,
    required this.statusCode,
    required this.message,
  });

  factory ServiceResult.success({
    int statusCode = 200,
    String message = 'Success',
  }) {
    return ServiceResult._(
      success: true,
      statusCode: statusCode,
      message: message,
    );
  }

  factory ServiceResult.error({
    required int statusCode,
    required String message,
  }) {
    return ServiceResult._(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  @override
  String toString() {
    return 'ServiceResult(success: $success, statusCode: $statusCode, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceResult &&
        other.success == success &&
        other.statusCode == statusCode &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(success, statusCode, message);
}
