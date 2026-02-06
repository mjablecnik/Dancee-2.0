# Slang Flutter Migration Guide

## Overview

This document describes the migration from Flutter's built-in localization system to `slang_flutter` for the Dancee App.

## What Changed

### Dependencies Added

**pubspec.yaml:**
- `slang: ^3.31.2` - Core slang library
- `slang_flutter: ^3.31.0` - Flutter integration
- `slang_build_runner: ^3.31.0` (dev) - Code generation
- `build_runner: ^2.4.13` (dev) - Build runner support

### Configuration Files

1. **slang.yaml** - Slang configuration file
   - Defines translation file locations
   - Sets up code generation options
   - Configures interpolation format

2. **lib/i18n/strings.i18n.json** - English translations (base locale)
3. **lib/i18n/strings_cs.i18n.json** - Czech translations
4. **lib/i18n/strings_es.i18n.json** - Spanish translations

### Generated Files

After running `task slang`, the following file is generated:
- `lib/i18n/translations.g.dart` - Generated translation classes

## Migration Steps

### 1. Install Dependencies

```bash
cd frontend/dancee_app
task get-deps
```

### 2. Generate Translation Files

```bash
task slang
```

This generates the `lib/i18n/translations.g.dart` file from your JSON translation files.

### 3. Update main.dart

**Before:**
```dart
import 'l10n/app_localizations.dart';

void main() {
  setupDependencies();
  runApp(const MyApp());
}

// In MaterialApp:
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('en'),
  Locale('cs'),
  Locale('es'),
],
```

**After:**
```dart
import 'i18n/translations.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  setupDependencies();
  runApp(TranslationProvider(child: const MyApp()));
}

// In MaterialApp:
locale: TranslationProvider.of(context).flutterLocale,
supportedLocales: AppLocaleUtils.supportedLocales,
localizationsDelegates: GlobalMaterialLocalizations.delegates,
```

### 4. Update Screen Files

**Before:**
```dart
import '../l10n/app_localizations.dart';

// Usage:
Text(AppLocalizations.of(context)!.events)
```

**After:**
```dart
import '../i18n/translations.g.dart';

// Usage:
Text(t.events)
```

### 5. Update Parameterized Strings

**Before:**
```dart
AppLocalizations.of(context)!.eventsCount(5)
```

**After:**
```dart
t.eventsCount(count: 5)
```

## New Task Commands

### Generate Translations
```bash
task slang
```
Generates translation files from JSON sources.

### Watch Mode
```bash
task slang-watch
```
Automatically regenerates translations when JSON files change.

### Analyze Translations
```bash
task slang-analyze
```
Checks for missing translation keys across locales.

## Benefits of Slang

1. **Type Safety** - Compile-time checking of translation keys
2. **Better Performance** - No runtime lookups
3. **Simpler API** - Direct access via `t.keyName`
4. **Auto-completion** - Full IDE support
5. **Parameterized Strings** - Named parameters with type safety
6. **Watch Mode** - Automatic regeneration during development

## File Structure

```
frontend/dancee_app/
├── lib/
│   └── i18n/
│       ├── strings.i18n.json          # English (base)
│       ├── strings_cs.i18n.json       # Czech
│       ├── strings_es.i18n.json       # Spanish
│       └── translations.g.dart        # Generated (do not edit)
├── slang.yaml                         # Slang configuration
└── pubspec.yaml                       # Updated dependencies
```

## Common Usage Patterns

### Simple String
```dart
Text(t.events)
```

### Parameterized String
```dart
Text(t.eventsCount(count: eventList.length))
```

### String with Named Parameter
```dart
Text(t.tuesdayDate(date: '4.2.2025'))
```

### Accessing in Build Methods
```dart
@override
Widget build(BuildContext context) {
  // Direct access to translations
  return Text(t.appTitle);
}
```

## Remaining Migration Tasks

The following files still need to be updated to use slang:

1. ✅ `lib/main.dart` - Updated
2. ⏳ `lib/screens/event_list_screen.dart` - Partially updated
3. ⏳ `lib/screens/favorites_screen.dart` - Needs update
4. ⏳ Any test files using translations

## Troubleshooting

### Translations not found
Run `task slang` to regenerate the translations file.

### IDE not recognizing `t`
The `t` variable is a global getter provided by slang. Make sure:
1. You've imported `translations.g.dart`
2. You've run `task slang` to generate the file
3. Your IDE has indexed the generated file

### Build errors after migration
1. Clean the project: `task clean`
2. Get dependencies: `task get-deps`
3. Generate translations: `task slang`
4. Run the app: `task run-web`

## References

- [Slang Documentation](https://pub.dev/packages/slang)
- [Slang Flutter Documentation](https://pub.dev/packages/slang_flutter)
- [Migration Guide](https://github.com/Tienisto/slang/blob/main/slang/MIGRATION.md)
