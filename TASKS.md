# Tasks: Event Search & Filter — Code Review Fixes

- [x] 1. [CRITICAL] Fix `weekendPreset` returning past Saturday when called on Sunday — use forward-looking logic (`event_filter.dart`)
- [x] 2. [HIGH] Initialize search bar `TextEditingController` with current search query from `EventFilterCubit` state (`sections.dart`)
- [x] 3. [HIGH] Replace hardcoded "Prague" label on location filter chip with dynamic label reflecting selected regions (`components.dart`)
- [x] 4. [HIGH] Replace hardcoded "Today" label on date filter chip with dynamic label reflecting active date filter (`components.dart`)
- [x] 5. [MEDIUM] Implement collapsible "Show more dances" button for long dance type lists per design mockup (`event_filters/sections.dart`)
- [x] 6. [MEDIUM] Implement custom location text input field below region checkboxes per design mockup, or document as intentionally deferred (`event_filters/sections.dart`)
- [x] 7. [MEDIUM] Document that location filter uses multi-select checkboxes (per spec) instead of radio buttons (per design mockup) as intentional deviation
- [x] 8. [MEDIUM] Make `setupDependencies` async and await `restoreFilters()` to prevent flash of unfiltered content on startup (`service_locator.dart`, `main.dart`)
- [x] 9. [MEDIUM] Change `EventFilterCubit` registration from `registerLazySingleton` to `registerSingleton` since it's accessed immediately (`service_locator.dart`)
- [ ] 10. [LOW] Remove duplicate live count from apply button — use a dedicated "Apply filters" label and keep count only in footer info text (`sections.dart`)
- [ ] 11. [LOW] Rename custom `FilterChip` class to `EventFilterChip` to avoid conflict with Flutter's built-in `FilterChip` (`components.dart`)
- [ ] 12. [LOW] Document the `isAfter(tomorrow)` edge case in `_groupUpcoming` as a known minor inconsistency (`event_filter.dart`)
- [ ] 13. [LOW] Add `eventFilters.applyFilters` i18n key to all three language files and use it for the apply button label
