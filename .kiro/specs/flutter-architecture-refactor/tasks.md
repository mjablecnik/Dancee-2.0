# Implementation Plan: Flutter Architecture Refactoring

## Overview

Incremental migration of the Dancee App from a flat directory structure (`screens/`, `models/`, `cubits/`, `widgets/`) to a clean architecture with feature-based organization (`features/`, `design/`, `core/`). Each phase builds on the previous one, ensuring the app compiles and functions correctly at every step. The implementation language is Dart (Flutter).

## Tasks

- [ ] 1. Phase 1: Setup and Infrastructure
  - [ ] 1.1 Add go_router, freezed, and build_runner dependencies to pubspec.yaml
    - Add `go_router`, `freezed_annotation` to dependencies
    - Add `go_router_builder`, `freezed`, `build_runner` to dev_dependencies
    - Run `task get-deps` to install
    - _Requirements: 10.1, 15.1, 15.2, 15.3_

  - [ ] 1.2 Create new directory structure scaffolding
    - Create `lib/features/` directory with subdirectories: `events/`, `app/`, `auth/`, `settings/`
    - Create `lib/design/` directory
    - Create each feature's internal structure: `data/`, `pages/`, `logic/`
    - _Requirements: 1.1, 1.2, 1.4, 1.5_

  - [ ] 1.3 Configure build_runner for code generation
    - Create or update `build.yaml` for go_router_builder and freezed configuration
    - Ensure generated files are in `.gitignore`
    - _Requirements: 15.1, 15.2, 15.3, 15.6_

- [ ] 2. Checkpoint - Ensure dependencies install and build_runner config is valid
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 3. Phase 2: Events Feature - Data Layer
  - [ ] 3.1 Create event entities with fromJson/toJson in `lib/features/events/data/entities.dart`
    - Consolidate `EventEntity`, `VenueEntity`, `AddressEntity`, `EventInfoEntity`, `EventPartEntity` into a single file
    - Each entity: `fromJson(Map<String, dynamic>)` factory, `toJson()`, `copyWith()`, Equatable
    - Reference existing models in `lib/models/` for field definitions
    - _Requirements: 2.2, 6.1, 6.2, 6.3, 6.5_

  - [ ]* 3.2 Write property test for entity serialization round-trip
    - **Property 1: Entity Serialization Round-Trip**
    - **Validates: Requirements 2.2, 6.2, 6.3**

  - [ ]* 3.3 Write property test for entity value equality
    - **Property 3: Entity Value Equality**
    - **Validates: Requirements 6.5**

  - [ ] 3.4 Migrate EventRepository to `lib/features/events/data/event_repository.dart`
    - Update repository to accept ApiClient via DI
    - Ensure repository receives `Map<String, dynamic>` from ApiClient and converts to Entity via `Entity.fromJson()`
    - Add data validation and custom exception throwing
    - Maintain existing methods: `getAllEvents`, `getFavoriteEvents`, `toggleFavorite`
    - _Requirements: 2.3, 2.7, 2.8, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7_

  - [ ]* 3.5 Write property test for repository error handling
    - **Property 4: Repository Error Handling**
    - **Validates: Requirements 7.5**

  - [ ]* 3.6 Write property test for repository data validation
    - **Property 5: Repository Data Validation**
    - **Validates: Requirements 7.6**

  - [ ]* 3.7 Write unit tests for EventRepository
    - Test `getAllEvents` success and error cases
    - Test `getFavoriteEvents` success and error cases
    - Test `toggleFavorite` add/remove paths
    - Test invalid response format handling
    - _Requirements: 7.4, 7.5, 7.6, 7.7_

- [ ] 4. Phase 2: Events Feature - Logic Layer
  - [ ] 4.1 Create EventListCubit with freezed state in `lib/features/events/logic/event_list.dart`
    - Combine cubit + state in one file using freezed
    - Define states: `initial`, `loading`, `loaded` (with grouped event lists), `error`
    - Implement `loadEvents`, `searchEvents`, `toggleFavorite` methods
    - Catch repository exceptions and emit translated error messages
    - _Requirements: 2.4, 11.1, 11.3, 11.4, 11.5, 11.6, 11.7_

  - [ ] 4.2 Create FavoritesCubit with freezed state in `lib/features/events/logic/favorites.dart`
    - Combine cubit + state in one file using freezed
    - Define states: `initial`, `loading`, `loaded`, `error`
    - Implement `loadFavorites`, `toggleFavorite` methods
    - _Requirements: 2.4, 11.2, 11.3, 11.4, 11.5, 11.6_

  - [ ]* 4.3 Write property test for cubit exception handling
    - **Property 7: Cubit Exception Handling**
    - **Validates: Requirements 11.4, 11.5**

  - [ ]* 4.4 Write unit tests for EventListCubit and FavoritesCubit
    - Test state transitions: initial → loading → loaded/error
    - Test event grouping by date (today, tomorrow, upcoming)
    - Test search filtering
    - Test toggleFavorite local state update
    - _Requirements: 11.4, 11.5, 11.6_

- [ ] 5. Phase 2: Events Feature - Presentation Layer
  - [ ] 5.1 Create EventListPage with route definition in `lib/features/events/pages/event_list/`
    - Create `event_list_page.dart` with `@TypedGoRoute<EventListRoute>(path: '/events')`
    - Add `part 'event_list_page.g.dart';` directive
    - Use `NoTransitionPage` in `buildPage` override
    - Wire up BlocBuilder with EventListCubit
    - _Requirements: 2.5, 8.2, 10.2, 10.3_

  - [ ] 5.2 Extract sections for EventListPage
    - Create `sections.dart` containing: `EventListHeaderSection`, `SearchAndFiltersSection`, `EventsByDateSection`, `LoadingSection`, `ErrorSection`
    - Each section is its own class (no private build methods)
    - _Requirements: 2.6, 8.1, 8.8_

  - [ ] 5.3 Extract components for EventListPage
    - Create `components.dart` containing: `EventCard`, `SectionHeader`, `SearchBar`, `FilterChipsRow`, `FilterChip`
    - Move and refactor EventCard from `lib/widgets/event_card.dart`
    - Each component is its own class
    - _Requirements: 2.6, 8.1, 8.4, 8.6, 8.7, 8.9_

  - [ ] 5.4 Create EventDetailPage with route definition in `lib/features/events/pages/event_detail/`
    - Create `event_detail_page.dart` with `@TypedGoRoute<EventDetailRoute>(path: '/events/:id')`
    - Create `sections.dart` with header, image, info, description, dance styles, event parts sections
    - Create `components.dart` with detail-specific components
    - Placeholder implementation (no additional backend calls)
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5_

  - [ ] 5.5 Create EventFiltersPage in `lib/features/events/pages/event_filters_page.dart`
    - Simple page (direct file, no folder) with `@TypedGoRoute` annotation
    - Placeholder implementation with filter UI structure based on `.design/event-filters.html`
    - _Requirements: 17.1, 17.2, 17.3, 17.4_

  - [ ] 5.6 Create FavoritesPage in `lib/features/events/pages/favorites_page.dart`
    - Simple page with `@TypedGoRoute<FavoritesRoute>(path: '/favorites')` annotation
    - Migrate existing favorites_screen.dart functionality
    - Maintain existing favorites functionality
    - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_

- [ ] 6. Checkpoint - Events feature compiles and functions correctly
  - Run `task build-runner` to generate routes and freezed classes
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Phase 3: App Feature
  - [ ] 7.1 Create MainLayout with shell route in `lib/features/app/layouts.dart`
    - Create `AppLayoutRoute` with `@TypedShellRoute` wrapping EventListRoute and FavoritesRoute
    - Create `AppLayout` widget with bottom navigation bar
    - Extract bottom navigation bar into separate component class
    - Maintain existing navigation functionality
    - _Requirements: 3.1, 3.2, 3.3, 3.6, 19.1, 19.2, 19.3, 19.4, 19.5_

  - [ ] 7.2 Create app pages (InitialPage, NotFoundPage, ErrorPage)
    - Create `lib/features/app/pages/initial_page.dart` as app entry point with route
    - Create `lib/features/app/pages/not_found_page.dart` for undefined routes
    - Create `lib/features/app/pages/error_page.dart` with retry option
    - All user-facing strings use translations
    - _Requirements: 3.4, 3.5, 20.2, 20.4, 20.5_

  - [ ] 7.3 Create GoRouter configuration in `lib/core/routing.dart`
    - Configure GoRouter with `$appRoutes`, initial location, and error builder
    - Implement redirect callback for authentication guards on protected routes
    - Wire up NotFoundPage via errorBuilder
    - _Requirements: 10.4, 10.5, 10.7, 10.8, 10.9, 10.10_

  - [ ] 7.4 Update main.dart to use MaterialApp.router
    - Replace `MaterialApp` with `MaterialApp.router` using `goRouter`
    - Maintain translation provider and locale settings
    - _Requirements: 10.6_

  - [ ]* 7.5 Write property test for authentication redirect
    - **Property 6: Authentication Redirect**
    - **Validates: Requirements 10.8**

- [ ] 8. Checkpoint - App feature and routing work correctly
  - Run `task build-runner` to regenerate routes
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Phase 4: Auth Feature
  - [ ] 9.1 Create auth data layer placeholders
    - Create `lib/features/auth/data/entities.dart` with placeholder auth entities (UserEntity)
    - Create `lib/features/auth/data/auth_repository.dart` with placeholder methods
    - _Requirements: 4.1_

  - [ ] 9.2 Create AuthCubit with freezed state in `lib/features/auth/logic/auth.dart`
    - Placeholder cubit with states: `initial`, `loading`, `authenticated`, `unauthenticated`, `error`
    - _Requirements: 4.1_

  - [ ] 9.3 Create LoginPage in `lib/features/auth/pages/login/`
    - Create `login_page.dart` with `@TypedGoRoute<LoginRoute>(path: '/login')`
    - Create `sections.dart` with: `LoginHeaderSection`, `LoginFormSection`, `LoginButtonSection`, `RegisterLinkSection`
    - Create `components.dart` with form field components
    - Structure based on `.design/auth-login.html`
    - Placeholder implementation (no backend integration)
    - _Requirements: 4.2, 4.4, 4.7_

  - [ ] 9.4 Create RegisterPage in `lib/features/auth/pages/register/`
    - Create `register_page.dart` with `@TypedGoRoute<RegisterRoute>(path: '/register')`
    - Create `sections.dart` with: `RegisterHeaderSection`, `RegisterFormSection`, `RegisterButtonSection`, `LoginLinkSection`
    - Create `components.dart` with form field components
    - Structure based on `.design/auth-register.html`
    - Placeholder implementation (no backend integration)
    - _Requirements: 4.3, 4.5, 4.7_

- [ ] 10. Phase 5: Settings Feature
  - [ ] 10.1 Create settings data layer placeholders
    - Create `lib/features/settings/data/entities.dart` with placeholder settings entities
    - Create `lib/features/settings/data/settings_repository.dart` with placeholder methods
    - _Requirements: 5.1_

  - [ ] 10.2 Create SettingsCubit with freezed state in `lib/features/settings/logic/settings.dart`
    - Placeholder cubit with states: `initial`, `loading`, `loaded`, `error`
    - _Requirements: 5.1_

  - [ ] 10.3 Create SettingsPage in `lib/features/settings/pages/settings_page.dart`
    - Simple page with `@TypedGoRoute<SettingsRoute>(path: '/settings')`
    - Structure based on `.design/settings.html` and `.design/settings-change.html`
    - Sections: `SettingsHeaderSection`, `ProfileSection`, `PreferencesSection`, `AccountSection`, `AppInfoSection`
    - Placeholder implementation (no backend integration)
    - _Requirements: 5.2, 5.3, 5.4, 5.5_

- [ ] 11. Checkpoint - Auth and Settings features compile with routes
  - Run `task build-runner` to regenerate all routes
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Phase 6: Design System
  - [ ] 12.1 Create color constants in `lib/design/colors.dart`
    - Extract all color constants from inline definitions across the codebase
    - Define `AppColors` class with primary, accent, neutral, and semantic colors
    - Define gradient constants
    - _Requirements: 9.1, 9.4, 9.8_

  - [ ] 12.2 Create typography definitions in `lib/design/typography.dart`
    - Extract text styles into `AppTypography` class
    - Define display, body, and label text styles
    - _Requirements: 9.1, 9.5, 9.9_

  - [ ] 12.3 Create theme configuration in `lib/design/theme.dart`
    - Create `AppTheme` class with `lightTheme` using `AppColors` and `AppTypography`
    - Configure Material 3 color scheme, text theme, card theme, button theme, input decoration
    - Update `main.dart` to use `AppTheme.lightTheme`
    - _Requirements: 9.1, 9.3_

  - [ ] 12.4 Create shared widgets in `lib/design/widgets.dart`
    - Identify and extract truly shared widgets (loading indicator, error message, empty state)
    - Move shared widgets from feature-specific locations to design system
    - Update imports across all features
    - _Requirements: 9.1, 9.2, 8.5_

- [ ] 13. Phase 7: Cleanup and Wiring
  - [ ] 13.1 Consolidate core module files
    - Move `lib/di/service_locator.dart` to `lib/core/service_locator.dart`
    - Consolidate `lib/core/clients/api_client.dart` to `lib/core/clients.dart`
    - Consolidate `lib/core/config/api_config.dart` to `lib/core/config.dart` (import from `lib/config.dart`)
    - Consolidate `lib/core/exceptions/api_exception.dart` to `lib/core/exceptions.dart`
    - _Requirements: 1.4, 20.1, 24.1, 24.3, 24.4, 24.5_

  - [ ] 13.2 Update dependency injection in `lib/core/service_locator.dart`
    - Register all feature repositories as lazy singletons
    - Register all feature cubits as factories
    - Ensure ApiClient is registered as lazy singleton
    - Update all import paths to new feature-based locations
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

  - [ ] 13.3 Update configuration management
    - Rename `lib/app_config.dart` to `lib/config.dart` (sensitive, gitignored)
    - Rename `lib/app_config.example.dart` to `lib/config.example.dart`
    - Create `lib/core/config.dart` that imports from `lib/config.dart` and adds public config values
    - Update all references across the codebase
    - _Requirements: 24.1, 24.2, 24.3, 24.4, 24.5_

  - [ ] 13.4 Remove legacy directories
    - Delete `lib/screens/` directory
    - Delete `lib/models/` directory
    - Delete `lib/cubits/` directory
    - Delete `lib/widgets/` directory
    - Delete `lib/repositories/` directory
    - Delete `lib/di/` directory
    - Verify no remaining imports reference old paths
    - _Requirements: 1.3, 23.5_

  - [ ] 13.5 Verify file naming conventions across the codebase
    - Ensure all files use snake_case
    - Ensure files are prefixed with feature name
    - Ensure pages suffixed with `_page.dart`, sections with `_section.dart`, cubits with `_cubit.dart`
    - Ensure class names use PascalCase
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7_

  - [ ] 13.6 Verify translation integration
    - Ensure all pages import `translations.g.dart`
    - Ensure all user-facing strings use the global `t` variable
    - Add any new translation keys to all language files (en, cs, es)
    - Run `task slang` to regenerate translations
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 14. Checkpoint - Full migration complete, all legacy code removed
  - Run `task build-runner` to regenerate all code
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Testing and Documentation
  - [ ] 15.1 Create test directory structure mirroring new architecture
    - Create `test/features/events/data/`, `test/features/events/logic/`, etc.
    - Create test helper files in `test/helpers/` (mock factories, property test helpers)
    - Migrate existing tests to new paths
    - _Requirements: 21.1, 21.2, 21.3, 21.4, 21.5_

  - [ ]* 15.2 Write property test for repository return type consistency
    - **Property 2: Repository Return Type Consistency**
    - **Validates: Requirements 2.7, 6.4**

  - [ ] 15.3 Update README.md with new architecture documentation
    - Document new feature module structure
    - Document data layer patterns (entities-only, repository pattern)
    - Document routing setup with go_router
    - Provide examples of creating new features
    - _Requirements: 22.1, 22.2, 22.3, 22.4, 22.5_

  - [ ] 15.4 Update taskfile.yaml with code generation commands
    - Ensure `build-runner`, `build-runner-watch`, `build-runner-force`, `build-runner-clean` tasks exist
    - Verify existing tasks still work with new architecture
    - _Requirements: 15.4, 25.2, 25.3_

- [ ] 16. Final Checkpoint - All tests pass, documentation complete
  - Run full test suite
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation after each phase
- Property tests validate universal correctness properties from the design document
- The app must compile and remain functional after each phase completion
- All user-facing strings must use slang translations (never hardcoded)
- Run `task build-runner` after creating pages with route annotations
