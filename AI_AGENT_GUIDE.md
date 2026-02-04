# AI Agent Guide - Dancee App

## Project Overview

Dancee App is a Flutter-based mobile and web application for dance enthusiasts. The project is structured as a multi-platform application supporting Android, iOS, and web platforms.

## Project Structure

```
├── frontend/
│   └── dancee_app/          # Main Flutter application
│       ├── lib/             # Dart source code
│       ├── android/         # Android-specific files
│       ├── ios/             # iOS-specific files
│       ├── web/             # Web-specific files
│       ├── test/            # Test files
│       ├── taskfile.yaml    # Task automation file
│       └── pubspec.yaml     # Flutter dependencies
└── backend/                 # Backend services (if applicable)
```

## Important Development Guidelines

### 🌍 Language Requirements
**CRITICAL**: All code, comments, strings, variable names, function names, and documentation MUST be written in English only. This is mandatory because international developers who don't speak Czech may work on this project.

Examples:
- ✅ `String userName = "Enter your name";`
- ❌ `String uzivatel = "Zadejte své jméno";`
- ✅ `// Calculate user score`
- ❌ `// Vypočítej skóre uživatele`

### 🛠️ Task Management

This project uses **Taskfile** for automation. Always use tasks instead of direct Flutter commands:

#### Essential Tasks:
- `task run-web` - Run app on web (port 3000)
- `task run-android` - Run app on Android device/emulator
- `task run-ios` - Run app on iOS device/simulator
- `task get-deps` - Install Flutter dependencies
- `task clean` - Clean project

#### Build Tasks:
- `task build-web` - Build for web production
- `task build-android` - Build APK for Android
- `task build-ios` - Build for iOS

#### Code Generation:
- `task build-runner` - Run build runner for code generation
- `task build-runner-force` - Run with delete conflicting outputs
- `task build-runner-watch` - Run in watch mode
- `task build-runner-clean` - Clean generated files

### 📱 Platform Support

The app supports three platforms:
1. **Web** - Progressive web app
2. **Android** - Native Android application
3. **iOS** - Native iOS application

### 🔧 Development Workflow

1. **Setup**: Run `task get-deps` to install dependencies
2. **Development**: Use `task run-web` for quick testing
3. **Code Generation**: Use `task build-runner-watch` when working with generated code
4. **Testing**: Test on all platforms before deployment
5. **Build**: Use appropriate build tasks for production

### 📋 Code Standards

- Follow Flutter/Dart conventions
- Use meaningful English variable and function names
- Add English comments for complex logic
- Ensure cross-platform compatibility
- Use proper state management patterns

### 🚨 Before Making Changes

1. Check current taskfile.yaml for available commands
2. Ensure all new code follows English-only rule
3. Test changes on multiple platforms when possible
4. Use build runner tasks for code generation needs

### 📞 Quick Commands Reference

```bash
# Start development
task get-deps
task run-web

# Code generation
task build-runner-watch

# Build for production
task build-web
task build-android
task build-ios
```

Remember: Always prioritize English language usage and utilize the taskfile for all operations!