---
inclusion: always
---

# Kiro AI Guide - Dancee App

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

## Critical Development Guidelines for Kiro AI

### 🌍 Language Requirements
**MANDATORY**: All code, comments, strings, variable names, function names, and documentation MUST be written in English only. This is non-negotiable because international developers who don't speak Czech may work on this project.

Examples:
- ✅ `String userName = "Enter your name";`
- ❌ `String uzivatel = "Zadejte své jméno";`
- ✅ `// Calculate user score`
- ❌ `// Vypočítej skóre uživatele`

### 🛠️ Task Management

This project uses **Taskfile** for automation. Always use tasks instead of direct Flutter commands when suggesting or running commands:

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

### 🔧 Development Workflow for Kiro AI

When working with this project:

1. **Setup**: Always suggest `task get-deps` to install dependencies
2. **Development**: Recommend `task run-web` for quick testing
3. **Code Generation**: Use `task build-runner-watch` when working with generated code
4. **Testing**: Suggest testing on multiple platforms when relevant
5. **Build**: Use appropriate build tasks for production builds

### 📋 Code Standards for AI

When generating or modifying code:
- Follow Flutter/Dart conventions strictly
- Use meaningful English variable and function names
- Add English comments for complex logic
- Ensure cross-platform compatibility
- Use proper state management patterns
- Never use Czech language in any code elements

### 🚨 Before Making Changes

As Kiro AI, always:
1. Check current taskfile.yaml for available commands
2. Ensure all new code follows English-only rule
3. Consider cross-platform implications
4. Use build runner tasks for code generation needs
5. Suggest appropriate task commands instead of direct Flutter commands

### 📞 Quick Commands Reference

When suggesting commands to users:

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

### 🤖 AI-Specific Instructions

- Always prioritize English language usage in all generated content
- Utilize taskfile commands in all suggestions
- Consider Flutter best practices and cross-platform compatibility
- When creating new files, ensure they follow the project structure
- Suggest appropriate testing strategies for multi-platform development
- Be aware of Flutter-specific patterns and state management approaches

Remember: This guide ensures consistency and maintainability for international development teams working on the Dancee App project.