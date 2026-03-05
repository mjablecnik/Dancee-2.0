---
inclusion: always
---

# Development Workflow

## Development Workflow for Kiro AI

When working with this project:

1. **Setup**: Always suggest `task get-deps` to install dependencies
2. **Development**: Recommend `task run-web` for quick testing
3. **Code Generation**: Use `task build-runner-watch` when working with generated code
4. **Translations**: Use `task slang-watch` when working with translations
5. **Testing**: Suggest testing on multiple platforms when relevant
6. **Build**: Use appropriate build tasks for production builds

## Code Standards for AI

When generating or modifying code:
- Follow Flutter/Dart conventions strictly
- Use meaningful English variable and function names
- Add English comments for complex logic
- Ensure cross-platform compatibility
- Use proper state management patterns
- **ALWAYS use slang translations for user-facing strings** - never hardcode text
- **Add translations to ALL language files** (en, cs, es) when creating new strings
- **Run `task slang`** after modifying translation files

## Before Making Changes

As Kiro AI, always:
1. Check current taskfile.yaml for available commands
2. **Ensure all user-facing strings use slang translations** (never hardcode)
3. **Add translations to ALL language files** when creating new strings
4. **Store sensitive values in `app_config.dart`** (API URLs, keys, tokens)
5. Consider cross-platform implications
6. Use build runner tasks for code generation needs
7. **Run `task slang`** after modifying translation files
8. Suggest appropriate task commands instead of direct Flutter commands
9. **Place documentation in `docs/` folder** (except README.md)

## AI-Specific Instructions

- **CRITICAL: Never hardcode user-facing strings** - always use slang translations
- **When adding new UI text**: Add to all 3 language files (en, cs, es) and run `task slang`
- **Store sensitive config in `app_config.dart`**: API URLs, keys, tokens, credentials
- Utilize taskfile commands in all suggestions
- Consider Flutter best practices and cross-platform compatibility
- When creating new files, ensure they follow the project structure
- Suggest appropriate testing strategies for multi-platform development
- Be aware of Flutter-specific patterns and state management approaches
- **Import translations**: Always include `import '../i18n/translations.g.dart';` in UI files
- **Use global `t` variable** for translations: `t.keyName` or `t.method(param: value)`
- **Never commit sensitive values** - always use `app_config.dart` for environment-specific data
- **Documentation placement**: All docs in `docs/` folder except `README.md`
- **Use appropriate backend**: `dancee_server` for scraping/external APIs, `dancee_event_service` for event data management
- **NestJS conventions**: Follow NestJS patterns for `dancee_server` (modules, controllers, services, DTOs)
- **TypeScript best practices**: Use proper typing, interfaces, and decorators in `dancee_server`

## Remember

This guide ensures consistency and maintainability for international development teams working on the Dancee App project.
