# Dancee App

A beautiful Flutter mobile app for discovering and browsing dance events in Czech Republic.

## Features

- **Beautiful Gradient Header** - Eye-catching purple-to-pink gradient design
- **Search Functionality** - Search for dance events with real-time filtering
- **Event Filtering** - Filter by dance style, location, and date
- **Event Cards** - Detailed event information with:
  - Event name and venue
  - Time and duration
  - Price and participant count
  - Dance style tags with color coding
  - Favorite functionality
- **Organized Sections** - Events grouped by:
  - Today's events
  - Tomorrow's events  
  - This week's events
- **Favorites Management** - Save and manage your favorite events
- **Bottom Navigation** - Easy navigation between app sections
- **Clean Architecture** - Repository pattern with Cubit state management

## Dance Styles Supported

- Salsa
- Bachata
- Kizomba
- Zouk (Brazilian Zouk)
- Tango (Argentinské Tango)
- Swing (Lindy Hop)
- Forró
- Merengue
- Reggaeton
- And more...

## Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Web browser or mobile device for testing

### Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd frontend/dancee_app
   ```

3. Install dependencies:
   ```bash
   task get-deps
   ```

4. Run the app:
   ```bash
   # For web (recommended for development)
   task run-web
   
   # For Android
   task run-android
   
   # For iOS
   task run-ios
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── di/
│   └── service_locator.dart     # Dependency injection setup
├── models/
│   ├── address.dart             # Address model
│   ├── venue.dart               # Venue model
│   ├── event_info.dart          # Event info model
│   ├── event_part.dart          # Event part model
│   └── event.dart               # Event model
├── repositories/
│   └── event_repository.dart    # Event data repository
├── cubits/
│   ├── event_list/
│   │   ├── event_list_cubit.dart   # Event list state management
│   │   └── event_list_state.dart   # Event list states
│   └── favorites/
│       ├── favorites_cubit.dart    # Favorites state management
│       └── favorites_state.dart    # Favorites states
└── screens/
    ├── event_list_screen.dart   # Main events listing screen
    └── favorites_screen.dart    # Favorites screen
```

## Dependencies

- `flutter`: Flutter SDK
- `google_fonts`: Beautiful Inter font family
- `flutter_bloc`: State management with Cubit
- `equatable`: Value equality for models
- `get_it`: Dependency injection
- `cupertino_icons`: iOS-style icons

## Design

The app follows the design from `design/event-list.html` with:
- Modern gradient backgrounds
- Clean card-based layout
- Intuitive filtering system
- Responsive design for mobile devices
- Czech language interface

## Architecture

The app follows clean architecture principles with:
- **Repository Pattern**: Centralized data management in `EventRepository`
- **State Management**: Cubit (from flutter_bloc) for business logic
- **Dependency Injection**: get_it for service locator pattern
- **Immutable Models**: Using Equatable for value equality
- **Separation of Concerns**: Clear separation between UI, business logic, and data layers

### Data Flow

1. **UI Layer** (Screens) → Displays data and handles user interactions
2. **State Management Layer** (Cubits) → Manages business logic and state
3. **Data Layer** (Repository) → Provides data access (currently hardcoded, ready for API integration)

## Development

The app is built with Flutter and uses:
- Material Design 3
- Google Fonts (Inter)
- Cubit for state management
- Repository pattern for data access
- Custom color schemes for dance style tags
- Taskfile for automation

## Running the App

The app is currently configured to run on:
- **Web**: http://localhost:3000 (use `task run-web`)
- **Android**: Connect your device and run `task run-android`
- **iOS**: Connect your device and run `task run-ios`

## Testing

Run tests using:
```bash
flutter test
```

## Building for Production

```bash
# Web
task build-web

# Android
task build-android

# iOS
task build-ios
```

## Next Steps

- ✅ Implement repository pattern with state management
- ✅ Add favorites functionality
- Add backend integration for real event data (API ready architecture)
- Implement user authentication
- Add event details screen
- Add location-based filtering
- Add push notifications for new events
- Implement event search and advanced filtering