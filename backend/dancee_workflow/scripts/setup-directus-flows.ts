/**
 * Creates Directus Flows for reprocessing events from the admin UI.
 * Each flow adds a manual trigger button in the Events detail view.
 *
 * Usage:
 *   bun run scripts/setup-directus-flows.ts
 *   bun run scripts/setup-directus-flows.ts --clean
 */

import * as dotenv from "dotenv";
dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";
const WORKFLOW_BASE_URL = process.env.WORKFLOW_BASE_URL ?? "https://dancee-workflow.fly.dev";

if (!DIRECTUS_BASE_URL || !DIRECTUS_ACCESS_TOKEN) {
  console.error("Error: DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set.");
  process.exit(1);
}

const headers = {
  "Content-Type": "application/json",
  Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
};

async function api(method: string, path: string, body?: unknown) {
  const res = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    method,
    headers,
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const json = await res.json().catch(() => null);
  if (!res.ok) {
    throw new Error(`${method} ${path} failed (${res.status}): ${JSON.stringify(json)}`);
  }
  return json as { data: Record<string, unknown> };
}

const FLOW_NAMES = ["Reprocess All", "Retranslate", "Re-extract Parts", "Re-extract Info"];

async function clean() {
  console.log("Cleaning existing reprocess flows...");
  const res = await api("GET", "/flows?fields=id,name&limit=-1");
  const flows = (res.data as unknown) as { id: string; name: string }[];
  for (const flow of flows) {
    if (FLOW_NAMES.includes(flow.name)) {
      console.log(`  Deleting: ${flow.name} (${flow.id})`);
      await api("DELETE", `/flows/${flow.id}`);
    }
  }
  console.log("Clean done.\n");
}

interface FlowDef {
  name: string;
  icon: string;
  color: string;
  steps: string[];
  description: string;
}

async function createFlow(def: FlowDef) {
  console.log(`Creating flow: ${def.name}...`);

  const flowRes = await api("POST", "/flows", {
    name: def.name,
    description: def.description,
    icon: def.icon,
    color: def.color,
    status: "active",
    trigger: "manual",
    options: {
      collections: ["events"],
      location: "item",
      requireConfirmation: true,
      confirmationDescription: `Are you sure you want to run: ${def.name}?`,
    },
  });

  const flowId = flowRes.data.id as string;
  console.log(`  Flow created: ${flowId}`);

  // The body must be a JSON string that Directus will send as the webhook payload.
  // {{$trigger.body.keys[0]}} is a Directus template variable resolved at runtime.
  const webhookBody = JSON.stringify({
    id: "{{$trigger.body.keys[0]}}",
    steps: def.steps,
  });

  const opRes = await api("POST", "/operations", {
    name: "Call Reprocess API",
    key: "reprocess_webhook",
    type: "request",
    flow: flowId,
    position_x: 19,
    position_y: 1,
    options: {
      method: "POST",
      url: `${WORKFLOW_BASE_URL}/api/event/reprocess`,
      headers: [{ header: "Content-Type", value: "application/json" }],
      body: webhookBody,
    },
  });

  const opId = opRes.data.id as string;

  // Link operation as the first step of the flow
  await api("PATCH", `/flows/${flowId}`, { operation: opId });
  console.log(`  Operation linked: ${opId}`);
}

async function main() {
  if (process.argv.includes("--clean")) {
    await clean();
  }

  const flows: FlowDef[] = [
    {
      name: "Reprocess All",
      icon: "autorenew",
      color: "#6644FF",
      steps: ["parts", "info", "translations", "dances"],
      description: "Re-extract parts, info, translations, and dances",
    },
    {
      name: "Retranslate",
      icon: "translate",
      color: "#2ECDA7",
      steps: ["translations"],
      description: "Re-translate event to CS, EN, and ES",
    },
    {
      name: "Re-extract Parts",
      icon: "category",
      color: "#FFA439",
      steps: ["parts", "dances"],
      description: "Re-extract event parts and recompute dances",
    },
    {
      name: "Re-extract Info",
      icon: "info",
      color: "#3399FF",
      steps: ["info"],
      description: "Re-extract event info (prices, URLs)",
    },
  ];

  for (const flow of flows) {
    await createFlow(flow);
  }

  console.log("\nDone. Flows are available in the Events detail view toolbar.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
