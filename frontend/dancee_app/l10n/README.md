# Localization Files (ARB)

This directory contains the Application Resource Bundle (ARB) files for internationalization.

## Files

- `app_en.arb` - English translations (template file)
- `app_cs.arb` - Czech translations
- `app_es.arb` - Spanish translations

## Structure

ARB files are JSON-based and contain key-value pairs for translations:

```json
{
  "@@locale": "en",
  "keyName": "Translation text",
  "@keyName": {
    "description": "Description of what this translation is for"
  }
}
```

## Adding New Translations

1. Add the new key to `app_en.arb` (template file) with description
2. Add the same key with translated text to `app_cs.arb`
3. Add the same key with translated text to `app_es.arb`
4. Run `task get-deps` to regenerate localization classes

## Generated Files

The generated Dart localization files are created in `lib/l10n/` directory:
- `app_localizations.dart` - Main localization class
- `app_localizations_en.dart` - English implementation
- `app_localizations_cs.dart` - Czech implementation
- `app_localizations_es.dart` - Spanish implementation

**Note**: The `lib/l10n/` directory is auto-generated and should not be edited manually. It's also added to `.gitignore`.

## Configuration

Localization generation is configured in `l10n.yaml`:
- Source ARB files: `l10n/` directory
- Generated output: `lib/l10n/` directory
- Template file: `app_en.arb`

## Usage in Code

```dart
import 'package:dancee_app/l10n/app_localizations.dart';

// In your widget
Text(AppLocalizations.of(context)!.keyName)
```

## Best Practices

1. Always use English for key names
2. Provide meaningful descriptions for each key
3. Keep translations consistent across all languages
4. Use placeholders for dynamic content
5. Test all languages before committing

## Placeholders Example

```json
{
  "eventsCount": "{count} events",
  "@eventsCount": {
    "description": "Number of events",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

Usage:
```dart
Text(AppLocalizations.of(context)!.eventsCount(5))
```
