# Dancee App — Task List

Derived from SPEC.md. Tasks ordered by dependency (setup → data → logic → UI → polish).

---

## Backend: Dance Styles API

- [x] 1. [HIGH] Add `listDanceStyles` function to `backend/dancee_workflow/src/clients/directus-client.ts` that fetches all dance styles with `code`, `name`, `parent_code`, `sort_order` from Directus
- [x] 2. [HIGH] Add `listDanceStyles` handler to `backend/dancee_workflow/src/services/api.ts` that returns the full dance styles list via the API
- [x] 3. [HIGH] Document the new `listDanceStyles` endpoint in `backend/dancee_api/specs/workflow.openapi.yaml`

## Frontend: Data Layer

- [x] 4. [HIGH] Add `DanceStyle` entity to `lib/features/events/data/entities.dart` with `code`, `name`, `parentCode` fields and `fromJson`/`toJson`
- [x] 5. [HIGH] Add `getDanceStyles()` method to `lib/features/events/data/event_repository.dart` that fetches dance styles from the API

## Frontend: Map Address Fix (Spec §1)

- [x] 6. [HIGH] In `lib/features/events/logic/event_detail.dart`, change `openMap()` to use `venue.address.fullAddress` (URL-encoded) as the Google Maps destination, falling back to coordinates if address is empty

## Frontend: Parent-Only Dance Styles in Filters (Spec §2)

- [x] 7. [HIGH] Modify `extractDanceTypes()` in `lib/features/events/logic/event_filter.dart` to accept a `List<DanceStyle>` parameter and return only parent style codes, aggregating child style event counts into their parent
- [x] 8. [HIGH] Modify `filterEvents()` in `lib/features/events/logic/event_filter.dart` so selecting a parent dance type also matches events tagged with any of its child styles
- [x] 9. [HIGH] Modify `countEventsForDanceType()` in `lib/features/events/logic/event_filter.dart` to account for parent-child style aggregation
- [x] 10. [HIGH] Update `EventFilterCubit` in `lib/features/events/logic/event_filter.dart` to load dance styles on init, store them in state, and expose them for UI consumption
- [x] 11. [MEDIUM] Update `DanceTypeFilterSection` in `lib/features/events/pages/event_filters/sections.dart` to display dance style display names (from `DanceStyle.name`) instead of raw codes
- [x] 12. [MEDIUM] Update `DanceTypeOption` in `lib/features/events/pages/event_filters/components.dart` to use dance style display names
- [x] 13. [HIGH] Wire dance styles loading in `lib/core/service_locator.dart` — ensure `EventFilterCubit` receives dance styles

## Frontend: Multi-Select Dance Style Chips on Event List (Spec §3)

- [x] 14. [HIGH] Add `toggleDanceType(String code)` method to `EventFilterCubit` in `lib/features/events/logic/event_filter.dart`
- [x] 15. [HIGH] Create `DanceStyleChipsRow` component in `lib/features/events/pages/event_list/components.dart` — horizontally scrollable row of toggle chips reading from `EventFilterCubit` state
- [x] 16. [HIGH] Add `DanceStyleChipsRow` to `SearchAndFiltersSection` in `lib/features/events/pages/event_list/sections.dart` below `FilterChipsRow`

## Frontend: CZ Regions + Abroad Location Filter (Spec §4)

- [x] 17. [HIGH] Add "abroad" translation key to `lib/i18n/strings.i18n.json` ("Abroad"), `strings_cs.i18n.json` ("Zahraničí"), `strings_es.i18n.json` ("Extranjero")
- [x] 18. [HIGH] Run `task slang` to regenerate translations
- [x] 19. [HIGH] Modify `extractRegions()` in `lib/features/events/logic/event_filter.dart` to separate CZ regions from foreign events, returning CZ regions + a single "Abroad" entry
- [x] 20. [HIGH] Modify `filterEvents()` in `lib/features/events/logic/event_filter.dart` to handle the "Abroad" region key — when selected, include non-CZ events; when nothing selected, show all
- [x] 21. [HIGH] Modify `countEventsForRegion()` in `lib/features/events/logic/event_filter.dart` to count foreign events for the "Abroad" option
- [x] 22. [MEDIUM] Update `LocationFilterSection` in `lib/features/events/pages/event_filters/sections.dart` to show CZ regions + "Abroad" option with event counts
- [x] 23. [LOW] Verify the free-text location search input remains hidden in `LocationFilterSection`

## Frontend: Dance Style Event Count Display (Spec §5)

- [x] 24. [MEDIUM] Verify `DanceTypeOption` in `lib/features/events/pages/event_filters/components.dart` displays the event count in parentheses; fix if missing

## Frontend: Favorites Heart Icon on Initial Load (Spec §6)

- [x] 25. [HIGH] Investigate and fix the favorites loading race condition — ensure `EventRepository.getAllEvents()` loads favorite IDs from SharedPreferences before constructing Event objects, and that `EventFilterCubit` preserves `isFavorite` through filtering
- [x] 26. [MEDIUM] Verify the fix by confirming heart icons are red on initial event list load for favorited events

## Frontend: Back Button Handling (Spec §7)

- [x] 27. [HIGH] Wrap the `Scaffold` in `AppLayout` (`lib/features/app/layouts.dart`) with `PopScope(canPop: false)` to prevent app exit on hardware back button when on main pages

## Code Generation & Validation

- [x] 28. [HIGH] Run `task build-runner` to regenerate freezed/json_serializable/go_router code after all changes
- [x] 29. [MEDIUM] Run `task test` to verify no regressions
- [x] 30. [LOW] Run `task slang-analyze` to verify no missing translation keys
