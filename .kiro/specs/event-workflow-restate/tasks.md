# Implementation Plan: event-workflow-restate

## Overview

Incremental implementation of the Restate-based event processing workflow service. Each task builds on the previous, starting with project scaffolding and core types, then clients, services, workflow orchestration, translation, and finally the setup script and Docker configuration. All code is TypeScript with Bun as the package manager.

## Tasks

- [x] 1. Scaffold project structure and configuration
  - [x] 1.1 Initialize the project with Bun and configure TypeScript
    - Create `backend/dancee_workflow/` directory
    - Run `bun init`, add dependencies: `@restatedev/restate-sdk`, `openai`, `zod`, `dotenv`, `@sentry/node`
    - Add dev dependencies: `vitest`, `fast-check`, `typescript`
    - Configure `tsconfig.json` with strict mode enabled
    - Configure `vitest.config.ts`
    - Set `"test": "vitest --run"` in `package.json` scripts
    - _Requirements: 15.1, 15.2, 16.1, 16.2, 16.8_

  - [x] 1.2 Create environment configuration files
    - Create `.env.example` with all variable keys: `OPENROUTER_API_KEY`, `OPENROUTER_MODEL`, `DIRECTUS_BASE_URL`, `DIRECTUS_ACCESS_TOKEN`, `SCRAPER_BASE_URL`, `NOMINATIM_BASE_URL`, `SENTRY_DSN`, `CORS_ORIGINS`, `APP_PORT`
    - Create `.gitignore` with `.env`, `node_modules/`, `dist/`
    - _Requirements: 15.1, 15.2, 15.3, 15.4_

  - [x] 1.3 Implement `src/core/config.ts` — environment config loader and Sentry initialization
    - Load all env vars via `dotenv`, export typed `config` object with defaults (`NOMINATIM_BASE_URL` defaults to `https://nominatim.openstreetmap.org`, `APP_PORT` defaults to `9080`)
    - Implement `initSentry()` that skips initialization and logs a warning when DSN is empty
    - Implement `captureError(error, context)` that attaches context as Sentry tags
    - _Requirements: 15.1, 18.1, 18.2, 18.3, 18.4_

  - [x] 1.4 Implement `src/core/schemas.ts` — Zod schemas and TypeScript types
    - Define all Zod schemas: `FacebookEventSchema`, `EventTypeSchema`, `EventPartSchema`, `EventInfoSchema`, `DirectusEventSchema`, `DirectusEventTranslationSchema`, `DirectusLanguageSchema`, `DirectusVenueSchema`, `DirectusGroupSchema`, `DirectusErrorSchema`, `NominatimResponseSchema`
    - Export inferred TypeScript types and `SUPPORTED_EVENT_TYPES` constant
    - Implement `parseEventType(value: string): EventType` that defaults to `"other"` for unrecognized values
    - Implement `filterEventInfo(items): EventInfo[]` that excludes entries with empty/null values
    - Implement `computeDances(parts: EventPart[]): string[]` that aggregates unique dance names
    - Implement `parseJsonResponse(raw: string): unknown` that strips markdown code fences before parsing
    - _Requirements: 3.2, 3.3, 5.3, 17.3, 20.1, 20.2, 20.3_

  - [x]* 1.5 Write property tests for core utility functions
    - **Property 4: Event type parsing always returns a valid type**
    - **Property 6: LLM response JSON parsing strips code fences**
    - **Property 8: Empty EventInfo values are filtered out**
    - **Property 15: Computed dances field is the unique set from all parts**
    - **Validates: Requirements 3.2, 3.3, 5.3, 17.3, 20.1, 20.2, 20.3**

  - [x] 1.6 Implement `src/core/prompts.ts` — LLM prompt templates
    - Implement `getEventTypeClassificationPrompt()` — English prompt for event type classification
    - Implement `getEventPartsExtractionPrompt(outputLanguage: string)` — English prompt with outputLanguage parameter for Czech extraction
    - Implement `getEventInfoExtractionPrompt()` — English prompt for event info extraction
    - Implement `getTranslationPrompt(targetLanguage: string)` — single parameterized English prompt for translation
    - All prompts must be in English per LLM prompt standards
    - _Requirements: 17.4, 17.5, 21.2, 21.3_

- [x] 2. Implement HTTP clients for external services
  - [x] 2.1 Implement `src/clients/scraper-client.ts`
    - Implement `scrapeEvent(eventIdOrUrl: string): Promise<FacebookEvent>` — GET to `/api/scraper/event/{eventId}`
    - Implement `scrapeEventList(pageId: string, eventType?: "upcoming" | "past"): Promise<FacebookEvent[]>` — GET to `/api/scraper/events?pageId={pageId}` with optional `eventType` query param
    - Propagate HTTP errors with status code and error message
    - Read base URL from config
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3_

  - [x]* 2.2 Write property tests for scraper client
    - **Property 1: Scraper client error propagation**
    - **Property 3: Event type query parameter inclusion**
    - **Validates: Requirements 1.2, 2.2, 2.3**

  - [x] 2.3 Implement `src/clients/nominatim-client.ts`
    - Implement `reverseGeocode(lat: number, lng: number): Promise<NominatimResponse>` — GET to Nominatim `/reverse` endpoint
    - Respect usage policy: max 1 request per second (simple delay/throttle)
    - Read base URL from config
    - _Requirements: 6.6_

  - [x] 2.4 Implement `src/clients/directus-client.ts`
    - Implement event functions: `createEvent`, `findEventByOriginalUrl`, `listEvents` (default filter: status=published)
    - Implement venue functions: `createVenue`, `findVenue` (by name/street/town), `findVenueByCoordinates`
    - Implement group functions: `getGroupsOrderedByUpdatedAt`, `updateGroupTimestamp`
    - Implement error functions: `createError`, `findErrorByUrl`
    - Implement language functions: `getLanguages`, `createLanguage`
    - `createEvent` uses nested translations relation for single API call creation
    - Read Directus base URL and token from config
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4, 11.1, 11.2, 11.3, 12.1, 12.2, 22.1, 22.4, 23.4_

  - [x]* 2.5 Write property tests for Directus client deduplication and ordering
    - **Property 10: Venue deduplication** (with mock Directus)
    - **Property 11: Event deduplication by original URL** (with mock Directus)
    - **Property 12: Error deduplication by URL** (with mock Directus)
    - **Property 13: Groups ordered by updated_at ascending**
    - **Validates: Requirements 6.7, 6.8, 7.2, 7.4, 8.2, 8.3, 10.3, 11.3, 12.2**

- [x] 3. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Implement business logic services
  - [x] 4.1 Implement `src/services/event-parser.ts` — LLM-based classification and extraction
    - Configure OpenAI SDK with `baseURL: "https://openrouter.ai/api/v1"` and `apiKey` from config
    - Implement `classifyEventType(description: string): Promise<EventType>` — uses classification prompt, parses with `parseEventType`
    - Implement `extractEventParts(description: string): Promise<{title, description, parts[]}>` — uses extraction prompt with `outputLanguage: "Czech"`, retries up to 2 additional times on invalid JSON
    - Implement `extractEventInfo(description: string): Promise<EventInfo[]>` — uses info extraction prompt, filters empty values
    - Use `parseJsonResponse` for all LLM response parsing
    - _Requirements: 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 5.1, 5.2, 5.3, 17.1, 17.2, 17.3, 17.4_

  - [x] 4.2 Implement `src/services/event-translator.ts` — LLM-based translation
    - Implement `translateEventContent(content, targetLanguage): Promise<TranslatedEventContent>` — uses translation prompt with `targetLanguage` parameter
    - Translate: title, description, EventPart name/description, EventInfo key
    - Do NOT translate: dates, times, coordinates, URLs, price values, dance names, lectors, DJs, organizer, venue names
    - Retry up to 2 additional times on invalid JSON before propagating error
    - Use `parseJsonResponse` for LLM response parsing
    - _Requirements: 17.5, 21.1, 21.2, 21.3, 21.7_

  - [x]* 4.3 Write property tests for translation logic
    - **Property 16: Translation produces non-empty content for all supported languages**
    - **Property 17: Translation preserves non-translatable fields**
    - **Property 20: Translation parts_translations array length matches parts array**
    - **Validates: Requirements 21.1, 21.2, 21.3, 22.2, 22.3**

  - [x] 4.4 Implement `src/services/venue-resolver.ts` — venue resolution with geocoding
    - Implement `resolveVenue(location: FacebookLocation): Promise<DirectusVenue>`
    - Check Directus for existing venue by coordinates or by (name, street, town) before calling Nominatim
    - Use Facebook location fields directly when available (name, address, city, countryCode)
    - Fall back to Nominatim reverse geocoded address when Facebook fields are missing
    - Map Nominatim `address.state` to venue `region`, default to `"Other"` when absent
    - Create new venue in Directus if not found
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 8.1, 8.4_

  - [x]* 4.5 Write property tests for venue resolution
    - **Property 9: Venue resolution field mapping**
    - **Property 2: Null end timestamp preservation**
    - **Property 5: Unsupported event types are skipped**
    - **Validates: Requirements 6.2, 6.3, 6.4, 6.5, 1.4, 3.4**

- [x] 5. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Implement Restate workflows and API service
  - [x] 6.1 Implement `src/services/workflow.ts` — single event processing workflow
    - Define Restate workflow with steps: scrape → classify → skip if unsupported → extract parts → extract info → resolve venue → derive organizer (hosts[0].name, fallback: event name) → translate to EN and ES → compute dances → compute translation_status → store event with all translations in Directus
    - Store event URL, processing status, and error messages in Restate K/V state
    - Set `status` to `"published"` and compute `translation_status` based on successful translations
    - Store `original_description` from raw Facebook description, Czech extraction output as "cs" translation
    - Store `end_time` as null when `endTimestamp` is null, missing, or invalid (no fallback to startTimestamp)
    - Use `restate.TerminalError` for permanent failures, let Restate retry transient failures
    - Capture errors to Sentry with context tags (workflow run ID, event URL, step name)
    - On translation failure for a language, log error and continue with remaining languages
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 1.4, 18.2, 18.4, 20.1, 21.5, 21.6, 23.2, 24.2, 24.3, 24.4, 24.5_

  - [x]* 6.2 Write property tests for workflow event processing
    - **Property 19: Czech extraction output maps to "cs" translation record**
    - **Property 21: Events collection does not contain title or description fields**
    - **Property 22: New events default to published status**
    - **Property 23: Translation status reflects actual translation completeness**
    - **Property 18: Translation failure isolation**
    - **Validates: Requirements 21.5, 22.5, 23.1, 23.2, 24.1, 24.2, 24.3, 24.4, 21.6**

  - [x] 6.3 Implement `src/services/batch.ts` — batch processing service
    - Retrieve all groups from Directus ordered by `updated_at` ascending
    - For each group: fetch event list from scraper, check each event against Directus, trigger single event workflow for new events
    - On single event failure: log error via `createError` in Directus, capture to Sentry, continue with remaining events
    - Update group `updated_at` after processing
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [x] 6.4 Implement `src/services/api.ts` — Restate API service with CORS
    - Implement `POST /api/event` handler — validate `url` field in body, return 400 if missing, trigger single event workflow, return processed event with 200
    - Implement `GET /api/events/process` handler — trigger batch workflow, return 200 with acknowledgment
    - Implement `GET /api/events/list` handler — retrieve published events from Directus, return with 200
    - Configure CORS with allowed origins from config (default `*`)
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 19.1, 19.2, 19.3_

  - [x]* 6.5 Write property test for API validation
    - **Property 14: Missing URL field returns 400**
    - **Property 24: List events endpoint returns only published events by default**
    - **Validates: Requirements 13.4, 23.4**

  - [x] 6.6 Implement `src/index.ts` — entry point
    - Initialize Sentry via `initSentry()`
    - Register all Restate services (apiService, eventWorkflow, batchService)
    - Start Restate endpoint on configured port
    - _Requirements: 16.3, 18.1_

- [x] 7. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Implement setup script and Docker configuration
  - [x] 8.1 Implement `scripts/setup-directus.ts` — Directus collection setup CLI script
    - Create collections: events, venues, groups, errors, languages, events_translations
    - Create all fields per schema: events (original_description, organizer, venue relation, start_time, end_time, timezone, original_url, parts JSON, info JSON, dances JSON, status with published default, translation_status), venues (name, street, number, town, country, postal_code, region, latitude, longitude), groups (url, type, updated_at), errors (url, message, datetime), languages (code PK, name), events_translations (events_id FK, languages_code FK, title, description, parts_translations JSON, info_translations JSON)
    - Set up Directus translations relation (M2Any) between events and events_translations
    - Seed languages: `{code: "cs", name: "Čeština"}`, `{code: "en", name: "English"}`, `{code: "es", name: "Español"}`
    - Skip existing collections with a log message
    - Read Directus base URL and admin token from `.env`
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8, 14.9, 14.10, 14.11, 23.5, 24.6_

  - [x] 8.2 Create Docker and deployment configuration
    - Create `Dockerfile` — multi-stage build: build TypeScript in build stage, copy Restate server binary from `restatedev/restate:latest`, install Node.js and supervisord on Debian base
    - Create `supervisord.conf` — manage `restate-server` (priority 10) and Node.js app (priority 20) processes
    - Create `docker-compose.yml` — single service `event-workflow` with ports 8080, 9070, 9080 and `env_file: .env`
    - _Requirements: 16.5, 16.6, 16.7_

- [x] 9. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The design uses TypeScript throughout, so no language selection was needed
