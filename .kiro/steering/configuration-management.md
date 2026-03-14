---
inclusion: always
---

# Sensitive Configuration Management

**CRITICAL**: Sensitive configuration values MUST be stored in `config.dart`, which is excluded from version control.

## Configuration Files

- **`lib/config.dart`** - Contains ONLY sensitive values (in .gitignore, NOT committed)
- **`lib/config.example.dart`** - Template file (committed to git)
- **`lib/core/config.dart`** - Public configuration that imports from Config

## What Goes in `config.dart` (Sensitive - Gitignored)

- **API URLs** (baseUrl for different environments)
- **API Keys** and tokens
- **Secret keys** and credentials
- **OAuth client IDs/secrets**
- **Third-party service credentials**
- **Sentry DSN** and monitoring keys
- Any environment-specific sensitive data

## What Goes in `core/config.dart` (Public - Committed)

- **Timeout values** (connectTimeout, receiveTimeout, sendTimeout)
- **Default user IDs** for development
- **Public constants** that don't expose security risks
- **Feature flags** and non-sensitive settings
- **Imports from sensitive config** (re-exports sensitive values for use in app)

## Usage Pattern

**lib/config.dart** (gitignored - ONLY sensitive data):
```dart
class Config {
  static const String apiBaseUrl = 'https://api.production.com';
  static const String apiKey = 'secret-key-here';
  static const String sentryDsn = 'your-sentry-dsn';
}
```

**lib/config.example.dart** (committed as template):
```dart
class Config {
  static const String apiBaseUrl = 'YOUR_API_BASE_URL_HERE';
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const String sentryDsn = 'YOUR_SENTRY_DSN_HERE';
}
```

**lib/core/config.dart** (public - all non-sensitive config):
```dart
import '../config.dart';

class AppConfig {
  // Import sensitive values from Config
  static const String apiBaseUrl = Config.apiBaseUrl;
  static const String apiKey = Config.apiKey;
  static const String sentryDsn = Config.sentryDsn;
  
  // Public non-sensitive values
  static const String userId = 'user123';
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
  static const int sendTimeout = 10000;
  static const bool enableLogging = true;
}
```

## Setup for New Developers

```bash
# Copy the example file
cp lib/config.example.dart lib/config.dart
# Edit lib/config.dart with actual values
```

## Important Rules

1. **NEVER commit `lib/config.dart`** - it's in .gitignore
2. **Always update `lib/config.example.dart`** when adding new sensitive fields
3. **Use placeholder values** in example file (e.g., 'YOUR_API_KEY_HERE')
4. **Document all fields** with comments explaining their purpose
5. **Keep sensitive data separate** - ONLY in `lib/config.dart`, all other config in `lib/core/config.dart`
6. **Import pattern**: `lib/core/config.dart` imports from `lib/config.dart` and re-exports for app use
