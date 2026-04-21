# Tasks — CMS Data Completeness

Derived from [CODE_REVIEW.md](./CODE_REVIEW.md).

- [x] 1. [CRITICAL] Add courses, favorites, and dance_styles endpoints to all three OpenAPI specs (`workflow.openapi.yaml`, `cms.openapi.yaml`, `combined.openapi.yaml`) with corresponding schemas
- [x] 2. [CRITICAL] Update `EventInfo.type` enum to `[url, price, dresscode]` in `cms.openapi.yaml` and `combined.openapi.yaml`
- [x] 3. [CRITICAL] Add `image`, `image_source`, and `event_type` fields to `DirectusEvent` schema in `cms.openapi.yaml` and `combined.openapi.yaml`
- [x] 4. [HIGH] Delete or fully update the deprecated local `backend/dancee_workflow/workflow.openapi.yaml` to match the canonical spec
- [x] 5. [HIGH] Update `combined.openapi.yaml` to include all missing workflow endpoints (`/api/event/reprocess`, `/api/events/group`, courses, favorites) and update `processEvent` description to mention course/lesson routing
- [ ] 6. [MEDIUM] Add `findCourseByOriginalUrl` duplicate check in `batch.ts` (`processAll` and `processSingle`) before scheduling workflows
- [ ] 7. [MEDIUM] Document `_contains` JSON substring matching limitation in `findExpiredEventWithImage` or store primary dance as a separate indexed field
- [ ] 8. [MEDIUM] Add property-based test (fast-check) for translation info_translations length preservation (Design Property 3)
- [ ] 9. [MEDIUM] Add property-based test (fast-check) for parent dance style filtering includes child codes (Design Property 8)
- [ ] 10. [LOW] Remove "Course" and "Lesson" from `event_type` dropdown choices in `setupEventsCollection` (these types route to courses collection)
- [ ] 11. [LOW] Fix route path mismatch: change `/api/events/process-group` in `index.ts` to `/api/events/group` to match the OpenAPI spec
- [ ] 12. [LOW] Seed `dance_styles_translations` with translated names for all 35 styles in cs, en, es languages
- [ ] 13. [LOW] Add `{ value: "incomplete", text: "Incomplete" }` to the events status field choices in `setupEventsCollection`
