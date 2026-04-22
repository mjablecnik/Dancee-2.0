# TASKS: Fix Broken Buttons & Links in dancee_app2

- [x] 1. [HIGH] Add `url_launcher` dependency to `pubspec.yaml` and run `task get-deps`
- [x] 2. [HIGH] Create `lib/shared/utils/url_launcher.dart` with `openUrl(String url)` and `openMap(double lat, double lng, String label)` utility functions
- [x] 3. [HIGH] Wire `onSource` callback in `event_detail_screen.dart` to open `event.originalUrl` via `openUrl()`
- [x] 4. [HIGH] Wire `onBuyTickets` callback in `event_detail_screen.dart` to open `event.registrationUrl` via `openUrl()`
- [x] 5. [HIGH] Wire `onMap` callback in `event_detail_screen.dart` to open map with venue coordinates via `openMap()` (enable only when venue has non-zero lat/lng)
- [x] 6. [HIGH] Wire `onSource` callback in `course_detail_screen.dart` to open `course.originalUrl` via `openUrl()`
- [x] 7. [HIGH] Wire `onRegister` callback in `course_detail_screen.dart` to open `course.registrationUrl` via `openUrl()`
- [x] 8. [HIGH] Add `onTap` navigation to `UpcomingEventCard` in `saved_events_list_section.dart` to navigate to `/events/detail?id=<id>`
- [ ] 9. [HIGH] Add `onTap` navigation to `CourseListCard` in `saved_events_list_section.dart` to navigate to `/courses/detail?id=<id>`
- [ ] 10. [MEDIUM] Verify the app builds successfully with `task build-web`
