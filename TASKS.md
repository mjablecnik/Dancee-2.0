# Tasks: CMS Flutter Integration

Derived from [CODE_REVIEW.md](CODE_REVIEW.md).

- [x] 1. [CRITICAL] Delete old mock repositories (`lib/data/event_repository.dart`, `lib/data/course_repository.dart`, `lib/data/city_repository.dart`) and update all files that import them
- [x] 2. [CRITICAL] Fix hardcoded `'en'` language in retry handlers — read current language from `SettingsCubit` in `EventsListScreen` and `CoursesListScreen`
- [x] 3. [CRITICAL] Delete dead `featured_courses_section.dart` and `featured_course_card.dart` that use old mock `CourseRepository` (Req 6.2: no featured courses)
- [x] 4. [HIGH] Wire `DanceStylesFilterSection` on list screens to `FilterCubit` — display translated names, reflect active selection, handle `onSelected` callback
- [x] 5. [HIGH] Replace hardcoded `'Praha, CZ'` in `EventsHeaderSection` with dynamic location derived from `FilterCubit.state.selectedRegions`
- [x] 6. [HIGH] Add error feedback (snackbar/notification) when favorite toggle fails in `FavoritesCubit` (Req 12.5)
- [x] 7. [HIGH] Add missing property tests: P1 (deep language filter), P2 (error-to-ApiException mapping), P4 (image URL construction), P5 (translation fallback chain), and repository/DirectusClient unit tests
- [ ] 8. [MEDIUM] Extract duplicated `_extractTranslation` helper from `event.dart`, `course.dart`, `dance_style.dart` into a shared utility
- [ ] 9. [MEDIUM] Extract UI-defining `_build*` private methods into separate widget classes (`SavedEventsListSection`, `SettingsSection`, `EventsHeaderSection`)
- [ ] 10. [MEDIUM] Extract duplicated `_formatDate`/`_formatTime` helpers into a shared utility and use localized month names instead of hardcoded English abbreviations
- [ ] 11. [MEDIUM] Replace hardcoded English strings with i18n keys: `'Event not found'`, `'Course not found'`, `'Lector:'`, `'DJ:'`, `'Program'`
- [ ] 12. [MEDIUM] Add `originalError` field to `ApiException` and pass `DioException` through in `DirectusClient._mapDioException`
- [ ] 13. [MEDIUM] Consider migrating from string-based `context.push('/path')` navigation to type-safe `@TypedGoRoute` routes (large refactor — track separately)
- [ ] 14. [MEDIUM] Align config pattern with spec — consider using `Config` class / `AppConfig` class instead of top-level constants with `export`
- [ ] 15. [LOW] Remove or implement the non-functional sort chip on events and courses list screens
- [ ] 16. [LOW] Remove unused `_buildQuickFilters` and `_buildQuickFilterPill` methods from `EventsHeaderSection`
- [ ] 17. [LOW] Implement URL launching for "Buy Tickets", "Source", "Register", and "Share" buttons in detail screens using `url_launcher`
- [ ] 18. [LOW] Add `sendTimeout` configuration to `DirectusClient` Dio options
