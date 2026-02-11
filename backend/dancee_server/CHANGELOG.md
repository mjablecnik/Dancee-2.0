# Changelog

All notable changes to the Dancee Server project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Refactored project structure: moved app files to `src/app/` folder
- Simplified Swagger authentication: using `express-basic-auth` instead of custom middleware
- Cleaned up documentation: removed 16 redundant/obsolete MD files

### Removed
- Custom `SwaggerAuthMiddleware` (replaced with `express-basic-auth`)
- Obsolete documentation files (migration guides, summaries, duplicates)

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Dancee Server
- Facebook event scraping functionality
- RESTful API endpoints
- Swagger/OpenAPI documentation with Basic Auth protection in production
- Events management API
- Favorites system with Firestore integration
- Docker support
- Fly.io deployment configuration
- Comprehensive documentation
