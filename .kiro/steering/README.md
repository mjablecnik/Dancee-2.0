---
inclusion: always
---

# Dancee App - Steering Files Overview

This directory contains steering files that guide AI development for the Dancee App project. Each file focuses on a specific aspect of the project.

## Available Steering Files

### 📁 project-structure.md
- Project overview and architecture
- Directory structure
- Backend services description
- Platform support information

### 📚 documentation-standards.md
- Documentation file placement rules
- Naming conventions
- Organization standards

### 🌐 internationalization.md
- Multi-language support (en, cs, es)
- slang_flutter usage
- Translation workflow
- Common mistakes to avoid

### 🔐 configuration-management.md
- Sensitive configuration handling
- app_config.dart usage
- Environment-specific settings
- Security best practices

### 🛠️ task-management.md
- Taskfile commands reference
- Frontend tasks (Flutter)
- Backend tasks (NestJS, Dart)
- Quick command reference

### 🔧 development-workflow.md
- Development workflow guidelines
- Code standards for AI
- Pre-change checklist
- AI-specific instructions

### 🔄 api-documentation-sync.md
- Centralized API documentation in dancee_api
- OpenAPI/Swagger synchronization rules
- Workflow for API changes
- Examples and validation

## How to Use

All steering files are set to `inclusion: always`, meaning they are automatically loaded into the AI context. You don't need to manually reference them.

## Adding New Steering Files

When adding new steering files:
1. Add frontmatter with `inclusion: always`
2. Use descriptive filenames (kebab-case)
3. Focus on a single topic per file
4. Update this README with the new file description
