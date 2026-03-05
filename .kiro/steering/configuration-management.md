---
inclusion: always
---

# Sensitive Configuration Management

**CRITICAL**: Sensitive configuration values MUST be stored in `app_config.dart`, which is excluded from version control.

## Configuration Files

- **`lib/app_config.dart`** - Contains sensitive values (in .gitignore, NOT committed)
- **`lib/app_config.example.dart`** - Template file (committed to git)
- **`lib/core/config/api_config.dart`** - Public configuration that imports from AppConfig

## What Goes in `app_config.dart` (Sensitive)

- **API URLs** (baseUrl for different environments)
- **API Keys** and tokens
- **Secret keys** and credentials
- **OAuth client IDs/secrets**
- **Third-party service credentials**
- Any environment-specific sensitive data

## What Goes in `api_config.dart` (Public)

- **Timeout values** (connectTimeout, receiveTimeout, sendTimeout)
- **Default user IDs** for development
- **Public constants** that don't expose security risks
- **Feature flags** and non-sensitive settings

## Usage Pattern

**app_config.dart** (gitignored):
```dart
class AppConfig {
  static const String baseUrl = 'https://api.production.com';
  static const String apiKey = 'secret-key-here';
}
```

**api_config.dart** (public):
```dart
import '../../app_config.dart';

class ApiConfig {
  // Import sensitive values
  static const String baseUrl = AppConfig.baseUrl;
  static const String apiKey = AppConfig.apiKey;
  
  // Public non-sensitive values
  static const String userId = 'user123';
  static const int connectTimeout = 10000;
}
```

## Setup for New Developers

```bash
# Copy the example file
cp lib/app_config.example.dart lib/app_config.dart
# Edit lib/app_config.dart with actual values
```

## Important Rules

1. **NEVER commit `app_config.dart`** - it's in .gitignore
2. **Always update `app_config.example.dart`** when adding new sensitive fields
3. **Use placeholder values** in example file (e.g., 'YOUR_API_KEY_HERE')
4. **Document all fields** with comments explaining their purpose
5. **Keep sensitive data separate** - don't mix with public config
