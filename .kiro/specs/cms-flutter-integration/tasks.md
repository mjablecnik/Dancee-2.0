# Implementation Plan: CMS Flutter Integration

## Overview

Replace all hardcoded mock data in dancee_app2 with live data from dancee_cms (Directus). Implementation proceeds bottom-up: dependencies → config → entities → client → repositories → states → cubits → UI wiring → filters → favorites → settings/language. Each step builds on the previous and ends with full integration.

## Tasks

- [x] 1. Add dependencies and configure CMS connection
  - [x] 1.1 Add required packages to pubspec.yaml
    - Add `dio`, `equatable`, `freezed_annotation`, `json_annotation`, `get_it` to dependencies
    - Add `freezed`, `json_serializable` to dev_dependencies
    - Run `flutter pub get`
    - _Requirements: 1.1, 1.6, 18.1_

  - [x] 1.2 Create CMS configuration in config files
    - Add `directusBaseUrl` and `directusAccessToken` to `lib/config.dart` (gitignored)
    - Add placeholder values to `lib/config.example.dart` (committed)
    - Create `lib/core/config.dart` re-exporting sensitive config + public constants (defaultUserId, timeouts)
    - _Requirements: 18.1, 18.2, 18.3_

  - [x] 1.3 Create ApiException class
    - Create `lib/core/exceptions.dart` with `ApiException` class containing status code and message
    - _Requirements: 1.7_

- [x] 2. Implement data entity classes
  - [x] 2.1 Create Venue entity
    - Create `lib/data/entities/venue.dart` with `Venue` class extending Equatable
    - Implement `fromDirectus()` factory parsing CMS venue JSON
    - Include `fullAddress` getter
    - _Requirements: 2.2_

  - [x] 2.2 Create EventInfo and EventPart entities
    - Create `lib/data/entities/event_info.dart` with `EventInfoType` enum and `EventInfo` class
    - Create `lib/data/entities/event_part.dart` with `EventPart` class
    - Both with `fromDirectus()` factories supporting translated fields
    - _Requirements: 2.1_

  - [x] 2.3 Create Event entity
    - Create `lib/data/entities/event.dart` with `Event` class extending Equatable
    - Implement `fromDirectus()` factory with translation extraction logic (match language → fallback to en → fallback to first)
    - Construct image URL from `{directusBaseUrl}/assets/{fileId}`
    - Accept `favoriteEventIds` set to set `isFavorited`
    - _Requirements: 2.1, 2.3, 2.4, 2.5_

  - [x]* 2.4 Write property tests for Event entity parsing
    - **Property 3: Translation extraction from CMS JSON** — generate random CMS event JSON with translations, verify parsed entity has correct translated fields
    - **Property 4: Image URL construction** — generate random file IDs and base URLs, verify URL pattern `{baseUrl}/assets/{fileId}`, null when fileId is null
    - **Property 5: Translation fallback chain** — generate translation arrays with missing languages, verify fallback to en then first available
    - **Validates: Requirements 2.3, 2.4, 2.5, 3.2, 3.3, 3.4**

  - [x] 2.5 Create Course entity
    - Create `lib/data/entities/course.dart` with `Course` class extending Equatable
    - Implement `fromDirectus()` factory with translation extraction and image URL construction
    - Accept `favoriteCourseIds` set to set `isFavorited`
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 2.6 Create DanceStyle and Favorite entities
    - Create `lib/data/entities/dance_style.dart` with `DanceStyle` class and `fromDirectus()` factory
    - Create `lib/data/entities/favorite.dart` with `Favorite` class and `fromDirectus()` factory
    - _Requirements: 8.1, 11.1_

  - [x] 2.7 Create FilterState data class
    - Create `lib/logic/states/filter_state.dart` with `FilterState` extending Equatable
    - Include `selectedDanceStyles` (Set<String>), `selectedRegions` (Set<String>), and `hasActiveFilters` getter
    - _Requirements: 7.1_

- [x] 3. Implement DirectusClient and repositories
  - [x] 3.1 Create DirectusClient
    - Create `lib/core/clients.dart` with Dio-based `DirectusClient`
    - Implement `get()`, `post()`, `delete()` methods with Directus envelope unwrapping (`data` field extraction)
    - Map HTTP errors and network failures to `ApiException`
    - Configure Dio with base URL, access token header, and timeouts from AppConfig
    - _Requirements: 1.1, 1.2, 1.3, 1.6, 1.7_

  - [ ]* 3.2 Write property tests for DirectusClient
    - **Property 1: Deep language filter in API queries** — verify query parameters include correct `deep[translations][_filter][languages_code][_eq]` for any valid language code
    - **Property 2: HTTP error to ApiException mapping** — generate random HTTP status codes (4xx, 5xx), verify ApiException is thrown with non-empty message
    - **Validates: Requirements 1.5, 1.7, 15.1, 15.2**

  - [x] 3.3 Create EventRepository
    - Create `lib/data/repositories/event_repository.dart` replacing the mock `EventRepository`
    - Implement `getEvents(String languageCode)` calling DirectusClient with fields, filter, sort, deep language params
    - Parse response into `List<Event>` using `Event.fromDirectus()`
    - _Requirements: 1.1, 1.5, 4.1, 15.1_

  - [x] 3.4 Create CourseRepository
    - Create `lib/data/repositories/course_repository.dart` replacing the mock `CourseRepository`
    - Implement `getCourses(String languageCode)` with same pattern as EventRepository
    - _Requirements: 1.2, 1.5, 6.1, 15.2_

  - [x] 3.5 Create FavoritesRepository
    - Create `lib/data/repositories/favorites_repository.dart`
    - Implement `getFavorites(userId)`, `addFavorite(userId, itemType, itemId)`, `removeFavorite(userId, itemType, itemId)`
    - _Requirements: 1.3, 11.1, 12.1, 12.2, 12.3_

  - [x] 3.6 Create DanceStyleRepository
    - Create `lib/data/repositories/dance_style_repository.dart`
    - Implement `getDanceStyles(String languageCode)` with deep language filter
    - _Requirements: 1.4, 1.5, 8.1_

- [x] 4. Checkpoint — Verify data layer
  - Ensure all entity classes and repositories compile correctly. Run `task build-runner` for any generated code. Ask the user if questions arise.

- [x] 5. Implement state classes and cubits
  - [x] 5.1 Create freezed state classes
    - Create `lib/logic/states/event_state.dart` — `EventState` with initial, loading, loaded (allEvents, filteredEvents, featuredEvents), error variants
    - Create `lib/logic/states/course_state.dart` — `CourseState` with initial, loading, loaded (allCourses, filteredCourses), error variants
    - Create `lib/logic/states/favorites_state.dart` — `FavoritesState` with initial, loading, loaded (eventIds, courseIds), error variants
    - Create `lib/logic/states/settings_state.dart` — `SettingsState` with languageCode field
    - Run `task build-runner` to generate freezed code
    - _Requirements: 4.1, 6.1, 11.1, 16.1_

  - [x] 5.2 Implement SettingsCubit
    - Create `lib/logic/cubits/settings_cubit.dart`
    - Implement `init()` — read persisted language from SharedPreferences, set locale via slang LocaleSettings
    - Implement `setLanguage(languageCode)` — persist to SharedPreferences, update slang locale, emit new state
    - Fall back to device locale or English if no persisted language
    - _Requirements: 16.2, 16.3, 16.4, 16.5_

  - [ ]* 5.3 Write property test for SettingsCubit language persistence
    - **Property 16: Language persistence round-trip** — for any valid language code (en, cs, es), persist and read back, verify equality
    - **Validates: Requirements 16.3, 16.4**

  - [x] 5.4 Implement FilterCubit
    - Create `lib/logic/cubits/filter_cubit.dart` using `FilterState` from `logic/states/filter_state.dart`
    - Implement `setDanceStyles(codes)`, `setLocations(regions)`, `clearAll()`
    - Implement `loadDanceStyles(languageCode)` to fetch dance styles from DanceStyleRepository
    - Expose loaded dance styles for filter UI and for parent/child expansion
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 15.5_

  - [x] 5.5 Implement EventCubit
    - Create `lib/logic/cubits/event_cubit.dart`
    - Implement `loadEvents(languageCode)` — fetch from EventRepository, apply filters, compute featured (festivals only), emit loaded state
    - Implement `applyFilters(FilterState)` — client-side AND filtering with parent/child dance style expansion, update filteredEvents and featuredEvents
    - Implement `updateFavoriteStatus(eventId, isFavorited)` — update isFavorited on matching event in allEvents and re-apply filters
    - _Requirements: 4.1, 4.2, 4.3, 5.1, 5.2, 5.3, 10.1, 10.3, 10.4, 15.3_

  - [ ]* 5.6 Write property tests for filtering logic
    - **Property 6: Featured events are filtered festivals** — generate random event lists with mixed types + random filters, verify featured subset contains only festivals matching all filters
    - **Property 7: Combined AND filtering** — generate random items + random filter states, verify AND logic for dance styles and regions
    - **Property 8: Parent/child dance style expansion** — generate random dance style trees, verify expansion includes parent + all children
    - **Validates: Requirements 4.2, 5.1, 5.2, 8.3, 8.4, 8.5, 9.3, 9.4, 10.1, 10.2**

  - [x] 5.7 Implement CourseCubit
    - Create `lib/logic/cubits/course_cubit.dart`
    - Implement `loadCourses(languageCode)` — fetch from CourseRepository, apply filters, emit loaded state
    - Implement `applyFilters(FilterState)` — same AND filtering logic as EventCubit (no featured section for courses)
    - Implement `updateFavoriteStatus(courseId, isFavorited)`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 10.2, 10.3, 10.4, 15.4_

  - [x] 5.8 Implement FavoritesCubit
    - Create `lib/logic/cubits/favorites_cubit.dart`
    - Implement `loadFavorites()` — fetch from FavoritesRepository using defaultUserId, emit loaded state with eventIds and courseIds sets
    - Implement `toggleFavorite(itemType, itemId)` — optimistic update, call CMS, revert on failure
    - Implement `isFavorited(itemType, itemId)` helper
    - Implement `getResolvedFavorites(events, courses)` — resolve favorite IDs against loaded data, sort by createdAt descending
    - _Requirements: 11.1, 11.2, 11.3, 12.1, 12.2, 12.3, 12.4, 12.5_

  - [ ]* 5.9 Write property tests for favorites logic
    - **Property 10: Favorite resolution against loaded data** — generate random favorites + items, verify resolution correctness
    - **Property 11: Favorites sorted by creation date** — generate random favorites with dates, verify descending sort
    - **Property 12: Favorites unaffected by filters** — generate random favorites + active filters, verify all favorites shown
    - **Property 13: Favorite toggle round-trip** — toggle twice, verify original state restored
    - **Property 14: Optimistic favorite update** — mock slow API, toggle, verify immediate state change
    - **Property 15: Revert on failure** — mock failing API, toggle, verify state reverts
    - **Validates: Requirements 11.2, 11.3, 11.4, 12.3, 12.4, 12.5**

- [x] 6. Checkpoint — Verify logic layer
  - Ensure all cubits and state classes compile. Run `task build-runner` for freezed generation. Run `task test` if property tests were written. Ask the user if questions arise.

- [x] 7. Set up dependency injection and app wiring
  - [x] 7.1 Create service locator
    - Create `lib/core/service_locator.dart` using get_it
    - Register DirectusClient, all repositories, and all cubits
    - Inject repository dependencies into cubits
    - _Requirements: 1.6, 18.4_

  - [x] 7.2 Wire cubits into the widget tree
    - Update `lib/main.dart` to initialize service locator, wrap MaterialApp with MultiBlocProvider providing all cubits (SettingsCubit, FilterCubit, FavoritesCubit, EventCubit, CourseCubit)
    - Initialize SettingsCubit on app start (read persisted language) before data fetch
    - Trigger initial data load (events, courses, dance styles, favorites) after language is resolved
    - _Requirements: 7.4, 16.4, 16.6_

  - [x] 7.3 Set up language change listener
    - When SettingsCubit emits a new language, trigger re-fetch on EventCubit, CourseCubit, and FilterCubit (dance styles)
    - Use BlocListener on SettingsCubit to coordinate re-fetches
    - _Requirements: 15.3, 15.4, 15.5, 16.6_

  - [x] 7.4 Set up filter change listener
    - When FilterCubit emits new FilterState, call `applyFilters()` on both EventCubit and CourseCubit
    - Use BlocListener on FilterCubit to coordinate filter application
    - _Requirements: 7.2, 7.3, 10.4_

- [x] 8. Update events UI screens
  - [x] 8.1 Update events list screen
    - Replace mock data usage with BlocBuilder on EventCubit
    - Display loading indicator, error with retry, or loaded state
    - Show "Featured events" section (horizontal scroll) with festivals only, hide when empty
    - Show "Upcoming events" section with all filtered events
    - Display each event with: image, title, date, location, dance style tags, favorite button
    - Wire favorite button to FavoritesCubit.toggleFavorite
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 4.6, 5.1, 5.3, 5.4, 12.6_

  - [x] 8.2 Update event detail screen
    - Accept event ID via route parameter, look up event from EventCubit's loaded state
    - Display: hero image, title, dance style chips, key info (date/time, location, organizer, price), description paragraphs, additional info (price range, dresscode, registration URL), program (multi-day slots), original source link
    - Wire favorite toggle button to FavoritesCubit
    - _Requirements: 13.1, 13.2, 13.3, 13.4_

  - [x] 8.3 Update event detail route to pass event ID
    - Modify GoRouter route for `/events/detail` to accept an `id` parameter (path or query param)
    - _Requirements: 13.1_

- [x] 9. Update courses UI screens
  - [x] 9.1 Update courses list screen
    - Replace mock data with BlocBuilder on CourseCubit
    - Display loading, error with retry, or loaded list (no featured section)
    - Show each course with: image, title, instructor, date range, dance style tags, price, favorite button
    - Wire favorite button to FavoritesCubit.toggleFavorite
    - _Requirements: 6.1, 6.2, 6.3, 6.5, 6.6, 6.7, 12.6_

  - [x] 9.2 Update course detail screen
    - Accept course ID via route parameter, look up course from CourseCubit's loaded state
    - Display: hero image, title, level, dance style chips, key info, description, schedule details, learning items, instructor section, pricing, original source link
    - Wire favorite toggle button to FavoritesCubit
    - _Requirements: 14.1, 14.2, 14.3, 14.4_

  - [x] 9.3 Update course detail route to pass course ID
    - Modify GoRouter route for `/courses/detail` to accept an `id` parameter
    - _Requirements: 14.1_

- [x] 10. Update filter screens
  - [x] 10.1 Update dance style filter screen
    - Replace mock data with dance styles from FilterCubit (fetched from CMS with translated names)
    - Allow multi-select of dance styles, update FilterCubit on confirmation
    - Show currently selected styles as pre-checked
    - _Requirements: 8.1, 8.2, 8.6_

  - [x] 10.2 Update location filter screen
    - Derive available regions from loaded events and courses venue data (union of all non-empty venue.region values)
    - Allow multi-select of regions, update FilterCubit on confirmation
    - Show currently selected regions as pre-checked
    - _Requirements: 9.1, 9.2, 9.5, 9.6_

  - [ ]* 10.3 Write property test for region extraction
    - **Property 9: Region extraction from loaded data** — generate random events/courses with venues, verify region set equals union of all non-empty venue.region values with no duplicates
    - **Validates: Requirements 9.1**

- [x] 11. Update saved items and favorites UI
  - [x] 11.1 Update saved items screen
    - Replace mock data with BlocBuilder on FavoritesCubit
    - Resolve favorites against EventCubit and CourseCubit loaded data
    - Display combined list sorted by createdAt descending (newest first)
    - Show loading indicator, empty state message when no favorites
    - Do NOT apply dance style or location filters to saved items
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

  - [x] 11.2 Ensure favorite status consistency across screens
    - When FavoritesCubit toggles a favorite, update isFavorited on the corresponding event/course in EventCubit and CourseCubit
    - Ensure favorite heart icon reflects current state on events list, courses list, event detail, course detail, and saved items
    - _Requirements: 12.6_

- [x] 12. Update settings screen for language selection
  - [x] 12.1 Implement language selection UI on settings/profile screen
    - Display language picker with Czech, English, Spanish options
    - Show currently selected language
    - On selection, call SettingsCubit.setLanguage() which persists and triggers re-fetch of all data
    - Settings page only shows language option (auth, profile, premium out of scope)
    - _Requirements: 16.1, 16.2, 16.6, 16.7, 16.8_

- [x] 13. Add i18n translation keys
  - [x] 13.1 Add translation keys for new UI elements
    - Add keys for: loading states, error messages, retry button, empty states, filter labels, saved items labels, language names, settings labels
    - Add to all three files: `strings.i18n.json` (en), `strings_cs.i18n.json` (cs), create `strings_es.i18n.json` (es)
    - Run `task slang` to regenerate
    - _Requirements: 17.1, 17.2, 17.3, 17.4_

- [x] 14. Final checkpoint — Full integration verification
  - Ensure all tests pass. Verify the app compiles with `flutter build web`. Ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- The app uses Dart/Flutter — all code examples use Dart
- No backend changes needed — the app talks directly to the existing Directus REST API
- The existing mock `EventRepository`, `CourseRepository`, and `CityRepository` in `lib/data/` will be replaced by the new repository implementations
