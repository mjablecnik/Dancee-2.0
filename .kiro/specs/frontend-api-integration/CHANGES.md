# Changes to Spec Based on Discussion

## Summary of Changes

Based on our discussion, the following architectural changes have been made:

### 1. EventRepository - Data Access Layer with Simple Helper
**REMOVED:**
- `_cachedEvents` field (no caching in repository)
- `searchEvents()` method (moved to EventListCubit)
- `filterEvents()` method (moved to EventListCubit)
- `getEventsByDate()` method (not needed)

**KEPT:**
- `getAllEvents()` - calls API, validates, parses
- `getFavoriteEvents()` - calls API, validates, parses
- `addFavorite()` - calls API
- `removeFavorite()` - calls API

**ADDED:**
- `toggleFavorite(eventId, currentIsFavorite)` - simple helper that delegates to add/remove

**IMPROVED:**
- Better error handling with context
- Response validation before parsing
- Converts FormatException to ApiException

### 2. EventListCubit - Enhanced with Business Logic
**ADDED:**
- `searchEvents()` - searches in cached state.allEvents (local)
- `filterEvents()` - filters cached state.allEvents (local)

**CHANGED:**
- `toggleFavorite()` now calls repository.toggleFavorite()
- Updates state locally without reloading

### 3. FavoritesCubit - Enhanced with Business Logic
**CHANGED:**
- `toggleFavorite()` now calls repository.toggleFavorite()

### 4. Dependency Injection
**SIMPLIFIED:**
- No FavoritesService to register
- Cubits only depend on EventRepository

## Rationale

### Why remove cache from Repository?
- Repository should be pure data access layer
- Cubits already cache data in their state
- Avoids duplication
- Clear separation of concerns

### Why toggleFavorite in Repository?
- It's a simple helper method (just if/else delegation)
- Avoids duplicating the if/else logic in both Cubits
- Not complex enough to warrant a separate service
- Repository still focuses on data access (the helper just delegates to existing methods)

### Why NOT create FavoritesService?
- Over-engineering for one simple method
- Adds unnecessary complexity (extra file, extra DI registration)
- The logic is trivial (if true → remove, if false → add)
- YAGNI principle (You Aren't Gonna Need It)

### Why move search/filter to Cubit?
- Cubits already have all events cached in state
- No need to call API for local operations
- Faster user experience
- Can be moved to API later if needed

## Implementation Impact

### Tasks to Update:
1. Remove cache-related code from EventRepository tasks
2. Add toggleFavorite helper method to EventRepository
3. Update Cubit tasks to call repository.toggleFavorite()
4. Update dependency injection task (simpler - no FavoritesService)
5. Update tests to reflect new architecture

### Requirements Impact:
- Requirement 7 (Toggle Favorite) - implementation in EventRepository as helper method
- Requirement 18 (Search and Filter) - implementation moved from Repository to Cubit
- No changes to API requirements (still same endpoints)

### Design Impact:
- Simpler architecture (no extra service layer)
- Cleaner separation of concerns
- Easier to understand and maintain
- Less boilerplate code
