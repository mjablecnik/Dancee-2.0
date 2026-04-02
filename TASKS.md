# Tasks: Event Search & Filter Feature

Derived from [CODE_REVIEW.md](./CODE_REVIEW.md).

- [x] 1. [CRITICAL] Fix `weekendPreset` to return current weekend (today) when called on Sunday instead of skipping 6 days ahead
- [x] 2. [HIGH] Add empty state message for when no events exist at all (not just filtered out) on the event list page
- [x] 3. [HIGH] Extract date grouping logic (`_groupToday`, `_groupTomorrow`, `_groupUpcoming`) into a shared pure function used by both `EventFilterCubit` and `EventListCubit`
- [x] 4. [HIGH] Restyle "Show more dances" / "Show less" toggle to match design mockup (full-width button with gray background, border, rounded corners)
- [ ] 5. [MEDIUM] Document location section checkbox vs radio button design deviation (spec requires multi-select, design shows single-select)
- [ ] 6. [MEDIUM] Track custom location search input from design as a future enhancement (not in current spec)
- [ ] 7. [MEDIUM] Replace hardcoded 120px bottom padding in filter page ListView with dynamic footer height measurement
- [ ] 8. [MEDIUM] Add `BlocListener` to `SearchAndFiltersSection` to sync search bar text when filter state changes externally (e.g., after reset or restore)
- [ ] 9. [MEDIUM] Change apply button text to dedicated "Apply filters" key and keep event count only in the footer info line, matching the design
- [ ] 10. [MEDIUM] Add `eventFilters.applyFilters` translation key to all three language files (en, cs, es)
- [ ] 11. [LOW] Update `weekendPreset` comment after fixing the Sunday behavior
- [ ] 12. [LOW] No action — `_kDanceTypeInitialCount = 5` is a reasonable UX choice
- [ ] 13. [LOW] No action — eager singleton registration for `EventFilterCubit` is correctly documented
- [ ] 14. [LOW] Rename "This week" section header to "Upcoming" or limit the group to current week events only
