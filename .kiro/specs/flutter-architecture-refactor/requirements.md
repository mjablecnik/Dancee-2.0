# Requirements Document: Flutter Architecture Refactoring

## Introduction

This document defines the requirements for refactoring the Dancee App Flutter application from its current basic structure to a clean architecture pattern following the flutter-architecture.md standards. The refactoring will transform the existing `screens/`, `models/`, `cubits/`, and `widgets/` directories into a feature-based architecture with proper separation of concerns, routing, and a shared design system.

The current application has basic functionality (event list, favorites) but lacks proper architectural organization. This refactoring will establish a scalable foundation for future features while maintaining all existing functionality.

## Glossary

- **Flutter_App**: The Dancee App mobile and web application built with Flutter
- **Feature_Module**: A self-contained directory containing all code for a specific feature (data, pages, logic)
- **Data_Layer**: The layer containing entities, DTOs, models, and repositories
- **Presentation_Layer**: The layer containing pages, sections, components, and widgets
- **Logic_Layer**: The layer containing cubits and state management
- **Design_System**: Shared UI components, themes, and design tokens used across features
- **Core_Module**: Shared utilities, configurations, and services used across features
- **Repository**: A class that abstracts data sources and returns entities
- **Entity**: Domain model used in application logic
- **DTO**: Data Transfer Object used for API communication
- **Model**: Data model used for database persistence
- **Cubit**: State management class using the Bloc pattern
- **Auto_Route**: Flutter routing package for type-safe navigation
- **Page**: A complete application screen
- **Section**: A major section within a page
- **Component**: A complex, app-specific UI element
- **Widget**: A simple, reusable UI element
- **Event_Feature**: Feature module for dance event management
- **App_Feature**: Feature module for core app functionality (layouts, navigation, error pages)
- **Auth_Feature**: Feature module for authentication (login, registration)
- **Settings_Feature**: Feature module for user settings and preferences

## Requirements

### Requirement 1: Feature-Based Directory Structure

**User Story:** As a developer, I want the codebase organized by features, so that I can easily locate and maintain related code.

#### Acceptance Criteria

1. THE Flutter_App SHALL create a `lib/features/` directory containing all feature modules
2. THE Flutter_App SHALL organize each feature module with `data/`, `pages/`, and `logic/` subdirectories
3. THE Flutter_App SHALL remove the legacy `lib/screens/`, `lib/models/`, and `lib/cubits/` directories after migration
4. THE Flutter_App SHALL maintain the existing `lib/core/` directory for shared utilities
5. THE Flutter_App SHALL create a `lib/design/` directory for the shared design system

### Requirement 2: Event Feature Module

**User Story:** As a developer, I want all event-related code in a single feature module, so that event functionality is self-contained and maintainable.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `lib/features/events/` directory structure
2. THE Flutter_App SHALL move event models to `lib/features/events/data/entities/`
3. THE Flutter_App SHALL create `lib/features/events/data/dtos/` for API data transfer objects
4. THE Flutter_App SHALL move EventRepository to `lib/features/events/data/event_repository.dart`
5. THE Flutter_App SHALL move event cubits to `lib/features/events/logic/`
6. THE Flutter_App SHALL move event screens to `lib/features/events/pages/`
7. THE Flutter_App SHALL create sections and components within each page directory
8. THE Flutter_App SHALL ensure EventRepository returns Entity objects (not DTOs)
9. WHEN EventRepository fetches data from API, THE EventRepository SHALL convert DTOs to Entities before returning
10. THE Flutter_App SHALL maintain all existing event functionality (list, search, favorites, toggle)

### Requirement 3: App Feature Module

**User Story:** As a developer, I want core app functionality organized in an app feature, so that layouts, navigation, and error handling are centralized.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `lib/features/app/` directory structure
2. THE Flutter_App SHALL create `lib/features/app/layouts/` for shared layouts
3. THE Flutter_App SHALL move MainNavigationScreen to `lib/features/app/layouts/main_layout.dart`
4. THE Flutter_App SHALL create `lib/features/app/pages/initial_page.dart` as the app entry point
5. THE Flutter_App SHALL create error pages in `lib/features/app/pages/` (NotFoundPage, ErrorPage)
6. THE Flutter_App SHALL ensure layouts are reusable across multiple pages

### Requirement 4: Auth Feature Module

**User Story:** As a developer, I want authentication functionality organized in an auth feature, so that login and registration are properly structured.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `lib/features/auth/` directory structure
2. THE Flutter_App SHALL create `lib/features/auth/pages/login/` with login_page.dart
3. THE Flutter_App SHALL create `lib/features/auth/pages/register/` with register_page.dart
4. THE Flutter_App SHALL create sections and components based on .design/auth-login.html
5. THE Flutter_App SHALL create sections and components based on .design/auth-register.html
6. WHERE authentication is required, THE Flutter_App SHALL create route guards in `lib/features/auth/`
7. THE Flutter_App SHALL create placeholder implementations for auth pages (no backend integration required)

### Requirement 5: Settings Feature Module

**User Story:** As a developer, I want settings functionality organized in a settings feature, so that user preferences are properly structured.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `lib/features/settings/` directory structure
2. THE Flutter_App SHALL create `lib/features/settings/pages/settings/` with settings_page.dart
3. THE Flutter_App SHALL create sections and components based on .design/settings.html
4. THE Flutter_App SHALL create sections and components based on .design/settings-change.html
5. THE Flutter_App SHALL create placeholder implementations for settings pages (no backend integration required)

### Requirement 6: Data Layer Architecture

**User Story:** As a developer, I want proper separation between DTOs, Models, and Entities, so that data transformation is explicit and maintainable.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `entities/` subdirectory in each feature's data directory
2. THE Flutter_App SHALL create `dtos/` subdirectory in each feature's data directory
3. WHERE database persistence is needed, THE Flutter_App SHALL create `models/` subdirectory
4. THE Flutter_App SHALL ensure all repositories return Entity objects
5. THE Flutter_App SHALL create conversion methods between DTOs and Entities
6. THE Flutter_App SHALL ensure Event entity has fromDto factory constructor
7. THE Flutter_App SHALL ensure Event DTO has toEntity method
8. THE Flutter_App SHALL maintain Equatable for value equality in entities

### Requirement 7: Repository Pattern Implementation

**User Story:** As a developer, I want repositories to follow clean architecture principles, so that data access is consistent and testable.

#### Acceptance Criteria

1. THE Flutter_App SHALL place each repository in its feature's data directory
2. THE Flutter_App SHALL ensure repositories accept ApiClient via dependency injection
3. THE Flutter_App SHALL ensure repositories return Entity objects (never DTOs)
4. WHEN repository fetches data from API, THE Repository SHALL convert DTOs to Entities
5. WHEN repository encounters errors, THE Repository SHALL throw custom exceptions
6. THE Flutter_App SHALL ensure repositories validate data before returning
7. THE Flutter_App SHALL maintain existing repository methods (getAllEvents, getFavoriteEvents, toggleFavorite)

### Requirement 8: UI Component Hierarchy

**User Story:** As a developer, I want UI components organized by complexity, so that the component hierarchy is clear and maintainable.

#### Acceptance Criteria

1. THE Flutter_App SHALL ensure every UI element is its own class (no private build methods)
2. THE Flutter_App SHALL organize pages in `features/<feature>/pages/<page_name>/`
3. THE Flutter_App SHALL organize sections in `features/<feature>/pages/<page_name>/sections/`
4. THE Flutter_App SHALL organize page-specific components in `features/<feature>/pages/<page_name>/components/`
5. THE Flutter_App SHALL move shared widgets to `lib/design/widgets/`
6. THE Flutter_App SHALL move EventCard to feature-specific components directory (used across multiple event pages)
7. THE Flutter_App SHALL extract all private build methods into separate widget classes
8. WHEN a page contains complex UI logic, THE Flutter_App SHALL extract it into sections
9. WHEN a section contains reusable UI elements, THE Flutter_App SHALL extract them into components

### Requirement 9: Design System Structure

**User Story:** As a developer, I want a centralized design system, so that UI consistency is maintained across features.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `lib/design/` directory
2. THE Flutter_App SHALL create `lib/design/widgets/` for shared widgets
3. THE Flutter_App SHALL create `lib/design/components/` for shared components
4. THE Flutter_App SHALL create `lib/design/theme/` for theme definitions
5. THE Flutter_App SHALL create `lib/design/colors/` for color constants
6. THE Flutter_App SHALL create `lib/design/typography/` for text styles
7. THE Flutter_App SHALL move EventCard to feature-specific components (shared across event pages)
8. THE Flutter_App SHALL extract color constants from inline definitions
9. THE Flutter_App SHALL extract text styles into typography definitions

### Requirement 10: Go Router Integration

**User Story:** As a developer, I want type-safe routing with go_router, so that navigation is maintainable and compile-time safe.

#### Acceptance Criteria

1. THE Flutter_App SHALL add go_router and go_router_builder dependencies
2. THE Flutter_App SHALL define route classes using @TypedGoRoute annotation in each page file
3. THE Flutter_App SHALL create route class extending GoRouteData in each page file
4. THE Flutter_App SHALL create `lib/core/routing/app_router.dart` for router configuration
5. THE Flutter_App SHALL generate routes using build_runner
6. THE Flutter_App SHALL replace MaterialApp with MaterialApp.router
7. THE Flutter_App SHALL configure GoRouter in app_router.dart with $appRoutes
8. THE Flutter_App SHALL implement redirect callback for authentication guards
9. THE Flutter_App SHALL ensure all navigation uses context.go() or context.push()
10. WHEN user navigates to undefined route, THE Flutter_App SHALL display NotFoundPage via errorBuilder

### Requirement 11: State Management Migration

**User Story:** As a developer, I want cubits organized within their feature modules, so that state management is co-located with related code.

#### Acceptance Criteria

1. THE Flutter_App SHALL move event_list_cubit to `lib/features/events/logic/event_list/`
2. THE Flutter_App SHALL move favorites_cubit to `lib/features/events/logic/favorites/`
3. THE Flutter_App SHALL ensure cubit state classes use freezed for immutability
4. THE Flutter_App SHALL ensure cubits catch repository exceptions
5. THE Flutter_App SHALL ensure cubits display user-friendly error messages using translations
6. THE Flutter_App SHALL maintain existing cubit functionality (load, search, toggle)
7. THE Flutter_App SHALL ensure cubits store entities in state (not DTOs)

### Requirement 12: Dependency Injection Updates

**User Story:** As a developer, I want dependency injection updated for the new architecture, so that all dependencies are properly registered.

#### Acceptance Criteria

1. THE Flutter_App SHALL update service_locator.dart to register feature repositories
2. THE Flutter_App SHALL update service_locator.dart to register feature cubits
3. THE Flutter_App SHALL maintain lazy singleton registration for repositories
4. THE Flutter_App SHALL maintain factory registration for cubits
5. THE Flutter_App SHALL ensure ApiClient is registered as lazy singleton
6. THE Flutter_App SHALL ensure all dependencies are resolved through GetIt

### Requirement 13: File Naming Conventions

**User Story:** As a developer, I want consistent file naming, so that files are easily discoverable.

#### Acceptance Criteria

1. THE Flutter_App SHALL use snake_case for all file names
2. THE Flutter_App SHALL prefix files with feature name (event_repository.dart, event_list_cubit.dart)
3. THE Flutter_App SHALL suffix pages with _page.dart
4. THE Flutter_App SHALL suffix sections with _section.dart
5. THE Flutter_App SHALL suffix cubits with _cubit.dart
6. THE Flutter_App SHALL suffix states with _state.dart
7. THE Flutter_App SHALL ensure class names use PascalCase

### Requirement 14: Translation Integration

**User Story:** As a developer, I want all user-facing strings to use translations, so that internationalization is maintained.

#### Acceptance Criteria

1. THE Flutter_App SHALL ensure all pages import translations.g.dart
2. THE Flutter_App SHALL ensure all user-facing strings use the global `t` variable
3. THE Flutter_App SHALL ensure no hardcoded strings exist in UI code
4. THE Flutter_App SHALL maintain existing translations for all features
5. WHERE new UI text is needed, THE Flutter_App SHALL add translations to all language files (en, cs, es)

### Requirement 15: Code Generation Setup

**User Story:** As a developer, I want code generation configured for the new architecture, so that routes and serialization are automatically generated.

#### Acceptance Criteria

1. THE Flutter_App SHALL configure build_runner for go_router_builder
2. THE Flutter_App SHALL configure build_runner for freezed
3. THE Flutter_App SHALL configure build_runner for json_serializable
4. THE Flutter_App SHALL update taskfile.yaml with build-runner tasks
5. THE Flutter_App SHALL generate routes after creating all pages
6. THE Flutter_App SHALL ensure generated files are gitignored

### Requirement 16: Event Detail Page Structure

**User Story:** As a developer, I want the event detail page properly structured, so that event information is displayed according to design specifications.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `lib/features/events/pages/event_detail/event_detail_page.dart`
2. THE Flutter_App SHALL create sections based on .design/event-detail.html
3. THE Flutter_App SHALL create components for event detail UI elements
4. THE Flutter_App SHALL ensure event detail page receives event ID via route parameters
5. THE Flutter_App SHALL create placeholder implementation (no additional backend calls required)

### Requirement 17: Event Filters Page Structure

**User Story:** As a developer, I want the event filters page properly structured, so that users can filter events according to design specifications.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `lib/features/events/pages/event_filters/event_filters_page.dart`
2. THE Flutter_App SHALL create sections based on .design/event-filters.html
3. THE Flutter_App SHALL create components for filter UI elements
4. THE Flutter_App SHALL create placeholder implementation (no filter logic required)

### Requirement 18: Favorites Page Migration

**User Story:** As a developer, I want the favorites page migrated to the new architecture, so that favorites functionality follows architectural standards.

#### Acceptance Criteria

1. THE Flutter_App SHALL move favorites_screen.dart to `lib/features/events/pages/favorites/favorites_page.dart`
2. THE Flutter_App SHALL extract sections from favorites page
3. THE Flutter_App SHALL extract components from favorites page
4. THE Flutter_App SHALL annotate favorites page with @RoutePage()
5. THE Flutter_App SHALL maintain existing favorites functionality

### Requirement 19: Main Layout Refactoring

**User Story:** As a developer, I want the main navigation layout properly structured, so that bottom navigation is reusable and maintainable.

#### Acceptance Criteria

1. THE Flutter_App SHALL move MainNavigationScreen to `lib/features/app/layouts/main_layout.dart`
2. THE Flutter_App SHALL extract bottom navigation bar into separate component
3. THE Flutter_App SHALL extract navigation items into separate widgets
4. THE Flutter_App SHALL ensure layout uses router for navigation
5. THE Flutter_App SHALL maintain existing navigation functionality

### Requirement 20: Error Handling Architecture

**User Story:** As a developer, I want consistent error handling across features, so that errors are displayed uniformly.

#### Acceptance Criteria

1. THE Flutter_App SHALL maintain custom exceptions in `lib/core/exceptions/`
2. THE Flutter_App SHALL create error pages in `lib/features/app/pages/`
3. THE Flutter_App SHALL ensure all cubits catch and handle exceptions
4. THE Flutter_App SHALL ensure all error messages use translations
5. THE Flutter_App SHALL display user-friendly error messages (not technical details)

### Requirement 21: Testing Structure Migration

**User Story:** As a developer, I want the test structure to mirror the new architecture, so that tests are co-located with implementation.

#### Acceptance Criteria

1. THE Flutter_App SHALL create `test/features/` directory structure
2. THE Flutter_App SHALL mirror lib/ structure in test/ directory
3. THE Flutter_App SHALL create test files for repositories
4. THE Flutter_App SHALL create test files for cubits
5. THE Flutter_App SHALL maintain existing test functionality

### Requirement 22: Documentation Updates

**User Story:** As a developer, I want documentation updated for the new architecture, so that the codebase is understandable.

#### Acceptance Criteria

1. THE Flutter_App SHALL update README.md with new architecture overview
2. THE Flutter_App SHALL document feature module structure
3. THE Flutter_App SHALL document data layer patterns
4. THE Flutter_App SHALL document routing setup
5. THE Flutter_App SHALL provide examples of creating new features

### Requirement 23: Backward Compatibility During Migration

**User Story:** As a developer, I want the app to remain functional during migration, so that development can proceed incrementally.

#### Acceptance Criteria

1. THE Flutter_App SHALL maintain existing functionality throughout migration
2. THE Flutter_App SHALL migrate features incrementally (events first, then app, then auth, then settings)
3. THE Flutter_App SHALL ensure app compiles after each feature migration
4. THE Flutter_App SHALL run existing tests after each feature migration
5. THE Flutter_App SHALL remove legacy directories only after complete migration

### Requirement 24: Configuration Management

**User Story:** As a developer, I want configuration properly organized, so that environment-specific settings are maintainable.

#### Acceptance Criteria

1. THE Flutter_App SHALL maintain app_config.dart in lib/ root
2. THE Flutter_App SHALL maintain app_config.example.dart as template
3. THE Flutter_App SHALL ensure ApiConfig imports from AppConfig
4. THE Flutter_App SHALL ensure sensitive values remain in app_config.dart
5. THE Flutter_App SHALL ensure app_config.dart remains gitignored

### Requirement 25: Build and Deployment Compatibility

**User Story:** As a developer, I want build and deployment processes to work with the new architecture, so that releases are not disrupted.

#### Acceptance Criteria

1. THE Flutter_App SHALL ensure Android builds work with new architecture
2. THE Flutter_App SHALL maintain existing taskfile.yaml commands
3. THE Flutter_App SHALL update taskfile.yaml with new code generation commands
