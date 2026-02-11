/// Application configuration file - EXAMPLE TEMPLATE.
///
/// This is an example template for app_config.dart.
/// 
/// To use:
/// 1. Copy this file to app_config.dart
/// 2. Update the values with your actual configuration
/// 3. The real app_config.dart is in .gitignore and won't be committed
class AppConfig {
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
