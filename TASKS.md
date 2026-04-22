# Tasks: CMS Flutter Integration

Derived from [CODE_REVIEW.md](CODE_REVIEW.md). Sorted by severity.

- [x] 1. [CRITICAL] Implement the entire courses feature: Course entity, CourseRepository, CourseCubit, course list page, course detail page, and courses tab in navigation
- [x] 2. [CRITICAL] Add `deep[translations][_filter][languages_code][_eq]` parameter to EventRepository.getAllEvents() and accept a languageCode parameter
- [x] 3. [CRITICAL] Implement SettingsCubit with SharedPreferences language persistence, slang LocaleSettings integration, and data re-fetch trigger on language change
- [x] 4. [CRITICAL] Replace local SharedPreferences favorites with CMS-synced favorites via FavoritesRepository calling Directus REST API (POST/DELETE /items/favorites)
- [x] 5. [CRITICAL] Add imageUrl field to Event entity, construct URL from Directus assets endpoint (`{baseUrl}/assets/{fileId}`), and display images in UI
- [x] 6. [CRITICAL] Create DanceStyle entity with fromDirectus() factory and DanceStyleRepository fetching translated dance styles from CMS with parent/child hierarchy
- [x] 7. [CRITICAL] Create Favorite entity with fromDirectus() factory and implement favorites resolution against loaded events/courses sorted by createdAt descending
- [x] 8. [HIGH] Add eventType field to Event entity, parse event_type from CMS, and implement "Featured events" section showing only festivals in horizontal scroll
- [x] 9. [HIGH] Refactor toggleFavorite() to use optimistic updates: emit toggled state immediately, call API in background, revert on failure
- [x] 10. [HIGH] Add MultiBlocProvider in main.dart wrapping MaterialApp.router to provide all cubits from getIt into the widget tree
- [x] 11. [HIGH] Add BlocListener on SettingsCubit to trigger re-fetch of events, courses, and dance styles when language changes
- [x] 12. [HIGH] Implement translation fallback chain in Event.fromDirectus(): requested language → English → first available → raw fields
- [ ] 13. [MEDIUM] Fix EventInfoType enum (text → dresscode) and add translation support to EventInfo.fromDirectus() and EventPart.fromDirectus()
- [ ] 14. [MEDIUM] Add id field to Venue entity and parse it from Directus JSON
- [ ] 15. [MEDIUM] Ensure FilterState and FilterCubit are shared between EventCubit and CourseCubit when courses feature is implemented
- [ ] 16. [MEDIUM] Simplify settings page to only show language selection (remove non-functional profile, account, app info placeholders)
- [ ] 17. [MEDIUM] Update extractRegions() to derive available regions from both events and courses venue data
- [ ] 18. [LOW] Align file structure with design document or document the deviation as intentional (current structure follows project steering)
- [ ] 19. [LOW] Add missing property tests: translation extraction (P3), fallback (P5), favorite resolution (P10), sort order (P11), optimistic update (P14/P15), language persistence (P16)
- [ ] 20. [LOW] Decide whether to keep FilterPersistenceService (contradicts Requirement 7.5 that filters reset on restart) or remove it
