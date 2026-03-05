---
inclusion: always
---

# Flutter Architecture Standards

## Project Structure Overview

Flutter projects follow a clean architecture pattern with clear separation of concerns:

```
lib/
├── core/                    # Shared utilities across features
├── features/                # Feature modules
├── i18n/                    # Localization (slang)
├── design/                  # Shared design system
└── config.dart             # Environment configuration (gitignored)

assets/                      # Images, fonts, icons
test/                        # All test files
```

## UI Component Hierarchy

### Component Types (from largest to smallest)

1. **Pages** - Complete application screens
2. **Sections** - Major sections within a page
3. **Components** - Complex, app-specific UI elements within sections
4. **Widgets** - Simple, reusable UI elements

### Hierarchy Rules

- **Pages** are composed of **Sections**
- **Sections** are composed of **Components** and **Widgets**
- **Components** are composed of **Widgets** (custom or Flutter built-in)
- **Widgets** are simple, reusable elements (buttons, text fields, sliders)

### Component Complexity

- **Components**: More complex, app-specific functionality
- **Widgets**: Simpler, more generic, highly reusable

### Class Creation Rule

**CRITICAL**: Every widget, component, section, and page MUST be its own class.

❌ **NEVER** create private methods that define UI appearance
✅ **ALWAYS** create a new class instead

```dart
// ❌ WRONG - Private method for UI
class LoginPage extends StatelessWidget {
  Widget _buildLoginButton() {
    return ElevatedButton(...);
  }
}

// ✅ CORRECT - Separate class
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginButton();
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(...);
  }
}
```

## Layouts

**Layouts** are shared UI structures used across multiple pages (e.g., headers, footers, navigation bars).

- Location: `lib/features/app/layouts/`
- Examples: `AppLayout`, `AuthLayout`, `MainLayout`

## Core Architecture

### Core Directory Structure

```
lib/core/
├── config/              # App-wide configuration
├── clients/             # HTTP clients, API clients
├── exceptions/          # Custom exceptions
├── utils/               # Utility functions
├── constants/           # App-wide constants
└── di/                  # Dependency injection setup
```

### What Goes in Core

- Universal configs shared between features
- API/HTTP clients
- Custom exceptions
- Shared utilities
- App-wide constants and enums
- DI initialization function

## Design System

### Design Directory Structure

```
lib/design/
├── widgets/             # Shared widgets
├── components/          # Shared components
├── theme/               # Color themes, text styles
├── colors/              # Color constants
└── typography/          # Font definitions
```

### What Goes in Design

- Widgets and components shared between features
- Color themes and constants
- Typography (fonts, text styles)
- Design tokens
- Shared UI elements

## Features Architecture

### Feature Directory Structure

Each feature follows clean architecture:

```
lib/features/<feature_name>/
├── data/
│   ├── entities/        # Domain entities (app-level models)
│   ├── models/          # Database models
│   ├── dtos/            # API data transfer objects
│   └── <feature>_repository.dart
├── pages/
│   ├── <page_name>/
│   │   ├── <page_name>_page.dart
│   │   ├── sections/    # Page sections
│   │   └── components/  # Page-specific components
│   └── ...
├── logic/
│   ├── <feature>_cubit.dart
│   ├── <feature>_state.dart
│   └── ...
└── constants/           # Feature-specific constants (optional)
```

### Common Features

- **app**: Core app functionality (initial page, redirects, layouts)
- **auth**: Authentication (login, registration, password reset, route guards)
- **settings**: User settings and preferences
- **payment**: Payment processing
- **[custom]**: Other domain-specific features

## Data Layer

### Data Models

Three types of data models, all in `features/<feature>/data/`:

1. **DTOs** (`dtos/`) - API communication
2. **Models** (`models/`) - Database persistence
3. **Entities** (`entities/`) - Application domain logic

### Repository Pattern

**Location**: `lib/features/<feature>/data/<feature>_repository.dart`

**Responsibilities**:
- Abstract data source (API, DB, or both)
- Return entities (never DTOs or Models)
- Handle data validation
- Throw exceptions on errors

**Data Source Patterns**:

```dart
// API only (default)
class AuthRepository {
  final Dio _httpClient;
  
  Future<UserEntity> login(String email, String password) async {
    final dto = await _httpClient.post(...);
    return UserEntity.fromDto(dto);
  }
}

// Database only
class SettingsRepository {
  final Database _db;
  
  Future<SettingsEntity> getSettings() async {
    final model = await _db.query(...);
    return SettingsEntity.fromModel(model);
  }
}

// Both API and DB (with custom logic)
class EventRepository {
  final Dio _httpClient;
  final Database _db;
  
  Future<List<EventEntity>> getEvents() async {
    // Custom logic: cache-first, network-first, etc.
    try {
      final cached = await _db.getEvents();
      if (cached.isNotEmpty) return cached.map((m) => EventEntity.fromModel(m)).toList();
    } catch (_) {}
    
    final dtos = await _httpClient.get(...);
    return dtos.map((dto) => EventEntity.fromDto(dto)).toList();
  }
}
```

**Return Types**: Always `Entity` or `List<Entity>`

**Error Handling**: Validate data and throw custom exceptions

```dart
Future<UserEntity> getUser(String id) async {
  try {
    final dto = await _httpClient.get('/users/$id');
    if (dto.email == null) {
      throw InvalidDataException('User email is required');
    }
    return UserEntity.fromDto(dto);
  } catch (e) {
    throw RepositoryException('Failed to fetch user', e);
  }
}
```

## State Management

### Bloc/Cubit Pattern

**Location**: `lib/features/<feature>/logic/`

**Files**:
- `<feature>_cubit.dart` - Business logic
- `<feature>_state.dart` - State definitions (use freezed)

**Cubit Responsibilities**:
- Call repository methods
- Receive entities from repository
- Store entities in state
- Catch repository exceptions
- Display appropriate errors to user

```dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  
  AuthCubit(this._repository) : super(AuthState.initial());
  
  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = await _repository.login(email, password);
      emit(state.copyWith(user: user, isLoading: false));
    } on InvalidCredentialsException catch (e) {
      emit(state.copyWith(error: t.auth.invalidCredentials, isLoading: false));
    } on NetworkException catch (e) {
      emit(state.copyWith(error: t.common.networkError, isLoading: false));
    }
  }
}
```

## Routing

### Auto Route

**Package**: `auto_route` with automatic route generation

**Route Definition**: Define routes at each page using `@RoutePage()` annotation

```dart
@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

**Route Guards**: Define in `lib/features/auth/` for authentication checks

```dart
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (isAuthenticated) {
      resolver.next();
    } else {
      router.push(LoginRoute());
    }
  }
}
```

**Error Pages**: Define in `lib/features/app/pages/`

Examples: `NotFoundPage`, `ErrorPage`, `NetworkErrorPage`

## Dependency Injection

### Setup

**Package**: `get_it`

**Location**: `lib/core/di/service_locator.dart` (or similar)

**Initialization**: Call setup function in `main.dart`

```dart
// lib/core/di/service_locator.dart
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register global API client (default)
  getIt.registerLazySingleton<Dio>(() => Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
  )));
  
  // Register repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<Dio>()),
  );
  
  // Register cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );
}

// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(MyApp());
}
```

**Global API Client**: One Dio instance registered in DI (unless specified otherwise)

## Configuration Management

### Environment Configuration

**File**: `lib/config.dart` (gitignored)
**Template**: `lib/config.example.dart` (committed)

```dart
// lib/config.dart (NOT committed)
class AppConfig {
  static const String apiBaseUrl = 'https://api.production.com';
  static const String sentryDsn = 'your-sentry-dsn';
  static const String apiKey = 'your-api-key';
}

// lib/config.example.dart (committed as template)
class AppConfig {
  static const String apiBaseUrl = 'YOUR_API_URL_HERE';
  static const String sentryDsn = 'YOUR_SENTRY_DSN_HERE';
  static const String apiKey = 'YOUR_API_KEY_HERE';
}
```

**Setup for new developers**:
```bash
cp lib/config.example.dart lib/config.dart
# Edit lib/config.dart with actual values
```

## Error Handling & Monitoring

### Sentry Integration

**Package**: `sentry_flutter`

**Usage**: Log errors and crashes to Sentry

```dart
void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

**Error Pages**: Located in `lib/features/app/pages/`

## Internationalization

### Slang

**Package**: `slang_flutter`

**Location**: `lib/i18n/`

**Usage**: See existing i18n steering file for complete guidelines

## HTTP Requests

### Dio

**Package**: `dio`

**Setup**: One global Dio instance in DI (default)

**Usage**: Inject into repositories

```dart
class EventRepository {
  final Dio _httpClient;
  
  EventRepository(this._httpClient);
  
  Future<List<EventEntity>> getEvents() async {
    final response = await _httpClient.get('/events');
    return (response.data as List)
        .map((json) => EventEntity.fromJson(json))
        .toList();
  }
}
```

## Database

### Database Selection

**Default**: No database (API only) unless specified

**Common Options**: Hive, Drift, SQLite, ObjectBox

**Location**: Models in `lib/features/<feature>/data/models/`

**Caching Strategy**: Defined per project (cache-first, network-first, etc.)

## Code Generation

### Build Runner

**Packages**:
- `auto_route_generator` - Route generation
- `slang` - Translation generation
- `freezed` - Immutable models
- `json_serializable` - JSON serialization

**Commands**:
```bash
task build-runner          # Generate code
task build-runner-watch    # Watch mode
task build-runner-force    # Delete conflicting outputs
```

## Naming Conventions

### Files

**Format**: `snake_case`
**Prefix**: Always start with feature name

Examples:
- `auth_repository.dart`
- `auth_cubit.dart`
- `auth_state.dart`
- `login_page.dart`
- `login_section.dart`
- `login_button.dart`

### Classes

**Format**: `PascalCase`

**Suffixes**:
- Pages: `LoginPage`, `SettingsPage`
- Sections: `LoginFormSection`, `HeaderSection`
- Components: `LoginForm`, `LoginFormComponent` (optional suffix)
- Widgets: `LoginButton`, `LoginButtonWidget` (optional suffix)

**Widget vs Component Suffix**:
- Widgets: Can have `Widget` suffix but not required
- Components: Can have `Component` suffix but not required
- Rule: Components are more complex than Widgets

### Variables

**Format**: `camelCase`

```dart
final userName = 'John';
final isLoggedIn = true;
final eventList = <Event>[];
```

## Assets Organization

### Structure

```
assets/
├── images/
├── icons/
├── fonts/
└── ...
```

**Location**: Same parent directory as `lib/` and `test/`

## Testing

### Test Structure

**Location**: `test/` directory (standard Flutter location)

**Structure**: Mirror `lib/` structure

```
test/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository_test.dart
│   │   └── logic/
│   │       └── auth_cubit_test.dart
│   └── ...
└── ...
```

## Task Automation

### Taskfile

**File**: `taskfile.yaml` in project root

**Common Tasks**:
- Build commands
- App store upload
- Code generation
- Testing
- Deployment

See `task-management.md` steering file for complete task reference.

## Quick Reference

### Creating a New Feature

1. Create feature directory: `lib/features/<feature_name>/`
2. Create subdirectories: `data/`, `pages/`, `logic/`
3. Create data models: `entities/`, `dtos/`, `models/` (as needed)
4. Create repository: `<feature>_repository.dart`
5. Create cubit: `logic/<feature>_cubit.dart` and `logic/<feature>_state.dart`
6. Create pages: `pages/<page_name>/<page_name>_page.dart`
7. Add route annotation: `@RoutePage()`
8. Register in DI: Add to `core/di/service_locator.dart`
9. Run code generation: `task build-runner`

### Creating a New Page

1. Create page directory: `lib/features/<feature>/pages/<page_name>/`
2. Create page file: `<page_name>_page.dart` with `@RoutePage()`
3. Create sections: `sections/<section_name>_section.dart`
4. Create components: `components/<component_name>.dart`
5. Use shared widgets from `lib/design/widgets/`
6. Run route generation: `task build-runner`

### Data Flow

```
UI (Page/Section/Component)
  ↓ user action
Cubit
  ↓ call method
Repository
  ↓ fetch data
API Client / Database
  ↓ return DTO/Model
Repository (converts to Entity)
  ↓ return Entity
Cubit (stores in state)
  ↓ emit new state
UI (rebuilds with new data)
```

## Remember

- **Every UI element is its own class** - no private build methods
- **Repository always returns entities** - never DTOs or Models
- **Cubit catches exceptions** - and displays user-friendly errors
- **Use slang for all user-facing text** - never hardcode strings
- **Prefix files with feature name** - `auth_repository.dart`, not `repository.dart`
- **One global API client** - unless specified otherwise
- **No database by default** - API only unless specified
- **Route guards in auth feature** - for authentication checks
- **Error pages in app feature** - for 404, network errors, etc.
