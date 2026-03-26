# Requirements Document

## Introduction

This feature implements an event processing workflow service (`event-workflow-restate`) that automates the pipeline of scraping Facebook dance events via the `dancee_scraper` API, enriching the raw scraped data using an LLM (via OpenRouter), and storing the processed events into Directus CMS. The service replicates the data processing logic currently in `serinus_service` (Dart/SurrealDB) but uses TypeScript with Bun as the package manager, Restate for durable workflow orchestration, OpenRouter for AI/LLM integration, and Directus as the data store. The project structure follows the pattern established by the existing `AiWorkflow` project.

## Glossary

- **Workflow_Service**: The Restate-based durable workflow service that orchestrates the full event processing pipeline from scraping through LLM-based event parsing to storage in Directus
- **Scraper_Client**: The HTTP client module that sends requests to the `dancee_scraper` API to retrieve raw Facebook event data
- **Event_Parser**: The module that uses an LLM via OpenRouter to classify event types, extract event parts (workshops, parties, open lessons), generate descriptions, and extract event info (prices, registration URLs)
- **Directus_Client**: The HTTP client module that communicates with the Directus CMS REST API to create, read, and update events, venues, groups, and errors
- **Event_Processor**: The core processing module that transforms raw scraped Facebook event data into the structured event format defined by the Dancee Events OpenAPI schema
- **Venue_Resolver**: The module that resolves venue information from raw Facebook location data, including reverse geocoding via the Nominatim API (OpenStreetMap) to determine the address and administrative region
- **Group_Manager**: The module that manages Facebook page/group URLs used as sources for event discovery
- **Error_Tracker**: The module that logs processing errors for individual event URLs into Directus for later review
- **Setup_Script**: A CLI script that creates the required collections and fields in a fresh Directus instance
- **Event**: A structured dance event object containing title, description, venue, date/time range, organizer, event parts, event info, original URL, and a computed dances field (aggregated unique dance names from all event parts). Events use Directus-assigned IDs
- **Venue**: A location object containing name, street, town, country, postal code, region (administrative area level 1 from reverse geocoding, universal across countries), and coordinates. Venues use Directus-assigned IDs and are deduplicated by name, street, and town
- **EventPart**: A sub-event within an Event (e.g., workshop, party, open lesson) with its own time range, dances, lectors, and DJs
- **EventInfo**: Additional event metadata such as price or registration URL
- **EventType**: Classification of an event as party, workshop, lesson, course, festival, holiday, or other
- **API_Service**: The Restate service that exposes HTTP endpoints for triggering event processing workflows
- **Sentry**: An external error monitoring and reporting platform that captures unhandled exceptions and errors for real-time alerting and debugging
- **Nominatim_API**: The OpenStreetMap-based reverse geocoding service used for resolving coordinates to addresses and administrative regions. Free to use with no API key required, subject to a usage policy of maximum 1 request per second

## Requirements

### Requirement 1: Scrape Single Event from dancee_scraper API

**User Story:** As a developer, I want the service to fetch raw event data from the dancee_scraper API by event ID or URL, so that I can process individual Facebook events into the Dancee format.

#### Acceptance Criteria

1. WHEN invoked with a Facebook event ID or URL, THE Scraper_Client SHALL send a GET request to the `dancee_scraper` API endpoint `/api/scraper/event/{eventId}` and return the raw FacebookEvent response object
2. WHEN the `dancee_scraper` API returns an HTTP error status, THE Scraper_Client SHALL propagate a descriptive error containing the HTTP status code and error message
3. THE Scraper_Client SHALL read the dancee_scraper base URL from the `.env` configuration file
4. WHEN the raw FacebookEvent data contains an `endTimestamp` that is null, missing, or invalid, THE Event_Processor SHALL fall back to using the `startTimestamp` value as the end time

### Requirement 2: Scrape Event List from dancee_scraper API

**User Story:** As a developer, I want the service to fetch a list of event URLs from a Facebook page or group via the dancee_scraper API, so that I can discover new events to process.

#### Acceptance Criteria

1. WHEN invoked with a Facebook page or group ID/URL, THE Scraper_Client SHALL send a GET request to the `dancee_scraper` API endpoint `/api/scraper/events?pageId={pageId}` and return the list of FacebookEvent objects
2. WHEN the `dancee_scraper` API returns an HTTP error status, THE Scraper_Client SHALL propagate a descriptive error containing the HTTP status code and error message
3. WHERE the optional `eventType` parameter is provided, THE Scraper_Client SHALL include it as a query parameter to filter by "upcoming" or "past" events

### Requirement 3: AI-Based Event Type Classification

**User Story:** As a developer, I want the service to classify scraped events by type using an LLM, so that only supported event types (party, workshop, festival, holiday) are processed further.

#### Acceptance Criteria

1. WHEN a raw event description is provided, THE Event_Parser SHALL send the description to the LLM via OpenRouter with the event type classification prompt and return the determined EventType
2. THE Event_Parser SHALL classify events into one of the following types: party, workshop, lesson, course, festival, holiday, or other
3. WHEN the LLM returns an unrecognized type value, THE Event_Parser SHALL default to the "other" type
4. WHEN the determined EventType is not one of party, workshop, festival, or holiday, THE Event_Processor SHALL skip further processing of that event and log the reason

### Requirement 4: AI-Based Event Parts Extraction

**User Story:** As a developer, I want the service to extract structured event parts (workshops, parties, open lessons) from the event description using an LLM, so that the event data includes a detailed breakdown of sub-events.

#### Acceptance Criteria

1. WHEN a raw event description is provided, THE Event_Parser SHALL send the description to the LLM via OpenRouter with the event parts extraction prompt and return a structured object containing a Czech description and a list of EventPart objects
2. EACH returned EventPart SHALL contain: name, description, type (party/workshop/openLesson), dances list, date_time_range (start and end in ISO 8601 UTC), lectors list, and DJs list
3. WHEN the LLM returns invalid JSON, THE Event_Parser SHALL retry the request up to 2 additional times before propagating an error

### Requirement 5: AI-Based Event Info Extraction

**User Story:** As a developer, I want the service to extract additional event information (prices, registration URLs) from the event description using an LLM, so that users can see pricing and registration details.

#### Acceptance Criteria

1. WHEN a raw event description is provided, THE Event_Parser SHALL send the description to the LLM via OpenRouter with the event info extraction prompt and return a list of EventInfo objects
2. EACH returned EventInfo SHALL contain: type (url or price), key (label), and value (the actual URL or price string)
3. WHEN an EventInfo value is empty or null, THE Event_Parser SHALL exclude that entry from the returned list

### Requirement 6: Venue Resolution from Facebook Location Data

**User Story:** As a developer, I want the service to resolve structured venue information from raw Facebook location data, so that events have accurate and complete venue details.

#### Acceptance Criteria

1. WHEN raw Facebook location data containing coordinates is provided, THE Venue_Resolver SHALL perform reverse geocoding to determine the street, town, country, and region
2. WHEN the Facebook location data contains name, address, city, and countryCode fields, THE Venue_Resolver SHALL use those values directly and supplement with reverse geocoding for the region
3. WHEN the Facebook location data is missing address fields, THE Venue_Resolver SHALL fall back to the reverse geocoded address components
4. THE Venue_Resolver SHALL determine the administrative region (state/province) from the Nominatim reverse geocoding response `address.state` field and store it as the venue's region
5. WHEN the Nominatim reverse geocoding response does not contain a `state` field or the location cannot be resolved, THE Venue_Resolver SHALL set the region to "Other"
6. THE Venue_Resolver SHALL use the Nominatim API (OpenStreetMap) for reverse geocoding, which requires no API key and is free to use, respecting the usage policy of maximum 1 request per second
7. BEFORE creating a new venue, THE Venue_Resolver SHALL check if a venue with the same name, street, and town already exists in Directus and reuse the existing record if found
8. BEFORE calling the Nominatim API for reverse geocoding, THE Venue_Resolver SHALL first check if a venue with matching coordinates (latitude and longitude) or matching address (name, street, town) already exists in Directus, and if found, reuse the existing venue record without making an external geocoding request

### Requirement 7: Store Events in Directus CMS

**User Story:** As a developer, I want processed events to be stored in Directus CMS via its REST API, so that the data is accessible through a standard CMS interface and API.

#### Acceptance Criteria

1. WHEN a processed Event is ready for storage, THE Directus_Client SHALL send a POST request to the Directus items API to create the event record
2. WHEN a processed Event already exists in Directus (matched by original_url), THE Directus_Client SHALL skip creating a duplicate record
3. WHEN a Venue does not yet exist in Directus (matched by name, street, and town), THE Directus_Client SHALL create the venue record before creating the event
4. WHEN a Venue already exists in Directus, THE Directus_Client SHALL link the event to the existing venue record
5. THE Directus_Client SHALL read the Directus base URL and access token from the `.env` configuration file

### Requirement 8: Store Venues in Directus CMS

**User Story:** As a developer, I want venues to be stored as separate records in Directus CMS, so that multiple events can reference the same venue.

#### Acceptance Criteria

1. THE Directus_Client SHALL store each Venue with the following fields: name, street, number, town, country, postal_code, region (administrative area / state / province from reverse geocoding), latitude, and longitude
2. WHEN checking for an existing venue, THE Directus_Client SHALL query Directus by name, street, and town to determine uniqueness
3. WHEN a venue with the same name, street, and town already exists, THE Directus_Client SHALL return the existing venue's Directus ID instead of creating a duplicate
4. WHEN a venue is created, THE Directus_Client SHALL return the Directus-assigned ID for linking to event records
5. THE region field SHALL store the administrative area level 1 (state/province) as returned by the Nominatim reverse geocoding API, making it universal across countries (e.g., "Jihomoravský kraj" for Czech Republic, "Bayern" for Germany, "Île-de-France" for France)

### Requirement 9: Durable Workflow Orchestration for Single Event Processing

**User Story:** As a developer, I want single event processing to run as a durable Restate workflow, so that failures at any step are automatically retried and the processing state is tracked.

#### Acceptance Criteria

1. WHEN a single event URL is submitted for processing, THE Workflow_Service SHALL create a Restate workflow run that orchestrates: scraping the event, classifying the event type, extracting event parts, extracting event info, resolving the venue, and storing the result in Directus
2. WHEN any step in the workflow fails, THE Workflow_Service SHALL automatically retry the failed step using Restate's built-in retry mechanism
3. THE Workflow_Service SHALL store the event URL, processing status, and any error messages in Restate K/V state for each workflow run

### Requirement 10: Batch Event Processing Workflow

**User Story:** As a developer, I want to trigger batch processing of all events from all registered Facebook groups, so that new events are automatically discovered and processed.

#### Acceptance Criteria

1. WHEN batch processing is triggered, THE Workflow_Service SHALL retrieve all registered group URLs from Directus via the Group_Manager
2. FOR EACH group URL, THE Workflow_Service SHALL fetch the event list from the dancee_scraper API via the Scraper_Client
3. FOR EACH event URL in the list, THE Workflow_Service SHALL check if the event already exists in Directus and skip processing if it does
4. FOR EACH new event URL, THE Workflow_Service SHALL trigger a single event processing workflow run
5. WHEN processing of a single event fails, THE Workflow_Service SHALL log the error via the Error_Tracker and continue processing the remaining events

### Requirement 11: Group Management via Directus

**User Story:** As a developer, I want Facebook group/page URLs to be managed as records in Directus, so that the list of event sources can be maintained through the CMS interface.

#### Acceptance Criteria

1. THE Directus_Client SHALL store each group record with the following fields: url, type (e.g., "facebook"), and updated_at timestamp
2. WHEN batch processing completes for a group, THE Group_Manager SHALL update the group's updated_at timestamp in Directus
3. THE Group_Manager SHALL retrieve groups ordered by updated_at ascending, so that the least recently processed groups are handled first

### Requirement 12: Error Tracking via Directus

**User Story:** As a developer, I want processing errors to be logged in Directus, so that I can review and debug failed event processing attempts.

#### Acceptance Criteria

1. WHEN an event processing error occurs, THE Error_Tracker SHALL create an error record in Directus containing the event URL, error message, and timestamp
2. WHEN an error record for the same URL already exists in Directus, THE Error_Tracker SHALL skip creating a duplicate error record

### Requirement 13: REST API for Triggering Workflows

**User Story:** As a developer, I want HTTP endpoints to trigger event processing, so that I can manually process individual events or start batch processing.

#### Acceptance Criteria

1. WHEN a POST request with a JSON body containing a "url" field is received at the `/api/event` endpoint, THE API_Service SHALL trigger a single event processing workflow and return the processed event data with HTTP status 200
2. WHEN a GET request is received at the `/api/events/process` endpoint, THE API_Service SHALL trigger the batch event processing workflow and return HTTP status 200 with an acknowledgment message
3. WHEN a GET request is received at the `/api/events/list` endpoint, THE API_Service SHALL retrieve all events from Directus and return them with HTTP status 200
4. IF a request to the `/api/event` endpoint is missing the "url" field, THEN THE API_Service SHALL return HTTP status 400 with a descriptive error message

### Requirement 14: Directus Database Setup Script

**User Story:** As a developer, I want a setup script that creates the required collections and fields in a fresh Directus instance, so that the database structure is reproducible and documented.

#### Acceptance Criteria

1. THE Setup_Script SHALL create the following Directus collections: events, venues, groups, and errors
2. THE Setup_Script SHALL create all required fields for the events collection matching the Event schema: title, description, original_description, organizer, venue (relation to venues), start_time, end_time, timezone, original_url, parts (JSON field for EventPart array), info (JSON field for EventInfo array), and dances (JSON field for string array, computed by aggregating all unique dance names from the event's parts)
3. THE Setup_Script SHALL create all required fields for the venues collection: name, street, number, town, country, postal_code, region, latitude, and longitude
4. THE Setup_Script SHALL create all required fields for the groups collection: url, type, and updated_at
5. THE Setup_Script SHALL create all required fields for the errors collection: url, message, and datetime
6. THE Setup_Script SHALL read the Directus base URL and admin token from the `.env` configuration file
7. WHEN a collection already exists in Directus, THE Setup_Script SHALL skip creating that collection and log a message

### Requirement 15: Environment Configuration

**User Story:** As a developer, I want all secrets and configuration values stored in .env files, so that sensitive data is not committed to version control.

#### Acceptance Criteria

1. THE project SHALL use a `.env` file for all sensitive configuration values including: OpenRouter API key, Directus base URL, Directus access token, dancee_scraper base URL, Nominatim base URL (defaulting to `https://nominatim.openstreetmap.org`), Sentry DSN, CORS allowed origins, and application port
2. THE project SHALL include a `.env.example` file committed to version control containing all variable keys with placeholder values
3. THE `.env` file SHALL be listed in `.gitignore` and excluded from version control
4. WHEN any environment variable is added or removed from `.env`, THE same change SHALL be applied to `.env.example` immediately

### Requirement 16: Project Structure and Tooling

**User Story:** As a developer, I want the project to use Bun as the package manager and follow the AiWorkflow project structure, so that it is consistent with existing backend services.

#### Acceptance Criteria

1. THE project SHALL use Bun as the package manager and runtime
2. THE project SHALL use TypeScript with strict mode enabled
3. THE project SHALL use the Restate SDK for workflow orchestration
4. THE project SHALL structure source code under a `src/` directory organized into `core/` (configuration, schemas, prompts), `clients/` (HTTP clients for external services), and `services/` (Restate workflows, business logic) subdirectories
5. THE project SHALL include a `docker-compose.yml` file for running the service alongside Restate server and Directus

### Requirement 17: LLM Integration via OpenRouter

**User Story:** As a developer, I want the event parser to use OpenRouter as the LLM provider, so that I can switch between models without changing the integration code.

#### Acceptance Criteria

1. THE Event_Parser SHALL send LLM requests to the OpenRouter API using the configured API key
2. THE Event_Parser SHALL use a configurable model identifier defaulting to a capable model (e.g., Google Gemini 2.0 Flash)
3. WHEN the LLM response contains markdown code fences around JSON, THE Event_Parser SHALL strip the code fences before parsing the JSON
4. THE Event_Parser SHALL include system prompts in Czech matching the existing prompt templates from the serinus_service for event type classification, event parts extraction, and event info extraction

### Requirement 18: Sentry Error Monitoring

**User Story:** As a developer, I want unhandled exceptions and processing errors to be captured and reported to Sentry, so that I can monitor service health and debug failures in real time.

#### Acceptance Criteria

1. THE Workflow_Service SHALL initialize the Sentry SDK at application startup using the Sentry DSN from the `.env` configuration file
2. WHEN an unhandled exception occurs during workflow processing, THE Workflow_Service SHALL capture the exception and send it to Sentry with relevant context (event URL, workflow step name)
3. WHEN the Sentry DSN environment variable is not set or is empty, THE Workflow_Service SHALL start without Sentry integration and log a warning message
4. THE Workflow_Service SHALL attach the current workflow run ID and event URL as Sentry tags to each captured error for filtering and search

### Requirement 19: CORS Configuration

**User Story:** As a developer, I want the service to support Cross-Origin Resource Sharing (CORS), so that the API can be called from frontend applications running on different origins.

#### Acceptance Criteria

1. THE API_Service SHALL enable CORS for all API endpoints
2. THE API_Service SHALL allow configurable allowed origins via the `.env` configuration file, defaulting to allowing all origins (`*`) in development
3. THE API_Service SHALL support the standard CORS headers including `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, and `Access-Control-Allow-Headers`

### Requirement 20: Computed Dances Field on Events

**User Story:** As a developer, I want the stored event to include a computed `dances` field that aggregates all unique dance names from the event's parts, so that events can be easily filtered and searched by dance style.

#### Acceptance Criteria

1. WHEN an Event is being prepared for storage, THE Event_Processor SHALL compute the `dances` field by collecting all dance names from all EventPart objects and deduplicating them into a unique set
2. THE computed `dances` field SHALL be stored as a JSON array of strings in the Directus events collection
3. WHEN an Event has no parts or no dances in any part, THE `dances` field SHALL be stored as an empty array
