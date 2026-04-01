---
inclusion: always
---

# Configuration Management

This project uses two different configuration patterns depending on the platform.

## Flutter Frontend (`dancee_app`)

**CRITICAL**: Sensitive configuration values MUST be stored in `config.dart`, which is excluded from version control.

### Configuration Files

- **`lib/config.dart`** - Contains ONLY sensitive values (in .gitignore, NOT committed)
- **`lib/config.example.dart`** - Template file (committed to git)
- **`lib/core/config.dart`** - Public configuration that imports from Config

### What Goes in `config.dart` (Sensitive - Gitignored)

- **API URLs** (baseUrl for different environments)
- **API Keys** and tokens
- **Secret keys** and credentials
- **OAuth client IDs/secrets**
- **Third-party service credentials**
- **Sentry DSN** and monitoring keys
- Any environment-specific sensitive data

### What Goes in `core/config.dart` (Public - Committed)

- **Timeout values** (connectTimeout, receiveTimeout, sendTimeout)
- **Default user IDs** for development
- **Public constants** that don't expose security risks
- **Feature flags** and non-sensitive settings
- **Imports from sensitive config** (re-exports sensitive values for use in app)

### Usage Pattern

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

### Setup for New Developers (Flutter)

```bash
cp lib/config.example.dart lib/config.dart
# Edit lib/config.dart with actual values
```

## Backend Services (`dancee_api`, `dancee_workflow`, `dancee_cms`)

Backend services use the standard `.env` pattern as defined in the global `env_configuration_standard` steering.

### Configuration Files

- **`.env`** - Contains actual secrets and configuration values (gitignored, NEVER committed)
- **`.env.example`** - Template with all keys and placeholder values (committed)

### Rules

1. **NEVER commit `.env`** — it's in .gitignore
2. **Always update `.env.example`** when adding or removing environment variables
3. **Keep `.env` and `.env.example` in sync** — same keys, same structure
4. Non-sensitive config can go in `fly.toml [env]` section for Fly.io deployments

### Setup for New Developers (Backend)

```bash
cp .env.example .env
# Edit .env with actual values
```

## Important Rules

1. **Flutter**: `lib/config.dart` (sensitive, gitignored) + `lib/core/config.dart` (public)
2. **Backend**: `.env` (sensitive, gitignored) + `.env.example` (template, committed)
3. **Never hardcode secrets** in source code
4. **Always provide templates** so new developers know which variables to set
5. **Import pattern (Flutter)**: `lib/core/config.dart` imports from `lib/config.dart` and re-exports for app use
