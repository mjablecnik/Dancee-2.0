import * as dotenv from "dotenv";

dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";

function authHeaders(): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
  };
}

async function directusGet(path: string): Promise<unknown> {
  const response = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    headers: authHeaders(),
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`GET ${path} failed ${response.status}: ${text}`);
  }
  return response.json();
}

async function directusPost(path: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    method: "POST",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`POST ${path} failed ${response.status}: ${text}`);
  }
  return response.json();
}

async function collectionExists(name: string): Promise<boolean> {
  try {
    const data = await directusGet(`/collections/${name}`) as { data?: unknown };
    return !!data?.data;
  } catch {
    return false;
  }
}

async function fieldExists(collection: string, field: string): Promise<boolean> {
  try {
    const data = await directusGet(`/fields/${collection}/${field}`) as { data?: unknown };
    return !!data?.data;
  } catch {
    return false;
  }
}

async function createCollectionIfNotExists(
  name: string,
  meta: Record<string, unknown> = {},
  schema: Record<string, unknown> | null = {},
): Promise<void> {
  if (await collectionExists(name)) {
    console.log(`Collection "${name}" already exists, skipping.`);
    return;
  }
  await directusPost("/collections", { collection: name, meta, schema });
  console.log(`Created collection "${name}".`);
}

async function createFieldIfNotExists(
  collection: string,
  field: string,
  type: string,
  meta: Record<string, unknown> = {},
  schema: Record<string, unknown> | null = {},
): Promise<void> {
  if (await fieldExists(collection, field)) {
    return;
  }
  await directusPost(`/fields/${collection}`, { field, type, meta, schema });
  console.log(`Created field "${collection}.${field}".`);
}

// ---- Create collections ----

async function setupEventsCollection(): Promise<void> {
  await createCollectionIfNotExists("events", {
    singleton: false,
    sort_field: null,
  });

  await createFieldIfNotExists("events", "title", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("events", "original_description", "text", {
    interface: "input-multiline",
    display: "raw",
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "organizer", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("events", "venue", "integer", {
    interface: "select-dropdown-m2o",
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "start_time", "dateTime", {
    interface: "datetime",
  }, { is_nullable: false });

  await createFieldIfNotExists("events", "end_time", "dateTime", {
    interface: "datetime",
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "timezone", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 100 });

  await createFieldIfNotExists("events", "original_url", "string", {
    interface: "input",
    unique: true,
  }, { is_nullable: false, max_length: 2048 });

  await createFieldIfNotExists("events", "parts", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "info", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "dances", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("events", "status", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "published", text: "Published" },
        { value: "draft", text: "Draft" },
        { value: "archived", text: "Archived" },
      ],
    },
    default_value: "published",
  }, { is_nullable: false, max_length: 50, default_value: "published" });

  await createFieldIfNotExists("events", "translation_status", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "complete", text: "Complete" },
        { value: "partial", text: "Partial" },
        { value: "missing", text: "Missing" },
      ],
    },
  }, { is_nullable: true, max_length: 50 });
}

async function setupVenuesCollection(): Promise<void> {
  await createCollectionIfNotExists("venues", { singleton: false });

  await createFieldIfNotExists("venues", "name", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("venues", "street", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("venues", "number", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("venues", "town", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("venues", "country", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 100 });

  await createFieldIfNotExists("venues", "postal_code", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 20 });

  await createFieldIfNotExists("venues", "region", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("venues", "latitude", "float", {
    interface: "input",
  }, { is_nullable: true });

  await createFieldIfNotExists("venues", "longitude", "float", {
    interface: "input",
  }, { is_nullable: true });
}

async function setupGroupsCollection(): Promise<void> {
  await createCollectionIfNotExists("groups", { singleton: false });

  await createFieldIfNotExists("groups", "url", "string", {
    interface: "input",
  }, { is_nullable: false, max_length: 2048 });

  await createFieldIfNotExists("groups", "type", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 100 });

  await createFieldIfNotExists("groups", "updated_at", "dateTime", {
    interface: "datetime",
  }, { is_nullable: true });
}

async function setupErrorsCollection(): Promise<void> {
  await createCollectionIfNotExists("errors", { singleton: false });

  await createFieldIfNotExists("errors", "url", "string", {
    interface: "input",
  }, { is_nullable: false, max_length: 2048 });

  await createFieldIfNotExists("errors", "message", "text", {
    interface: "input-multiline",
  }, { is_nullable: true });

  await createFieldIfNotExists("errors", "type", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { text: "Scrape Failed", value: "scrape_failed" },
        { text: "Parse Failed", value: "parse_failed" },
        { text: "LLM Parse Failed", value: "llm_parse_failed" },
        { text: "Workflow Failed", value: "workflow_failed" },
        { text: "Schedule Failed", value: "schedule_failed" },
        { text: "Unknown", value: "unknown" },
      ],
    },
  }, { is_nullable: true, default_value: "unknown" });

  await createFieldIfNotExists("errors", "datetime", "dateTime", {
    interface: "datetime",
  }, { is_nullable: true });
}

async function setupSkippedEventsCollection(): Promise<void> {
  await createCollectionIfNotExists("skipped_events", { singleton: false });

  await createFieldIfNotExists("skipped_events", "original_url", "string", {
    interface: "input",
  }, { is_nullable: false, max_length: 2048 });

  await createFieldIfNotExists("skipped_events", "reason", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("skipped_events", "event_type", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 64 });

  await createFieldIfNotExists("skipped_events", "datetime", "dateTime", {
    interface: "datetime",
  }, { is_nullable: true });
}

async function setupLanguagesCollection(): Promise<void> {
  if (await collectionExists("languages")) {
    console.log(`Collection "languages" already exists, skipping.`);
    return;
  }
  // Create languages with a custom primary key (code)
  await directusPost("/collections", {
    collection: "languages",
    meta: { singleton: false },
    schema: {},
    fields: [
      {
        field: "code",
        type: "string",
        schema: { is_primary_key: true, max_length: 10, is_nullable: false },
        meta: { interface: "input", required: true },
      },
      {
        field: "name",
        type: "string",
        schema: { max_length: 255, is_nullable: false },
        meta: { interface: "input" },
      },
    ],
  });
  console.log(`Created collection "languages" with code (PK) and name fields.`);
}

async function setupEventsTranslationsCollection(): Promise<void> {
  await createCollectionIfNotExists("events_translations", { singleton: false });

  await createFieldIfNotExists("events_translations", "events_id", "integer", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true });

  await createFieldIfNotExists("events_translations", "languages_code", "string", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true, max_length: 10 });

  await createFieldIfNotExists("events_translations", "title", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 512 });

  await createFieldIfNotExists("events_translations", "description", "text", {
    interface: "input-multiline",
  }, { is_nullable: true });

  await createFieldIfNotExists("events_translations", "parts_translations", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });

  await createFieldIfNotExists("events_translations", "info_translations", "json", {
    interface: "input-code",
    options: { language: "json" },
  }, { is_nullable: true });
}

async function setupTranslationsRelation(): Promise<void> {
  // Check if relation already exists
  try {
    const data = await directusGet("/relations/events/translations") as { data?: unknown };
    if (data?.data) {
      console.log(`Relation "events.translations" already exists, skipping.`);
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  // Create the translations field on events (O2M list interface for browsable translations)
  await createFieldIfNotExists("events", "translations", "alias", {
    interface: "list-o2m",
    options: {
      template: "{{languages_code}} — {{title}}",
      enableCreate: false,
      enableSelect: false,
    },
    display: "related-values",
    display_options: {
      template: "{{languages_code}} — {{title}}",
    },
    special: ["translations"],
  }, null);

  // Create the O2M relation from events to events_translations
  try {
    await directusPost("/relations", {
      collection: "events_translations",
      field: "events_id",
      related_collection: "events",
      meta: {
        one_collection: "events",
        many_collection: "events_translations",
        many_field: "events_id",
        one_field: "translations",
        one_collection_field: null,
        one_allowed_collections: null,
        junction_field: "languages_code",
        sort_field: null,
      },
      schema: {
        on_delete: "CASCADE",
      },
    });
    console.log(`Created relation events <-> events_translations.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      console.log(`Relation events <-> events_translations already exists, skipping.`);
    } else {
      throw err;
    }
  }

  // Create the M2O relation from events_translations to languages
  try {
    await directusPost("/relations", {
      collection: "events_translations",
      field: "languages_code",
      related_collection: "languages",
      meta: {
        one_collection: "languages",
        many_collection: "events_translations",
        many_field: "languages_code",
        one_field: null,
      },
      schema: {},
    });
    console.log(`Created relation events_translations <-> languages.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      console.log(`Relation events_translations <-> languages already exists, skipping.`);
    } else {
      throw err;
    }
  }
}

async function setupVenueRelation(): Promise<void> {
  // Check if relation already exists
  try {
    const data = await directusGet("/relations/events/venue") as { data?: unknown };
    if (data?.data) {
      console.log(`Relation "events.venue" already exists, skipping.`);
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  try {
    await directusPost("/relations", {
      collection: "events",
      field: "venue",
      related_collection: "venues",
      meta: {
        one_collection: "venues",
        many_collection: "events",
        many_field: "venue",
        one_field: null,
      },
      schema: {
        on_delete: "SET NULL",
      },
    });
    console.log(`Created relation events.venue -> venues.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      console.log(`Relation events.venue -> venues already exists, skipping.`);
    } else {
      throw err;
    }
  }
}


async function seedLanguages(): Promise<void> {
  const languages = [
    { code: "cs", name: "Čeština" },
    { code: "en", name: "English" },
    { code: "es", name: "Español" },
  ];

  for (const lang of languages) {
    try {
      const existing = await directusGet(`/items/languages/${lang.code}`) as { data?: unknown };
      if (existing?.data) {
        console.log(`Language "${lang.code}" already exists, skipping.`);
        continue;
      }
    } catch {
      // Not found, create it
    }
    try {
      await directusPost("/items/languages", lang);
      console.log(`Seeded language "${lang.code}" (${lang.name}).`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      if (msg.includes("already exists") || msg.includes("409") || msg.includes("unique")) {
        console.log(`Language "${lang.code}" already exists, skipping.`);
      } else {
        throw err;
      }
    }
  }
}

async function main(): Promise<void> {
  if (!DIRECTUS_BASE_URL || !DIRECTUS_ACCESS_TOKEN) {
    throw new Error("DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set in .env");
  }

  console.log("Setting up Directus collections...\n");

  await setupEventsCollection();
  await setupVenuesCollection();
  await setupGroupsCollection();
  await setupErrorsCollection();
  await setupSkippedEventsCollection();
  await setupLanguagesCollection();
  await setupEventsTranslationsCollection();
  await setupTranslationsRelation();
  await setupVenueRelation();
  await seedLanguages();

  console.log("\nDirectus setup complete.");
}

// Export the promise so tests can await full completion before inspecting side effects.
export const ready = main().catch((err) => {
  console.error("Setup failed:", err);
  process.exit(1);
});
