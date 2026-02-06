# Frontend REST API Integration - Spec

## Overview

This spec defines the integration of the dancee_event_service backend REST API with the dancee_app frontend Flutter application using the Dio HTTP client.

## Architecture

Clean architecture with clear separation of concerns:

```
UI (Screens)
    ↓
State Management (Cubits) - caches data, business logic
    ↓
Data Access (EventRepository) - API calls + simple helper
    ↓
HTTP Client (ApiClient) - Dio wrapper
    ↓
Backend REST API
```

## Key Components

### 1. ApiClient (`lib/core/clients/api_client.dart`)
- Wraps Dio HTTP client
- Converts DioException → ApiException
- Methods: `get()`, `post()`, `delete()`, `checkHealth()`

### 2. EventRepository (`lib/repositories/event_repository.dart`)
- **Data access layer with simple helper method**
- Methods: `getAllEvents()`, `getFavoriteEvents()`, `addFavorite()`, `removeFavorite()`
- Helper: `toggleFavorite(eventId, currentIsFavorite)` - decides add vs remove
- Validates responses and adds error context

### 3. EventListCubit (`lib/cubits/event_list/`)
- Caches all events in state
- Methods: `loadEvents()`, `searchEvents()`, `filterEvents()`, `toggleFavorite()`
- Search/filter work on cached state (local, fast)

### 4. FavoritesCubit (`lib/cubits/favorites/`)
- Caches favorite events in state
- Methods: `loadFavorites()`, `toggleFavorite()`

## Key Design Decisions

### Why NO cache in Repository?
- Repository is pure data access layer
- Cubits already cache data in their state
- Avoids duplication
- Clear separation of concerns

### Why toggleFavorite in Repository?
- Simple helper method that delegates to addFavorite/removeFavorite
- Avoids duplicating if/else logic in both Cubits
- Still keeps Repository focused on data access
- Not complex enough to warrant a separate service

### Why search/filter in Cubit?
- Cubits already have all events cached in state
- No need to call API for local operations
- Faster user experience
- Can be moved to API later if needed

## Error Handling

Three-layer error handling:

1. **ApiClient**: DioException → ApiException (generic)
2. **Repository**: catches exceptions → adds context → rethrows ApiException
3. **Cubit**: catches ApiException → emits Error state with message

## Files

### Spec Documents
- `requirements.md` - 18 requirements with acceptance criteria
- `design.md` - Technical design with code examples
- `tasks.md` - 14 implementation tasks with subtasks
- `ARCHITECTURE_SUMMARY.md` - Quick architecture reference
- `CHANGES.md` - Summary of changes from discussion

### Implementation Files (to be created)
- `lib/core/config/api_config.dart`
- `lib/core/exceptions/api_exception.dart`
- `lib/core/clients/api_client.dart`
- `lib/repositories/event_repository.dart` ← UPDATED (with toggleFavorite helper)
- `lib/cubits/event_list/event_list_cubit.dart` ← UPDATED
- `lib/cubits/favorites/favorites_cubit.dart` ← UPDATED
- `lib/di/service_locator.dart` ← UPDATED

## Getting Started

1. Read `ARCHITECTURE_SUMMARY.md` for quick overview
2. Read `requirements.md` for detailed requirements
3. Read `design.md` for technical design
4. Follow `tasks.md` for implementation

## Testing Strategy

- **Unit tests**: Test individual components (ApiClient, Repository, Service, Cubits)
- **Property tests**: Test universal properties (serialization, error handling, state transitions)
- **Integration tests**: Test end-to-end flows

## Translation

All user-facing strings use slang translations:
- `lib/i18n/strings.i18n.json` (English)
- `lib/i18n/strings_cs.i18n.json` (Czech)
- `lib/i18n/strings_es.i18n.json` (Spanish)

Run `task slang` after modifying translation files.

## Next Steps

Start implementing tasks from `tasks.md`:
1. Add Dio dependency
2. Implement ApiClient
3. Add translation keys
4. Implement EventRepository (pure data access)
5. Implement FavoritesService (shared logic)
6. Update Cubits
7. Update dependency injection
8. Update UI screens

## Questions?

See `CHANGES.md` for rationale behind architectural decisions.
