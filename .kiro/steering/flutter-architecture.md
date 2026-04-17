---
inclusion: manual
---

# Flutter Architecture Standards

## Project Structure Overview

Flutter projects follow a clean architecture pattern with clear separation of concerns:

```
lib/
├── core/                    # Shared utilities across features
│   ├── service_locator.dart # Dependency injection
│   ├── clients.dart         # API clients (or folder if multiple)
│   ├── config.dart          # Public configuration
│   ├── exceptions.dart      # Custom exceptions (or folder if multiple)
│   └── routing.dart         # App router
├── features/                # Feature modules
├── i18n/                    # Localization (slang)
├── design/                  # Shared design system
├── config.dart              # Sensitive configuration (gitignored)
└── config.example.dart      # Template for config.dart

assets/                      # Images, fonts, icons
test/                        # All test files
```

## Directory Structure Rules

### Single File = No Folder Rule

**CRITICAL**: If a directory would contain only ONE file, don't create the directory. Use a single file with the directory name instead.

**Examples:**
- ❌ `core/clients/api_client.dart` → ✅ `core/clients.dart`
- ❌ `logic/auth_cubit.dart` + `auth_state.dart` in separate folders → ✅ `logic/auth.dart` (both in one file)
- ❌ `design/theme/app_theme.dart` → ✅ `design/theme.dart`

### When to Create a Folder

Create a folder only when:
1. A file grows beyond ~500 lines
2. A page has sections AND components (needs multiple files)
3. There are multiple related files that need organization

### Pages Structure Rules

- **Simple page** (no sections/components, < 500 lines):
  - File: `pages/page_name.dart` directly in pages/
  - Example: `pages/event_filters_page.dart`

- **Complex page** (has sections/components OR > 500 lines):
  - Folder: `pages/page_name/` with:
    - `page_name_page.dart`
    - `sections.dart` (all sections in one file)
    - `components.dart` (all components in one file)
  - Example: `pages/event_list/event_list_page.dart`, `sections.dart`, `components.dart`

### Data Layer Rules

Combine multiple small related classes into one file:
- ❌ `entities/event.dart`, `entities/venue.dart`, etc. in separate files
- ✅ `entities.dart` (all entities in one file)

**No DTOs or Models by default.** Entities handle JSON conversion directly via `fromJson`/`toJson`. Only create DTOs or Models when there is a genuine structural mismatch between API response and domain object, or when database persistence requires a different schema. In most cases, a single Entity class is sufficient.

### Logic Layer Rules

Combine Cubit + State into one file:
- ❌ `logic/event_list/event_list_cubit.dart` + `event_list_state.dart` in folder
- ✅ `logic/event_list.dart` (both Cubit and State in one file)

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
- Examples: `AppLayout`, `AuthLayout`

## Core Architecture

### Core Directory Structure

```
lib/core/
├── service_locator.dart # Dependency injection (moved from lib/di/)
├── clients.dart         # API clients (or folder if multiple clients)
├── config.dart          # Public configuration
├── exceptions.dart      # Custom exceptions (or folder if multiple)
├── routing.dart         # App router
├── utils.dart           # Utility functions (or folder if multiple)
└── constants.dart       # App-wide constants (or folder if multiple)
```

### What Goes in Core

- Dependency injection setup (service_locator.dart)
- Universal configs shared between features
- API/HTTP clients
- Custom exceptions
- Shared utilities
- App-wide constants and enums

## Design System

### Design Directory Structure

```
lib/design/
├── widgets.dart         # Shared widgets (or folder if multiple)
├── components.dart      # Shared components (or folder if multiple)
├── theme.dart           # Color themes, text styles
├── colors.dart          # Color constants
└── typography.dart      # Font definitions
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
│   ├── entities.dart        # All domain entities in one file (with fromJson/toJson)
│   └── <feature>_repository.dart
├── pages/
│   ├── <simple_page>.dart   # Simple pages directly in pages/
│   └── <complex_page>/      # Complex pages in folders
│       ├── <page>_page.dart
│       ├── sections.dart    # All sections in one file
│       └── components.dart  # All components in one file
├── logic/
│   ├── <cubit_name>.dart    # Cubit + State in one file
│   └── ...
└── constants.dart           # Feature-specific constants (optional)
```

**Note:** No separate DTOs or Models directories. Entities handle JSON serialization directly. Only add `dtos.dart` or `models.dart` when there is a genuine structural mismatch that justifies a separate class.

### Common Features

- **app**: Core app functionality (initial page, redirects, layouts)
- **auth**: Authentication (login, registration, password reset, route guards)
- **settings**: User settings and preferences
- **payment**: Payment processing
- **[custom]**: Other domain-specific features

## Data Layer

### Data Models

**Entities only by default.** Each feature has a single `entities.dart` file containing all domain entities with `fromJson`/`toJson` methods.

- **Entities** - Domain objects with JSON serialization, used everywhere in the app. Entity class names do NOT use an `Entity` suffix (e.g., `Event`, `Venue`, `User` — not `EventEntity`, `VenueEntity`, `UserEntity`).
- **DTOs** - Only when API response structure differs significantly from domain model (rare)
- **Models** - Only when local database persistence requires a different schema (rare)

### Repository Pattern

**Location**: `lib/features/<feature>/data/<feature>_repository.dart`

**Responsibilities**:
- Fetch data from API (receives `Map<String, dynamic>`)
- Convert JSON maps to entities via `Entity.fromJson()`
- Return entities
- Handle data validation
- Throw exceptions on errors

**Data Source Pattern**:

```dart
// API only (default)
class EventRepository {
  final ApiClient _apiClient;
  
  EventRepository(this._apiClient);
  
  Future<List<Event>> getAllEvents() async {
    final response = await _apiClient.get('/api/events/list');
    return (response as List)
        .map((json) => Event.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
```

**Return Types**: Always entity or `List<entity>`

**Error Handling**: Validate data and throw custom exceptions

```dart
Future<User> getUser(String id) async {
  try {
    final json = await _apiClient.get('/api/users/$id');
    return User.fromJson(json as Map<String, dynamic>);
  } catch (e) {
    throw ApiException(message: 'Failed to fetch user', originalError: e);
  }
}
```

## State Management

### Bloc/Cubit Pattern

**Location**: `lib/features/<feature>/logic/`

**Files**:
- `<cubit_name>.dart` - Cubit + State in ONE file (use freezed for state)

**Example Structure:**
```dart
// lib/features/auth/logic/auth.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';

// State definition
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.error(String message) = AuthError;
}

// Cubit implementation
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  
  AuthCubit(this._repository) : super(const AuthState.initial());
  
  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    try {
      final user = await _repository.login(email, password);
      emit(AuthState.authenticated(user));
    } on InvalidCredentialsException {
      emit(AuthState.error(t.auth.invalidCredentials));
    } on NetworkException {
      emit(AuthState.error(t.common.networkError));
    }
  }
}
```

**Cubit Responsibilities**:
- Call repository methods
- Receive entities from repository
- Store entities in state
- Catch repository exceptions
- Display appropriate errors to user

## Routing

### Go Router

**Package**: `go_router` with `go_router_builder` for type-safe route generation

**Route Definition**: Define routes directly in each page file using `@TypedGoRoute` annotation

**CRITICAL**: All routes MUST use `NoTransitionPage` by default (no page transition animations). Override `buildPage` instead of `build`.

```dart
// lib/features/auth/pages/login/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'login_page.g.dart';

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: LoginPage());
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

**Route with Parameters**:

```dart
@TypedGoRoute<EventDetailRoute>(path: '/event/:id')
class EventDetailRoute extends GoRouteData {
  final String id;

  const EventDetailRoute({required this.id});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(child: EventDetailPage(eventId: id));
  }
}
```

**Router Configuration**: Create `lib/core/routing.dart`

```dart
import 'package:go_router/go_router.dart';

// Import all route files
import '../features/auth/pages/login/login_page.dart';
import '../features/events/pages/event_list/event_list_page.dart';
// ... other imports

final goRouter = GoRouter(
  routes: $appRoutes, // Generated by go_router_builder
  errorBuilder: (context, state) => const NotFoundPage(),
  redirect: (context, state) {
    // Authentication guard logic
    final isAuthenticated = false; // Get from auth state
    
    if (!isAuthenticated && state.matchedLocation == '/settings') {
      return '/login';
    }
    
    return null; // No redirect
  },
);
```

**Shell Routes for Layouts**:

```dart
@TypedShellRoute<AppLayoutRoute>(
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<EventListRoute>(path: '/events'),
    TypedGoRoute<FavoritesRoute>(path: '/favorites'),
  ],
)
class AppLayoutRoute extends ShellRouteData {
  const AppLayoutRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AppLayout(child: navigator);
  }
}
```

**Navigation**:

**CRITICAL**: Never use string-based paths for navigation. Always use the generated route classes and their extension methods.

```dart
// ✅ CORRECT — type-safe navigation via generated extensions
const EventListRoute().go(context);
const LoginRoute().push(context);
const EventDetailRoute(id: '123').go(context);

// ❌ WRONG — hardcoded string paths
context.go('/events');
context.push('/login');
context.go('/events/123');
```

**Import rules for route extensions**:
- Routes defined with `@TypedGoRoute` directly on the class: import the page file (e.g., `login_page.dart`)
- Routes defined inside `@TypedShellRoute` (e.g., `EventListRoute`, `FavoritesRoute`): import both the shell route file (`layouts.dart`) for the `.go()` extension AND the page file for the class itself

**Error Pages**: Define in `lib/features/app/pages/`

Examples: `NotFoundPage`, `ErrorPage`, `NetworkErrorPage`

## Dependency Injection

### Setup

**Package**: `get_it`

**Location**: `lib/core/service_locator.dart`

**Initialization**: Call setup function in `main.dart`

```dart
// lib/core/service_locator.dart
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

**Sensitive Config File**: `lib/config.dart` (gitignored - ONLY sensitive data)
**Template File**: `lib/config.example.dart` (committed)
**Public Config File**: `lib/core/config.dart` (committed - all non-sensitive config)

```dart
// lib/config.dart (NOT committed - ONLY sensitive values)
class Config {
  static const String apiBaseUrl = 'https://api.production.com';
  static const String sentryDsn = 'your-sentry-dsn';
  static const String apiKey = 'your-api-key';
}

// lib/config.example.dart (committed as template)
class Config {
  static const String apiBaseUrl = 'YOUR_API_URL_HERE';
  static const String sentryDsn = 'YOUR_SENTRY_DSN_HERE';
  static const String apiKey = 'YOUR_API_KEY_HERE';
}

// lib/core/config.dart (committed - public config + imports from Config)
import '../config.dart';

class AppConfig {
  // Import sensitive values
  static const String apiBaseUrl = Config.apiBaseUrl;
  static const String apiKey = Config.apiKey;
  static const String sentryDsn = Config.sentryDsn;
  
  // Public non-sensitive values
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
  static const bool enableLogging = true;
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

**Usage**: Inject into repositories via ApiClient wrapper

```dart
class EventRepository {
  final ApiClient _apiClient;
  
  EventRepository(this._apiClient);
  
  Future<List<Event>> getEvents() async {
    final response = await _apiClient.get('/api/events');
    return (response as List)
        .map((json) => Event.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
```

## Database

### Database Selection

**Default**: No database (API only) unless specified

**Common Options**: Hive, Drift, SQLite, ObjectBox

**Location**: If needed, models in `lib/features/<feature>/data/models.dart`

**Caching Strategy**: Defined per project (cache-first, network-first, etc.)

**Note**: Only create Model classes when you actually have a local database. Don't create them preemptively.

## Code Generation

### Build Runner

**Packages**:
- `go_router_builder` - Route generation
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
3. Create `data/entities.dart` with all entities (including `fromJson`/`toJson`)
4. Create repository: `data/<feature>_repository.dart`
5. Create cubit: `logic/<cubit_name>.dart` (Cubit + State in one file)
6. Create pages: `pages/<page_name>.dart` (simple) or `pages/<page_name>/` (complex with sections/components)
7. Add route definition: `@TypedGoRoute` with `GoRouteData` class in page file
8. Register in DI: Add to `core/service_locator.dart`
9. Run code generation: `task build-runner`

### Creating a New Page

1. **Simple page** (no sections/components):
   - Create: `lib/features/<feature>/pages/<page_name>.dart`
   - Add `@TypedGoRoute` and route class
   - Add `part '<page_name>.g.dart';` directive

2. **Complex page** (with sections/components):
   - Create directory: `lib/features/<feature>/pages/<page_name>/`
   - Create: `<page_name>_page.dart` with `@TypedGoRoute` and route class
   - Create: `sections.dart` (all sections in one file)
   - Create: `components.dart` (all components in one file)
   - Add `part '<page_name>_page.g.dart';` directive

3. Run route generation: `task build-runner`

### Data Flow

```
UI (Page/Section/Component)
  ↓ user action
Cubit
  ↓ call method
Repository
  ↓ fetch data
API Client
  ↓ return Map<String, dynamic>
Repository (converts to entity via fromJson)
  ↓ return entity
Cubit (stores in state)
  ↓ emit new state
UI (rebuilds with new data)
```

## Remember

- **Single file = no folder rule** - If only one file would be in a folder, use a single file instead
- **Every UI element is its own class** - no private build methods
- **Entities only by default** - no separate DTOs or Models unless genuinely needed
- **Entity has fromJson/toJson** - handles JSON serialization directly
- **Entity class names have NO `Entity` suffix** - use `Event`, `Venue`, `User` (not `EventEntity`, `VenueEntity`, `UserEntity`)
- **Repository receives Map, returns entity** - converts via `Entity.fromJson()`
- **Cubit catches exceptions** - and displays user-friendly errors
- **Use slang for all user-facing text** - never hardcode strings
- **Prefix files with feature name** - `auth_repository.dart`, not `repository.dart`
- **One global API client** - unless specified otherwise
- **No database by default** - API only unless specified
- **Route definitions in page files** - using @TypedGoRoute with GoRouteData
- **Type-safe navigation only** - always use `const SomeRoute().go(context)`, never `context.go('/path')`
- **Error pages in app feature** - for 404, network errors, etc.
- **Combine related files** - entities.dart (all entities), cubit+state in one file
- **Simple pages directly in pages/** - only create folder if page has sections/components
- **Config separation** - `lib/config.dart` (sensitive, gitignored), `lib/core/config.dart` (public)
- **DI in core/** - `lib/core/service_locator.dart` (moved from lib/di/)
