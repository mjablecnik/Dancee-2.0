/// Sensitive configuration file - EXAMPLE TEMPLATE.
///
/// This is an example template for config.dart.
///
/// To use:
/// 1. Copy this file to config.dart
/// 2. Update the values with your actual configuration
/// 3. The real config.dart is in .gitignore and won't be committed
class Config {
  /// Base URL for the backend API service.
  ///
  /// IMPORTANT: Do NOT include /api in the base URL.
  /// The /api prefix is added automatically by the repository layer.
  ///
  /// Examples:
  /// - Local development: 'http://localhost:8080'
  /// - Android Emulator: 'http://10.0.2.2:8080'
  /// - Production: 'https://dancee-events.fly.dev'
  static const String baseUrl = 'YOUR_API_BASE_URL_HERE';
}
