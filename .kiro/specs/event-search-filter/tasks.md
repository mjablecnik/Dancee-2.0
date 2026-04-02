# Implementation Plan: Event Search & Filter

## Overview

Implement local search and filtering for the Dancee App event list. This adds a `FilterState` data model (freezed), an `EventFilterCubit` for filter logic, a `FilterPersistenceService` for optional SharedPreferences persistence, upgrades the existing placeholder `EventFiltersPage` to a fully interactive filter page, and wires the event list page to display filtered results. All filtering is local — no API changes needed.

## Tasks

- [x] 1. Update data models and add FilterState
  - [x] 1.1 Add `region` field to the `Venue` entity
    - Add `region` String field to `Venue` class, constructor, `fromDirectus`, `toJson`, `copyWith`, and `props`
    - Default to empty string when `region` is absent or null in Directus JSON
    - _Requirements: 4.7_

  - [x] 1.2 Create `FilterState` and `EventFilterState` freezed models
    - Create `lib/features/events/logic/event_filter.dart`
    - Define `FilterState` with freezed: `searchQuery`, `selectedDanceTypes` (Set<String>), `selectedRegions` (Set<String>), `dateFrom`, `dateTo`
    - Add `fromJson`/`toJson` via json_serializable for persistence
    - Define `EventFilterState` with freezed: `filters`, `filteredEvents`, `todayEvents`, `tomorrowEvents`, `upcomingEvents`
    - Run `task build-runner` to generate freezed/json code
    - _Requirements: 7.2, 7.3_

  - [x]* 1.3 Write property test for Venue region parsing (Property 8)
    - **Property 8: Venue region parsing from Directus JSON**
    - **Validates: Requirements 4.7**

  - [x]* 1.4 Write property test for FilterState serialization round trip (Property 7)
    - **Property 7: FilterState serialization round trip**
    - **Validates: Requirements 7.2, 7.3**

- [x] 2. Implement FilterPersistenceService
  - [x] 2.1 Create `FilterPersistenceService`
    - Create `lib/features/events/data/filter_persistence_service.dart`
    - Implement `loadFilters()` — read JSON from SharedPreferences, deserialize to `FilterState`, return `null` on failure
    - Implement `saveFilters(FilterState)` — serialize to JSON, write to SharedPreferences
    - Implement `clearFilters()` — remove key from SharedPreferences
    - Use key `saved_event_filters`
    - _Requirements: 7.2, 7.3, 7.4, 7.5_

  - [x]* 2.2 Write unit tests for FilterPersistenceService
    - Test save and load round trip
    - Test corrupt JSON returns null
    - Test clearFilters removes from storage
    - _Requirements: 7.2, 7.3, 7.4, 7.5_

- [x] 3. Implement EventFilterCubit with core filter logic
  - [x] 3.1 Implement pure filter function and helper methods
    - In `event_filter.dart`, implement `applyFilters(events, filters)` as a static/top-level pure function
    - Implement `extractDanceTypes(events)` — returns sorted unique dance types from all events
    - Implement `extractRegions(events)` — returns sorted unique non-empty regions from all events
    - Implement `countEventsForDanceType(events, danceType, filters)` — cross-filter count ignoring current dance type selections
    - Implement `countEventsForRegion(events, region, filters)` — cross-filter count ignoring current region selections
    - Implement `getActiveFilterCount(filters)` — count of non-empty filter categories
    - Implement quick date preset computation: Today, Tomorrow, This Week, Weekend
    - _Requirements: 1.2, 1.3, 3.1, 3.3, 3.4, 3.5, 4.1, 4.3, 4.4, 4.5, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 6.1, 6.2_

  - [x] 3.2 Implement EventFilterCubit
    - Subscribe to `EventListCubit` stream to receive all events
    - Implement `applyFilters(FilterState)` — set filters and re-compute filtered + grouped events
    - Implement `resetFilters()` — clear all filters, clear saved filters from persistence
    - Implement `updateSearchQuery(String)` — with 300ms debounce timer
    - Implement `saveFilters()` — persist current FilterState via FilterPersistenceService
    - Implement `restoreFilters()` — load from persistence on startup, fallback to empty state
    - Re-apply filters automatically when EventListCubit emits new loaded state
    - Group filtered events into today/tomorrow/upcoming (reuse grouping logic)
    - _Requirements: 1.2, 1.3, 6.1, 6.2, 6.5, 7.1, 7.2, 7.3, 7.5, 7.6, 9.1, 9.2_

  - [x]* 3.3 Write property test for combined AND filter correctness (Property 1)
    - **Property 1: Combined AND filter correctness**
    - **Validates: Requirements 1.2, 1.3, 3.3, 3.4, 4.3, 4.4, 5.2, 5.3, 5.4, 5.5, 6.1, 9.1, 9.2**

  - [x]* 3.4 Write property test for dance type extraction (Property 2)
    - **Property 2: Dance type extraction returns all unique dances**
    - **Validates: Requirements 3.1**

  - [x]* 3.5 Write property test for region extraction (Property 3)
    - **Property 3: Region extraction returns all unique regions**
    - **Validates: Requirements 4.1**

  - [x]* 3.6 Write property test for cross-filter count accuracy (Property 4)
    - **Property 4: Per-option cross-filter event count accuracy**
    - **Validates: Requirements 3.5, 4.5**

  - [x]* 3.7 Write property test for active filter category count (Property 5)
    - **Property 5: Active filter category count**
    - **Validates: Requirements 6.3, 8.1**

  - [x]* 3.8 Write property test for quick date preset computation (Property 6)
    - **Property 6: Quick date preset computation**
    - **Validates: Requirements 5.7**

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Add i18n translation keys
  - [x] 5.1 Add new translation keys to all three language files
    - Add keys to `strings.i18n.json` (en), `strings_cs.i18n.json` (cs), `strings_es.i18n.json` (es)
    - New keys needed: `eventFilters.noEventsMatch`, `eventFilters.showEvents` (with `{count}` param), `eventFilters.activeFilterCount` (with `{count}` param), `eventFilters.noResults`
    - Run `task slang` to regenerate translations
    - _Requirements: 10.1, 10.2, 10.3, 10.4_

- [x] 6. Register dependencies in service locator
  - [x] 6.1 Register FilterPersistenceService and EventFilterCubit in DI
    - Register `FilterPersistenceService` as lazy singleton
    - Register `EventFilterCubit` as lazy singleton, injecting `EventListCubit` and `FilterPersistenceService`
    - Call `restoreFilters()` on EventFilterCubit after registration
    - _Requirements: 7.3_

- [x] 7. Upgrade EventFiltersPage to interactive filter page
  - [x] 7.1 Refactor EventFiltersPage to StatefulWidget with draft FilterState
    - Convert `EventFiltersPage` to accept optional `scrollTo` parameter for auto-scrolling to a section
    - Update `EventFiltersRoute` to pass `scrollTo` query parameter
    - Maintain local draft `FilterState` in the StatefulWidget
    - Initialize draft from current `EventFilterCubit` filters on page open
    - _Requirements: 2.1, 2.2, 2.3, 2.5, 2.6_

  - [x] 7.2 Wire DanceTypeFilterSection to draft state
    - Populate dance type list dynamically from `extractDanceTypes(allEvents)`
    - Show checkboxes reflecting draft `selectedDanceTypes`
    - Toggle dance types in draft state on tap
    - Display cross-filter count next to each option using `countEventsForDanceType`
    - Wire "Clear" button to deselect all dance types in draft
    - _Requirements: 3.1, 3.2, 3.3, 3.5, 3.6_

  - [x] 7.3 Wire LocationFilterSection to draft state
    - Populate region list dynamically from `extractRegions(allEvents)`
    - Show checkboxes reflecting draft `selectedRegions`
    - Toggle regions in draft state on tap
    - Display cross-filter count next to each option using `countEventsForRegion`
    - Wire "Clear" button to deselect all regions in draft
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.6_

  - [x] 7.4 Wire DateRangeFilterSection to draft state
    - Wire "From" and "To" date input fields to draft `dateFrom`/`dateTo`
    - Open date picker on tap
    - Wire quick date preset buttons (Today, Tomorrow, This Week, Weekend) to populate draft dates
    - Wire "Clear" button to clear both date fields in draft
    - _Requirements: 5.1, 5.2, 5.6, 5.7, 5.8_

  - [x] 7.5 Wire footer actions and live preview count
    - Compute live matching count from draft FilterState against all events using `applyFilters` pure function
    - Display count in footer (e.g., "Show 42 events")
    - "Apply filters" button pushes draft to `EventFilterCubit.applyFilters()` and pops back
    - "Clear all" button resets draft to empty FilterState
    - Update `ActiveFiltersSummary` to show real active filter count and matching event count
    - _Requirements: 6.3, 6.4, 6.5, 9.1, 9.2, 9.3, 9.4_

  - [x] 7.6 Wire SaveFilterSection
    - "Save filters" button calls `EventFilterCubit.saveFilters()` with current draft
    - Show feedback (snackbar) on save success/failure
    - _Requirements: 7.2, 7.6_

  - [x] 7.7 Wire reset button in header
    - Reset button clears all draft filter selections on the Filter_Page
    - _Requirements: 2.4_

- [x] 8. Update Event List Page to use EventFilterCubit
  - [x] 8.1 Wire SearchAndFiltersSection to EventFilterCubit
    - Replace `EventListCubit.searchEvents()` calls with `EventFilterCubit.updateSearchQuery()`
    - Add 300ms debounce in the search text field change handler
    - Show clear button only when text is present
    - _Requirements: 1.1, 1.2, 1.4_

  - [x] 8.2 Wire FilterChipsRow to EventFilterCubit state
    - "Filters" chip shows active filter category count as badge from `EventFilterCubit`
    - "Filters" chip navigates to `EventFiltersRoute()` on tap
    - Date chip navigates to `EventFiltersRoute(scrollTo: 'date')` on tap
    - Location chip navigates to `EventFiltersRoute(scrollTo: 'location')` on tap
    - Visually distinguish active vs inactive chips based on filter state
    - _Requirements: 2.1, 2.5, 2.6, 8.1, 8.2, 8.3, 8.4_

  - [x] 8.3 Wire EventListPage to read filtered events from EventFilterCubit
    - Replace `BlocBuilder<EventListCubit>` with `BlocBuilder<EventFilterCubit>` for the event list display
    - Read `todayEvents`, `tomorrowEvents`, `upcomingEvents` from `EventFilterState`
    - Show empty state message when filtered results are empty and filters are active
    - Keep `EventListCubit` for loading/error states
    - Favorites page remains unaffected — always shows all favorited events
    - _Requirements: 1.5, 6.1, 6.2_

- [x] 9. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Integration testing
  - [x]* 10.1 Write unit tests for EventFilterCubit
    - Test empty event list returns empty filtered list
    - Test search with whitespace-only query
    - Test filter with dance types not present in any event returns empty
    - Test date range where from > to returns empty
    - Test re-apply filters when EventListCubit emits new loaded state
    - Test quick date presets on edge days (Sunday for "This Week", Saturday for "Weekend")
    - _Requirements: 1.2, 1.3, 1.5, 3.3, 3.4, 5.2, 6.1_

  - [x]* 10.2 Write unit tests for Venue region parsing edge cases
    - Test Venue with missing region field defaults to empty string
    - Test Venue with null region defaults to empty string
    - Test Venue with valid region string parses correctly
    - _Requirements: 4.7_

- [x] 11. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- No backend/API changes needed — all filtering is local
- The design uses Dart (not pseudocode), so all code examples use Dart
