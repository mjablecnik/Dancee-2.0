# Dancee App

A beautiful Flutter mobile app for discovering and browsing dance events in Czech Republic.

## Features

- **Multi-language Support** - English, Czech, and Spanish
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

4. Generate translations (if needed):
   ```bash
   task slang
   ```

5. Run the app:
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
├── i18n/
│   ├── strings.i18n.json        # English translations (base)
│   ├── strings_cs.i18n.json     # Czech translations
│   ├── strings_es.i18n.json     # Spanish translations
│   └── translations.g.dart      # Generated translation code (do not edit)
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
- `slang`: Type-safe internationalization
- `slang_flutter`: Flutter integration for slang
- `intl`: Internationalization utilities

## Internationalization (i18n)

The app supports multiple languages using **slang_flutter** for type-safe translations.

### Supported Languages

- **English (en)** - Base locale
- **Czech (cs)** - Primary target audience  
- **Spanish (es)** - Additional language

### Adding New Translations

1. **Add to all language files** in `lib/i18n/`:
   - `strings.i18n.json` (English)
   - `strings_cs.i18n.json` (Czech)
   - `strings_es.i18n.json` (Spanish)

2. **Simple string:**
   ```json
   {
     "myNewKey": "My new text"
   }
   ```

3. **String with parameters:**
   ```json
   {
     "welcomeUser": "Welcome, {name}!",
     "itemCount": "{count} items"
   }
   ```

4. **Generate translations:**
   ```bash
   task slang
   ```

5. **Use in code:**
   ```dart
   import '../i18n/translations.g.dart';
   
   // Simple string
   Text(t.myNewKey)
   
   // With parameters (named parameters required)
   Text(t.welcomeUser(name: userName))
   Text(t.itemCount(count: items.length))
   ```

### Translation Commands

```bash
task slang              # Generate translations
task slang-watch        # Auto-regenerate on file changes
task slang-analyze      # Check for missing keys
```

### Important Rules

- ✅ **Always use translations**: `Text(t.events)` 
- ❌ **Never hardcode strings**: `Text('Events')`
- ✅ **Add to ALL language files** (en, cs, es)
- ✅ **Use named parameters**: `t.eventsCount(count: 5)`
- ✅ **Run `task slang`** after modifying translation files

## Design

The app follows the design from `.design/event-list.html` with:
- Modern gradient backgrounds
- Clean card-based layout
- Intuitive filtering system
- Responsive design for mobile devices
- Multi-language support (English, Czech, Spanish)

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
3. **Data Layer** (Repository) → Provides data access via REST API

## Development

The app is built with Flutter and uses:
- Material Design 3
- Google Fonts (Inter)
- Cubit for state management
- Repository pattern for data access
- **slang_flutter** for type-safe internationalization
- Custom color schemes for dance style tags
- Taskfile for automation

### Development Workflow

For active development with translations:

```bash
# Terminal 1: Watch translations
task slang-watch

# Terminal 2: Run app
task run-web
```

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

- Add backend integration for real-time event updates
- Implement user authentication
- Add event details screen
- Add location-based filtering
- Add push notifications for new events
- Implement advanced search and filtering