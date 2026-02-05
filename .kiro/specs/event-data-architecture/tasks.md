# Implementation Tasks

## Overview
This document outlines the implementation tasks for the event data architecture feature. Tasks should be completed in order as they have dependencies.

## Task List

- [x] 1. Setup Dependencies
  - [x] 1.1 Add flutter_bloc package to pubspec.yaml
  - [x] 1.2 Add equatable package to pubspec.yaml
  - [x] 1.3 Add get_it package to pubspec.yaml
  - [x] 1.4 Run task get-deps to install dependencies

- [x] 2. Create Data Models
  - [x] 2.1 Create lib/models directory
  - [x] 2.2 Create Address model class in lib/models/address.dart
  - [x] 2.3 Implement Address fields (street, city, postalCode, country)
  - [x] 2.4 Implement Address copyWith method
  - [x] 2.5 Implement Address fullAddress getter
  - [x] 2.6 Implement Address equality comparison (using Equatable)
  - [x] 2.7 Create Venue model class in lib/models/venue.dart
  - [x] 2.8 Implement Venue fields (name, address, description, latitude, longitude)
  - [x] 2.9 Implement Venue copyWith method
  - [x] 2.10 Implement Venue equality comparison (using Equatable)
  - [x] 2.11 Create EventInfo model and enum in lib/models/event_info.dart
  - [x] 2.12 Implement EventInfoType enum (text, url, price)
  - [x] 2.13 Implement EventInfo fields (type, key, value)
  - [x] 2.14 Implement EventInfo copyWith method
  - [x] 2.15 Implement EventInfo equality comparison (using Equatable)
  - [x] 2.16 Create EventPart model and enum in lib/models/event_part.dart
  - [x] 2.17 Implement EventPartType enum (party, workshop, openLesson)
  - [x] 2.18 Implement EventPart fields (name, description, type, startTime, endTime, lectors, djs)
  - [x] 2.19 Implement EventPart copyWith method
  - [x] 2.20 Implement EventPart equality comparison (using Equatable)
  - [x] 2.21 Create Event model class in lib/models/event.dart
  - [x] 2.22 Implement Event fields (id, title, description, organizer, venue, startTime, endTime, duration, dances, info, parts, isFavorite, isPast, badge)
  - [x] 2.23 Implement Event copyWith method
  - [x] 2.24 Implement Event equality comparison (using Equatable)
  - [x] 2.25 Write unit tests for Address model
  - [x] 2.26 Write unit tests for Venue model
  - [x] 2.27 Write unit tests for EventInfo model
  - [x] 2.28 Write unit tests for EventPart model
  - [x] 2.29 Write unit tests for Event model

- [x] 3. Create EventRepository
  - [x] 3.1 Create lib/repositories directory
  - [x] 3.2 Create EventRepository class in lib/repositories/event_repository.dart
  - [x] 3.3 Implement _initializeEvents() with hardcoded data from EventListScreen
  - [x] 3.4 Add hardcoded data from FavoritesScreen
  - [x] 3.5 Implement getAllEvents() method
  - [x] 3.6 Implement getFavoriteEvents() method
  - [x] 3.7 Implement getEventsByDate() method
  - [x] 3.8 Implement toggleFavorite() method
  - [x] 3.9 Implement searchEvents() method
  - [x] 3.10 Implement filterEvents() method
  - [x] 3.11 Write unit tests for EventRepository

- [x] 4. Create EventListCubit
  - [x] 4.1 Create lib/cubits/event_list directory
  - [x] 4.2 Create EventListState classes in lib/cubits/event_list/event_list_state.dart
  - [x] 4.3 Implement EventListInitial state
  - [x] 4.4 Implement EventListLoading state
  - [x] 4.5 Implement EventListLoaded state with grouped events
  - [x] 4.6 Implement EventListError state
  - [x] 4.7 Create EventListCubit in lib/cubits/event_list/event_list_cubit.dart
  - [x] 4.8 Implement loadEvents() method
  - [x] 4.9 Implement searchEvents() method
  - [x] 4.10 Implement toggleFavorite() method
  - [x] 4.11 Write cubit tests for EventListCubit

- [x] 5. Create FavoritesCubit
  - [x] 5.1 Create lib/cubits/favorites directory
  - [x] 5.2 Create FavoritesState classes in lib/cubits/favorites/favorites_state.dart
  - [x] 5.3 Implement FavoritesInitial state
  - [x] 5.4 Implement FavoritesLoading state
  - [x] 5.5 Implement FavoritesEmpty state
  - [x] 5.6 Implement FavoritesLoaded state with separated events
  - [x] 5.7 Implement FavoritesError state
  - [x] 5.8 Create FavoritesCubit in lib/cubits/favorites/favorites_cubit.dart
  - [x] 5.9 Implement loadFavorites() method
  - [x] 5.10 Implement toggleFavorite() method
  - [x] 5.11 Write cubit tests for FavoritesCubit

- [x] 6. Setup Dependency Injection
  - [x] 6.1 Create lib/di/service_locator.dart file
  - [x] 6.2 Import get_it package
  - [x] 6.3 Create getIt instance
  - [x] 6.4 Create setupDependencies() function
  - [x] 6.5 Register EventRepository as lazy singleton
  - [x] 6.6 Register EventListCubit as lazy singleton with loadEvents() call
  - [x] 6.7 Register FavoritesCubit as lazy singleton with loadFavorites() call
  - [x] 6.8 Update lib/main.dart to call setupDependencies() before runApp()
  - [x] 6.9 Remove RepositoryProvider from main.dart
  - [x] 6.10 Test dependency injection setup

- [x] 7. Integrate EventListScreen
  - [x] 7.1 Remove BlocProvider from EventListScreen
  - [x] 7.2 Update BlocBuilder to use bloc: getIt<EventListCubit>()
  - [x] 7.3 Implement loading state UI
  - [x] 7.4 Implement error state UI with retry button
  - [x] 7.5 Update _buildEventsList to use state.todayEvents, state.tomorrowEvents, state.upcomingEvents
  - [x] 7.6 Remove all hardcoded event data
  - [x] 7.7 Update search functionality to call getIt<EventListCubit>().searchEvents()
  - [x] 7.8 Update favorite toggle to call getIt<EventListCubit>().toggleFavorite()
  - [x] 7.9 Test EventListScreen integration

- [x] 8. Integrate FavoritesScreen
  - [x] 8.1 Remove BlocProvider from FavoritesScreen
  - [x] 8.2 Update BlocBuilder to use bloc: getIt<FavoritesCubit>()
  - [x] 8.3 Implement loading state UI
  - [x] 8.4 Implement empty state UI (reuse existing _buildEmptyState)
  - [x] 8.5 Implement error state UI with retry button
  - [x] 8.6 Update _buildFavoritesList to use state.upcomingEvents and state.pastEvents
  - [x] 8.7 Remove all hardcoded FavoriteEvent data
  - [x] 8.8 Remove FavoriteEvent class (use Event model instead)
  - [x] 8.9 Update favorite toggle to call getIt<FavoritesCubit>().toggleFavorite()
  - [x] 8.10 Test FavoritesScreen integration

- [x] 9. Testing and Validation
  - [x] 9.1 Run all unit tests
  - [x] 9.2 Run all cubit tests
  - [x] 9.3 Write widget tests for EventListScreen
  - [x] 9.4 Write widget tests for FavoritesScreen
  - [x] 9.5 Test favorite toggle across both screens
  - [x] 9.6 Test search functionality
  - [x] 9.7 Test error handling and retry functionality
  - [x] 9.8 Test loading states
  - [x] 9.9 Test empty state on FavoritesScreen
  - [x] 9.10 Verify no hardcoded data remains in UI

- [x] 10. Code Quality and Documentation
  - [x] 10.1 Verify all code uses English (variables, comments, strings)
  - [x] 10.2 Add documentation comments to public APIs
  - [x] 10.3 Run task build-runner if using code generation
  - [x] 10.4 Fix any linting issues
  - [x] 10.5 Update README if needed
  - [x] 10.6 Remove any print statements (use logging framework)

## Task Details

### Task 1: Setup Dependencies

**Description**: Add required packages for state management and testing.

**Files to modify**:
- `frontend/dancee_app/pubspec.yaml`

**Dependencies to add**:
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.0

dev_dependencies:
  bloc_test: ^9.1.4
  mocktail: ^1.0.0
```

**Commands to run**:
```bash
cd frontend/dancee_app
task get-deps
```

### Task 2: Create Data Models

**Description**: Create immutable Address, Venue, EventInfo, EventPart, and Event model classes with all required fields.

**Files to create**:
- `frontend/dancee_app/lib/models/address.dart`
- `frontend/dancee_app/lib/models/venue.dart`
- `frontend/dancee_app/lib/models/event_info.dart`
- `frontend/dancee_app/lib/models/event_part.dart`
- `frontend/dancee_app/lib/models/event.dart`

**Key requirements**:
- All fields in English
- Immutable with const constructor
- copyWith methods for updates
- Equatable for value equality
- DateTime for time fields
- Duration object for duration
- Enums for EventInfoType and EventPartType
- Nested objects for structured data

**Address structure**:
```dart
import 'package:equatable/equatable.dart';

class Address extends Equatable {
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
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }
  
  String get fullAddress => '$street, $postalCode $city, $country';
  
  @override
  List<Object?> get props => [street, city, postalCode, country];
}
```

**Venue structure**:
```dart
import 'package:equatable/equatable.dart';
import 'address.dart';

class Venue extends Equatable {
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
  }) {
    return Venue(
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
  
  @override
  List<Object?> get props => [name, address, description, latitude, longitude];
}
```

**EventInfo structure**:
```dart
import 'package:equatable/equatable.dart';

enum EventInfoType {
  text,
  url,
  price,
}

class EventInfo extends Equatable {
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
  }) {
    return EventInfo(
      type: type ?? this.type,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
  
  @override
  List<Object?> get props => [type, key, value];
}
```

**EventPart structure**:
```dart
import 'package:equatable/equatable.dart';

enum EventPartType {
  party,
  workshop,
  openLesson,
}

class EventPart extends Equatable {
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
  }) {
    return EventPart(
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lectors: lectors ?? this.lectors,
      djs: djs ?? this.djs,
    );
  }
  
  @override
  List<Object?> get props => [name, description, type, startTime, endTime, lectors, djs];
}
```

**Event structure**:
```dart
import 'package:equatable/equatable.dart';
import 'venue.dart';
import 'event_info.dart';
import 'event_part.dart';

class Event extends Equatable {
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
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizer: organizer ?? this.organizer,
      venue: venue ?? this.venue,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      dances: dances ?? this.dances,
      info: info ?? this.info,
      parts: parts ?? this.parts,
      isFavorite: isFavorite ?? this.isFavorite,
      isPast: isPast ?? this.isPast,
      badge: badge ?? this.badge,
    );
  }
  
  @override
  List<Object?> get props => [
    id, title, description, organizer, venue, startTime, endTime,
    duration, dances, info, parts, isFavorite, isPast, badge
  ];
}
```

### Task 3: Create EventRepository

**Description**: Create repository class with hardcoded event data and data access methods.

**Files to create**:
- `frontend/dancee_app/lib/repositories/event_repository.dart`

**Key requirements**:
- Initialize with hardcoded data from both screens
- All methods return Future for API compatibility
- Maintain in-memory state
- Support search, filter, and favorite toggle

**Hardcoded events to include**:
From EventListScreen:
- Salsa Social Night (Today) - Lucerna Music Bar
- Bachata Tuesdays (Today, favorite) - Dance Arena Prague
- Zouk Workshop & Party (Today) - Studio Tance
- Kizomba Wednesday (Tomorrow) - Club Lavka
- Tango Practica (Tomorrow, favorite) - Café Milonga
- Latin Mix Party (This week) - Cross Club

From FavoritesScreen (additional favorites):
- Salsa & Bachata Night Prague (favorite, badge: TODAY) - Dance Club Central
- Bachata Sensual Workshop (favorite, badge: IN 2 DAYS) - Studio Rytmus
- Kizomba Fusion Party (favorite) - Karlín Hall
- Zouk Social Dance (favorite) - Dance Factory
- Salsa On2 Masterclass (favorite) - Dance Club Central
- Samba de Gafieira Evening (favorite) - Rio Dance Studio
- Latin Night Mix (favorite) - Lucerna Music Bar
- Bachata Romántica Night (favorite) - Dance Club Central
- Salsa Cubana Workshop (favorite, past, badge: FINISHED) - Studio Rytmus
- Kizomba Ladies Styling (favorite, past, badge: FINISHED) - Karlín Hall

**Important**: Use DateTime for startTime/endTime, Duration for duration, Venue objects for locations, and dances list for dance styles. Include description for each event.

### Task 4: Create EventListCubit

**Description**: Create cubit for managing event list screen state.

**Files to create**:
- `frontend/dancee_app/lib/cubits/event_list/event_list_state.dart`
- `frontend/dancee_app/lib/cubits/event_list/event_list_cubit.dart`

**Key requirements**:
- Four states: Initial, Loading, Loaded, Error
- EventListLoaded contains pre-grouped events (today, tomorrow, upcoming)
- loadEvents() groups events by date
- searchEvents() filters and groups results
- toggleFavorite() updates repository and reloads

### Task 5: Create FavoritesCubit

**Description**: Create cubit for managing favorites screen state.

**Files to create**:
- `frontend/dancee_app/lib/cubits/favorites/favorites_state.dart`
- `frontend/dancee_app/lib/cubits/favorites/favorites_cubit.dart`

**Key requirements**:
- Five states: Initial, Loading, Empty, Loaded, Error
- FavoritesLoaded separates upcoming and past events
- loadFavorites() loads and separates events
- toggleFavorite() updates repository and reloads

### Task 6: Setup Dependency Injection

**Description**: Setup get_it for dependency injection and register all services.

**Files to create**:
- `frontend/dancee_app/lib/di/service_locator.dart`

**Files to modify**:
- `frontend/dancee_app/lib/main.dart`

**Key requirements**:
- Use get_it for service locator pattern
- Register repository as lazy singleton
- Register cubits as lazy singletons
- Initialize cubits with data loading
- Call setup before app starts

**Service Locator structure**:
```dart
import 'package:get_it/get_it.dart';
import '../repositories/event_repository.dart';
import '../cubits/event_list/event_list_cubit.dart';
import '../cubits/favorites/favorites_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register repository
  getIt.registerLazySingleton<EventRepository>(
    () => EventRepository(),
  );
  
  // Register cubits with automatic data loading
  getIt.registerLazySingleton<EventListCubit>(
    () => EventListCubit(getIt<EventRepository>())..loadEvents(),
  );
  
  getIt.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(getIt<EventRepository>())..loadFavorites(),
  );
}
```

**Main.dart changes**:
```dart
import 'di/service_locator.dart';

void main() {
  setupDependencies();
  runApp(MyApp());
}
```

**Design decisions**:
- Lazy singletons created on first access
- Cubits automatically load data on creation
- No BlocProvider needed in widget tree
- Screens access cubits via getIt

### Task 7: Integrate EventListScreen

**Description**: Update EventListScreen to use EventListCubit for state management.

**Files to modify**:
- `frontend/dancee_app/lib/screens/event_list_screen.dart`

**Key changes**:
- Wrap with BlocProvider
- Replace StatefulWidget with StatelessWidget (optional)
- Add BlocBuilder for state handling
- Remove hardcoded event data
- Update search to use cubit
- Update favorite toggle to use cubit
- Add loading and error states

**State handling**:
```dart
BlocBuilder<EventListCubit, EventListState>(
  bloc: getIt<EventListCubit>(),
  builder: (context, state) {
    if (state is EventListLoading) return LoadingIndicator();
    if (state is EventListError) return ErrorWidget(state.message);
    if (state is EventListLoaded) return EventsList(state);
    return SizedBox.shrink();
  },
)
```

**Accessing cubit**:
```dart
// For actions
getIt<EventListCubit>().searchEvents(query);
getIt<EventListCubit>().toggleFavorite(eventId);
```

### Task 8: Integrate FavoritesScreen

**Description**: Update FavoritesScreen to use FavoritesCubit for state management.

**Files to modify**:
- `frontend/dancee_app/lib/screens/favorites_screen.dart`

**Key changes**:
- Wrap with BlocProvider
- Replace StatefulWidget with StatelessWidget (optional)
- Add BlocBuilder for state handling
- Remove hardcoded FavoriteEvent data
- Remove FavoriteEvent class definition
- Update to use Event model
- Update favorite toggle to use cubit
- Add loading, empty, and error states

### Task 9: Testing and Validation

**Description**: Comprehensive testing of all components.

**Test files to create**:
- `frontend/dancee_app/test/models/address_test.dart`
- `frontend/dancee_app/test/models/venue_test.dart`
- `frontend/dancee_app/test/models/event_info_test.dart`
- `frontend/dancee_app/test/models/event_part_test.dart`
- `frontend/dancee_app/test/models/event_test.dart`
- `frontend/dancee_app/test/repositories/event_repository_test.dart`
- `frontend/dancee_app/test/cubits/event_list/event_list_cubit_test.dart`
- `frontend/dancee_app/test/cubits/favorites/favorites_cubit_test.dart`
- `frontend/dancee_app/test/screens/event_list_screen_test.dart`
- `frontend/dancee_app/test/screens/favorites_screen_test.dart`

**Test coverage**:
- Unit tests for Address model (copyWith, equality, fullAddress getter)
- Unit tests for Venue model (copyWith, equality, Address integration)
- Unit tests for EventInfo model (copyWith, equality, enum types)
- Unit tests for EventPart model (copyWith, equality, DateTime handling)
- Unit tests for Event model (copyWith, equality, nested objects)
- Unit tests for repository (getAllEvents, search, filter, toggle)
- Cubit tests for state transitions
- Widget tests for UI integration
- Integration tests for user flows
- DateTime and Duration handling tests

**Commands to run**:
```bash
cd frontend/dancee_app
flutter test
```

### Task 10: Code Quality and Documentation

**Description**: Final code quality checks and documentation.

**Checklist**:
- All code in English (no Czech strings, variables, or comments)
- Documentation comments on public APIs
- No print statements (use proper logging)
- No linting errors
- Proper error handling everywhere
- README updated if needed

**Commands to run**:
```bash
cd frontend/dancee_app
flutter analyze
```

## Dependencies Between Tasks

```
1 (Dependencies) → 2 (Event Model) → 3 (Repository) → 4 (EventListCubit)
                                                    → 5 (FavoritesCubit)
                                                    
4, 5 → 6 (Main Setup) → 7 (EventListScreen Integration)
                      → 8 (FavoritesScreen Integration)
                      
7, 8 → 9 (Testing) → 10 (Code Quality)
```

## Estimated Effort

- Task 1: 15 minutes
- Task 2: 2.5 hours
- Task 3: 2 hours
- Task 4: 1.5 hours
- Task 5: 1.5 hours
- Task 6: 15 minutes
- Task 7: 2 hours
- Task 8: 2 hours
- Task 9: 3 hours
- Task 10: 1 hour

**Total estimated effort**: ~16 hours

## Notes

- All code must be in English per project requirements
- Use `task` commands instead of direct Flutter commands
- Test on web platform first using `task run-web`
- Maintain existing UI design and functionality
- Focus on clean separation of concerns
- Prepare architecture for future API migration
