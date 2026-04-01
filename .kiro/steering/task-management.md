---
inclusion: always
---

# Task Management

This project uses **Taskfile** for automation. Always use tasks instead of direct commands when suggesting or running commands.

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

### Testing Tasks
- `task test` - Run all Flutter tests
- `task test-coverage` - Run tests with coverage report

## Backend Tasks

### dancee_api (TypeScript/Express)
```bash
task install        # Install dependencies (npm)
task dev            # Start development server with hot reload
task build          # Build TypeScript to JavaScript
task start          # Start production server
task test           # Run all tests
task test-watch     # Run tests in watch mode
task test-coverage  # Run tests with coverage report
task lint           # Run ESLint
task lint-fix       # Run ESLint and fix issues
task format         # Format code with Prettier
task format-check   # Check code formatting
task clean          # Clean build artifacts
task clean-build    # Clean and rebuild
```

### dancee_workflow (TypeScript/Restate)
```bash
task install          # Install dependencies (bun)
task dev              # Start development server with hot reload
task build            # Build TypeScript to JavaScript
task start            # Start production server
task test             # Run all tests
task setup-directus   # Create Directus collections and seed languages
task docker-build     # Build Docker image
task docker-up        # Start service with Docker Compose
task docker-down      # Stop Docker Compose service
task clean            # Clean build artifacts
task clean-build      # Clean and rebuild
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

# Testing
task test
task test-coverage

# Build for production
task build-web
task build-android
task build-ios
```

**Backend - dancee_api (Express):**
```bash
# Start development
task install
task dev

# Code quality
task lint
task format

# Testing
task test
task test-watch
task test-coverage

# Build for production
task build
task start
```

**Backend - dancee_workflow (Restate):**
```bash
# Start development
task install
task dev

# Testing
task test

# Docker
task docker-build
task docker-up
task docker-down

# Directus setup
task setup-directus

# Build for production
task build
task start
```
