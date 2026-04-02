# Tasks: Event Search & Filter Feature

Derived from [CODE_REVIEW.md](CODE_REVIEW.md).

- [x] 1. [MEDIUM] Decouple "Save filter" from "Apply filters" — add `persistFilters(FilterState)` method to `EventFilterCubit` and update `SaveFilterSection.onSave` to save the draft without applying it
- [x] 2. [MEDIUM] Wire "Clear all" (footer) and "Reset" (header) buttons to clear persisted filters via `EventFilterCubit.resetFilters()` so saved filters don't reappear on app restart
- [x] 3. [MEDIUM] Add date range validation in `EventFiltersPage` — prevent or warn when `dateFrom > dateTo` (e.g., auto-swap dates, constrain picker, or show warning)
- [x] 4. [MEDIUM] Add `persistFilters(FilterState filters)` method to `EventFilterCubit` that saves an arbitrary FilterState to persistence without applying it to the cubit state
- [ ] 5. [LOW] Rename custom `FilterChip` class in `event_list/components.dart` to `EventFilterChip` to avoid naming conflict with Flutter's built-in `FilterChip`
- [ ] 6. [LOW] Consider adjusting `weekendPreset()` behavior on Sunday to show only today or next weekend instead of including yesterday (Saturday)
- [ ] 7. [LOW] Make `EventFiltersPage` reactive to `EventListCubit` state changes by wrapping content in a `BlocBuilder` instead of reading state synchronously via getter

Note: Tasks 1 and 4 are related — task 4 provides the API that task 1 needs. Implement task 4 first, then update the UI in task 1.
