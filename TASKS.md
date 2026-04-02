# Tasks: Event Search & Filter Feature

Derived from [CODE_REVIEW.md](./CODE_REVIEW.md).

- [x] 1. [HIGH] Fix header reset button in `EventFiltersPage` — should only reset local draft state, not call `resetFilters()` on the cubit (which clears saved persistence)
- [x] 2. [HIGH] Fix footer "Clear all" button in `EventFiltersPage` — should only reset local draft state, not immediately apply empty filters to the cubit or clear persistence
- [ ] 3. [MEDIUM] Trim whitespace from search query in `filterEvents()` and `getActiveFilterCount()` to prevent whitespace-only queries from showing zero results
- [ ] 4. [MEDIUM] Add a proper confirmation i18n key (`eventFilters.filtersSaved`) for the save snackbar instead of reusing the section title `eventFilters.saveFilter`
- [ ] 5. [MEDIUM] Add try/catch error handling around `persistFilters()` call in the save action of `EventFiltersPage`
- [ ] 6. [MEDIUM] Trim search query in `EventFilterCubit.updateSearchQuery()` or in `filterEvents()` to handle whitespace-padded input (can be combined with task 3)
- [ ] 7. [LOW] Clear filtered results in `EventFilterCubit` when `EventListCubit` emits an error state to avoid showing stale data
- [ ] 8. [LOW] Remove unused grouped fields (`todayEvents`, `tomorrowEvents`, `upcomingEvents`) from `EventListLoaded` since the UI now reads from `EventFilterCubit`
- [ ] 9. [LOW] Prevent redundant `updateSearchQuery('')` call when `BlocListener` syncs the search text controller after a filter reset
