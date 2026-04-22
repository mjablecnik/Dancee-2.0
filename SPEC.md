# Dancee App — Bug Fixes & Feature Improvements Specification

## Overview

This specification covers 8 bug fixes and feature improvements for the Dancee Flutter app. All changes are frontend-only unless explicitly noted. The backend already has the necessary data structures (dance styles with `parent_code`, venue with `country`/`region`).

---

## 1. Map Opens with Address Instead of Coordinates

**Current behavior**: `EventDetailCubit.openMap()` opens Google Maps with `destination=${venue.latitude},${venue.longitude}`, which shows raw coordinates in the Maps UI.

**Required behavior**: Use the venue's full address as the destination so Google Maps displays a human-readable address.

**Technical approach**:
- In `EventDetailCubit.openMap()`, change the `destination` parameter from `${venue.latitude},${venue.longitude}` to the URL-encoded `venue.address.fullAddress`.
- Keep coordinates as a fallback: if `fullAddress` is empty, fall back to coordinates.

**File**: `lib/features/events/logic/event_detail.dart`

---

## 2. Dance Style Filters Show Only Parent Styles

**Current behavior**: `extractDanceTypes()` in `event_filter.dart` collects every unique dance string from all events (including sub-styles like `salsa-on1`, `salsa-on2`). The filter page and the event list both show all of them.

**Required behavior**: The dance type filter (both in the filter page and the horizontal scroll on the event list) should show only parent dance styles. Events tagged with a child style (e.g., `salsa-on2`) should count toward and match the parent style (e.g., `salsa`).

**Technical approach**:
- The backend `dance_styles` collection already has `code`, `name`, `parent_code`, and `sort_order` fields. The Flutter app needs to fetch this data.
- Add a new API handler `listDanceStyles` to the workflow service that returns all dance styles with their `parent_code`.
- Add a `DanceStyle` entity to the Flutter app with `code`, `name`, `parentCode`.
- Add a repository method to fetch dance styles.
- Modify `extractDanceTypes()` to accept the dance styles list and return only parent codes (styles where `parentCode` is null), aggregating child style counts into their parent.
- Modify `filterEvents()` so that when a parent dance type is selected, events with any child style of that parent also match.
- The `EventFilterCubit` should load dance styles on initialization and expose them.
- Update `DanceTypeFilterSection` and `DanceTypeOption` to use the dance style name (not raw code) for display.

**Files**:
- `backend/dancee_workflow/src/services/api.ts` — new `listDanceStyles` handler
- `backend/dancee_workflow/src/clients/directus-client.ts` — new `listDanceStyles` function
- `backend/dancee_api/specs/workflow.openapi.yaml` — document new endpoint
- `lib/features/events/data/entities.dart` — add `DanceStyle` entity
- `lib/features/events/data/event_repository.dart` — add `getDanceStyles()` method
- `lib/features/events/logic/event_filter.dart` — modify `extractDanceTypes()`, `filterEvents()`, `countEventsForDanceType()`
- `lib/core/service_locator.dart` — wire up dance styles loading
- `lib/features/events/pages/event_filters/sections.dart` — use dance style names
- `lib/features/events/pages/event_filters/components.dart` — use dance style names

---

## 3. Multi-Select Dance Style Chips on Event List Page

**Current behavior**: The event list page has a `SearchAndFiltersSection` with a search bar and `FilterChipsRow` (filter/date/location chips). There is no horizontal dance style selector on the event list page itself. Dance style filtering is only available via the full filter page.

**Required behavior**: Add a horizontally scrollable row of dance style chips below the existing filter chips on the event list/course list page. Tapping a chip toggles it (adds to filter on first tap, removes on second tap). Multiple chips can be selected simultaneously.

**Technical approach**:
- Create a new `DanceStyleChipsRow` component in `event_list/components.dart`.
- It reads dance styles from `EventFilterCubit` state and renders a horizontal `SingleChildScrollView` with toggle chips.
- Each chip shows the parent dance style name. Selected chips have a distinct visual style (filled/highlighted).
- Tapping a chip calls `EventFilterCubit.toggleDanceType(code)` which adds/removes from `selectedDanceTypes`.
- Add `DanceStyleChipsRow` to `SearchAndFiltersSection` below `FilterChipsRow`.

**Files**:
- `lib/features/events/pages/event_list/components.dart` — new `DanceStyleChipsRow` component
- `lib/features/events/pages/event_list/sections.dart` — add `DanceStyleChipsRow` to `SearchAndFiltersSection`
- `lib/features/events/logic/event_filter.dart` — add `toggleDanceType()` method to cubit

---

## 4. Location Filter: CZ Regions Only + "Abroad" Group

**Current behavior**: `extractRegions()` returns all unique regions from all events, regardless of country. All regions are shown as flat checkboxes.

**Required behavior**:
- Show only Czech Republic regions in the location filter.
- All non-CZ events are grouped under a single "Abroad" (translated: "Zahraničí" in CS, "Abroad" in EN, "Extranjero" in ES) option.
- The "Abroad" option shows the count of foreign events.
- Each CZ region shows its event count in parentheses.
- If nothing is selected, all events (including foreign) are shown.
- If any CZ region is selected (but not "Abroad"), only CZ events from those regions are shown.
- If "Abroad" is selected, foreign events are included.
- Hide the free-text location search field (it's already deferred/hidden per code comments, but verify).

**Technical approach**:
- The `Address` entity already has a `country` field. The `Venue` has a `region` field. Events from CZ have `country` set to a Czech country value (need to check actual data — likely `"CZ"`, `"Česko"`, or `"Czech Republic"`).
- Modify `extractRegions()` to accept a country filter and separate CZ regions from foreign ones.
- Add a constant `ABROAD_REGION_KEY` (e.g., `"__abroad__"`) used internally for the "Abroad" filter option.
- Modify `filterEvents()` to handle the "Abroad" key: if selected, include events where `venue.address.country` is not CZ.
- Add translations for "Abroad" to all 3 language files.
- Update `LocationFilterSection` to show CZ regions + the "Abroad" option.
- Ensure the free-text location search input remains hidden.

**Files**:
- `lib/features/events/logic/event_filter.dart` — modify `extractRegions()`, `filterEvents()`, `countEventsForRegion()`
- `lib/features/events/pages/event_filters/sections.dart` — update `LocationFilterSection`
- `lib/i18n/strings.i18n.json`, `strings_cs.i18n.json`, `strings_es.i18n.json` — add "abroad" translation
- `lib/features/events/data/entities.dart` — possibly add a helper to check if venue is in CZ

---

## 5. Dance Style Filter Page: Show Event Count per Style

**Current behavior**: `DanceTypeOption` in the filter page shows a checkbox with the dance type name but no event count.

**Required behavior**: Each dance style in the filter page should show a small number in parentheses indicating how many events have that style.

**Technical approach**:
- `countEventsForDanceType()` already exists and is used in the filter page. The count is already passed to `DanceTypeOption` as the `count` parameter.
- Verify that `DanceTypeOption` actually displays the count. If not, add it to the label display.
- After the parent-style changes (spec item 2), the count should aggregate child styles into the parent count.

**Files**:
- `lib/features/events/pages/event_filters/components.dart` — verify/fix `DanceTypeOption` count display

---

## 6. Favorites Heart Icon Not Showing on Initial Load

**Current behavior**: When the event list or course list loads fresh, the heart icons on event cards don't reflect the saved favorite status. They only update after the user taps any heart, which triggers a state update that refreshes all hearts.

**Root cause**: `EventRepository.getAllEvents()` loads favorite IDs from `SharedPreferences` and marks events with `isFavorite: true` in `Event.fromDirectus()`. However, the issue is likely that the `EventFilterCubit` caches `filteredEvents` and doesn't pick up the `isFavorite` flag correctly, OR the `EventListCubit` emits state before favorites are loaded from SharedPreferences.

**Required behavior**: When events are first loaded and displayed, the heart icons must immediately reflect the correct favorite status.

**Technical approach**:
- Investigate the timing: `EventListCubit` calls `loadEvents()` in its constructor, which calls `_repository.getAllEvents()`. The repository loads favorite IDs from SharedPreferences before mapping events. This should work.
- The likely issue is that `EventFilterCubit` listens to `EventListCubit` and stores `filteredEvents` in its state. When `EventListCubit` emits `loaded`, `EventFilterCubit` re-filters and emits new state. The UI rebuilds from `EventFilterCubit.state.filteredEvents` (via `filterState.todayEvents`, etc.). Check if the filtered events preserve the `isFavorite` flag.
- Another possibility: the `EventFilterCubit` is initialized (eager singleton) before `EventListCubit` loads events, and the initial filter state has empty events. When `EventListCubit` later emits loaded state, the filter cubit should pick it up via stream subscription.
- Debug by checking the data flow: `EventListCubit.loadEvents()` → emits `loaded(allEvents)` → `EventFilterCubit._onEventListChanged()` → re-filters → emits new `EventFilterState` with `filteredEvents`. The `isFavorite` flag should be preserved through filtering.
- If the issue is a race condition in SharedPreferences loading, ensure `getAllEvents()` awaits the favorites load before constructing events.

**Files**:
- `lib/features/events/logic/event_list.dart` — investigate and fix timing
- `lib/features/events/logic/event_filter.dart` — verify isFavorite preservation
- `lib/features/events/data/event_repository.dart` — verify favorites loading order

---

## 7. Prevent App Exit on Hardware Back Button

**Current behavior**: Pressing the hardware back button on main pages (event list, course list, favorites, profile/settings) closes the app entirely.

**Required behavior**:
- On main pages (pages with bottom navigation bar visible): hardware back button should do nothing (don't exit the app).
- On detail pages or sub-pages: hardware back button should navigate back normally.

**Technical approach**:
- Use Flutter's `PopScope` widget (replaces deprecated `WillPopScope`) in the `AppLayout` shell route.
- Set `canPop: false` to prevent the app from popping the last route (which would exit the app).
- The `onPopInvokedWithResult` callback can be left empty (do nothing) since we want to block the back action on main pages.
- Detail pages (EventDetailPage, EventFiltersPage, etc.) are outside the shell route and should continue to allow normal back navigation — they don't need any changes.

**Files**:
- `lib/features/app/layouts.dart` — wrap `Scaffold` with `PopScope(canPop: false)`

---

## 8. Free-Text Location Search Field: Ensure Hidden

**Current behavior**: Per code comments, the free-text location search input is intentionally deferred. Verify it's not visible.

**Required behavior**: The field must not be visible in the location filter section.

**Technical approach**:
- Verify in `LocationFilterSection` that no text input is rendered.
- This is likely already done (the code comments say it's deferred), but confirm.

**File**: `lib/features/events/pages/event_filters/sections.dart`

---

## Constraints & Edge Cases

1. **Dance style hierarchy**: The backend `dance_styles` collection has `parent_code`. A style with `parent_code: null` is a parent. A style with `parent_code: "salsa"` is a child of salsa. The frontend must fetch this hierarchy.
2. **Country detection for CZ**: Need to determine the exact `country` value used in Directus data (e.g., `"CZ"`, `"Česko"`, `"Czech Republic"`, `"Czechia"`). The filter logic should handle the actual value. May need to check a few events' data or use a set of known CZ country values.
3. **"Abroad" filter semantics**: When no region is selected at all, show everything. When only CZ regions are selected, show only those CZ regions. When "Abroad" is selected (alone or with CZ regions), include foreign events too.
4. **Favorites race condition**: The fix must ensure SharedPreferences favorites are loaded before events are mapped, not after.
5. **Back button**: `PopScope` only affects the shell route pages. Detail pages pushed on top of the shell route are not affected and will navigate back normally.
6. **Translations**: All new user-facing strings must be added to all 3 language files (EN, CS, ES) and `task slang` must be run.
7. **API documentation sync**: The new `listDanceStyles` endpoint must be documented in `backend/dancee_api/specs/workflow.openapi.yaml`.

---

## File Structure Summary

No new files are created (except possibly a new API handler). Changes are to existing files:

**Backend**:
- `backend/dancee_workflow/src/services/api.ts` — new `listDanceStyles` handler
- `backend/dancee_workflow/src/clients/directus-client.ts` — new `listDanceStyles` function
- `backend/dancee_api/specs/workflow.openapi.yaml` — document new endpoint

**Frontend — Data layer**:
- `lib/features/events/data/entities.dart` — add `DanceStyle` entity
- `lib/features/events/data/event_repository.dart` — add `getDanceStyles()` method

**Frontend — Logic layer**:
- `lib/features/events/logic/event_detail.dart` — fix map URL
- `lib/features/events/logic/event_filter.dart` — parent-only dance types, CZ/abroad regions, toggleDanceType method
- `lib/features/events/logic/event_list.dart` — investigate favorites timing

**Frontend — UI layer**:
- `lib/features/events/pages/event_list/components.dart` — new `DanceStyleChipsRow`
- `lib/features/events/pages/event_list/sections.dart` — add dance style chips to search section
- `lib/features/events/pages/event_filters/sections.dart` — update location filter, verify dance type count
- `lib/features/events/pages/event_filters/components.dart` — verify count display, use dance style names
- `lib/features/app/layouts.dart` — add `PopScope` for back button handling

**Frontend — DI**:
- `lib/core/service_locator.dart` — wire dance styles loading

**Frontend — i18n**:
- `lib/i18n/strings.i18n.json` — add "abroad" key
- `lib/i18n/strings_cs.i18n.json` — add "abroad" key (Zahraničí)
- `lib/i18n/strings_es.i18n.json` — add "abroad" key (Extranjero)
