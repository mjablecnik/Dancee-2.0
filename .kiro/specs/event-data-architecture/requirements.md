# Requirements Document

## Introduction

This document specifies the requirements for implementing a data architecture with repository pattern and Cubit state management for dance events in the Dancee Flutter application. The system will centralize event data management using hardcoded data initially, with the architecture designed to easily transition to REST API data fetching in the future. This will replace scattered hardcoded event data in EventListScreen and FavoritesScreen with a centralized, maintainable data architecture.

## Glossary

- **Event**: A dance event with properties including title, venue, date, time, tags, and favorite status
- **Repository**: A data access layer that abstracts the source of event data
- **Cubit**: A state management component from the flutter_bloc package that manages UI state
- **Data_Source**: The provider of event data (currently hardcoded, future REST API)
- **Event_Model**: A Dart class representing an event
- **State**: The current condition of data in the application (loading, loaded, error, empty)
- **Favorite_Toggle**: The action of marking or unmarking an event as favorite
- **Event_List_Screen**: The main screen displaying all events grouped by date
- **Favorites_Screen**: The screen displaying only favorite events

## Requirements

### Requirement 1: Hardcoded Data Storage with Future API Support

**User Story:** As a developer, I want event data centralized in the repository with hardcoded data initially, so that I can easily transition to REST API data fetching in the future without changing UI code.

#### Acceptance Criteria

1. THE Event_Repository SHALL contain hardcoded event data from EventListScreen (Salsa Social Night, Bachata Tuesdays, Zouk Workshop & Party, Kizomba Wednesday, Tango Practica, Latin Mix Party)
2. THE Event_Repository SHALL contain hardcoded favorite events from FavoritesScreen
3. THE Event_Repository SHALL be designed with an interface that abstracts the data source
4. THE Event_Repository SHALL provide methods that return Future types to support future async API calls
5. THE Event_Repository architecture SHALL allow easy replacement of hardcoded data with REST API calls without modifying UI code

### Requirement 2: Event, Venue, Address, EventInfo, and EventPart Data Models

**User Story:** As a developer, I want strongly-typed data model classes for events and related entities, so that event data is type-safe and consistent throughout the application.

#### Acceptance Criteria

1. THE Address_Model SHALL include fields for street, city, postalCode, and country
2. THE Address_Model SHALL be immutable using const constructor
3. THE Address_Model SHALL include a copyWith method for creating modified copies
4. THE Address_Model SHALL provide a fullAddress getter for display purposes
5. THE Venue_Model SHALL include fields for name, address (Address object), description, latitude, and longitude
6. THE Venue_Model SHALL be immutable using const constructor
7. THE Venue_Model SHALL include a copyWith method for creating modified copies
8. THE EventInfo_Model SHALL include fields for type (EventInfoType enum), key, and value
9. THE EventInfo_Model SHALL support three types: text, url, and price
10. THE EventInfo_Model SHALL store price values as strings including currency (e.g., "120 Kč", "50 EUR")
11. THE EventInfo_Model SHALL be immutable using const constructor
11. THE EventPart_Model SHALL include fields for name, description, type (EventPartType enum), startTime, endTime, lectors, and djs
12. THE EventPart_Model SHALL support three types: party, workshop, and openLesson
13. THE EventPart_Model SHALL use DateTime for startTime and endTime
14. THE EventPart_Model SHALL be immutable using const constructor
15. THE Event_Model SHALL include fields for id, title, description, organizer, venue (Venue object), startTime (DateTime), endTime (DateTime), and duration (Duration)
16. THE Event_Model SHALL include a dances field as a list of strings representing dance styles
17. THE Event_Model SHALL include a price field as integer
18. THE Event_Model SHALL include an info field as list of EventInfo objects
19. THE Event_Model SHALL include a parts field as list of EventPart objects
20. THE Event_Model SHALL include an isFavorite boolean flag
21. THE Event_Model SHALL include an isPast boolean flag for historical events
22. THE Event_Model SHALL follow Dart naming conventions with camelCase for properties
23. THE Event_Model SHALL be immutable using const constructor
24. THE Event_Model SHALL include a copyWith method for creating modified copies
25. THE Event_Model SHALL use DateTime objects for startTime and endTime for proper date/time handling
26. THE Event_Model SHALL use Duration object for event duration

### Requirement 3: Repository Pattern Implementation

**User Story:** As a developer, I want a repository class to manage event data access, so that data loading logic is separated from UI components.

#### Acceptance Criteria

1. THE Event_Repository SHALL provide a method getAllEvents() that returns a Future of list of all events
2. THE Event_Repository SHALL provide a method getFavoriteEvents() that returns a Future of only events where isFavorite is true
3. THE Event_Repository SHALL provide a method getEventsByDate(date) that returns a Future of events for a specific date
4. THE Event_Repository SHALL provide a method toggleFavorite(eventId) that updates the favorite status of an event
5. WHEN getAllEvents() is called, THE Event_Repository SHALL return hardcoded event data
6. THE Event_Repository SHALL maintain event state in memory for the current session
7. WHEN toggleFavorite is called, THE Event_Repository SHALL update the in-memory event state
8. THE Event_Repository SHALL provide a method searchEvents(query) that filters events by title, venue name, or description
9. THE Event_Repository SHALL provide a method filterEvents(criteria) that filters events by dances, isPast, or date range
10. THE Event_Repository architecture SHALL support future replacement with REST API calls

### Requirement 4: Event List State Management

**User Story:** As a user, I want the event list screen to load data reliably, so that I can see all available dance events.

#### Acceptance Criteria

1. THE Event_List_Cubit SHALL manage states: loading, loaded, and error
2. WHEN Event_List_Screen initializes, THE Event_List_Cubit SHALL emit loading state
3. WHEN event data is successfully loaded, THE Event_List_Cubit SHALL emit loaded state with events grouped by date
4. IF event loading fails, THEN THE Event_List_Cubit SHALL emit error state with error message
5. THE Event_List_Cubit SHALL provide a method to load all events
6. THE Event_List_Cubit SHALL provide a method to search events by query string
7. THE Event_List_Cubit SHALL provide a method to filter events by criteria
8. WHEN search is performed, THE Event_List_Cubit SHALL update the loaded state with filtered results
9. THE Event_List_Cubit SHALL use Event_Repository to access event data

### Requirement 5: Favorites State Management

**User Story:** As a user, I want my favorite events to be reliably displayed and managed, so that I can track events I'm interested in.

#### Acceptance Criteria

1. THE Favorites_Cubit SHALL manage states: loading, loaded, empty, and error
2. WHEN Favorites_Screen initializes, THE Favorites_Cubit SHALL emit loading state
3. WHEN favorite events exist, THE Favorites_Cubit SHALL emit loaded state with favorite events
4. WHEN no favorite events exist, THE Favorites_Cubit SHALL emit empty state
5. IF favorite loading fails, THEN THE Favorites_Cubit SHALL emit error state with error message
6. THE Favorites_Cubit SHALL provide a method to toggle favorite status of an event
7. WHEN favorite is toggled, THE Favorites_Cubit SHALL update the repository and refresh the state
8. THE Favorites_Cubit SHALL separate upcoming events from past events in the loaded state
9. THE Favorites_Cubit SHALL use Event_Repository to access event data

### Requirement 6: Event List Screen Integration

**User Story:** As a user, I want the event list screen to display data from the repository, so that I see consistent and up-to-date event information.

#### Acceptance Criteria

1. THE Event_List_Screen SHALL use Event_List_Cubit for state management
2. WHEN Event_List_Cubit emits loading state, THE Event_List_Screen SHALL display a loading indicator
3. WHEN Event_List_Cubit emits loaded state, THE Event_List_Screen SHALL display events grouped by date
4. WHEN Event_List_Cubit emits error state, THE Event_List_Screen SHALL display an error message
5. THE Event_List_Screen SHALL remove all hardcoded event data
6. WHEN user searches for events, THE Event_List_Screen SHALL call Event_List_Cubit search method
7. WHEN user toggles favorite on an event, THE Event_List_Screen SHALL update the event's favorite status
8. THE Event_List_Screen SHALL maintain existing UI design and layout

### Requirement 7: Favorites Screen Integration

**User Story:** As a user, I want the favorites screen to display data from the repository, so that I see my saved events reliably.

#### Acceptance Criteria

1. THE Favorites_Screen SHALL use Favorites_Cubit for state management
2. WHEN Favorites_Cubit emits loading state, THE Favorites_Screen SHALL display a loading indicator
3. WHEN Favorites_Cubit emits loaded state, THE Favorites_Screen SHALL display favorite events
4. WHEN Favorites_Cubit emits empty state, THE Favorites_Screen SHALL display the empty state UI
5. WHEN Favorites_Cubit emits error state, THE Favorites_Screen SHALL display an error message
6. THE Favorites_Screen SHALL remove all hardcoded FavoriteEvent data
7. WHEN user removes a favorite, THE Favorites_Screen SHALL call Favorites_Cubit toggle method
8. THE Favorites_Screen SHALL maintain existing UI design and layout
9. THE Favorites_Screen SHALL display upcoming and past events in separate sections

### Requirement 8: Dependency Management

**User Story:** As a developer, I want all required packages properly configured with dependency injection, so that the application can be built and run successfully with singleton services.

#### Acceptance Criteria

1. THE System SHALL include flutter_bloc package in pubspec.yaml dependencies
2. THE System SHALL include equatable package in pubspec.yaml dependencies for value equality
3. THE System SHALL include get_it package in pubspec.yaml dependencies for dependency injection
4. WHEN dependencies are added, THE System SHALL run task get-deps to install them
5. THE System SHALL use get_it for service locator pattern
6. THE System SHALL register EventRepository as lazy singleton
7. THE System SHALL register EventListCubit as lazy singleton with automatic data loading
8. THE System SHALL register FavoritesCubit as lazy singleton with automatic data loading
9. THE System SHALL initialize dependencies before app starts
10. THE System SHALL NOT use BlocProvider in widget tree

### Requirement 9: Error Handling

**User Story:** As a user, I want clear error messages when something goes wrong, so that I understand what happened and can take appropriate action.

#### Acceptance Criteria

1. WHEN data loading fails, THE System SHALL display an error message indicating data loading failure
2. WHEN an unexpected error occurs, THE System SHALL display a user-friendly error message
3. THE System SHALL log detailed error information for debugging purposes
4. WHEN an error occurs, THE System SHALL not crash but instead show error state in UI
5. THE System SHALL provide retry functionality when errors occur

### Requirement 10: Code Quality Standards

**User Story:** As a developer working on an international team, I want all code to follow English-only standards, so that any developer can understand and maintain the code.

#### Acceptance Criteria

1. THE System SHALL use English for all variable names
2. THE System SHALL use English for all function names
3. THE System SHALL use English for all class names
4. THE System SHALL use English for all comments
5. THE System SHALL use English for all string literals in code
6. THE System SHALL follow Flutter and Dart best practices
7. THE System SHALL follow proper Dart naming conventions (camelCase for variables, PascalCase for classes)
