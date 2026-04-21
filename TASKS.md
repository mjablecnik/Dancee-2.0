# Tasks: CMS Data Completeness

Derived from [CODE_REVIEW.md](CODE_REVIEW.md).

- [x] 1. [CRITICAL] Pass `danceStyleCodes` to `getCourseExtractionPrompt` in `extractCourseData` and update `runCourseWorkflow` call site
- [x] 2. [CRITICAL] Pass `danceStyleCodes` to `extractEventParts` and add `validateDanceCodes` after `computeDances` in `reprocessEvent`
- [x] 3. [HIGH] Add `IMAGE_GENERATION_MODEL=black-forest-labs/flux-schnell` to `.env.example`
- [x] 4. [HIGH] Create `src/__tests__/services/image-processor.test.ts` with tests for the full fallback chain
- [x] 5. [HIGH] Add unit tests for `translateCourseContent` in `event-translator.test.ts`
- [x] 6. [HIGH] Update `workflow.openapi.yaml` with new event fields (image, image_source, event_type, dresscode) and course/lesson routing
- [x] 7. [HIGH] Add duplicate check in `createFavorite` before inserting to enforce unique (user_id, item_type, item_id)
- [x] 8. [HIGH] Add item_id existence validation in `createFavorite` (verify referenced event/course exists)
- [x] 9. [MEDIUM] Add property-based test (fast-check) for Property 3: info_translations length matches info array length
- [x] 10. [MEDIUM] Fix mislabeled Property 8 test and add actual Property 8 test for parent dance style filtering
- [x] 11. [MEDIUM] Add API endpoints for listing courses and managing favorites, or document that these use Directus directly
- [ ] 12. [LOW] Add "image" as a valid reprocess step in `reprocessEvent`
- [ ] 13. [LOW] Document that `instructor_bio` and `instructor_avatar_url` are reserved for future use
- [ ] 14. [LOW] Verify dance style seed data count matches design document exactly
