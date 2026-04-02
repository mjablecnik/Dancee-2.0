# Tasks — Dancee App Frontend Improvements

- [x] 1. [CRITICAL] Add error handling and logging to FilterPersistenceService.saveFilters/clearFilters/loadFilters
- [x] 2. [CRITICAL] Fix inconsistent whitespace handling between updateSearchQuery (trims) and applyFilters (doesn't trim)
- [x] 3. [CRITICAL] Inject EventListCubit into FavoritesCubit constructor instead of accessing getIt directly
- [x] 4. [HIGH] Add user-facing error feedback in EventDetailCubit.openMap and openUrl instead of silent catch
- [x] 5. [HIGH] Accept optional DateTime parameter in Event.fromDirectus for deterministic isPast computation
- [x] 6. [HIGH] Replace print() with developer.log() in DirectusClient LogInterceptor and guard behind debug flag
- [x] 7. [HIGH] Add tests for EventFilterCubit stream subscription and debounce timer cleanup on close()
- [x] 8. [HIGH] Preserve loaded state in EventListCubit.toggleFavorite on error instead of emitting error state
- [ ] 9. [MEDIUM] Add Event.fromJson() factory or document that toJson() is not round-trippable with fromDirectus()
- [ ] 10. [MEDIUM] Log warning in EventPart.fromDirectus when start time is missing instead of silently using DateTime.now()
- [ ] 11. [MEDIUM] Add dateFrom/dateTo validation in EventFiltersPage._updateDraft to prevent invalid ranges
- [ ] 12. [MEDIUM] Add test for FilterPersistenceService behavior when SharedPreferences write fails
- [ ] 13. [MEDIUM] Add safeguard in EventRepository.getFavoriteEvents for large favorite ID lists exceeding URL limits
- [ ] 14. [MEDIUM] Add test for EventListCubit error recovery after toggleFavorite failure
- [ ] 15. [LOW] Replace hardcoded 'Retry' fallback in AppErrorMessage with t.retry translation
- [ ] 16. [LOW] Extract duplicated dance type icon/color mappings into a single shared utility
- [ ] 17. [LOW] Consider using BlocProvider/context.read instead of direct getIt access in EventFiltersPage
- [ ] 18. [LOW] Add test for EventFilterCubit.persistFilters (save draft without applying)
