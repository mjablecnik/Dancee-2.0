# Changelog

## [Unreleased]

### Added
- **isPast field**: Events now include an `isPast` boolean field that indicates whether an event has already ended
  - Calculated automatically by the backend based on `endTime` (or `startTime` if `endTime` is not available)
  - Events are considered past if their end time is before the current server time
  - This field is included in all event responses (`/api/events/list` and `/api/events/favorites`)
  - Frontend favorites screen now correctly separates upcoming and past events

### Changed
- Updated Event model to include `isPast` field (not stored in Firestore, calculated on-the-fly)
- Modified `EventService.GetAllEvents()` to calculate and set `isPast` for all events
- Modified `EventService.GetFavorites()` to calculate and set `isPast` for favorite events
- Updated API documentation to reflect the new `isPast` field

### Technical Details
- The `isPast` calculation uses RFC3339 time parsing for ISO 8601 formatted timestamps
- If time parsing fails, the event is assumed to be not past (safe default)
- The field is marked with `firestore:"-"` tag to prevent storage in database (computed field)

## Previous Versions

No previous changelog entries available.
