# Changelog

All notable changes to the Dancee Server project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **SwaggerAuthMiddleware path detection bug** - Fixed critical issue where `req.path` always returned "/" causing incorrect route protection. Changed to use `req.originalUrl || req.url` for accurate path detection. This ensures:
  - `/api` and `/api/*` routes are properly protected with basic auth in production
  - `/events/*` routes remain publicly accessible
  - Query strings are handled correctly
  - Development mode bypasses authentication as expected
  - See [docs/SWAGGER_AUTH_FIX.md](./docs/SWAGGER_AUTH_FIX.md) for details

### Added
- Comprehensive unit tests for path detection in SwaggerAuthMiddleware (9 new tests)
- Documentation for middleware testing in [docs/MIDDLEWARE_TESTING.md](./docs/MIDDLEWARE_TESTING.md)
- Documentation for the authentication fix in [docs/SWAGGER_AUTH_FIX.md](./docs/SWAGGER_AUTH_FIX.md)

### Changed
- Removed debug console.log statements from SwaggerAuthMiddleware

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Dancee Server
- Facebook event scraping functionality
- RESTful API endpoints
- Swagger/OpenAPI documentation
- Events management API
- Favorites system
- Docker support
- Fly.io deployment configuration
