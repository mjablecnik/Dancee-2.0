# Architecture Summary - Frontend API Integration

## Final Architecture Decision

Based on discussion, we've agreed on the following clean architecture:

### Components

1. **ApiClient** (`lib/core/clients/api_client.dart`)
   - Wraps Dio HTTP client
   - Converts DioException → ApiException
   - Provides: `get()`, `post()`, `delete()`, `checkHealth()`

2. **EventRepository** (`lib/repositories/event_repository.dart`)
   - **Data access layer with simple helper method**
   - Methods: `getAllEvents()`, `getFavoriteEvents()`, `addFavorite()`, `removeFavorite()`
   - Helper: `toggleFavorite(eventId, currentIsFavorite)` - decides add vs remove
   - Error handling: validates response + converts to ApiException with context

3. **EventListCubit** (`lib/cubits/event_list/`)
   - Caches all events in state (allEvents, todayEvents, tomorrowEvents, upcomingEvents)
   - Methods: `loadEvents()`, `searchEvents()`, `filterEvents()`, `toggleFavorite()`
   - `toggleFavorite()` calls repository.toggleFavorite()
   - `searchEvents()` and `filterEvents()` work on cached state.allEvents (local)

4. **FavoritesCubit** (`lib/cubits/favorites/`)
   - Caches favorite events in state (upcomingEvents, pastEvents)
   - Methods: `loadFavorites()`, `toggleFavorite()`
   - `toggleFavorite()` calls repository.toggleFavorite()

## Key Design Decisions

### Why NO cache in Repository?
- Repository is pure data access layer
- Cubits already cache data in their state
- Avoids duplication
- Clear separation of concerns

### Why toggleFavorite in Repository?
- Simple helper method (just if/else delegation)
- Avoids duplicating logic in both Cubits
- Not complex enough to warrant a separate service
- Repository still focuses on data access (helper just delegates)

### Why search/filter in Cubit?
- Cubits already have all events cached in state
- No need to call API for local operations
- Faster user experience
- Can be moved to API later if needed

## Error Handling Flow

```
ApiClient: DioException → ApiException (generic)
    ↓
Repository: catches exceptions → adds context → rethrows ApiException
    ↓
Cubit: catches ApiException → emits Error state with message
    ↓
UI: displays error message + retry button
```

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── api_config.dart
│   ├── exceptions/
│   │   └── api_exception.dart
│   └── clients/
│       └── api_client.dart
├── repositories/
│   └── event_repository.dart           ← With toggleFavorite helper
├── cubits/
│   ├── event_list/
│   │   ├── event_list_cubit.dart       ← Calls repository.toggleFavorite
│   │   └── event_list_state.dart
│   └── favorites/
│       ├── favorites_cubit.dart        ← Calls repository.toggleFavorite
│       └── favorites_state.dart
└── screens/
    ├── event_list_screen.dart
    └── favorites_screen.dart
```
