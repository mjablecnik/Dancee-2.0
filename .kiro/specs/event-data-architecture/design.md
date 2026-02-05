# Design Document

## Overview

This document describes the technical design for implementing a data architecture with repository pattern and Cubit state management for the Dancee Flutter application. The system centralizes event data management using hardcoded data initially, with architecture designed to easily transition to REST API data fetching in the future.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  ┌──────────────────────┐      ┌──────────────────────┐    │
│  │ EventListScreen      │      │ FavoritesScreen      │    │
│  │ (BlocBuilder)        │      │ (BlocBuilder)        │    │
│  └──────────┬───────────┘      └──────────┬───────────┘    │
└─────────────┼──────────────────────────────┼────────────────┘
              │                              │
┌─────────────┼──────────────────────────────┼────────────────┐
│             │    State Management Layer    │                │
│  ┌──────────▼───────────┐      ┌──────────▼───────────┐    │
│  │ EventListCubit       │      │ FavoritesCubit       │    │
│  │ - loadEvents()       │      │ - loadFavorites()    │    │
│  │ - searchEvents()     │      │ - toggleFavorite()   │    │
│  │ - filterEvents()     │      │                      │    │
│  └──────────┬───────────┘      └──────────┬───────────┘    │
└─────────────┼──────────────────────────────┼────────────────┘
              │                              │
              └──────────────┬───────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                    Data Layer                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ EventRepository                                      │   │
│  │ - getAllEvents()                                     │   │
│  │ - getFavoriteEvents()                                │   │
│  │ - getEventsByDate()                                  │   │
│  │ - toggleFavorite()                                   │   │
│  │ - searchEvents()                                     │   │
│  │ - filterEvents()                                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                             │                                │
│  ┌──────────────────────────▼────────────────────────────┐  │
│  │ Hardcoded Event Data (in-memory)                      │  │
│  │ Future: REST API calls                                │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Component Design

### 1. Data Models

#### Address Model

```dart
class Address {
  final String street;
  final String city;
  final String postalCode;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  Address copyWith({
    String? street,
    String? city,
    String? postalCode,
    String? country,
  });
  
  String get fullAddress => '$street, $postalCode $city, $country';
}
```

**Design Decisions:**
- Immutable class with const constructor
- Structured address fields for flexibility
- fullAddress getter for display purposes
- Separate fields allow for filtering/searching by city, country, etc.

#### Venue Model

```dart
class Venue {
  final String name;
  final Address address;
  final String description;
  final double latitude;
  final double longitude;

  const Venue({
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  Venue copyWith({
    String? name,
    Address? address,
    String? description,
    double? latitude,
    double? longitude,
  });
}
```

**Design Decisions:**
- Immutable class with const constructor
- Contains all venue information in one place
- Address object for structured location data
- Latitude/longitude for future map integration
- Description for venue details

#### EventInfo Model

```dart
enum EventInfoType {
  text,
  url,
  price,
}

class EventInfo {
  final EventInfoType type;
  final String key;
  final String value;

  const EventInfo({
    required this.type,
    required this.key,
    required this.value,
  });

  EventInfo copyWith({
    EventInfoType? type,
    String? key,
    String? value,
  });
}
```

**Design Decisions:**
- Flexible key-value structure for additional event information
- Type field allows UI to render differently (text, clickable URL, price formatting)
- Examples: {"type": "url", "key": "Facebook Event", "value": "https://..."}
- Examples: {"type": "price", "key": "Entry Fee", "value": "150 Kč"}
- Examples: {"type": "price", "key": "Workshop Only", "value": "50 EUR"}
- Examples: {"type": "text", "key": "Dress Code", "value": "Casual"}
- Price values include currency as string (e.g., "120 Kč", "50 EUR")

#### EventPart Model

```dart
enum EventPartType {
  party,
  workshop,
  openLesson,
}

class EventPart {
  final String name;
  final String? description;
  final EventPartType type;
  final DateTime startTime;
  final DateTime endTime;
  final List<String>? lectors;
  final List<String>? djs;

  const EventPart({
    required this.name,
    this.description,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.lectors,
    this.djs,
  });

  EventPart copyWith({
    String? name,
    String? description,
    EventPartType? type,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? lectors,
    List<String>? djs,
  });
}
```

**Design Decisions:**
- Represents individual parts of an event (workshop before party, etc.)
- startTime and endTime allow precise scheduling
- lectors for workshop/lesson instructors
- djs for party music
- Optional fields for flexibility
- Type enum for filtering and display logic

#### Event Model

```dart
class Event {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final Venue venue;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final List<String> dances;
  final List<EventInfo> info;
  final List<EventPart> parts;
  final bool isFavorite;
  final bool isPast;
  final String? badge;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.dances,
    this.info = const [],
    this.parts = const [],
    this.isFavorite = false,
    this.isPast = false,
    this.badge,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? organizer,
    Venue? venue,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    List<String>? dances,
    List<EventInfo>? info,
    List<EventPart>? parts,
    bool? isFavorite,
    bool? isPast,
    String? badge,
  });
}
```

**Design Decisions:**
- Immutable class with const constructor for performance
- copyWith method for creating modified copies (especially for favorite toggle)
- All fields use English names per requirements
- Optional badge field for "TODAY", "IN 2 DAYS", "FINISHED" labels
- DateTime for startTime and endTime for proper date/time handling
- Duration object for event duration (calculated from start/end)
- dances instead of tags for clarity
- Venue object for structured location data
- description field for event details
- organizer field for event organizer name
- info list for flexible additional information (URLs, prices, text)
- parts list for event schedule (workshops, parties, lessons)
- Default empty lists for info and parts
- Price removed - managed via EventInfo objects with type=price

### 2. Repository Layer

#### EventRepository

```dart
class EventRepository {
  // In-memory storage
  List<Event> _events = [];
  
  EventRepository() {
    _initializeEvents();
  }

  void _initializeEvents() {
    // Hardcoded event data from EventListScreen and FavoritesScreen
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _events = [
      // Today events
      Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa, Bachata, and Kizomba dancing!',
        organizer: 'Prague Dance Events',
        venue: Venue(
          name: 'Lucerna Music Bar',
          address: Address(
            street: 'Vodičkova 36',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          ),
          description: 'Historic music venue in the heart of Prague',
          latitude: 50.0813,
          longitude: 14.4253,
        ),
        startTime: today.add(Duration(hours: 20)),
        endTime: today.add(Duration(hours: 26)), // 2:00 next day
        duration: Duration(hours: 6),
        dances: ['Salsa', 'Bachata', 'Kizomba'],
        info: [
          EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '150 Kč',
          ),
          EventInfo(
            type: EventInfoType.url,
            key: 'Facebook Event',
            value: 'https://facebook.com/events/123456',
          ),
          EventInfo(
            type: EventInfoType.text,
            key: 'Dress Code',
            value: 'Casual',
          ),
        ],
        parts: [
          EventPart(
            name: 'Social Dancing',
            description: 'Open social dancing with DJ',
            type: EventPartType.party,
            startTime: today.add(Duration(hours: 20)),
            endTime: today.add(Duration(hours: 26)),
            djs: ['DJ Carlos', 'DJ Maria'],
          ),
        ],
        isFavorite: false,
      ),
      Event(
        id: '2',
        title: 'Bachata Tuesdays',
        description: 'Weekly Bachata social with sensual styling workshop',
        organizer: 'Dance Arena Team',
        venue: Venue(
          name: 'Dance Arena Prague',
          address: Address(
            street: 'Komunardů 30',
            city: 'Prague',
            postalCode: '170 00',
            country: 'Czech Republic',
          ),
          description: 'Modern dance studio with professional floor',
          latitude: 50.1025,
          longitude: 14.4378,
        ),
        startTime: today.add(Duration(hours: 19, minutes: 30)),
        endTime: today.add(Duration(hours: 23, minutes: 30)),
        duration: Duration(hours: 4),
        dances: ['Bachata', 'Sensual'],
        info: [
          EventInfo(
            type: EventInfoType.price,
            key: 'Full Event',
            value: '100 Kč',
          ),
          EventInfo(
            type: EventInfoType.price,
            key: 'Workshop Only',
            value: '50 Kč',
          ),
          EventInfo(
            type: EventInfoType.price,
            key: 'Party Only',
            value: '80 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Sensual Styling Workshop',
            description: 'Learn sensual bachata styling techniques',
            type: EventPartType.workshop,
            startTime: today.add(Duration(hours: 19, minutes: 30)),
            endTime: today.add(Duration(hours: 21)),
            lectors: ['Anna Martinez', 'Carlos Rodriguez'],
          ),
          EventPart(
            name: 'Bachata Social',
            description: 'Social dancing with live DJ',
            type: EventPartType.party,
            startTime: today.add(Duration(hours: 21)),
            endTime: today.add(Duration(hours: 23, minutes: 30)),
            djs: ['DJ Bachata King'],
          ),
        ],
        isFavorite: true,
      ),
      // ... more events
    ];
  }

  Future<List<Event>> getAllEvents() async {
    // Simulate async operation for future API compatibility
    await Future.delayed(Duration(milliseconds: 100));
    return List.unmodifiable(_events);
  }

  Future<List<Event>> getFavoriteEvents() async {
    await Future.delayed(Duration(milliseconds: 100));
    return _events.where((event) => event.isFavorite).toList();
  }

  Future<List<Event>> getEventsByDate(String date) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _events.where((event) => event.date == date).toList();
  }

  Future<void> toggleFavorite(String eventId) async {
    await Future.delayed(Duration(milliseconds: 50));
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isFavorite: !_events[index].isFavorite,
      );
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    await Future.delayed(Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    return _events.where((event) =>
      event.title.toLowerCase().contains(lowerQuery) ||
      event.venue.name.toLowerCase().contains(lowerQuery) ||
      event.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  Future<List<Event>> filterEvents(Map<String, dynamic> criteria) async {
    await Future.delayed(Duration(milliseconds: 100));
    var filtered = _events;
    
    if (criteria.containsKey('dances')) {
      final dances = criteria['dances'] as List<String>;
      filtered = filtered.where((event) =>
        event.dances.any((dance) => dances.contains(dance))
      ).toList();
    }
    
    if (criteria.containsKey('isPast')) {
      final isPast = criteria['isPast'] as bool;
      filtered = filtered.where((event) => event.isPast == isPast).toList();
    }
    
    if (criteria.containsKey('dateRange')) {
      final range = criteria['dateRange'] as Map<String, DateTime>;
      final start = range['start'];
      final end = range['end'];
      if (start != null && end != null) {
        filtered = filtered.where((event) =>
          event.startTime.isAfter(start) && event.startTime.isBefore(end)
        ).toList();
      }
    }
    
    return filtered;
  }
}
```

**Design Decisions:**
- All methods return Future for API compatibility
- In-memory storage with List<Event>
- Simulated delays to mimic async operations
- Unmodifiable list returned from getAllEvents to prevent external modification
- toggleFavorite modifies in-memory state
- Search is case-insensitive and searches title, venue name, and description
- Filter supports multiple criteria via Map (dances, isPast, dateRange)
- DateTime objects allow proper date/time comparisons and formatting
- Duration object provides type-safe duration handling

### 3. State Management

#### EventListCubit

**States:**

```dart
abstract class EventListState {}

class EventListInitial extends EventListState {}

class EventListLoading extends EventListState {}

class EventListLoaded extends EventListState {
  final List<Event> allEvents;
  final List<Event> todayEvents;
  final List<Event> tomorrowEvents;
  final List<Event> upcomingEvents;
  
  EventListLoaded({
    required this.allEvents,
    required this.todayEvents,
    required this.tomorrowEvents,
    required this.upcomingEvents,
  });
}

class EventListError extends EventListState {
  final String message;
  EventListError(this.message);
}
```

**Cubit Implementation:**

```dart
class EventListCubit extends Cubit<EventListState> {
  final EventRepository repository;
  
  EventListCubit(this.repository) : super(EventListInitial());

  Future<void> loadEvents() async {
    emit(EventListLoading());
    try {
      final events = await repository.getAllEvents();
      
      // Group events by date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));
      final dayAfterTomorrow = today.add(Duration(days: 2));
      
      final todayEvents = events.where((e) => 
        e.startTime.isAfter(today) && e.startTime.isBefore(tomorrow)
      ).toList();
      
      final tomorrowEvents = events.where((e) => 
        e.startTime.isAfter(tomorrow) && e.startTime.isBefore(dayAfterTomorrow)
      ).toList();
      
      final upcomingEvents = events.where((e) => 
        e.startTime.isAfter(dayAfterTomorrow)
      ).toList();
      
      emit(EventListLoaded(
        allEvents: events,
        todayEvents: todayEvents,
        tomorrowEvents: tomorrowEvents,
        upcomingEvents: upcomingEvents,
      ));
    } catch (e) {
      emit(EventListError('Failed to load events: ${e.toString()}'));
    }
  }

  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      await loadEvents();
      return;
    }
    
    emit(EventListLoading());
    try {
      final events = await repository.searchEvents(query);
      // Group search results by date
      // ... similar grouping logic
      emit(EventListLoaded(...));
    } catch (e) {
      emit(EventListError('Search failed: ${e.toString()}'));
    }
  }

  Future<void> toggleFavorite(String eventId) async {
    try {
      await repository.toggleFavorite(eventId);
      await loadEvents(); // Reload to reflect changes
    } catch (e) {
      emit(EventListError('Failed to toggle favorite: ${e.toString()}'));
    }
  }
}
```

**Design Decisions:**
- Separate states for initial, loading, loaded, and error
- EventListLoaded contains pre-grouped events for UI convenience
- Search reloads all events when query is empty
- toggleFavorite reloads events to reflect changes
- Error messages include details for debugging

#### FavoritesCubit

**States:**

```dart
abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesEmpty extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Event> upcomingEvents;
  final List<Event> pastEvents;
  
  FavoritesLoaded({
    required this.upcomingEvents,
    required this.pastEvents,
  });
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}
```

**Cubit Implementation:**

```dart
class FavoritesCubit extends Cubit<FavoritesState> {
  final EventRepository repository;
  
  FavoritesCubit(this.repository) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavoriteEvents();
      
      if (favorites.isEmpty) {
        emit(FavoritesEmpty());
        return;
      }
      
      final upcoming = favorites.where((e) => !e.isPast).toList();
      final past = favorites.where((e) => e.isPast).toList();
      
      emit(FavoritesLoaded(
        upcomingEvents: upcoming,
        pastEvents: past,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: ${e.toString()}'));
    }
  }

  Future<void> toggleFavorite(String eventId) async {
    try {
      await repository.toggleFavorite(eventId);
      await loadFavorites(); // Reload to reflect changes
    } catch (e) {
      emit(FavoritesError('Failed to toggle favorite: ${e.toString()}'));
    }
  }
}
```

**Design Decisions:**
- Separate empty state for better UX
- Pre-separated upcoming and past events
- toggleFavorite reloads favorites to reflect changes
- Error handling with descriptive messages

### 4. UI Integration

#### EventListScreen Integration

```dart
class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<EventListCubit, EventListState>(
        bloc: getIt<EventListCubit>(),
        builder: (context, state) {
          if (state is EventListLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is EventListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => getIt<EventListCubit>().loadEvents(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is EventListLoaded) {
            return _buildEventsList(context, state);
          }
          
          return SizedBox.shrink();
        },
      ),
    );
  }
}
```

**Design Decisions:**
- No BlocProvider needed
- BlocBuilder with explicit bloc parameter
- Cubit accessed via getIt
- Data already loaded at app startup
- Existing UI widgets reused with state data

#### FavoritesScreen Integration

```dart
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        bloc: getIt<FavoritesCubit>(),
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is FavoritesEmpty) {
            return _buildEmptyState();
          }
          
          if (state is FavoritesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => getIt<FavoritesCubit>().loadFavorites(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is FavoritesLoaded) {
            return _buildFavoritesList(context, state);
          }
          
          return SizedBox.shrink();
        },
      ),
    );
  }
}
```

**Design Decisions:**
- No BlocProvider needed
- BlocBuilder with explicit bloc parameter
- Cubit accessed via getIt
- Data already loaded at app startup
- Empty state uses existing _buildEmptyState widget
- Error handling with retry functionality
- Existing UI components reused

### 5. Dependency Injection

#### Service Locator Setup

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register repository as singleton
  getIt.registerLazySingleton<EventRepository>(() => EventRepository());
  
  // Register cubits as singletons
  getIt.registerLazySingleton<EventListCubit>(
    () => EventListCubit(getIt<EventRepository>())..loadEvents(),
  );
  
  getIt.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(getIt<EventRepository>())..loadFavorites(),
  );
}
```

**Design Decisions:**
- get_it for dependency injection (industry standard)
- Lazy singletons - created on first access
- Repository registered first (dependency)
- Cubits registered with automatic data loading
- Single instance shared across app
- No need for BlocProvider in widget tree

#### Main App Setup

```dart
void main() {
  setupDependencies();
  runApp(MyApp());
}
```

**Design Decisions:**
- Dependencies setup before app starts
- No RepositoryProvider needed
- Cubits initialized and data loaded at startup
- Screens access cubits via getIt

## Data Flow

### Loading Events Flow

1. App starts, main() calls setupDependencies()
2. EventRepository registered as lazy singleton
3. EventListCubit registered with loadEvents() call
4. FavoritesCubit registered with loadFavorites() call
5. User opens EventListScreen
6. BlocBuilder accesses cubit via getIt
7. UI displays current state (loading/loaded/error)
8. Data already loaded or loading from startup

### Toggle Favorite Flow

1. User taps favorite button on event
2. UI calls getIt<EventListCubit>().toggleFavorite(eventId)
3. Cubit calls repository.toggleFavorite(eventId)
4. Repository updates in-memory event
5. Cubit reloads events
6. UI updates to show new favorite status
7. FavoritesCubit automatically updates (shared repository)
8. If on FavoritesScreen, list updates automatically

### Search Flow

1. User types in search field
2. UI calls getIt<EventListCubit>().searchEvents(query)
3. Cubit emits EventListLoading
4. Repository filters events by query
5. Cubit groups filtered results
6. Cubit emits EventListLoaded with filtered events
7. UI displays search results

## Error Handling Strategy

### Repository Level
- Wrap operations in try-catch
- Throw descriptive exceptions
- Log errors for debugging

### Cubit Level
- Catch repository exceptions
- Emit error states with user-friendly messages
- Preserve previous state when possible

### UI Level
- Display error messages clearly
- Provide retry buttons
- Show loading indicators during operations
- Handle empty states gracefully

## Future API Migration Path

### Current Implementation
```dart
Future<List<Event>> getAllEvents() async {
  await Future.delayed(Duration(milliseconds: 100));
  return List.unmodifiable(_events);
}
```

### Future API Implementation
```dart
Future<List<Event>> getAllEvents() async {
  final response = await http.get(Uri.parse('$baseUrl/events'));
  if (response.statusCode == 200) {
    final List<dynamic> json = jsonDecode(response.body);
    return json.map((e) => Event.fromJson(e)).toList();
  }
  throw Exception('Failed to load events');
}
```

**Migration Steps:**
1. Add http package dependency
2. Add fromJson/toJson to Event model
3. Replace hardcoded data with API calls in repository
4. No changes needed in Cubits or UI
5. Add proper error handling for network failures

## Testing Strategy

### Unit Tests
- Event model copyWith functionality
- Repository methods (getAllEvents, getFavoriteEvents, etc.)
- Search and filter logic
- Favorite toggle logic

### Cubit Tests
- State transitions
- Loading → Loaded flow
- Loading → Error flow
- Search functionality
- Favorite toggle updates state

### Widget Tests
- EventListScreen displays loading indicator
- EventListScreen displays events when loaded
- EventListScreen displays error message
- FavoritesScreen empty state
- Favorite button toggle

### Integration Tests
- Complete user flow: browse → favorite → view favorites
- Search and filter events
- Toggle favorite across screens

## Performance Considerations

1. **In-Memory Storage**: Fast access, no disk I/O
2. **Immutable Events**: Safe to share across widgets
3. **List.unmodifiable**: Prevents accidental modifications
4. **Cubit over Bloc**: Less overhead, simpler state management
5. **Pre-grouped Events**: Reduces UI computation

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.0

dev_dependencies:
  bloc_test: ^9.1.4
  mocktail: ^1.0.0
```

## File Structure

```
lib/
├── di/
│   └── service_locator.dart
├── models/
│   ├── address.dart
│   ├── venue.dart
│   ├── event_info.dart
│   ├── event_part.dart
│   └── event.dart
├── repositories/
│   └── event_repository.dart
├── cubits/
│   ├── event_list/
│   │   ├── event_list_cubit.dart
│   │   └── event_list_state.dart
│   └── favorites/
│       ├── favorites_cubit.dart
│       └── favorites_state.dart
└── screens/
    ├── event_list_screen.dart
    └── favorites_screen.dart
```

## Correctness Properties

### Property 1: Favorite Toggle Consistency
**Validates: Requirements 3.4, 5.6**

When an event's favorite status is toggled, the change must be reflected consistently across all screens.

```dart
// Property test
test('favorite toggle is consistent across repository calls', () async {
  final repository = EventRepository();
  final event = (await repository.getAllEvents()).first;
  final initialFavoriteStatus = event.isFavorite;
  
  await repository.toggleFavorite(event.id);
  final afterToggle = (await repository.getAllEvents())
      .firstWhere((e) => e.id == event.id);
  
  expect(afterToggle.isFavorite, !initialFavoriteStatus);
});
```

### Property 2: Search Results Subset
**Validates: Requirements 3.8, 4.6**

Search results must always be a subset of all events.

```dart
// Property test
test('search results are always subset of all events', () async {
  final repository = EventRepository();
  final allEvents = await repository.getAllEvents();
  final searchResults = await repository.searchEvents('Salsa');
  
  for (final result in searchResults) {
    expect(allEvents.any((e) => e.id == result.id), true);
  }
});
```

### Property 3: State Transition Validity
**Validates: Requirements 4.1-4.4**

Cubit state transitions must follow valid patterns.

```dart
// Property test
blocTest<EventListCubit, EventListState>(
  'emits [loading, loaded] when loadEvents succeeds',
  build: () => EventListCubit(mockRepository),
  act: (cubit) => cubit.loadEvents(),
  expect: () => [
    isA<EventListLoading>(),
    isA<EventListLoaded>(),
  ],
);
```

### Property 4: Favorites Filter Correctness
**Validates: Requirements 3.2, 5.3**

getFavoriteEvents must only return events where isFavorite is true.

```dart
// Property test
test('getFavoriteEvents returns only favorite events', () async {
  final repository = EventRepository();
  final favorites = await repository.getFavoriteEvents();
  
  for (final event in favorites) {
    expect(event.isFavorite, true);
  }
});
```

### Property 5: Event Immutability
**Validates: Requirements 2.7, 2.8**

Event objects must be immutable and copyWith must create new instances.

```dart
// Property test
test('copyWith creates new instance with updated fields', () {
  final event = Event(id: '1', title: 'Test', ...);
  final updated = event.copyWith(isFavorite: true);
  
  expect(event.isFavorite, false);
  expect(updated.isFavorite, true);
  expect(identical(event, updated), false);
});
```

## Conclusion

This design provides a clean separation of concerns with:
- **Data Layer**: EventRepository manages event data
- **State Management**: Cubits handle business logic and state
- **UI Layer**: Screens display data and handle user interaction

The architecture supports future API migration without UI changes and follows Flutter best practices for maintainability and testability.
