# Scripts

All scripts are located in `scripts/` and should be run from the project root (`backend/dancee_workflow/`).

## setup-directus.ts

Creates all Directus collections, fields, relations, and seeds initial data (languages).

```bash
bun run scripts/setup-directus.ts
```

Run this once when setting up a fresh Directus instance. Safe to re-run — skips existing collections/fields.

Creates:
- `events` collection (title, original_description, organizer, venue, start_time, end_time, timezone, original_url, parts, info, dances, status, translation_status)
- `events_translations` collection (events_id, languages_code, title, description, parts_translations, info_translations)
- `venues` collection (name, street, number, town, country, postal_code, region, latitude, longitude)
- `groups` collection (url, type, updated_at)
- `errors` collection (url, message, datetime)
- `languages` collection + seeds cs, en, es
- Relations between events ↔ events_translations ↔ languages, events → venues

## setup-directus-flows.ts

Creates Directus Flows (manual trigger buttons) for reprocessing events from the admin UI.

```bash
bun run scripts/setup-directus-flows.ts          # create flows
bun run scripts/setup-directus-flows.ts --clean   # delete existing + recreate
```

Creates these flows:

| Flow | Collection | Steps | Description |
|---|---|---|---|
| Reprocess All | events | parts, info, translations, dances | Full re-extraction and re-translation |
| Retranslate | events | translations | Re-translate to CS, EN, ES |
| Re-extract Parts | events | parts, dances | Re-extract parts + recompute dances |
| Re-extract Info | events | info | Re-extract prices and URLs |
| Retranslate This Language | events_translations | translations (single lang) | Re-translate only the selected language |

Flows appear as action buttons in the Directus item detail toolbar.

## clear-directus.sh

Deletes all items from Directus collections. Useful for resetting the database during development.

```bash
./scripts/clear-directus.sh                  # clear events, venues, errors
./scripts/clear-directus.sh --include-groups  # also clear groups
./scripts/clear-directus.sh --all             # clear everything including languages
./scripts/clear-directus.sh --help            # show usage
```

Groups and languages are protected by default since they are manually curated / reference data.

## register-deployment.sh

Registers the Restate deployment with the Restate server. Typically called automatically on startup, but can be run manually if needed.

```bash
./scripts/register-deployment.sh
```

## Environment

All scripts read `DIRECTUS_BASE_URL` and `DIRECTUS_ACCESS_TOKEN` from `.env` automatically. The flows script also accepts `WORKFLOW_BASE_URL` (defaults to `https://dancee-workflow.fly.dev`).
