---
inclusion: always
---

# Internationalization (i18n) Requirements

**CRITICAL**: The app supports multiple languages and ALL user-facing strings MUST be translated.

## Supported Languages

- **English (en)** - Base locale
- **Czech (cs)** - Primary target audience
- **Spanish (es)** - Additional language

## Localization System

The app uses **slang_flutter** for type-safe translations.

**NEVER hardcode user-facing strings in code!**

❌ **WRONG:**
```dart
Text('Events')  // Hardcoded string
Text('${count} events')  // Hardcoded with interpolation
```

✅ **CORRECT:**
```dart
Text(t.events)  // Using slang translation
Text(t.eventsCount(count: count))  // With parameters
```

## Adding New Translations

1. **Add to all language files** in `lib/i18n/`:
   - `strings.i18n.json` (English - base)
   - `strings_cs.i18n.json` (Czech)
   - `strings_es.i18n.json` (Spanish)

2. **Simple string:**
```json
{
  "myNewKey": "My new text"
}
```

3. **String with parameters** (use `{paramName}` syntax):
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

## Translation Tasks

- `task slang` - Generate translations from JSON files
- `task slang-watch` - Auto-regenerate on file changes (use during development)
- `task slang-analyze` - Check for missing translation keys

## Important Rules

1. **Always add translations to ALL language files** (en, cs, es)
2. **Never hardcode user-facing strings** in Dart code
3. **Use named parameters** for parameterized strings: `t.method(param: value)`
4. **Run `task slang`** after modifying translation files
5. **Import translations**: `import '../i18n/translations.g.dart';`
6. **Access via global `t`**: No need for `context` or `of(context)`

## Common Mistakes to Avoid

❌ Hardcoding strings: `Text('Hello')`
❌ Missing language: Only adding to English file
❌ Wrong parameter syntax: `t.eventsCount(5)` instead of `t.eventsCount(count: 5)`
❌ Forgetting to regenerate: Not running `task slang` after changes
❌ Using old system: `AppLocalizations.of(context)` (deprecated)
