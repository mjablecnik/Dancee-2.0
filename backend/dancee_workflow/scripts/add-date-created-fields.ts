import * as dotenv from "dotenv";

dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";

const fieldPayload = {
  field: "date_created",
  type: "timestamp",
  meta: {
    special: ["date-created"],
    interface: "datetime",
    display: "datetime",
    readonly: true,
    hidden: false,
    width: "half",
  },
  schema: {
    default_value: null,
  },
};

async function addField(collection: string): Promise<void> {
  const url = `${DIRECTUS_BASE_URL}/fields/${collection}`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
    },
    body: JSON.stringify(fieldPayload),
  });

  if (res.ok) {
    console.log(`✅ Added date_created to ${collection}`);
  } else {
    const text = await res.text().catch(() => "");
    if (text.includes("already exists") || res.status === 400) {
      console.log(`⏭️  date_created already exists on ${collection}, skipping`);
    } else {
      console.error(`❌ Failed to add date_created to ${collection} (${res.status}): ${text}`);
    }
  }
}

async function main() {
  if (!DIRECTUS_BASE_URL || !DIRECTUS_ACCESS_TOKEN) {
    console.error("Missing DIRECTUS_BASE_URL or DIRECTUS_ACCESS_TOKEN in .env");
    process.exit(1);
  }

  console.log(`Directus: ${DIRECTUS_BASE_URL}\n`);
  await addField("events");
  await addField("courses");
}

main();
