# Implementation Plan: Event Detail Page

## Overview

Complete the existing event detail page scaffold by adding an `EventDetailCubit` with optimistic favorite toggle, map/URL navigation via `url_launcher`, wiring the cubit into the existing page and sections, and adding the missing translation keys. No new backend endpoints or entities are needed — all data comes from the already-loaded `EventListCubit` state.

## Tasks

- [x] 1. Wire navigation from event list and favorites to event detail page
  - [x] 1.1 Update `EventsByDateSection` in `lib/features/events/pages/event_list/sections.dart` to navigate on event card tap
    - Replace the `// TODO: Navigate to event detail` placeholders in all three event groups (today, tomorrow, upcoming)
    - Import `event_detail_page.dart` and use `EventDetailRoute(id: event.id).go(context)` for type-safe navigation
    - _Requirements: 1.1_

  - [x] 1.2 Update `FavoritesPage` in `lib/features/events/pages/favorites_page.dart` to navigate on event card tap
    - Replace the `// TODO: Navigate to event detail` placeholders in both upcoming and past event lists
    - Import `event_detail_page.dart` and use `EventDetailRoute(id: event.id).go(context)` for type-safe navigation
    - _Requirements: 1.1_

- [x] 2. Add `url_launcher` dependency and create `EventDetailCubit`
  - [x] 2.1 Add `url_launcher` package to `pubspec.yaml` and run `task get-deps`
    - _Requirements: 4.3, 7.3, 10.1_

  - [x] 2.2 Create `lib/features/events/logic/event_detail.dart` with `EventDetailCubit` and `EventDetailState` (freezed)
    - Define `EventDetailState` with `initial`, `loaded` (event + isTogglingFavorite), and `error` states
    - Implement `loadEvent()` — find event by ID from `EventListCubit.state.allEvents`
    - Implement `toggleFavorite()` — optimistic flip, call `EventRepository.toggleFavorite()`, sync back to `EventListCubit` on success, revert on failure
    - Implement `openMap(Venue venue)` — build Google Maps directions URL using coordinates when available, fallback to encoded address, launch via `url_launcher`
    - Implement `openUrl(String url)` — launch external URL via `url_launcher` (for info items of type URL)
    - Emit error state when event not found or `EventListCubit` state is not loaded
    - _Requirements: 1.3, 1.4, 4.3, 4.4, 4.5, 9.1, 9.2, 9.3, 9.4, 10.1, 10.2_

  - [x] 2.3 Write property test: favorite toggle round trip (Property 6)
    - **Property 6: Favorite toggle round trip**
    - For any event in loaded state, `toggleFavorite()` flips `isFavorite` and calls repository with correct event ID and original status
    - **Validates: Requirements 9.1, 9.2**

  - [x] 2.4 Write property test: favorite toggle error recovery (Property 7)
    - **Property 7: Favorite toggle error recovery**
    - For any event in loaded state, if repository throws, cubit reverts `isFavorite` to original value
    - **Validates: Requirements 9.4**

  - [x] 2.5 Write property test: map URL construction (Property 5)
    - **Property 5: Map URL construction uses coordinates when available**
    - For any venue with non-null lat/lng, URL contains coordinates; for null coordinates, URL contains encoded address
    - **Validates: Requirements 4.3, 4.4, 4.5, 10.1**

- [x] 3. Register `EventDetailCubit` in DI and add translation keys
  - [x] 3.1 Register `EventDetailCubit` as `factoryParam` in `lib/core/service_locator.dart`
    - Use `registerFactoryParam<EventDetailCubit, String, void>` with eventId parameter
    - Import the new cubit file
    - _Requirements: 9.1_

  - [x] 3.2 Add new translation keys to all three language files (`strings.i18n.json`, `strings_cs.i18n.json`, `strings_es.i18n.json`)
    - Add `eventDetail.addedToFavorites`, `eventDetail.removedFromFavorites`, `eventDetail.favoriteError`, `eventDetail.remove`
    - Run `task slang` to regenerate
    - _Requirements: 11.1, 11.2_

- [x] 4. Checkpoint - Ensure cubit, DI, and navigation compile correctly
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Wire `EventDetailCubit` into the page and update sections
  - [x] 5.1 Update `EventDetailPage` to use `BlocProvider<EventDetailCubit>` instead of directly reading `EventListCubit`
    - Create cubit via `getIt<EventDetailCubit>(param1: eventId)` and call `loadEvent()`
    - Use `BlocBuilder<EventDetailCubit, EventDetailState>` with `state.when()` for initial/loaded/error
    - Pass cubit callbacks to header section (onFavoritePressed, onMapPressed) and venue section (onNavigatePressed)
    - Show snackbar on favorite toggle success/failure using `BlocListener`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 9.2, 9.3, 9.4_

  - [x] 5.2 Update `EventDetailHeaderSection` to accept and use favorite/map callbacks
    - Accept `onFavoritePressed` and `onMapPressed` callbacks
    - Update `_QuickActionsRow` to use callbacks and show filled/outlined heart icon based on `event.isFavorite`
    - Remove the placeholder share button (no share functionality for now)
    - _Requirements: 1.1, 1.3, 1.4, 10.1, 10.2_

  - [x] 5.3 Update `EventVenueSection` to accept and use navigate callback
    - Accept `onNavigatePressed` callback
    - Wire the navigate button's `onPressed` to the callback
    - _Requirements: 4.2, 4.3_

  - [x] 5.4 Update `EventInfoSection` and `EventInfoCard` to handle URL taps
    - Accept `onUrlTapped` callback in `EventInfoSection` and pass to `EventInfoCard`
    - Make URL-type info cards tappable (wrap in `GestureDetector` or `InkWell`)
    - Call cubit's `openUrl()` when a URL-type info item is tapped
    - _Requirements: 7.3_

  - [x] 5.5 Write property test: favorite icon reflects event state (Property 1)
    - **Property 1: Favorite icon reflects event state**
    - For any event, favorite button shows filled heart iff `event.isFavorite` is true
    - **Validates: Requirements 1.4, 9.3**

  - [x] 5.6 Write property test: time range formatting (Property 4)
    - **Property 4: Time range formatting**
    - For any start/end DateTime pair, output matches "HH:MM - HH:MM"; for null end, output is "HH:MM"
    - **Validates: Requirements 2.4, 2.5**

  - [x] 5.7 Write property test: date formatting (Property 3)
    - **Property 3: Date formatting produces day-of-week and date**
    - For any valid DateTime, the formatting function produces a non-empty string with a recognizable date
    - **Validates: Requirements 2.3**

  - [x] 5.8 Write property test: event part type label mapping (Property 8)
    - **Property 8: Event part type label mapping**
    - For any `EventPartType` value, the label function returns the correct localized string
    - **Validates: Requirements 8.3**

- [x] 6. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- No new backend endpoints are needed — the existing favorite toggle API and event list API are sufficient
- The `url_launcher` package is the only new dependency required
- Property tests validate universal correctness properties from the design document
- Existing sections and components are already scaffolded — tasks focus on wiring callbacks and adding the cubit layer
