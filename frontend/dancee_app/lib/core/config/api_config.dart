import '../../app_config.dart';

/// API configuration constants.
///
/// This file contains all API-related configuration.
/// Sensitive values (like baseUrl) are imported from app_config.dart.
class ApiConfig {
  /// Base URL for the backend API service.
  /// 
  /// Imported from AppConfig (app_config.dart) - environment-specific.
  static const String baseUrl = AppConfig.baseUrl;
  
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
