# Tasks: CMS Data Completeness

Derived from [CODE_REVIEW.md](CODE_REVIEW.md).

- [x] 1. [MEDIUM] Add `IMAGE_GENERATION_MODEL` to `fly.toml [env]` section and update design doc to reflect the new env var
- [x] 2. [MEDIUM] Seed `dance_styles_translations` with translated names for all 36 dance styles in cs, en, and es
- [x] 3. [MEDIUM] Mitigate `_contains` substring matching in `findExpiredEventWithImage` — either add post-filtering for exact array membership or add a `primary_dance` field, or document the accepted trade-off in the design doc
- [x] 4. [LOW] Add test in `batch.test.ts` asserting `clearDanceStyleCodesCache()` is called during `processAll`
- [x] 5. [LOW] Add `"dresscode"` to `eventInfoArb` type arbitrary in `workflow.test.ts` and `event-translator.test.ts`
- [x] 6. [LOW] Fix design doc count: "35 dance styles (15 parents + 20 sub-styles)" → "36 dance styles (15 parents + 21 sub-styles)"
- [ ] 7. [LOW] Consider adding `image` as a reprocessing step in `reprocessEvent` handler (future iteration, out of current scope)
