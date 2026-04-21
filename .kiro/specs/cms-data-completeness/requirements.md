# Requirements Document

## Introduction

The dancee_app2 Flutter application requires data for events, courses, and saved items. Currently, the dancee_cms (Directus) and dancee_workflow only handle dance events (parties, workshops, festivals, holidays) scraped from Facebook. The app also needs courses, event images, and several event fields that are not yet stored or extracted by the workflow.

This document specifies what must change in dancee_cms (Directus collections/fields) and dancee_workflow (scraping, AI parsing, storage) so that all data required by dancee_app2 is available via the CMS API. Auth/profile features are out of scope — a default user is used.

## Gap Analysis Summary

### Events — What exists vs. what the app needs

| App Field | CMS Status | Notes |
|---|---|---|
| id | ✅ Exists | Directus auto-generated |
| imageUrl | ❌ Missing | App needs a hero image per event; CMS has no image field; images should be stored in Directus Files (S3) |
| title | ✅ Exists | Via translations |
| description (paragraphs) | ✅ Exists | Via translations (needs splitting into paragraphs) |
| date/time display | ✅ Exists | start_time, end_time, timezone |
| location (name + address) | ✅ Exists | Via venue relation |
| price / isFree / priceRange | ⚠️ Partial | Price exists in `info` JSON as type=price items; stays in info structure but needs well-defined schema |
| isFavorited | ❌ Missing | No favorites collection in CMS |
| tags (dance styles) | ⚠️ Needs limit | `dances` JSON array exists but has no cap or relevance ordering; should be max 6, ordered by relevance |
| organizer | ✅ Exists | `organizer` field |
| dresscode | ⚠️ Missing from info | Not extracted by workflow; should be added as an info item type |
| info field schema | ⚠️ Incomplete | Currently only supports "url" and "price" types; needs "dresscode" type and a well-defined, typed schema |
| program (multi-day slots) | ✅ Exists | `parts` JSON with date_time_range, lectors, djs |
| original_url (source link) | ✅ Exists | `original_url` field |
| event type | ⚠️ Missing in CMS | Classified by workflow but not stored in events collection |

### Courses — Entirely missing

The CMS has no `courses` collection. The workflow does not scrape or parse courses. The app needs:
- Course list (id, imageUrl, title, instructor, dateRange, tags/styles, price, levelLabel)
- Course detail (description, schedule details, learning items, instructor info, pricing/spots, original_url)

### Images — Missing for both events and courses

Neither events nor courses have image storage. Facebook events often have cover images that the scraper could capture. Images should be downloaded and stored in Directus Files (Supabase S3 storage) rather than linking to external URLs. When no image is available from Facebook, the workflow should generate one via AI or reuse an existing image from an expired event with matching dance style and event type.

### Favorites — Missing

No mechanism to store user favorites in the CMS. The app needs a favorites/saved items collection.

### Dance Styles — Missing as a collection

Dance styles are stored as string arrays in events. The app uses them for filtering with display metadata (color, icon, subtitle). A dedicated dance_styles collection would enable consistent filtering.

## Glossary

- **CMS**: dancee_cms — Directus headless CMS storing all structured data
- **Workflow**: dancee_workflow — TypeScript/Restate service that scrapes Facebook, parses with AI, and stores data in CMS
- **App**: dancee_app2 — Flutter frontend consuming CMS data
- **Event**: A dance event (party, workshop, festival, holiday) scraped from Facebook
- **Course**: A multi-session dance course/class with recurring schedule, instructor, and enrollment capacity
- **Venue**: A physical location where events or courses take place
- **Dance_Style**: A named dance genre (e.g. Salsa, Bachata, Kizomba) used for categorization and filtering
- **Favorite**: A user-saved reference to an event or course
- **Event_Image**: A cover/hero image associated with an event or course
- **Scraper**: External service that fetches Facebook page/event data
- **Parser**: AI-powered component in Workflow that extracts structured data from event descriptions

## Requirements

### Requirement 1: Event Image Storage in Directus Files

**User Story:** As a dancer browsing events, I want to see a cover image for each event stored reliably in the CMS, so that images are always available regardless of external URL expiration.

#### Acceptance Criteria

1. THE CMS SHALL store an `image` field on the events collection as a nullable M2O relation to the Directus `directus_files` collection
2. WHEN the Workflow processes an event with a cover image, THE Workflow SHALL download the image from the source URL, upload it to Directus Files API (stored in Supabase S3), and link the resulting file ID to the event's `image` field
3. THE CMS SHALL serve event images via the Directus assets endpoint (e.g. `/assets/{file_id}`) with support for image transformations (resize, format)
4. THE same image storage pattern SHALL apply to the courses collection — courses SHALL have an `image` field as a nullable M2O relation to `directus_files`

### Requirement 2: Event Type Storage

**User Story:** As a dancer, I want events to be categorized by type (party, workshop, festival, holiday), so that the app can filter and display events by type.

#### Acceptance Criteria

1. THE CMS SHALL store an `event_type` field on the events collection as a string with allowed values: party, workshop, festival, holiday, other
2. WHEN the Workflow classifies an event type, THE Workflow SHALL store the classified event_type value in the CMS alongside the event data
3. THE CMS SHALL make the event_type field available via the events API response

### Requirement 3: Event Info Field — Well-Defined Typed Schema

**User Story:** As a developer building the event detail screen, I want the event `info` field to have a well-defined, typed schema with known item types, so that the app can reliably parse and display additional information (prices, dresscode, URLs).

#### Acceptance Criteria

1. THE EventInfoSchema in the Workflow SHALL support the following item types: "url", "price", and "dresscode"
2. WHEN the Workflow extracts event info, THE Parser SHALL extract dresscode information from the event description and include the dresscode as an info item with type "dresscode"
3. THE event info extraction LLM prompt SHALL instruct the LLM to extract prices, registration URLs, and dresscode from the event description
4. WHEN the LLM finds dresscode information in the event description, THE Parser SHALL produce an info item with type "dresscode", a descriptive key (e.g. "Dresscode"), and the dresscode value as a string
5. IF no dresscode information is found in the event description, THEN THE Parser SHALL omit the dresscode item from the info array (no empty or null items)
6. THE EventInfoSchema SHALL validate that each info item has a non-empty type (one of "url", "price", "dresscode"), a non-empty key, and a non-empty value
7. THE info_translations array in event translations SHALL contain translated keys for all info items, preserving the same array order and length as the info array

### Requirement 4: Dance Styles Extraction — Max 6, Ordered by Relevance

**User Story:** As a dancer browsing events, I want to see the most relevant dance styles for each event (up to 6), ordered from most to least important, so that the tags are meaningful and not cluttered.

#### Acceptance Criteria

1. THE Workflow SHALL store a maximum of 6 dance style tags per event in the `dances` JSON array
2. THE dance styles in the `dances` array SHALL be ordered from most relevant/prominent to least relevant for the event
3. THE LLM extraction prompt SHALL instruct the LLM to return dance styles per part ordered by relevance (most prominent dance style first)
4. THE `computeDances` function in the Workflow SHALL preserve the relevance ordering from the parts (first-seen order from parts) and truncate the result to a maximum of 6 entries
5. IF an event has fewer than 6 dance styles, THE Workflow SHALL store all of them without padding
6. THIS requirement SHALL also apply to the `dances` field on courses — max 6 styles, ordered by relevance

### Requirement 5: Courses Collection in CMS

**User Story:** As a dancer looking for regular classes, I want to browse dance courses, so that I can find and enroll in courses that match my level and preferred dance style.

#### Acceptance Criteria

1. THE CMS SHALL provide a `courses` collection with the following fields: id (auto), title (string), description (text), instructor_name (string), instructor_bio (text, nullable), instructor_avatar_url (string, nullable), venue (M2O relation to venues), start_date (date), end_date (date, nullable), schedule_day (string, e.g. "Tuesday"), schedule_time (string, e.g. "19:00 - 20:30"), lesson_count (integer, nullable), lesson_duration_minutes (integer, nullable), max_participants (integer, nullable), current_participants (integer, default 0), price (string), price_note (string, nullable), level (string with values: beginner, intermediate, advanced, all_levels), dances (JSON array of dance style strings), image (M2O relation to directus_files, nullable), original_url (string, nullable), status (string: published, draft, archived)
2. THE CMS SHALL provide a `courses_translations` collection with fields: id (auto), courses_id (M2O to courses), languages_code (M2O to languages), title (string), description (text), learning_items (JSON array of strings)
3. THE CMS SHALL configure a translations relation between courses and courses_translations using the existing languages collection
4. THE CMS SHALL configure a M2O relation from courses to venues for the venue field

### Requirement 6: Course Data Extraction in Workflow

**User Story:** As a system operator, I want the workflow to identify and extract course data from Facebook event descriptions, so that courses are automatically populated in the CMS.

#### Acceptance Criteria

1. WHEN the Workflow classifies an event as type "course" or "lesson", THE Workflow SHALL extract course-specific fields (instructor name, schedule pattern, level, lesson count, price, max participants) from the event description using the Parser
2. WHEN a course is extracted, THE Workflow SHALL create a record in the courses collection instead of the events collection
3. WHEN a course is extracted, THE Workflow SHALL generate translations for the course title, description, and learning items in all three languages (cs, en, es)
4. WHEN a course is extracted, THE Workflow SHALL resolve the venue using the same venue resolution logic used for events
5. IF the Parser cannot extract course-specific fields (instructor, schedule, level), THEN THE Workflow SHALL use sensible defaults: instructor_name from the organizer/host, level as "all_levels", and store the raw description
6. THE Workflow SHALL process the Facebook event cover image for the course using the same image fallback chain as events (Requirement 12) and link the resulting Directus file to the course `image` field
7. THE Workflow SHALL store the original Facebook URL as the course original_url

### Requirement 7: Course LLM Extraction Prompt

**User Story:** As a developer, I want a dedicated LLM prompt for extracting course data, so that the Parser can reliably identify course-specific information from event descriptions.

#### Acceptance Criteria

1. THE Parser SHALL use a dedicated course extraction prompt that instructs the LLM to extract: title, description, instructor_name, level (beginner/intermediate/advanced/all_levels), schedule_day, schedule_time, lesson_count, lesson_duration_minutes, max_participants, price, learning_items (list of skills taught)
2. THE Parser SHALL validate the LLM response against a Zod schema for course extraction
3. IF the LLM returns invalid JSON after 3 retry attempts, THEN THE Parser SHALL throw a TerminalError with a descriptive message
4. THE course extraction prompt SHALL be written in English and instruct the LLM to output translatable text in Czech (matching the event extraction pattern)

### Requirement 8: Dance Styles Collection

**User Story:** As a dancer filtering events and courses by dance style, I want a consistent set of dance styles, so that filtering works reliably across the app.

#### Acceptance Criteria

1. THE CMS SHALL provide a `dance_styles` collection with fields: code (string, primary key, e.g. "salsa"), name (string, e.g. "Salsa"), parent_code (string, nullable, self-referencing M2O to dance_styles), sort_order (integer)
2. THE CMS SHALL provide a `dance_styles_translations` collection with fields: id (auto), dance_styles_code (M2O to dance_styles), languages_code (M2O to languages), name (string)
3. THE CMS SHALL seed the dance_styles collection with a hierarchical structure of parent styles and sub-styles. Parent styles (parent_code = null): salsa, bachata, kizomba, zouk, tango, swing, reggaeton, afro, forro, ballroom (standard), latin, dancehall, hip-hop, contemporary, ecstatic-dance. Sub-styles examples: salsa-on1, salsa-on2, salsa-cubana (parent: salsa), bachata-sensual, bachata-dominicana (parent: bachata), urban-kiz, semba (parent: kizomba), lambada (parent: zouk), lindy-hop, west-coast-swing, boogie-woogie, charleston (parent: swing), waltz, viennese-waltz, quickstep, slowfox (parent: ballroom), cha-cha, rumba, samba, paso-doble, jive (parent: latin)
4. THE CMS SHALL configure translations relations between dance_styles and dance_styles_translations using the existing languages collection
5. WHEN the app filters events or courses by a parent dance style (e.g. "bachata"), THE filtering logic SHALL include all events/courses tagged with the parent code OR any of its child codes (e.g. "bachata", "bachata-sensual", "bachata-dominicana")
6. THE LLM extraction prompt SHALL dynamically include dance style codes fetched from the dance_styles collection (via `getDanceStyleCodes()`) so that extracted tags match the hierarchical structure. The codes SHALL be cached per batch run to avoid repeated API calls.
7. WHEN the Workflow stores dance style tags on an event or course, THE Workflow SHALL validate each tag against the dance_styles collection codes and discard any unrecognized tags

### Requirement 9: Favorites Collection

**User Story:** As a dancer, I want to save events and courses as favorites, so that I can quickly find them later in the saved items screen.

#### Acceptance Criteria

1. THE CMS SHALL provide a `favorites` collection with fields: id (auto), user_id (string, indexed), item_type (string with values: "event" or "course"), item_id (integer), created_at (datetime, auto-set)
2. THE CMS SHALL enforce a unique constraint on the combination of user_id, item_type, and item_id to prevent duplicate favorites
3. WHEN a favorite is created with item_type "event", THE CMS SHALL validate that item_id references an existing event
4. WHEN a favorite is created with item_type "course", THE CMS SHALL validate that item_id references an existing course

### Requirement 10: Directus Setup Script Update

**User Story:** As a developer setting up the project, I want the setup-directus script to create all new collections and fields, so that the CMS schema is reproducible.

#### Acceptance Criteria

1. WHEN the setup-directus script runs, THE Script SHALL create the courses collection with all fields defined in Requirement 5
2. WHEN the setup-directus script runs, THE Script SHALL create the courses_translations collection and configure the translations relation
3. WHEN the setup-directus script runs, THE Script SHALL create the dance_styles and dance_styles_translations collections and seed the initial dance styles
4. WHEN the setup-directus script runs, THE Script SHALL create the favorites collection with the unique constraint
5. WHEN the setup-directus script runs, THE Script SHALL add the image (M2O to directus_files), image_source (string: "facebook" or "ai_generated"), and event_type fields to the existing events collection
6. THE Script SHALL be idempotent — running the script multiple times SHALL produce the same result without errors or duplicate data

### Requirement 11: Workflow Event Type Routing

**User Story:** As a system operator, I want the workflow to route scraped Facebook events to the correct CMS collection based on their type, so that events and courses are stored separately.

#### Acceptance Criteria

1. WHEN the Workflow classifies an event as "party", "workshop", "festival", or "holiday", THE Workflow SHALL store the data in the events collection (existing behavior)
2. WHEN the Workflow classifies an event as "course" or "lesson", THE Workflow SHALL store the data in the courses collection using the course extraction flow
3. WHEN the Workflow classifies an event as "other", THE Workflow SHALL create a skipped_events record with reason "Unsupported event type: other" (existing behavior)
4. THE Workflow SHALL update the SUPPORTED_EVENT_TYPES constant to include "course" and "lesson" so these types are no longer skipped

### Requirement 12: Event Image Extraction with Fallback

**User Story:** As a developer, I want every event and course to have a cover image, so that the app always has visual content to display.

#### Acceptance Criteria

1. WHEN the Scraper returns Facebook event data, THE Workflow SHALL extract the cover image URL from the scraped payload if present
2. THE FacebookEventSchema in the Workflow SHALL accept an optional `imageUrl` field (string, nullable) from the scraper response
3. WHEN a cover image URL is available, THE Workflow SHALL download the image and upload it to Directus Files API, then link the file ID to the event/course `image` field
4. IF the cover image URL is missing OR the download fails, THE Workflow SHALL attempt to reuse an AI-generated image from an existing expired event (end_time in the past) that has the same primary dance style and event_type — selecting the most recently expired match. Only AI-generated images are eligible for reuse; images originally downloaded from Facebook SHALL NOT be reused.
5. IF no reusable AI-generated image is found from expired events, THE Workflow SHALL generate a new image using an AI image generation service via OpenRouter (e.g. FLUX or Gemini image model), upload it to Directus Files, and link it to the event/course
6. THE AI image generation prompt SHALL include the event title, primary dance style, and event type to produce a relevant cover image
7. IF AI image generation also fails, THE Workflow SHALL store null for the image field and log a warning — the event/course SHALL still be saved without an image

