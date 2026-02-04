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
- **Bottom Navigation** - Easy navigation between app sections
- **Czech Language Support** - Full Czech localization

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
   flutter pub get
   ```

4. Run the app:
   ```bash
   # For web
   flutter run -d web-server --web-port 8080
   
   # For mobile (with device connected)
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
└── screens/
    └── event_list_screen.dart   # Main events listing screen
```

## Dependencies

- `flutter`: Flutter SDK
- `google_fonts`: Beautiful Inter font family
- `cupertino_icons`: iOS-style icons

## Design

The app follows the design from `design/event-list.html` with:
- Modern gradient backgrounds
- Clean card-based layout
- Intuitive filtering system
- Responsive design for mobile devices
- Czech language interface

## Development

The app is built with Flutter and uses:
- Material Design 3
- Google Fonts (Inter)
- Stateful widgets for interactivity
- Custom color schemes for dance style tags

## Running the App

The app is currently configured to run on:
- **Web**: http://localhost:3000 
- **Mobile**: Connect your device and run `flutter run`

## Next Steps

- Add backend integration for real event data
- Implement user authentication
- Add event details screen
- Implement favorites functionality
- Add location-based filtering
- Add push notifications for new events