# Dancee Shared

Shared Dart package containing common models, utilities, and business logic for both the Dancee App frontend and backend services.

## Purpose

This package provides:
- **Data Models**: Event, Venue, Address, EventInfo, EventPart
- **Shared Business Logic**: Common utilities and functions
- **Type Safety**: Consistent data structures across frontend and backend

## Usage

### In Frontend (Flutter)

Add to `pubspec.yaml`:
```yaml
dependencies:
  dancee_shared:
    path: ../../shared/dancee_shared
```

### In Backend (Dart)

Add to `pubspec.yaml`:
```yaml
dependencies:
  dancee_shared:
    path: ../../shared/dancee_shared
```

### Import Models

```dart
import 'package:dancee_shared/dancee_shared.dart';

// Use models
final event = Event(
  id: '1',
  title: 'Salsa Night',
  // ...
);
```

## Development

### Install Dependencies
```bash
dart pub get
```

### Run Tests
```bash
dart test
```

### Analyze Code
```bash
dart analyze
```

## Structure

```
lib/
├── src/
│   └── models/
│       ├── address.dart
│       ├── event.dart
│       ├── event_info.dart
│       ├── event_part.dart
│       └── venue.dart
└── dancee_shared.dart  # Main export file
```
