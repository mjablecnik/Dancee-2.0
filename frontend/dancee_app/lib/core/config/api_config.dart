/// API configuration constants.
///
/// This file contains all API-related configuration.
/// Future configurations (app settings, feature flags, etc.) can be added
/// to the core/config/ directory.
class ApiConfig {
  /// Base URL for the backend API service.
  /// 
  /// Change this value for different environments:
  /// - Development: http://localhost:8080
  /// - Staging: https://staging-api.dancee.app
  /// - Production: https://api.dancee.app
  static const String baseUrl = 'http://172.18.86.68:8080';
  
  /// Hardcoded user ID for initial implementation.
  /// 
  /// This will be replaced with actual authentication in the future.
  static const String userId = 'user123';
  
  /// Connection timeout in milliseconds.
  static const int connectTimeout = 10000;
  
  /// Receive timeout in milliseconds.
  static const int receiveTimeout = 10000;
  
  /// Send timeout in milliseconds.
  static const int sendTimeout = 10000;
}
