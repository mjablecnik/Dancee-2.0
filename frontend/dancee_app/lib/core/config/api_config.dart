/// API configuration constants for the Dancee Event Service backend
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for the backend API service
  /// Change this for different environments (development, staging, production)
  static const String baseUrl = 'http://localhost:8080';

  /// Connection timeout in milliseconds
  static const int connectionTimeout = 10000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 10000;

  /// Send timeout in milliseconds
  static const int sendTimeout = 10000;

  /// Hardcoded user ID for initial implementation
  /// TODO: Replace with actual authentication system
  static const String userId = 'user123';

  /// API endpoints
  static const String eventsEndpoint = '/api/events';
  static const String favoritesEndpoint = '/api/favorites';
  static const String healthEndpoint = '/health';
}
