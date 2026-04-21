# Requirements Document

## Introduction

The dancee_app2 Flutter application currently uses hardcoded mock data in its repositories (EventRepository, CourseRepository, CityRepository). This feature replaces all mock data with live data fetched from dancee_cms (Directus) via its REST API. The scope covers events, courses, and saved/favorite items. Auth, user profile, and premium features are out of scope — a default user ID is used for favorites.

The integration includes:
- Fetching events and courses from Directus with language-aware translations
- Local filtering by dance style and location for both events and courses (shared filter state)
- Featured events showing only festivals (featured courses are not displayed)
- Favorites management (add/remove) synced to CMS
- Detail pages populated from CMS data
- Language switching in settings (Czech, English, Spanish) that affects fetched data
- All filtering performed client-side on the full dataset fetched from CMS

## Glossary

- **App**: dancee_app2 — the Flutter frontend application
- **CMS**: dancee_cms — Directus headless CMS providing the REST API for all data
- **Directus_Client**: A Dart HTTP client class in the App that communicates with the CMS REST API
- **Event**: A dance event (party, workshop, festival, holiday) stored in the CMS events collection
- **Course**: A multi-session dance course stored in the CMS courses collection
- **Favorite**: A user-saved reference to an event or course, stored in the CMS favorites collection
- **Dance_Style**: A dance genre code (e.g. "salsa", "bachata") from the CMS dance_styles collection
- **Venue**: A physical location associated with events or courses, including region for location filtering
- **Filter_State**: An immutable data object holding the current filter configuration (selected dance styles, selected locations) shared between events and courses pages
- **Event_Cubit**: A Cubit managing the list of events fetched from CMS and their filtered view
- **Course_Cubit**: A Cubit managing the list of courses fetched from CMS and their filtered view
- **Filter_Cubit**: A Cubit managing the shared Filter_State for dance style and location filters
- **Favorites_Cubit**: A Cubit managing the user's favorite items (events and courses) and sync with CMS
- **Settings_Cubit**: A Cubit managing app settings including the selected language
- **Default_User_ID**: A hardcoded user identifier used for favorites operations since auth is out of scope

## Requirements

### Requirement 1: Directus HTTP Client

**User Story:** As a developer, I want a reusable Dart HTTP client for the Directus REST API, so that all CMS data fetching is centralized and consistent.

#### Acceptance Criteria

1. THE Directus_Client SHALL provide methods to fetch published events with expanded translations and venue data from the CMS REST API
2. THE Directus_Client SHALL provide methods to fetch published courses with expanded translations and venue data from the CMS REST API
3. THE Directus_Client SHALL provide methods to list, create, and delete favorites for a given user ID in the CMS
4. THE Directus_Client SHALL provide a method to fetch all dance styles (with translations) from the CMS
5. THE Directus_Client SHALL include the `deep` parameter with a language filter on translations so that only translations matching the currently selected app language are returned
6. THE Directus_Client SHALL read the CMS base URL and access token from the App configuration (config.dart pattern)
7. IF a CMS API request fails, THEN THE Directus_Client SHALL throw a descriptive exception that callers can handle gracefully

### Requirement 2: Event Data Models

**User Story:** As a developer, I want Dart data models that map to the CMS event structure, so that the app can parse and display event data from Directus.

#### Acceptance Criteria

1. THE App SHALL define an Event model class with fields: id, imageUrl (constructed from Directus assets endpoint + file ID), title, description (list of paragraphs), startTime, endTime, timezone, organizer, venue (with name, address, region), dances (list of dance style codes), eventType, info (list of typed info items: url, price, dresscode), parts (program data), originalUrl, isFavorited
2. THE App SHALL define a Venue model class with fields: id, name, street, number, town, country, postalCode, region, latitude, longitude
3. THE App SHALL parse the CMS JSON response into these model classes, extracting translated fields (title, description, parts translations, info translations) from the translations array based on the current app language
4. WHEN the CMS returns an event with an image file ID, THE App SHALL construct the full image URL using the pattern `{directusBaseUrl}/assets/{fileId}`
5. IF a translation for the current language is missing, THEN THE App SHALL fall back to the English translation, then to the first available translation

### Requirement 3: Course Data Models

**User Story:** As a developer, I want Dart data models that map to the CMS course structure, so that the app can parse and display course data from Directus.

#### Acceptance Criteria

1. THE App SHALL define a Course model class with fields: id, imageUrl, title, description, instructorName, instructorBio, instructorAvatarUrl, venue (Venue model), startDate, endDate, scheduleDay, scheduleTime, lessonCount, lessonDurationMinutes, maxParticipants, currentParticipants, price, priceNote, level, dances (list of dance style codes), learningItems (list of strings), originalUrl, isFavorited
2. THE App SHALL parse the CMS JSON response into the Course model, extracting translated fields (title, description, learning_items) from the courses_translations array based on the current app language
3. WHEN the CMS returns a course with an image file ID, THE App SHALL construct the full image URL using the pattern `{directusBaseUrl}/assets/{fileId}`
4. IF a translation for the current language is missing, THEN THE App SHALL fall back to the English translation, then to the first available translation

### Requirement 4: Fetch and Display Events from CMS

**User Story:** As a dancer, I want to see real events from the CMS when I open the events page, so that I can browse actual upcoming dance events.

#### Acceptance Criteria

1. WHEN the events page loads, THE Event_Cubit SHALL fetch all published events from the CMS via the Directus_Client with translations for the current app language
2. THE events page SHALL display events grouped into "Featured events" (festivals only) and "Upcoming events" (all event types) sections
3. THE Event_Cubit SHALL store the full list of fetched events in memory for local filtering
4. WHILE events are loading, THE events page SHALL display a loading indicator
5. IF fetching events fails, THEN THE events page SHALL display an error message with a retry option
6. THE events page SHALL display each event with: image, title, date, location name, price, dance style tags, and favorite status

### Requirement 5: Featured Events — Festivals Only

**User Story:** As a dancer, I want the featured events section to show only festivals, so that I can quickly discover major dance festivals.

#### Acceptance Criteria

1. THE events page SHALL display in the "Featured events" section only events where event_type equals "festival"
2. WHEN active filters are applied, THE "Featured events" section SHALL show only festivals that also match the active filter criteria (dance style and location)
3. WHEN no festivals match the current filters, THE "Featured events" section SHALL be hidden
4. THE "Featured events" section SHALL display events in a horizontal scrollable card format

### Requirement 6: Fetch and Display Courses from CMS

**User Story:** As a dancer, I want to see real courses from the CMS when I open the courses page, so that I can browse available dance courses.

#### Acceptance Criteria

1. WHEN the courses page loads, THE Course_Cubit SHALL fetch all published courses from the CMS via the Directus_Client with translations for the current app language
2. THE courses page SHALL NOT display a "Featured courses" section (featured courses are hidden)
3. THE courses page SHALL display all courses in a list format
4. THE Course_Cubit SHALL store the full list of fetched courses in memory for local filtering
5. WHILE courses are loading, THE courses page SHALL display a loading indicator
6. IF fetching courses fails, THEN THE courses page SHALL display an error message with a retry option
7. THE courses page SHALL display each course with: image, title, instructor name, date range, dance style tags, and price

### Requirement 7: Shared Filter State for Events and Courses

**User Story:** As a dancer, I want filters I set on the events page to also apply on the courses page and vice versa, so that I get a consistent filtered view across both pages.

#### Acceptance Criteria

1. THE Filter_Cubit SHALL maintain a shared Filter_State containing: selected dance style codes (list of strings) and selected locations (list of region strings)
2. WHEN the user changes filters on the events page, THE Filter_Cubit SHALL update the shared Filter_State and THE courses page SHALL reflect the updated filters when navigated to
3. WHEN the user changes filters on the courses page, THE Filter_Cubit SHALL update the shared Filter_State and THE events page SHALL reflect the updated filters when navigated to
4. THE Filter_Cubit SHALL be provided as a single instance (via BlocProvider) above both the events and courses pages in the widget tree
5. THE Filter_State SHALL hold filters only in memory — filters are reset when the app is restarted

### Requirement 8: Dance Style Filter

**User Story:** As a dancer, I want to filter events and courses by dance style, so that I see only items matching my preferred dances.

#### Acceptance Criteria

1. THE dance style filter page SHALL display dance styles fetched from the CMS dance_styles collection with translated names for the current app language
2. THE dance style filter page SHALL allow the user to select multiple dance styles
3. WHEN one or more dance styles are selected, THE Event_Cubit SHALL include only events that contain at least one of the selected dance style codes in the event dances list
4. WHEN one or more dance styles are selected, THE Course_Cubit SHALL include only courses that contain at least one of the selected dance style codes in the course dances list
5. WHEN a parent dance style is selected (e.g. "bachata"), THE filtering logic SHALL include items tagged with the parent code OR any of its child codes (e.g. "bachata", "bachata-sensual", "bachata-dominicana")
6. WHEN no dance styles are selected, THE filtering SHALL not restrict items by dance style

### Requirement 9: Location Filter

**User Story:** As a dancer, I want to filter events and courses by location (region), so that I see only items near my area.

#### Acceptance Criteria

1. THE location filter page SHALL display a list of regions derived from the venue region field of loaded events and courses
2. THE location filter page SHALL allow the user to select multiple regions
3. WHEN one or more regions are selected, THE Event_Cubit SHALL include only events whose venue region matches one of the selected regions
4. WHEN one or more regions are selected, THE Course_Cubit SHALL include only courses whose venue region matches one of the selected regions
5. WHEN no regions are selected, THE filtering SHALL not restrict items by location
6. THE location filter page SHALL be accessible from both the events page and the courses page

### Requirement 10: Combined Local Filtering

**User Story:** As a dancer, I want dance style and location filters to work together, so that I can narrow down events and courses using multiple criteria.

#### Acceptance Criteria

1. THE Event_Cubit SHALL apply all active filters (dance styles, locations) from the shared Filter_State using AND logic — an event is included only when the event matches all active filter criteria
2. THE Course_Cubit SHALL apply all active filters (dance styles, locations) from the shared Filter_State using AND logic — a course is included only when the course matches all active filter criteria
3. THE filtering SHALL be performed locally on the device using the already-fetched lists without making additional API requests
4. WHEN filters change, THE Event_Cubit and Course_Cubit SHALL re-apply filters and emit updated state immediately

### Requirement 11: Favorites — Fetch and Display Saved Items

**User Story:** As a dancer, I want to see my saved events and courses on the saved items page, so that I can quickly access items I marked as favorites.

#### Acceptance Criteria

1. WHEN the saved items page loads, THE Favorites_Cubit SHALL fetch the user's favorites from the CMS using the Default_User_ID
2. THE Favorites_Cubit SHALL resolve each favorite's item_id against the loaded events and courses lists to display full item details
3. THE saved items page SHALL display saved events and saved courses in a combined list, sorted by the favorite creation date (newest first)
4. THE saved items page SHALL NOT apply dance style or location filters — all saved items are shown regardless of active filters
5. WHILE favorites are loading, THE saved items page SHALL display a loading indicator
6. WHEN the user has no saved items, THE saved items page SHALL display an empty state message

### Requirement 12: Favorites — Add and Remove

**User Story:** As a dancer, I want to save events and courses as favorites and remove them, so that I can manage my personal collection of interesting items.

#### Acceptance Criteria

1. WHEN the user taps the favorite button on an event (list or detail), THE Favorites_Cubit SHALL create a favorite record in the CMS via the Directus_Client with item_type "event" and the event's ID
2. WHEN the user taps the favorite button on a course (list or detail), THE Favorites_Cubit SHALL create a favorite record in the CMS via the Directus_Client with item_type "course" and the course's ID
3. WHEN the user taps the favorite button on an already-favorited item, THE Favorites_Cubit SHALL delete the favorite record from the CMS via the Directus_Client
4. THE Favorites_Cubit SHALL update the local favorite state immediately (optimistic update) before the CMS request completes
5. IF the CMS favorite create or delete request fails, THEN THE Favorites_Cubit SHALL revert the optimistic update and display an error message
6. THE favorite status (isFavorited) SHALL be reflected consistently across the events list, courses list, event detail, course detail, and saved items pages

### Requirement 13: Event Detail from CMS

**User Story:** As a dancer, I want to see full event details fetched from the CMS, so that I can read the description, program, and additional info of an event.

#### Acceptance Criteria

1. WHEN the user navigates to an event detail page, THE App SHALL display the event data from the already-fetched event list (no additional API call needed)
2. THE event detail page SHALL display: hero image, title, dance style chips, key info (date/time, location with address, organizer, price), description paragraphs, additional info (admission/price range, dresscode, registration URL), program (multi-day slots with times, titles, descriptions, lectors/DJs), and original source link
3. THE event detail page SHALL display a favorite toggle button that reflects the current favorite status and allows adding/removing the event from favorites
4. THE event detail page SHALL display translated content based on the current app language

### Requirement 14: Course Detail from CMS

**User Story:** As a dancer, I want to see full course details fetched from the CMS, so that I can read the description, schedule, instructor info, and pricing.

#### Acceptance Criteria

1. WHEN the user navigates to a course detail page, THE App SHALL display the course data from the already-fetched course list (no additional API call needed)
2. THE course detail page SHALL display: hero image, title, level label, dance style chips, key info (date range, location, instructor, price), description paragraphs, schedule details (lesson count, duration, max participants, level), learning items list, instructor section (name, bio, avatar), pricing section (price, price note, available spots), and original source link
3. THE course detail page SHALL display a favorite toggle button that reflects the current favorite status and allows adding/removing the course from favorites
4. THE course detail page SHALL display translated content based on the current app language

### Requirement 15: Language-Aware Data Fetching

**User Story:** As a dancer, I want the app to fetch data in my selected language, so that event and course content is displayed in Czech, English, or Spanish based on my preference.

#### Acceptance Criteria

1. WHEN the app fetches events from the CMS, THE Directus_Client SHALL include a deep filter on translations to request only the translation matching the current app locale (e.g. `deep[translations][_filter][languages_code][_eq]=cs`)
2. WHEN the app fetches courses from the CMS, THE Directus_Client SHALL include the same deep language filter on translations
3. WHEN the user changes the language in settings, THE Event_Cubit SHALL re-fetch all events from the CMS with the new language filter and update the displayed list
4. WHEN the user changes the language in settings, THE Course_Cubit SHALL re-fetch all courses from the CMS with the new language filter and update the displayed list
5. WHEN the user changes the language in settings, THE Filter_Cubit SHALL re-fetch dance styles from the CMS with translated names for the new language
6. THE App SHALL map the slang locale codes (en, cs, es) to the Directus language codes used in the CMS languages collection

### Requirement 16: Settings — Language Change and Persistence

**User Story:** As a dancer, I want to change the app language in settings and have the app remember my choice, so that I can use the app in Czech, English, or Spanish and the selected language is restored after restarting the app.

#### Acceptance Criteria

1. THE settings page SHALL display a language selection option with three choices: Czech, English, and Spanish
2. WHEN the user selects a language, THE Settings_Cubit SHALL update the app locale via slang LocaleSettings
3. WHEN the user selects a language, THE Settings_Cubit SHALL persist the selected language code to SharedPreferences
4. WHEN the app starts, THE Settings_Cubit SHALL read the persisted language code from SharedPreferences and set the app locale to the stored value before any data is fetched
5. IF no persisted language is found in SharedPreferences on app start, THEN THE Settings_Cubit SHALL use the device default locale or fall back to English
6. WHEN the language changes, THE App SHALL trigger a re-fetch of all data (events, courses, dance styles) from the CMS with translations for the new language so that the user sees updated content without restarting the app
7. THE settings page SHALL display the currently selected language
8. THE settings page SHALL only contain the language change option (auth, profile, premium, and other settings are out of scope)

### Requirement 17: Internationalization of New UI Elements

**User Story:** As a user, I want all new UI elements to be fully translated, so that I can use the app in my preferred language.

#### Acceptance Criteria

1. ALL user-facing strings in new or modified UI elements SHALL be defined in the slang i18n translation files (en, cs, es) and accessed via the `t` global variable
2. NO user-facing string SHALL be hardcoded in Dart source code
3. WHEN new translation keys are added, THEY SHALL be added to all three language files: `strings.i18n.json` (en), `strings_cs.i18n.json` (cs), and a new `strings_es.i18n.json` (es)
4. Parameterized strings (e.g. "Show {count} events") SHALL use slang named parameter syntax

### Requirement 18: App Configuration for CMS Connection

**User Story:** As a developer, I want CMS connection settings in the app configuration, so that the Directus base URL and access token are configurable and not hardcoded.

#### Acceptance Criteria

1. THE App SHALL store the Directus base URL and access token in `lib/config.dart` (gitignored, sensitive)
2. THE App SHALL provide placeholder values in `lib/config.example.dart` (committed) for the Directus base URL and access token
3. THE `lib/core/config.dart` SHALL re-export the Directus configuration values for use throughout the app
4. THE Directus_Client SHALL read the base URL and access token from the app configuration
