---
inclusion: always
---

# Task Management

This project uses **Taskfile** for automation. Always use tasks instead of direct Flutter commands when suggesting or running commands.

## Frontend Tasks (Flutter)

### Essential Tasks
- `task run-web` - Run app on web (port 3000)
- `task run-android` - Run app on Android device/emulator
- `task run-ios` - Run app on iOS device/simulator
- `task get-deps` - Install Flutter dependencies
- `task clean` - Clean project

### Build Tasks
- `task build-web` - Build for web production
- `task build-android` - Build APK for Android
- `task build-ios` - Build for iOS

### Code Generation
- `task build-runner` - Run build runner for code generation
- `task build-runner-force` - Run with delete conflicting outputs
- `task build-runner-watch` - Run in watch mode
- `task build-runner-clean` - Clean generated files

### Translation Tasks
- `task slang` - Generate translations from JSON files
- `task slang-watch` - Watch and auto-regenerate translations
- `task slang-analyze` - Analyze translations for missing keys

## Backend Tasks

### dancee_server (NestJS)
```bash
task install      # Install dependencies
task dev          # Start development server with hot reload
task start        # Start production server
task build        # Build the application
task lint         # Run linter
task format       # Format code with prettier
task test         # Run tests
task test-watch   # Run tests in watch mode
task test-e2e     # Run end-to-end tests
task clean        # Clean build artifacts
```

### dancee_event_service (Dart)
```bash
task get-deps     # Install dependencies
task run          # Start the service
task test         # Run tests
```

## Quick Commands Reference

**Frontend (Flutter):**
```bash
# Start development
task get-deps
task run-web

# Code generation
task build-runner-watch

# Translations
task slang              # Generate translations
task slang-watch        # Auto-regenerate translations
task slang-analyze      # Check for missing keys

# Build for production
task build-web
task build-android
task build-ios
```

**Backend - dancee_server (NestJS):**
```bash
# Start development
task install
task dev                # Development with hot reload

# Code quality
task lint
task format

# Testing
task test
task test-watch
task test-e2e

# Build for production
task build
task start
```

**Backend - dancee_event_service (Dart):**
```bash
# Start development
task get-deps
task run

# Testing
task test
```
