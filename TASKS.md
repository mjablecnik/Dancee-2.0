# Tasks: CMS Flutter Integration

Derived from [CODE_REVIEW.md](CODE_REVIEW.md). Sorted by severity.

## Critical

- [x] 1. [CRITICAL] Implement the entire courses feature: `Course` entity, `CourseRepository`, `CourseCubit`, courses list page, course detail page, and add Courses tab to bottom navigation (Reqs 3, 6, 7, 9, 10, 14)
- [x] 2. [CRITICAL] Replace local SharedPreferences favorites with CMS-synced `FavoritesRepository` calling Directus `/items/favorites` endpoint using `AppConfig.userId` (Reqs 11, 12)
- [x] 3. [CRITICAL] Add `deep[translations][_filter][languages_code][_eq]` parameter to all Directus API calls and pass current language code from cubit to repository (Reqs 1.5, 15.1, 15.2)
- [x] 4. [CRITICAL] Implement language change re-fetch: add `BlocListener<SettingsCubit>` that triggers `loadEvents()`, `loadCourses()`, `loadDanceStyles()` on language change (Reqs 15.3–15.5, 16.6)
- [x] 5. [CRITICAL] Implement `SettingsCubit` with `SharedPreferences` language persistence, slang `LocaleSettings` integration, and `init()`/`setLanguage()` methods (Reqs 16.2–16.5)
- [x] 6. [CRITICAL] Create `DanceStyle` entity and `DanceStyleRepository` fetching from CMS `/items/dance_styles` with translations, and implement parent/child hierarchy expansion in filter logic (Reqs 8.1, 8.5)
- [x] 7. [CRITICAL] Add `eventType` field to `Event` entity and implement "Featured events" horizontal scroll section showing only festivals, hidden when empty (Reqs 4.2, 5.1–5.4)
- [x] 8. [CRITICAL] Add `imageUrl` field to `Event` entity, construct from `{directusBaseUrl}/assets/{fileId}` in `fromDirectus()`, and display images on event cards and detail pages (Reqs 2.1, 2.4)

## High

- [x] 9. [HIGH] Implement translation fallback chain in `Event.fromDirectus()`: requested language → English → first available translation (Reqs 2.5, 3.4)
- [x] 10. [HIGH] Apply `parts_translations` and `info_translations` from event translation object to `EventPart` and `EventInfo` parsing
- [x] 11. [HIGH] Implement optimistic updates for favorite toggling: emit new state immediately, call API, revert on failure (Reqs 12.4, 12.5)
- [x] 12. [HIGH] Add `MultiBlocProvider` in `main.dart` wrapping `MaterialApp.router` to provide all cubits in the widget tree
- [x] 13. [HIGH] Simplify settings page to show only language selection picker; remove non-functional placeholder sections (Req 16.8)
- [x] 14. [HIGH] Add `id` field to `Venue` entity and parse it from Directus JSON

## Medium

- [ ] 15. [MEDIUM] Create `Favorite` entity class with `id`, `userId`, `itemType`, `itemId`, `createdAt` fields and `fromDirectus()` factory
- [ ] 16. [MEDIUM] Rename `selectedDanceTypes` to `selectedDanceStyles` throughout codebase for consistency with specification
- [ ] 17. [MEDIUM] Extract shared `FilterCubit` from `EventFilterCubit` to manage `FilterState` shared between events and courses pages (Req 7)
- [ ] 18. [MEDIUM] Refactor `FavoritesState.loaded` to store favorite IDs (`Set<int>`) instead of full event objects; resolve against loaded data at render time
- [ ] 19. [MEDIUM] Add `filteredEvents` and `featuredEvents` fields to `EventListState.loaded` to match design state structure
- [ ] 20. [MEDIUM] Implement missing property tests P1–P16 as specified in the design document's testing strategy

## Low

- [ ] 21. [LOW] Verify `.gitignore` covers `lib/config.dart` and consider rotating the Directus access token
- [ ] 22. [LOW] Remove dead code: `FavoritesEmptyIcon` and `FavoritesFilterSection` classes in `favorites_page.dart`
- [ ] 23. [LOW] Evaluate whether `Address` class should be flattened into `Venue` to match design spec
- [ ] 24. [LOW] Accept `DateTime now` parameter in `EventListCubit._emitGrouped()` for deterministic testing
