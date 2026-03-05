---
inclusion: always
---

# Kiro AI Guide - Dancee App

## Project Overview

Dancee App is a Flutter-based mobile and web application for dance enthusiasts. The project is structured as a multi-platform application supporting Android, iOS, and web platforms.

## Project Structure

```
├── frontend/
│   └── dancee_app/          # Main Flutter application
│       ├── lib/             # Dart source code
│       ├── android/         # Android-specific files
│       ├── ios/             # iOS-specific files
│       ├── web/             # Web-specific files
│       ├── test/            # Test files
│       ├── taskfile.yaml    # Task automation file
│       └── pubspec.yaml     # Flutter dependencies
└── backend/
    ├── dancee_api/          # TypeScript API Gateway (Express)
    ├── dancee_events/       # Go events service
    ├── dancee_scraper/      # TypeScript scraping service
    ├── dancee_event_service/ # Dart backend service (REST API)
    └── dancee_server/       # NestJS backend service (Node.js/TypeScript)
        ├── src/             # TypeScript source code
        ├── docs/            # Documentation files
        ├── test/            # Test files
        ├── taskfile.yaml    # Task automation file
        └── package.json     # Node.js dependencies
```

## Backend Services

The project includes two backend services:

### 🎯 dancee_event_service (Dart)
- **Technology**: Dart with shelf framework
- **Purpose**: REST API for event data management
- **Location**: `backend/dancee_event_service/`
- **Port**: Configurable (typically 8080)

### 🚀 dancee_server (NestJS)
- **Technology**: Node.js with NestJS framework (TypeScript)
- **Purpose**: Web scraping and data collection service
- **Location**: `backend/dancee_server/`
- **Port**: 3001 (default)
- **Key Features**:
  - Facebook event scraping
  - RESTful API endpoints
  - Swagger/OpenAPI documentation
  - CORS enabled for frontend communication

#### dancee_server Structure:
```
backend/dancee_server/
├── src/
│   ├── scraper/           # Scraper module
│   │   ├── dto/          # Data Transfer Objects
│   │   ├── scraper.controller.ts
│   │   ├── scraper.service.ts
│   │   └── scraper.module.ts
│   ├── app.controller.ts  # Main controller
│   ├── app.module.ts      # Root module
│   ├── app.service.ts     # Business logic
│   └── main.ts           # Application entry point
├── docs/                  # Documentation files (REQUIRED)
├── test/                  # Test files
├── taskfile.yaml         # Task automation
└── package.json          # Dependencies
```

#### dancee_server Task Commands:
```bash
task install      # Install dependencies
task dev          # Start development server with hot reload
task start        # Start production server
task build        # Build the application
task lint         # Run linter
task format       # Format code with prettier
task test         # Run tests
task test-watch   # Run tests in watch mode
task test-e2e     # Run end-to-end tests
task clean        # Clean build artifacts
```

#### dancee_server API Documentation:
- **Swagger UI**: Available at `http://localhost:3001/api`
- **Interactive testing**: Test endpoints directly from browser
- **Complete schemas**: Request/response documentation
- **Examples**: Sample requests and responses

For detailed information, see:
- `backend/dancee_server/README.md` - Main documentation
- `backend/dancee_server/docs/SWAGGER.md` - Swagger setup guide
- `backend/dancee_server/docs/EXAMPLES.md` - Usage examples

## Critical Development Guidelines for Kiro AI

### � Documentation Requirements

**CRITICAL**: All documentation files MUST follow strict organizational rules.

#### Documentation File Placement:

**For ALL backend services (`dancee_server`, `dancee_event_service`):**
- ✅ **All documentation files** MUST be placed in the `docs/` folder
- ✅ **Exception**: Only `README.md` can be in the root directory
- ❌ **Never** place documentation files (`.md`) in the root except `README.md`

**Examples:**
```
✅ CORRECT:
backend/dancee_server/README.md              # Root README only
backend/dancee_server/docs/SWAGGER.md        # Documentation in docs/
backend/dancee_server/docs/EXAMPLES.md       # Documentation in docs/
backend/dancee_server/docs/QUICK_START.md    # Documentation in docs/

❌ WRONG:
backend/dancee_server/SWAGGER.md             # Should be in docs/
backend/dancee_server/API_GUIDE.md           # Should be in docs/
backend/dancee_server/SETUP.md               # Should be in docs/
```

#### Documentation Standards:
1. **README.md** - Overview, quick start, basic usage (root only)
2. **docs/** folder - All other documentation:
   - Setup guides
   - API documentation
   - Examples and tutorials
   - Troubleshooting guides
   - Architecture documentation
   - Deployment guides

#### When Creating New Documentation:
1. **Check if it's a README** - If yes, place in root
2. **All other docs** - Place in `docs/` folder
3. **Create docs/ folder** if it doesn't exist
4. **Use descriptive names** - `SWAGGER.md`, `EXAMPLES.md`, `DEPLOYMENT.md`
5. **Link from README** - Reference docs from main README.md

### 🌐 Internationalization (i18n) Requirements

**CRITICAL**: The app supports multiple languages and ALL user-facing strings MUST be translated.

#### Supported Languages:
- **English (en)** - Base locale
- **Czech (cs)** - Primary target audience
- **Spanish (es)** - Additional language

#### Localization System:
The app uses **slang_flutter** for type-safe translations.

**NEVER hardcode user-facing strings in code!**

❌ **WRONG:**
```dart
Text('Events')  // Hardcoded string
Text('${count} events')  // Hardcoded with interpolation
```

✅ **CORRECT:**
```dart
Text(t.events)  // Using slang translation
Text(t.eventsCount(count: count))  // With parameters
```

#### Adding New Translations:

1. **Add to all language files** in `lib/i18n/`:
   - `strings.i18n.json` (English - base)
   - `strings_cs.i18n.json` (Czech)
   - `strings_es.i18n.json` (Spanish)

2. **Simple string:**
```json
{
  "myNewKey": "My new text"
}
```

3. **String with parameters** (use `{paramName}` syntax):
```json
{
  "welcomeUser": "Welcome, {name}!",
  "itemCount": "{count} items"
}
```

4. **Generate translations:**
```bash
task slang
```

5. **Use in code:**
```dart
import '../i18n/translations.g.dart';

// Simple string
Text(t.myNewKey)

// With parameters (named parameters required)
Text(t.welcomeUser(name: userName))
Text(t.itemCount(count: items.length))
```

#### Translation Tasks:
- `task slang` - Generate translations from JSON files
- `task slang-watch` - Auto-regenerate on file changes (use during development)
- `task slang-analyze` - Check for missing translation keys

#### Important Rules:
1. **Always add translations to ALL language files** (en, cs, es)
2. **Never hardcode user-facing strings** in Dart code
3. **Use named parameters** for parameterized strings: `t.method(param: value)`
4. **Run `task slang`** after modifying translation files
5. **Import translations**: `import '../i18n/translations.g.dart';`
6. **Access via global `t`**: No need for `context` or `of(context)`

#### Common Mistakes to Avoid:
❌ Hardcoding strings: `Text('Hello')`
❌ Missing language: Only adding to English file
❌ Wrong parameter syntax: `t.eventsCount(5)` instead of `t.eventsCount(count: 5)`
❌ Forgetting to regenerate: Not running `task slang` after changes
❌ Using old system: `AppLocalizations.of(context)` (deprecated)

### 🔐 Sensitive Configuration Management

**CRITICAL**: Sensitive configuration values MUST be stored in `app_config.dart`, which is excluded from version control.

#### Configuration Files:
- **`lib/app_config.dart`** - Contains sensitive values (in .gitignore, NOT committed)
- **`lib/app_config.example.dart`** - Template file (committed to git)
- **`lib/core/config/api_config.dart`** - Public configuration that imports from AppConfig

#### What Goes in `app_config.dart` (Sensitive):
- **API URLs** (baseUrl for different environments)
- **API Keys** and tokens
- **Secret keys** and credentials
- **OAuth client IDs/secrets**
- **Third-party service credentials**
- Any environment-specific sensitive data

#### What Goes in `api_config.dart` (Public):
- **Timeout values** (connectTimeout, receiveTimeout, sendTimeout)
- **Default user IDs** for development
- **Public constants** that don't expose security risks
- **Feature flags** and non-sensitive settings

#### Usage Pattern:

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

#### Setup for New Developers:
```bash
# Copy the example file (Linux/WSL)
cp lib/app_config.example.dart lib/app_config.dart
# Edit lib/app_config.dart with actual values
```

#### Important Rules:
1. **NEVER commit `app_config.dart`** - it's in .gitignore
2. **Always update `app_config.example.dart`** when adding new sensitive fields
3. **Use placeholder values** in example file (e.g., 'YOUR_API_KEY_HERE')
4. **Document all fields** with comments explaining their purpose
5. **Keep sensitive data separate** - don't mix with public config

### �️ Task ManagementD

This project uses **Taskfile** for automation. Always use tasks instead of direct Flutter commands when suggesting or running commands:

#### Essential Tasks:
- `task run-web` - Run app on web (port 3000)
- `task run-android` - Run app on Android device/emulator
- `task run-ios` - Run app on iOS device/simulator
- `task get-deps` - Install Flutter dependencies
- `task clean` - Clean project

#### Build Tasks:
- `task build-web` - Build for web production
- `task build-android` - Build APK for Android
- `task build-ios` - Build for iOS

#### Code Generation:
- `task build-runner` - Run build runner for code generation
- `task build-runner-force` - Run with delete conflicting outputs
- `task build-runner-watch` - Run in watch mode
- `task build-runner-clean` - Clean generated files

#### Translation Tasks:
- `task slang` - Generate translations from JSON files
- `task slang-watch` - Watch and auto-regenerate translations
- `task slang-analyze` - Analyze translations for missing keys

### 📱 Platform Support

The app supports three platforms:
1. **Web** - Progressive web app
2. **Android** - Native Android application
3. **iOS** - Native iOS application

### 🔧 Development Workflow for Kiro AI

When working with this project:

1. **Setup**: Always suggest `task get-deps` to install dependencies
2. **Development**: Recommend `task run-web` for quick testing
3. **Code Generation**: Use `task build-runner-watch` when working with generated code
4. **Translations**: Use `task slang-watch` when working with translations
5. **Testing**: Suggest testing on multiple platforms when relevant
6. **Build**: Use appropriate build tasks for production builds

### 📋 Code Standards for AI

When generating or modifying code:
- Follow Flutter/Dart conventions strictly
- Use meaningful English variable and function names
- Add English comments for complex logic
- Ensure cross-platform compatibility
- Use proper state management patterns
- Never use Czech language in any code elements
- **ALWAYS use slang translations for user-facing strings** - never hardcode text
- **Add translations to ALL language files** (en, cs, es) when creating new strings
- **Run `task slang`** after modifying translation files

### 🚨 Before Making Changes

As Kiro AI, always:
1. Check current taskfile.yaml for available commands
2. **Ensure all user-facing strings use slang translations** (never hardcode)
3. **Add translations to ALL language files** when creating new strings
4. **Store sensitive values in `app_config.dart`** (API URLs, keys, tokens)
5. Consider cross-platform implications
6. Use build runner tasks for code generation needs
7. **Run `task slang`** after modifying translation files
8. Suggest appropriate task commands instead of direct Flutter commands
9. **Place documentation in `docs/` folder** (except README.md)

### 📞 Quick Commands Reference

When suggesting commands to users:

**Frontend (Flutter):**
```bash
# Start development
task get-deps
task run-web

# Code generation
task build-runner-watch

# Translations
task slang              # Generate translations
task slang-watch        # Auto-regenerate translations
task slang-analyze      # Check for missing keys

# Build for production
task build-web
task build-android
task build-ios
```

**Backend - dancee_server (NestJS):**
```bash
# Start development
task install
task dev                # Development with hot reload

# Code quality
task lint
task format

# Testing
task test
task test-watch
task test-e2e

# Build for production
task build
task start
```

**Backend - dancee_event_service (Dart):**
```bash
# Start development
task get-deps
task run

# Testing
task test
```

### 🤖 AI-Specific Instructions

- **CRITICAL: Never hardcode user-facing strings** - always use slang translations
- **When adding new UI text**: Add to all 3 language files (en, cs, es) and run `task slang`
- **Store sensitive config in `app_config.dart`**: API URLs, keys, tokens, credentials
- Utilize taskfile commands in all suggestions
- Consider Flutter best practices and cross-platform compatibility
- When creating new files, ensure they follow the project structure
- Suggest appropriate testing strategies for multi-platform development
- Be aware of Flutter-specific patterns and state management approaches
- **Import translations**: Always include `import '../i18n/translations.g.dart';` in UI files
- **Use global `t` variable** for translations: `t.keyName` or `t.method(param: value)`
- **Never commit sensitive values** - always use `app_config.dart` for environment-specific data
- **Documentation placement**: All docs in `docs/` folder except `README.md`
- **Use appropriate backend**: `dancee_server` for scraping/external APIs, `dancee_event_service` for event data management
- **NestJS conventions**: Follow NestJS patterns for `dancee_server` (modules, controllers, services, DTOs)
- **TypeScript best practices**: Use proper typing, interfaces, and decorators in `dancee_server`

Remember: This guide ensures consistency and maintainability for international development teams working on the Dancee App project.