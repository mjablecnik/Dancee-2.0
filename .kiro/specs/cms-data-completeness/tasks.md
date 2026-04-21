# Implementation Plan: CMS Data Completeness

## Overview

Extend the dancee_cms schema and dancee_workflow pipeline to support courses, event images, dance styles, favorites, and missing event fields. Implementation proceeds bottom-up: schemas and setup script first, then Directus client functions, then service logic (image processor, prompts, parser, workflow routing), and finally wiring everything together.

## Tasks

- [x] 1. Update Zod schemas and constants in `src/core/schemas.ts`
  - [x] 1.1 Add `"dresscode"` to `EventInfoSchema` type enum, add `imageUrl` to `FacebookEventObjectSchema`, add `image`, `image_source`, and `event_type` fields to `DirectusEventSchema`, add `"course"` and `"lesson"` to `SUPPORTED_EVENT_TYPES`
    - Update `EventInfoSchema.type` to `z.enum(["url", "price", "dresscode"])`
    - Add `imageUrl: z.string().nullable().optional()` to `FacebookEventObjectSchema`
    - Add `image: z.union([z.number(), z.string()]).nullable().optional()` and `image_source: z.string().nullable().optional()` and `event_type: z.string().nullable().optional()` to `DirectusEventSchema`
    - Update `SUPPORTED_EVENT_TYPES` to include `"course"` and `"lesson"`
    - _Requirements: 2.1, 2.2, 3.1, 3.6, 4.1, 11.4, 12.2_

  - [x] 1.2 Update `computeDances` to preserve first-seen order and cap at 6
    - Rewrite to iterate parts then dances within each part, deduplicate preserving first-seen order, and slice to max 6
    - _Requirements: 4.1, 4.2, 4.4, 4.5_

  - [x] 1.3 Add new schemas: `CourseExtractionSchema`, `DirectusCourseSchema`, `DirectusCourseTranslationSchema`, `DirectusDanceStyleSchema`, `DirectusFavoriteSchema`
    - Define all schemas as specified in the design document Data Models section
    - _Requirements: 5.1, 5.2, 7.2, 8.1, 9.1_

  - [x]* 1.4 Write property test: `computeDances` preserves first-seen order and caps at 6
    - **Property 4: computeDances preserves first-seen order and caps at 6**
    - **Validates: Requirements 4.1, 4.2, 4.4, 4.5**

  - [x]* 1.5 Write property test: `EventInfoSchema` validates type, key, and value constraints
    - **Property 2: EventInfoSchema validates type, key, and value constraints**
    - **Validates: Requirements 3.1, 3.6**

  - [x]* 1.6 Write property test: `CourseExtractionSchema` validates course data structure
    - **Property 6: CourseExtractionSchema validates course data structure**
    - **Validates: Requirements 7.2**

  - [x]* 1.7 Write property test: `FacebookEventSchema` accepts optional imageUrl
    - **Property 9: FacebookEventSchema accepts optional imageUrl**
    - **Validates: Requirements 12.2**

  - [x]* 1.8 Write property test: `parseEventType` maps all valid types and defaults invalid to "other"
    - **Property 1: parseEventType maps all valid types and defaults invalid to "other"**
    - **Validates: Requirements 2.2**

- [x] 2. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. Update setup script `scripts/setup-directus.ts` with new collections and fields
  - [x] 3.1 Add `image` (M2O to `directus_files`), `image_source`, and `event_type` fields to existing events collection setup
    - Add `createFieldIfNotExists` calls for `image` (integer, nullable), `image_source` (string, nullable, max_length 50), and `event_type` (string, nullable, max_length 50 with dropdown choices)
    - Add M2O relation from `events.image` to `directus_files`
    - _Requirements: 1.1, 2.1, 10.5_

  - [x] 3.2 Create `dance_styles` and `dance_styles_translations` collections with seed data
    - Create `dance_styles` collection with `code` as custom string PK, `name`, `parent_code` (self-referencing M2O), `sort_order`
    - Create `dance_styles_translations` collection with `dance_styles_code`, `languages_code`, `name`
    - Configure translations relation between `dance_styles` and `dance_styles_translations`
    - Seed all 36 dance styles from the design document (15 parents + 21 sub-styles)
    - Must be idempotent — skip existing records
    - _Requirements: 8.1, 8.2, 8.3, 10.3_

  - [x] 3.3 Create `courses` and `courses_translations` collections
    - Create `courses` collection with all fields from Requirement 5.1 (including `image` M2O to `directus_files`, `image_source`, `original_description`, `translation_status`)
    - Create `courses_translations` collection with `courses_id`, `languages_code`, `title`, `description`, `learning_items` (JSON)
    - Configure translations relation between `courses` and `courses_translations`
    - Configure M2O relation from `courses.venue` to `venues`
    - Configure M2O relation from `courses.image` to `directus_files`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 10.1, 10.2_

  - [x] 3.4 Create `favorites` collection with unique constraint
    - Create `favorites` collection with `user_id` (string, indexed), `item_type` (string), `item_id` (integer), `created_at` (datetime)
    - Note: Directus doesn't support composite unique constraints via API — document this limitation and handle uniqueness at the application level or via a Directus flow
    - _Requirements: 9.1, 9.2, 10.4_

  - [x] 3.5 Update `main()` to call all new setup functions in correct order
    - Call new functions after existing setup: `setupDanceStylesCollection`, `setupDanceStylesTranslationsCollection`, `setupDanceStylesTranslationsRelation`, `seedDanceStyles`, `setupCoursesCollection`, `setupCoursesTranslationsCollection`, `setupCoursesTranslationsRelation`, `setupCoursesVenueRelation`, `setupFavoritesCollection`, and add new event fields
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_

- [x] 4. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Add new Directus client functions in `src/clients/directus-client.ts`
  - [x] 5.1 Add `uploadFile(buffer, filename, mimeType)` function
    - Upload binary data to Directus Files API (`/files`) using multipart/form-data
    - Return the file ID from the response
    - Use existing `authHeaders` pattern but with `multipart/form-data` content type
    - _Requirements: 1.2, 12.3_

  - [x] 5.2 Add course CRUD functions: `createCourse`, `findCourseByOriginalUrl`
    - `createCourse(course)` — POST to `/items/courses`, validate with `DirectusCourseSchema`
    - `findCourseByOriginalUrl(url)` — GET with filter, for duplicate detection
    - _Requirements: 6.2, 6.7_

  - [x] 5.3 Add `getDanceStyleCodes()` function with per-batch caching
    - Fetch all dance_style codes from `/items/dance_styles?fields=code`
    - Cache result in module-level variable; add `clearDanceStyleCodesCache()` for invalidation at batch start
    - Return as `string[]` for both prompt injection and validation
    - _Requirements: 8.6, 8.7_

  - [x] 5.4 Add `findExpiredEventWithImage(primaryDance, eventType)` function
    - Query events where `end_time < now`, `image IS NOT NULL`, `image_source = "ai_generated"`, matching `dances` contains `primaryDance` and `event_type` matches
    - Sort by `end_time` descending, limit 1
    - Return the `image` file ID or null
    - _Requirements: 12.4_

  - [x] 5.5 Add favorites functions: `createFavorite`, `deleteFavorite`
    - `createFavorite(favorite)` — POST to `/items/favorites`
    - `deleteFavorite(userId, itemType, itemId)` — find by filter then DELETE
    - _Requirements: 9.1, 9.2_

- [x] 6. Update LLM prompts in `src/core/prompts.ts`
  - [x] 6.1 Update `getEventInfoExtractionPrompt` to include dresscode extraction
    - Add `"dresscode"` to the type enum in the prompt JSON structure
    - Add instruction to extract dresscode information from event descriptions
    - Add example: `{ "type": "dresscode", "key": "Dresscode", "value": "Elegant / semi-formal" }`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [x] 6.2 Update `getEventPartsExtractionPrompt` to accept dynamic dance style codes and order by relevance
    - Add `danceStyleCodes: string[]` parameter to the prompt function
    - Inject the codes list dynamically into the prompt (fetched from CMS, cached per batch)
    - Add instruction: "Order dances by relevance (most prominent first)"
    - Add instruction: "Use only dance style codes from this list: {codes}"
    - _Requirements: 4.3, 8.6_

  - [x] 6.3 Add `getCourseExtractionPrompt(outputLanguage, eventStartTime, eventEndTime, danceStyleCodes)` for course data extraction
    - Create dedicated prompt instructing LLM to extract: title, description, instructor_name, level, schedule_day, schedule_time, lesson_count, lesson_duration_minutes, max_participants, price, price_note, learning_items, dances
    - Prompt must be in English, instruct LLM to output translatable text in Czech
    - Accept `danceStyleCodes: string[]` parameter and inject codes dynamically
    - _Requirements: 7.1, 7.4_

  - [x] 6.4 Add `getImageGenerationPrompt(title, primaryDance, eventType)` for AI image generation
    - Create prompt that produces a relevant dance event cover image
    - Include event title, primary dance style, and event type for context
    - _Requirements: 12.6_

  - [x]* 6.5 Write unit tests for prompt content
    - Verify `getEventInfoExtractionPrompt()` mentions "dresscode"
    - Verify `getEventPartsExtractionPrompt()` mentions relevance ordering and dance style codes
    - Verify `getCourseExtractionPrompt()` is in English and mentions Czech output
    - Verify `getImageGenerationPrompt()` includes title, dance, and type parameters
    - _Requirements: 3.3, 4.3, 7.4, 12.6_

- [x] 7. Add course extraction to `src/services/event-parser.ts`
  - [x] 7.1 Add `extractCourseData(description, eventStartTime, eventEndTime)` function
    - Call LLM with `getCourseExtractionPrompt`, validate response against `CourseExtractionSchema`
    - Use existing `retryOnJsonError` pattern (3 retries, TerminalError on exhaustion)
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 7.2 Add `validateDanceCodes(dances, validCodes)` utility function
    - Filter dance style tags against valid codes set, preserve order, discard unrecognized
    - Can be placed in `schemas.ts` or `event-parser.ts`
    - _Requirements: 8.7_

  - [x]* 7.3 Write property test: dance style tag validation discards unrecognized codes
    - **Property 7: Dance style tag validation discards unrecognized codes**
    - **Validates: Requirements 8.7**

- [x] 8. Create image processor service `src/services/image-processor.ts`
  - [x] 8.1 Implement `processEventImage(imageUrl, primaryDance, eventType, title)` with fallback chain
    - Step 1: If `imageUrl` provided, download and upload to Directus → return `{ fileId, source: "facebook" }`
    - Step 2: If download fails or no URL, call `findExpiredEventWithImage` → return `{ fileId, source: "ai_generated" }` (reuse)
    - Step 3: If no reusable image, generate via AI (OpenRouter image model), upload → return `{ fileId, source: "ai_generated" }`
    - Step 4: If all fail, return `{ fileId: null, source: null }` and log warning
    - _Requirements: 12.1, 12.3, 12.4, 12.5, 12.7_

  - [x] 8.2 Implement `downloadImage(url)` helper
    - Download image from URL, return `{ buffer: Buffer, mimeType: string, filename: string }`
    - Handle HTTP errors and timeouts gracefully
    - _Requirements: 12.1, 12.3_

  - [x] 8.3 Implement `generateAiImage(title, primaryDance, eventType)` helper
    - Call OpenRouter API with image generation model (configured in `config.ts` as `imageGenerationModel`)
    - Use `getImageGenerationPrompt` for the prompt
    - Parse base64 image from response, return buffer
    - _Requirements: 12.5, 12.6_

  - [x] 8.4 Add `imageGenerationModel` to `src/core/config.ts`
    - Add config option with sensible default (e.g. a FLUX model on OpenRouter)
    - Uses existing `OPENROUTER_API_KEY` — no new env vars
    - _Requirements: 12.5_

- [x] 9. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Update workflow routing and add course workflow in `src/services/workflow.ts`
  - [x] 10.1 Update `runWorkflow` to route `course`/`lesson` types to new `runCourseWorkflow`
    - After classification, check if `eventType` is `"course"` or `"lesson"` → call `runCourseWorkflow`
    - Existing event types (`party`, `workshop`, `festival`, `holiday`) continue to existing flow
    - `"other"` continues to create skipped_events record
    - _Requirements: 11.1, 11.2, 11.3, 11.4_

  - [x] 10.2 Add image processing and dance style validation to existing event workflow branch
    - At batch start, call `clearDanceStyleCodesCache()` to ensure fresh codes
    - Fetch dance style codes via `getDanceStyleCodes()` (cached for the batch)
    - Pass codes to `extractEventParts` prompt and to `validateDanceCodes`
    - After `computeDances`, call `processEventImage(facebookEvent.imageUrl, dances[0], eventType, extracted.title)`
    - Add `image`, `image_source`, and `event_type` to the `newEvent` object
    - _Requirements: 1.2, 2.2, 8.6, 8.7, 12.1, 12.3_

  - [x] 10.3 Implement `runCourseWorkflow` function
    - Extract course data via `extractCourseData`
    - Translate course content (cs → en, es) using a course translation prompt
    - Resolve venue using existing `resolveVenue`
    - Compute and validate dances (max 6, ordered, validated against dance_styles codes)
    - Process image via `processEventImage`
    - Build `DirectusCourse` object and store via `createCourse`
    - Handle duplicate check via `findCourseByOriginalUrl`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

  - [x]* 10.4 Write property test: event type routing correctness
    - **Property 5: Event type routing correctness**
    - **Validates: Requirements 6.2, 11.1, 11.2, 11.3**

  - [x]* 10.5 Write unit tests for workflow integration
    - Test that `SUPPORTED_EVENT_TYPES` includes "course" and "lesson"
    - Test `computeDances` edge cases: empty parts → empty result, single part with 10 dances → first 6, duplicates across parts → deduplicated
    - _Requirements: 4.1, 11.4_

- [x] 11. Add course translation support
  - [x] 11.1 Add `getTranslationPromptForCourse(targetLanguage)` to `src/core/prompts.ts`
    - Similar to existing `getTranslationPrompt` but for course structure (title, description, learning_items)
    - _Requirements: 6.3_

  - [x] 11.2 Add `translateCourseContent` function to `src/services/event-translator.ts` (or new file)
    - Translate course title, description, and learning_items to target language
    - Use `retryOnJsonError` pattern
    - _Requirements: 6.3_

- [x] 12. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- No new environment variables are needed — image generation uses existing `OPENROUTER_API_KEY`
- The setup script must remain idempotent throughout all changes
