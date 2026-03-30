# Design Document: event-workflow-restate

## Overview

This service (`event-workflow-restate`) replaces the existing `serinus_service` (Dart/SurrealDB) with a TypeScript/Bun implementation using Restate for durable workflow orchestration, Directus CMS for data storage, OpenRouter for LLM integration, and Nominatim for reverse geocoding.

The service automates the pipeline: scrape Facebook events → classify via LLM → extract parts & info via LLM → translate to multiple languages via LLM → resolve venues → store in Directus. It follows the project structure established by the `AiWorkflow` reference project. All LLM prompts are written in English, with explicit `outputLanguage`/`targetLanguage` parameters controlling the language of generated content.

### Key Technology Decisions

| Concern | Old (serinus_service) | New (event-workflow-restate) |
|---|---|---|
| Language/Runtime | Dart | TypeScript / Bun |
| Framework | Serinus | Restate SDK |
| Database | SurrealDB | Directus CMS (REST API) |
| LLM Provider | DanceeAiClient | OpenRouter (via OpenAI SDK) |
| Geocoding | Google Geocoding API | Nominatim (OpenStreetMap) |
| Error Monitoring | None | Sentry |
| Workflow | Sequential in-process | Durable Restate workflows |

### Rationale

- Restate provides automatic retries, K/V state tracking, and durable execution without custom retry logic.
- Directus CMS gives a built-in admin UI for managing events, venues, and groups without building a custom dashboard.
- Nominatim is free with no API key, replacing the paid Google Geocoding API.
- OpenRouter allows model switching without code changes. It exposes an OpenAI-compatible API, so the `openai` npm package is used as the client SDK with `baseURL` pointed to `https://openrouter.ai/api/v1`.
- Bun is used as the package manager per project requirements (runtime remains Node.js for Restate SDK compatibility).

## Architecture

### System Context Diagram

```mermaid
graph TB
    subgraph External Services
        FB[dancee_scraper API<br/>Port 3002]
        OR[OpenRouter API<br/>LLM Provider]
        NOM[Nominatim API<br/>OpenStreetMap]
        SEN[Sentry<br/>Error Monitoring]
    end

    subgraph event-workflow-restate
        RS[Restate Server<br/>Port 8080 ingress]
        APP[Application Service<br/>Port 9080]
    end

    subgraph Data Store
        DIR[Directus CMS<br/>Port 8055]
    end

    CLIENT[API Client / dancee_api] -->|HTTP| RS
    RS -->|Workflow orchestration| APP
    APP -->|GET /api/scraper/event/:id| FB
    APP -->|GET /api/scraper/events| FB
    APP -->|OpenAI SDK /chat/completions| OR
    APP -->|GET /reverse| NOM
    APP -->|REST API /items/*| DIR
    APP -->|Error capture| SEN
```

### Workflow Sequence - Single Event Processing

```mermaid
sequenceDiagram
    participant C as Client
    participant API as API Service
    participant WF as Workflow
    participant SC as Scraper Client
    participant AI as Event Parser
    participant TR as Event Translator
    participant VR as Venue Resolver
    participant DC as Directus Client

    C->>API: POST /api/event {url}
    API->>WF: Start workflow run
    WF->>SC: Scrape event by URL
    SC-->>WF: FacebookEvent data
    WF->>AI: Classify event type
    AI-->>WF: EventType
    alt Unsupported type
        WF-->>API: Skip (log reason)
    end
    WF->>AI: Extract event parts (output: Czech)
    AI-->>WF: {title, description, parts[]}
    Note over WF: title + description = LLM Czech output<br/>original_description = raw Facebook description
    WF->>AI: Extract event info
    AI-->>WF: EventInfo[]
    WF->>VR: Resolve venue from location
    VR->>DC: Check existing venue
    alt Venue not found
        VR->>NOM: Reverse geocode
        NOM-->>VR: Address + region
        VR->>DC: Create venue
    end
    VR-->>WF: Venue (with Directus ID)
    Note over WF: Derive organizer from hosts[0].name<br/>(fallback: event name)
    WF->>DC: Check event exists (by original_url)
    alt Event is new
        Note over WF: Czech content becomes "cs" translation
        WF->>TR: Translate to English (targetLanguage: "en")
        TR-->>WF: EN translations
        WF->>TR: Translate to Spanish (targetLanguage: "es")
        TR-->>WF: ES translations
        WF->>DC: Create event with all translations (cs, en, es)
    end
    WF-->>API: Processed event
    API-->>C: 200 OK {event}
```

### Batch Processing Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant API as API Service
    participant BW as Batch Workflow
    participant SC as Scraper Client
    participant DC as Directus Client
    participant EW as Event Workflow

    C->>API: GET /api/events/process
    API-->>C: 200 OK (acknowledged)
    API->>BW: Start batch workflow
    BW->>DC: Get all groups (ordered by updated_at ASC)
    DC-->>BW: Group[]
    loop For each group
        BW->>SC: Get event list for group
        SC-->>BW: FacebookEvent[]
        loop For each event URL
            BW->>DC: Check event exists
            alt Event is new
                BW->>EW: Trigger single event workflow
            end
        end
        BW->>DC: Update group updated_at
    end
```

## Components and Interfaces

### Project Structure

```
backend/dancee_workflow/
├── src/
│   ├── index.ts                        # Entry point, registers Restate services
│   ├── core/
│   │   ├── config.ts                   # Environment configuration (dotenv) + Sentry initialization
│   │   ├── schemas.ts                  # Zod schemas and TypeScript interfaces
│   │   └── prompts.ts                  # LLM prompt templates (all in English, with outputLanguage/targetLanguage params)
│   ├── clients/
│   │   ├── scraper-client.ts           # HTTP client for dancee_scraper API
│   │   ├── directus-client.ts          # Directus CMS REST API (events, venues, groups, errors, translations)
│   │   └── nominatim-client.ts         # Nominatim reverse geocoding HTTP client
│   ├── services/
│   │   ├── api.ts                      # Restate service: HTTP API handlers
│   │   ├── workflow.ts                 # Restate workflow: single event processing (incl. translation step)
│   │   ├── batch.ts                    # Restate service: batch processing orchestration
│   │   ├── event-parser.ts             # LLM-based event classification and extraction (OpenAI SDK)
│   │   ├── event-translator.ts         # LLM-based translation of event content to target languages
│   │   └── venue-resolver.ts           # Venue resolution logic (uses directus-client + nominatim-client)
├── scripts/
│   └── setup-directus.ts              # CLI script to create Directus collections (incl. languages, events_translations)
├── .env.example
├── .gitignore
├── docker-compose.yml
├── Dockerfile                          # Multi-stage build: Restate server + Node.js app via supervisord
├── supervisord.conf                    # Manages restate-server and app processes in single container
├── package.json
├── tsconfig.json
└── vitest.config.ts
```

### Component Interfaces

#### core/prompts.ts
```typescript
// All prompts are written in English.
// Extraction prompts use an outputLanguage parameter to instruct the LLM to produce Czech output.
// Translation prompt uses a targetLanguage parameter to control the output language.

export function getEventTypeClassificationPrompt(): string;
export function getEventPartsExtractionPrompt(outputLanguage: string): string;
export function getEventInfoExtractionPrompt(): string;
export function getTranslationPrompt(targetLanguage: string): string;
```

#### core/config.ts
```typescript
import * as Sentry from "@sentry/node";

export const config: {
  openRouterApiKey: string;
  openRouterModel: string;
  directusBaseUrl: string;
  directusToken: string;
  scraperBaseUrl: string;
  nominatimBaseUrl: string;
  sentryDsn: string;
  corsOrigins: string;
  appPort: number;
};

// Sentry initialization (called at startup)
export function initSentry(): void;

// Sentry error capture with context tags
export function captureError(error: Error, context: Record<string, string>): void;
```

#### clients/scraper-client.ts
```typescript
// Fetches raw event data from dancee_scraper API
export async function scrapeEvent(eventIdOrUrl: string): Promise<FacebookEvent>;
export async function scrapeEventList(pageId: string, eventType?: "upcoming" | "past"): Promise<FacebookEvent[]>;
```

#### services/event-parser.ts
```typescript
// LLM calls via OpenRouter using the OpenAI SDK (openai npm package)
// OpenRouter is OpenAI-compatible; the SDK is configured with:
//   baseURL: "https://openrouter.ai/api/v1"
//   apiKey: config.openRouterApiKey
import OpenAI from "openai";

const openai = new OpenAI({
  baseURL: "https://openrouter.ai/api/v1",
  apiKey: config.openRouterApiKey,
});

export async function classifyEventType(description: string): Promise<EventType>;
export async function extractEventParts(description: string): Promise<{ title: string; description: string; parts: EventPart[] }>;
export async function extractEventInfo(description: string): Promise<EventInfo[]>;
```

#### services/event-translator.ts
```typescript
// LLM-based translation of event content to target languages via OpenRouter
// Uses a single parameterized English prompt with targetLanguage parameter
// Translates: title, description, EventPart name/description, EventInfo key
// Does NOT translate: dates, times, coordinates, URLs, price values, dance names, lectors, DJs, organizer, venue names
import OpenAI from "openai";

export interface TranslatedEventContent {
  title: string;
  description: string;
  parts_translations: Array<{ name: string; description: string }>;
  info_translations: Array<{ key: string }>;
}

export async function translateEventContent(
  content: {
    title: string;
    description: string;
    parts: EventPart[];
    info: EventInfo[];
  },
  targetLanguage: string,
): Promise<TranslatedEventContent>;
```

#### clients/directus-client.ts
```typescript
// All Directus CMS REST API operations (events, venues, groups, errors, translations)

// Events (created with nested translations via Directus M2Any relation)
export async function createEvent(event: DirectusEvent): Promise<DirectusEvent>;
export async function findEventByOriginalUrl(originalUrl: string): Promise<DirectusEvent | null>;
export async function listEvents(): Promise<DirectusEvent[]>;

// Venues
export async function createVenue(venue: DirectusVenue): Promise<DirectusVenue>;
export async function findVenue(name: string, street: string, town: string): Promise<DirectusVenue | null>;
export async function findVenueByCoordinates(lat: number, lng: number): Promise<DirectusVenue | null>;

// Groups
export async function createGroup(group: DirectusGroup): Promise<DirectusGroup>;
export async function getGroupsOrderedByUpdatedAt(): Promise<DirectusGroup[]>;
export async function updateGroupTimestamp(id: string | number, updatedAt: string): Promise<DirectusGroup>;

// Errors
// NOTE: datetime is auto-generated internally when not provided by caller
export async function createError(entry: Omit<DirectusError, "id" | "datetime"> & { datetime?: string }): Promise<DirectusError>;
export async function findErrorByUrl(url: string): Promise<DirectusError | null>;

// Languages
export async function getLanguages(): Promise<DirectusLanguage[]>;
export async function createLanguage(code: string, name: string): Promise<DirectusLanguage>;
```

#### services/venue-resolver.ts
```typescript
// Resolves venue from Facebook location data, using Directus cache + Nominatim
export async function resolveVenue(location: FacebookLocation): Promise<DirectusVenue>;
```

#### clients/nominatim-client.ts
```typescript
// Nominatim reverse geocoding HTTP client (OpenStreetMap)
// Respects usage policy: max 1 request per second
export async function reverseGeocode(lat: number, lng: number): Promise<NominatimResponse>;
```

#### services/api.ts (Restate service)
```typescript
// Restate service handlers exposed via Restate ingress
// POST /api/event         → processEvent handler
// GET  /api/events/process → processBatch handler
// GET  /api/events/list    → listEvents handler
export const apiService: restate.ServiceDefinition;
```

#### services/workflow.ts (Restate workflow)
```typescript
// Durable workflow for single event processing
// Steps: scrape → classify → extract parts → extract info → resolve venue → derive organizer → translate (en, es) → store with translations
//
// Field mapping:
//   status               = "published" (default for new events)
//   translation_status   = "complete" | "partial" | "missing" (computed from translation count)
//   original_description = raw Facebook event description (from scraped data)
//   organizer            = hosts[0].name from scraped data (fallback: event name)
//   translations[cs]     = Czech title + description from extraction, parts/info translations from extraction
//   translations[en]     = English translations via LLM
//   translations[es]     = Spanish translations via LLM
export const eventWorkflow: restate.WorkflowDefinition;
```

#### services/batch.ts (Restate service)
```typescript
// Orchestrates batch processing across all groups
export const batchService: restate.ServiceDefinition;
```


## Data Models

### TypeScript Interfaces and Zod Schemas (core/schemas.ts)

All data models are defined as Zod schemas for runtime validation and TypeScript types for compile-time safety.

#### FacebookEvent (from scraper response)
```typescript
const FacebookEventSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string().optional(),
  startTimestamp: z.number(),
  endTimestamp: z.number().nullable().optional(),
  location: z.object({
    name: z.string().optional(),
    address: z.string().optional(),
    city: z.string().optional(),
    country: z.string().optional(),
    latitude: z.number().optional(),
    longitude: z.number().optional(),
  }).optional(),
  url: z.string(),
  hosts: z.array(z.object({
    name: z.string(),
    id: z.string(),
    url: z.string(),
    type: z.string(),
  })).optional(),
  timezone: z.string().optional(),
});
```

#### EventType
```typescript
const EventTypeSchema = z.enum([
  "party", "workshop", "lesson", "course", "festival", "holiday", "other"
]);
type EventType = z.infer<typeof EventTypeSchema>;

const SUPPORTED_EVENT_TYPES: EventType[] = ["party", "workshop", "festival", "holiday"];
```

#### EventPart
```typescript
const EventPartSchema = z.object({
  name: z.string(),
  description: z.string(),
  type: z.enum(["party", "workshop", "openLesson"]),
  dances: z.array(z.string()),
  date_time_range: z.object({
    start: z.string(), // ISO 8601 UTC
    end: z.string(),   // ISO 8601 UTC
  }),
  lectors: z.array(z.string()),
  djs: z.array(z.string()),
});
```

#### EventInfo
```typescript
const EventInfoSchema = z.object({
  type: z.enum(["url", "price"]),
  key: z.string(),
  value: z.string(),
});
```

#### Directus Collection Schemas

```typescript
// Directus events collection (title and description are in events_translations, not here)
const DirectusEventSchema = z.object({
  id: z.string().optional(),           // Directus-assigned
  status: z.enum(["published", "draft", "archived"]).default("published"), // Directus built-in status
  translation_status: z.enum(["complete", "partial", "missing"]), // Auto-set by workflow
  original_description: z.string(),
  organizer: z.string(),
  venue: z.string().optional(),         // Directus relation ID
  start_time: z.string(),              // ISO 8601
  end_time: z.string().nullable(),      // ISO 8601 or null when unknown
  timezone: z.string(),
  original_url: z.string(),
  parts: z.array(EventPartSchema),     // JSON field
  info: z.array(EventInfoSchema),      // JSON field
  dances: z.array(z.string()),         // JSON field, computed from parts
  translations: z.array(DirectusEventTranslationSchema).optional(), // Nested M2Any for create
});

// Directus events_translations collection
const DirectusEventTranslationSchema = z.object({
  id: z.string().optional(),           // Directus-assigned
  events_id: z.string().optional(),    // FK to events (set by Directus on nested create)
  languages_code: z.string(),          // FK to languages (e.g., "cs", "en", "es")
  title: z.string(),
  description: z.string(),
  parts_translations: z.array(z.object({  // Translated EventPart name/description per part
    name: z.string(),
    description: z.string(),
  })),
  info_translations: z.array(z.object({   // Translated EventInfo key per item
    key: z.string(),
  })),
});

// Directus languages collection
const DirectusLanguageSchema = z.object({
  code: z.string(),                    // PK (e.g., "cs", "en", "es")
  name: z.string(),                    // e.g., "Čeština", "English", "Español"
});

// Directus venues collection
const DirectusVenueSchema = z.object({
  id: z.string().optional(),           // Directus-assigned
  name: z.string(),
  street: z.string(),
  number: z.string(),
  town: z.string(),
  country: z.string(),
  postal_code: z.string(),
  region: z.string(),                  // admin area level 1 from Nominatim
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
});

// Directus groups collection
const DirectusGroupSchema = z.object({
  id: z.string().optional(),           // Directus-assigned
  url: z.string(),
  type: z.string(),                    // e.g., "facebook"
  updated_at: z.string().optional(),   // ISO 8601
});

// Directus errors collection
const DirectusErrorSchema = z.object({
  id: z.string().optional(),           // Directus-assigned
  url: z.string(),
  message: z.string(),
  datetime: z.string(),                // ISO 8601
});
```

### Directus Collection Relationships

```mermaid
erDiagram
    events ||--o| venues : "venue (M2O)"
    events ||--o{ events_translations : "translations (O2M)"
    events_translations }o--|| languages : "languages_code (M2O)"
    events {
        string id PK
        string status
        string translation_status
        string original_description
        string organizer
        string venue FK
        datetime start_time
        datetime end_time "nullable"
        string timezone
        string original_url UK
        json parts
        json info
        json dances
    }
    events_translations {
        string id PK
        string events_id FK
        string languages_code FK
        string title
        string description
        json parts_translations
        json info_translations
    }
    languages {
        string code PK
        string name
    }
    venues {
        string id PK
        string name
        string street
        string number
        string town
        string country
        string postal_code
        string region
        float latitude
        float longitude
    }
    groups {
        string id PK
        string url
        string type
        datetime updated_at
    }
    errors {
        string id PK
        string url UK
        string message
        datetime datetime
    }
```

### Nominatim Reverse Geocoding Response (relevant fields)

```typescript
interface NominatimResponse {
  address: {
    road?: string;
    house_number?: string;
    city?: string;
    town?: string;
    village?: string;
    state?: string;          // → maps to venue.region
    country?: string;
    postcode?: string;
    country_code?: string;
  };
  display_name: string;
  lat: string;
  lon: string;
}
```

The `address.state` field from Nominatim maps to the venue `region` field. This is universal across countries (e.g., "Jihomoravský kraj" for CZ, "Bayern" for DE, "Île-de-France" for FR). When `state` is absent, region defaults to `"Other"`.

### Computed Dances Field

The `dances` field on events is computed at storage time by aggregating all unique dance names from all `EventPart` objects:

```typescript
function computeDances(parts: EventPart[]): string[] {
  const danceSet = new Set<string>();
  for (const part of parts) {
    for (const dance of part.dances) {
      danceSet.add(dance);
    }
  }
  return Array.from(danceSet);
}
```

### LLM Response Parsing

The event parser module must handle markdown code fences in LLM responses:

```typescript
function parseJsonResponse(raw: string): unknown {
  // Strip ```json ... ``` or ``` ... ``` wrappers
  const stripped = raw.replace(/^```(?:json)?\s*\n?/m, "").replace(/\n?```\s*$/m, "");
  return JSON.parse(stripped);
}
```

Retry logic: up to 2 additional attempts on invalid JSON for event parts extraction and translation.

### Docker Compose Setup

Directus is managed externally (deployed separately on Fly.io). The docker-compose only runs the workflow service. Directus connection is configured via `.env` (`DIRECTUS_BASE_URL` and `DIRECTUS_ACCESS_TOKEN`).

```yaml
services:
  event-workflow:
    build: .
    ports:
      - "8080:8080"   # Restate ingress
      - "9070:9070"   # Restate dashboard
      - "9080:9080"   # Application service
    env_file:
      - .env
```

### Container Architecture

The Docker container runs both the Restate server and the application process using supervisord, following the AiWorkflow reference pattern:

- **Multi-stage Dockerfile**: Build stage compiles TypeScript, production stage copies the Restate server binary from the official `restatedev/restate:latest` image, installs Node.js and supervisord on a Debian base
- **supervisord.conf**: Manages two processes — `restate-server` (priority 10, starts first) and the Node.js application (priority 20, starts after Restate server with a short delay)
- **Exposed ports**: 8080 (Restate ingress), 9070 (Restate dashboard), 9080 (application service)

```
┌─────────────────────────────────┐
│         Docker Container        │
│                                 │
│  ┌──────────┐  ┌─────────────┐  │
│  │ Restate  │  │  Node.js    │  │
│  │ Server   │  │  App        │  │
│  │ :8080    │  │  :9080      │  │
│  │ :9070    │  │             │  │
│  └──────────┘  └─────────────┘  │
│         supervisord             │
└─────────────────────────────────┘
```

### Test Script

The `package.json` includes a test script for single-execution test runs:

```json
{
  "scripts": {
    "test": "vitest --run"
  }
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Scraper client error propagation

*For any* HTTP error status code (4xx or 5xx) and any error message string returned by the dancee_scraper API, the error thrown by the Scraper_Client shall contain both the status code and the error message.

**Validates: Requirements 1.2, 2.2**

### Property 2: Null end timestamp preservation

*For any* FacebookEvent object where `endTimestamp` is null, undefined, zero, or negative, the processed event's `end_time` shall be null.

**Validates: Requirements 1.4**

### Property 3: Event type query parameter inclusion

*For any* call to `scrapeEventList` with an `eventType` parameter of "upcoming" or "past", the constructed request URL shall include `eventType` as a query parameter with the provided value. When `eventType` is omitted, the URL shall not contain the `eventType` parameter.

**Validates: Requirements 2.3**

### Property 4: Event type parsing always returns a valid type

*For any* string value returned by the LLM as the event type, parsing it shall always produce a valid `EventType` enum value. For any string that does not match a known type (party, workshop, lesson, course, festival, holiday), the result shall be "other".

**Validates: Requirements 3.2, 3.3**

### Property 5: Unsupported event types are skipped

*For any* EventType that is not in the supported set (party, workshop, festival, holiday), the Event_Processor shall skip further processing and return a skip result with a reason string.

**Validates: Requirements 3.4**

### Property 6: LLM response JSON parsing strips code fences

*For any* valid JSON string, wrapping it in markdown code fences (`` ```json ... ``` `` or `` ``` ... ``` ``) and then passing it through the `parseJsonResponse` function shall produce a value equal to parsing the original unwrapped JSON.

**Validates: Requirements 17.3**

### Property 7: EventPart and EventInfo schema validation

*For any* valid EventPart object, it shall contain all required fields: name, description, type (one of party/workshop/openLesson), dances (array), date_time_range (with start and end), lectors (array), and djs (array). *For any* valid EventInfo object, it shall contain type (url or price), key, and value.

**Validates: Requirements 4.2, 5.2**

### Property 8: Empty EventInfo values are filtered out

*For any* list of EventInfo-like objects where some have empty string or null values, the filtering function shall return only entries where `value` is a non-empty, non-null string. The length of the filtered list shall be less than or equal to the original, and every entry in the result shall have a truthy `value`.

**Validates: Requirements 5.3**

### Property 9: Venue resolution field mapping

*For any* Facebook location data that contains non-null `name`, `address`, `city`, and `countryCode` fields, the resolved venue shall use those values directly for `name`, `street`, `town`, and `country`. *For any* Nominatim response with a non-empty `address.state` field, the venue `region` shall equal that state value. *For any* Nominatim response without an `address.state` field, the venue `region` shall be "Other".

**Validates: Requirements 6.2, 6.3, 6.4, 6.5**

### Property 10: Venue deduplication

*For any* two venue resolution requests with the same (name, street, town) tuple or the same (latitude, longitude) coordinates, the Venue_Resolver shall return the same Directus venue ID without creating a duplicate record.

**Validates: Requirements 6.7, 6.8, 7.4, 8.2, 8.3**

### Property 11: Event deduplication by original URL

*For any* event with an `original_url` that already exists in Directus, attempting to store it again shall not create a duplicate record. The total count of events with that URL shall remain exactly 1.

**Validates: Requirements 7.2, 10.3**

### Property 12: Error deduplication by URL

*For any* error URL that already has an error record in Directus, calling `trackError` with the same URL shall not create a duplicate error record.

**Validates: Requirements 12.2**

### Property 13: Groups ordered by updated_at ascending

*For any* set of group records with distinct `updated_at` timestamps, `getGroupsOrderedByUpdatedAt` shall return them sorted in ascending order by `updated_at`.

**Validates: Requirements 11.3**

### Property 14: Missing URL field returns 400

*For any* request body that does not contain a `url` field (including empty objects, objects with other fields, null, and undefined), the API service shall respond with HTTP status 400.

**Validates: Requirements 13.4**

### Property 15: Computed dances field is the unique set from all parts

*For any* list of EventPart objects, the computed `dances` field shall contain exactly the unique set of all dance names across all parts, with no duplicates. When the parts list is empty or no part contains any dances, the result shall be an empty array.

**Validates: Requirements 20.1, 20.2, 20.3**

### Property 16: Translation produces non-empty content for all supported languages

*For any* valid event content (non-empty title, description, parts, and info), translating it to any supported target language ("en" or "es") shall produce a `TranslatedEventContent` where `title` and `description` are non-empty strings, `parts_translations` has the same length as the input parts array with non-empty `name` and `description` for each entry, and `info_translations` has the same length as the input info array with a non-empty `key` for each entry.

**Validates: Requirements 21.1, 21.2**

### Property 17: Translation preserves non-translatable fields

*For any* event content with EventPart objects containing dances, lectors, DJs, and date_time_range fields, and EventInfo objects containing value fields, the translation process shall not modify these fields. The original parts and info arrays on the event shall remain unchanged after translation.

**Validates: Requirements 21.3**

### Property 18: Translation failure isolation

*For any* set of target languages where one translation fails, the successfully completed translations shall still be available and stored. A failure translating to language X shall not affect the translation for language Y.

**Validates: Requirements 21.6**

### Property 19: Czech extraction output maps to "cs" translation record

*For any* event processed through the extraction step, the Czech title, description, EventPart names/descriptions, and EventInfo keys from the extraction output shall be stored as the "cs" language translation record with matching field values.

**Validates: Requirements 21.5, 22.1**

### Property 20: Translation parts_translations array length matches parts array

*For any* event with N EventPart objects, each translation record's `parts_translations` JSON array shall have exactly N entries, maintaining index correspondence with the original parts array. Similarly, for M EventInfo objects, `info_translations` shall have exactly M entries.

**Validates: Requirements 22.2, 22.3**

### Property 21: Events collection does not contain title or description fields

*For any* event stored in Directus, the event record itself shall not contain `title` or `description` fields. These fields shall exist only in the associated events_translations records.

**Validates: Requirements 22.5**

### Property 22: New events default to published status

*For any* event created by the workflow, the `status` field shall be set to `"published"`. The status field shall only contain one of the allowed values: `"published"`, `"draft"`, or `"archived"`.

**Validates: Requirements 23.1, 23.2**

### Property 23: Translation status reflects actual translation completeness

*For any* event with N translation records (where N is between 0 and 3), the `translation_status` field shall be `"complete"` when N equals 3 (all supported languages), `"partial"` when N is between 1 and 2, and `"missing"` when N is 0.

**Validates: Requirements 24.1, 24.2, 24.3, 24.4**

### Property 24: List events endpoint returns only published events by default

*For any* set of events with mixed statuses (published, draft, archived), the `/api/events/list` endpoint without explicit filters shall return only events where `status` is `"published"`. The count of returned events shall equal the count of published events in the dataset.

**Validates: Requirements 23.4**

## Error Handling

### Error Categories

| Category | Handling Strategy | Example |
|---|---|---|
| Scraper HTTP errors | Propagate with status code + message, Restate retries | dancee_scraper returns 404 |
| LLM invalid JSON | Retry up to 2 additional times, then propagate | OpenRouter returns malformed response |
| LLM unrecognized type | Default to "other", skip processing | LLM returns "concert" |
| Translation LLM failure | Retry up to 2 times, log error, skip that language | OpenRouter returns invalid JSON for EN translation |
| Translation partial failure | Store successful translations, log failed ones, continue | ES translation fails but CS and EN succeed |
| Nominatim failure | Set region to "Other", use available data | Nominatim rate limited or down |
| Directus API errors | Propagate, Restate retries | Directus returns 500 |
| Unsupported event type | Skip event, log reason, continue batch | Event classified as "lesson" |
| Single event failure in batch | Log via Directus error tracking, continue with next event | Any exception during single event processing |
| Missing Sentry DSN | Start without Sentry, log warning | Empty SENTRY_DSN in .env |

### Error Flow

1. Restate provides automatic retries for transient failures (network timeouts, 5xx errors).
2. For permanent failures (4xx, validation errors), use `restate.TerminalError` to stop retries.
3. In batch processing, individual event failures are caught, logged to Directus via the error tracking functions in `directus-client.ts`, and reported to Sentry. The batch continues with remaining events.
4. Sentry captures unhandled exceptions with context tags: workflow run ID, event URL, and workflow step name.

### Sentry Integration

Sentry initialization and error capture are part of `core/config.ts`:

```typescript
// core/config.ts (Sentry section)
import * as Sentry from "@sentry/node";

export function initSentry(): void {
  if (!config.sentryDsn) {
    console.warn("SENTRY_DSN not set, Sentry integration disabled");
    return;
  }
  Sentry.init({ dsn: config.sentryDsn });
}

export function captureError(error: Error, context: Record<string, string>): void {
  Sentry.withScope((scope) => {
    for (const [key, value] of Object.entries(context)) {
      scope.setTag(key, value);
    }
    Sentry.captureException(error);
  });
}
```

## Testing Strategy

### Dual Testing Approach

This project uses both unit tests and property-based tests for comprehensive coverage:

- **Unit tests** (vitest): Specific examples, integration points, edge cases, error conditions
- **Property-based tests** (fast-check via vitest): Universal properties across generated inputs

### Property-Based Testing Configuration

- Library: `fast-check` (already used in the AiWorkflow reference project)
- Framework: `vitest` with `--run` flag for single execution
- Minimum iterations: 100 per property test
- Each property test must reference its design document property with a tag comment:
  ```typescript
  // Feature: event-workflow-restate, Property 15: Computed dances field is the unique set from all parts
  ```

### Test Structure

> **NOTE**: The implementation uses a consolidated test file layout (fewer files with grouped properties)
> rather than the one-file-per-property structure originally planned. This is intentional — consolidated
> files are more maintainable. The mapping table below reflects the actual layout.

Test directory mirrors the `src/` structure:

```
backend/dancee_workflow/
├── src/
│   └── __tests__/
│       ├── core/
│       │   └── schemas.test.ts               # Properties 4, 6, 8, 15 (consolidated)
│       ├── clients/
│       │   ├── scraper-client.test.ts        # Properties 1, 3 + unit tests
│       │   └── directus-client.test.ts       # Properties 10, 11, 12, 13 (consolidated)
│       └── services/
│           ├── venue-resolver.test.ts        # Properties 2, 5, 9 (consolidated)
│           ├── event-translator.test.ts      # Properties 16, 17 (consolidated)
│           ├── api.test.ts                   # Property 14 + unit tests
│           └── workflow.test.ts              # Properties 18, 19, 21, 22, 23 + error-tracking
```

### Unit Test Focus Areas

- API endpoint integration tests (POST /api/event, GET /api/events/process, GET /api/events/list)
- Directus client CRUD operations with mocked HTTP (including translations nested create)
- Workflow step orchestration order (including translation step after extraction, before storage)
- Sentry initialization with/without DSN
- Setup script collection creation and idempotency (including languages, events_translations collections and language seeding)
- LLM retry behavior on invalid JSON (3 attempts max, for both extraction and translation)
- Translation prompt parameterization (targetLanguage correctly injected)
- Translation failure isolation (one language failure doesn't affect others)
- Translation retry on invalid JSON (up to 2 additional attempts before skipping that language, verify retry count and final error logging)
- Event status defaults to "published" on creation, list endpoint filters by published status
- Translation status computed correctly based on number of translation records (complete/partial/missing)

### Property Test to Design Property Mapping

| Test File | Design Properties | Pattern |
|---|---|---|
| core/schemas.test.ts | Properties 4, 6, 8, 15 | Invariant / Round-trip / Metamorphic |
| clients/scraper-client.test.ts | Properties 1, 3 | Invariant |
| clients/directus-client.test.ts | Properties 10, 11, 12, 13 | Idempotence / Invariant (sorted) |
| services/venue-resolver.test.ts | Properties 2, 5, 9 | Invariant |
| services/event-translator.test.ts | Properties 16, 17 | Invariant (non-empty / unchanged fields) |
| services/api.test.ts | Property 14 | Error condition |
| services/workflow.test.ts | Properties 18, 19, 21, 22, 23 | Error condition / Invariant / error-tracking |

