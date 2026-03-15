import '../config.dart';

/// Application configuration.
///
/// This file consolidates all configuration values:
/// - Sensitive values are imported from lib/config.dart (gitignored)
/// - Public non-sensitive values are defined directly here
///
/// All code should import this file for configuration access.
class AppConfig {
  /// Base URL for the backend API service.
  ///
  /// Imported from sensitive config (config.dart) - environment-specific.
  static const String baseUrl = Config.baseUrl;

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
