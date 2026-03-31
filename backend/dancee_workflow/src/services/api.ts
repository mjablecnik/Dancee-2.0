import * as restate from "@restatedev/restate-sdk";
import { listPublishedEvents, findEventByOriginalUrl } from "../clients/directus-client";
import { config } from "../core/config";
import { log } from "../core/logger";
import { normalizeEventUrl } from "../core/utils";
import type { EventWorkflow } from "./workflow";
import type { BatchService } from "./batch";

export const corsOrigins = config.corsOrigins;

// Only these top-level filter fields are allowed from client input.
// This prevents clients from crafting filters that bypass the published-only
// restriction or target internal/sensitive fields (e.g. status, translations).
const ALLOWED_FILTER_FIELDS = new Set([
  "dances",
  "start_time",
  "end_time",
  "venue",
  "organizer",
  "translation_status",
]);

/**
 * Strips any filter keys that are not in the allowed set.
 * Returns undefined if no valid keys remain.
 */
export function sanitizeFilter(
  raw: Record<string, unknown>,
): Record<string, unknown> | undefined {
  const sanitized: Record<string, unknown> = {};
  for (const key of Object.keys(raw)) {
    if (ALLOWED_FILTER_FIELDS.has(key)) {
      sanitized[key] = raw[key];
    } else {
      log({ level: "warn", message: `sanitizeFilter: dropping disallowed filter field "${key}"` });
    }
  }
  return Object.keys(sanitized).length > 0 ? sanitized : undefined;
}

export const apiService = restate.service({
  name: "ApiService",
  handlers: {
    processEvent: async (
      ctx: restate.Context,
      request: { url?: string },
    ) => {
      if (!request?.url) {
        throw new restate.TerminalError(
          "Missing required field: 'url'",
          { errorCode: 400 },
        );
      }

      const normalizedUrl = normalizeEventUrl(request.url);
      const workflowKey = normalizedUrl
        .replace(/[^a-zA-Z0-9]/g, "_")
        .slice(0, 128);

      const wfClient = ctx.workflowClient<EventWorkflow>({ name: "EventWorkflow" }, workflowKey);

      try {
        const result = await wfClient.run(request.url);
        return result;
      } catch (err) {
        // 409 means the workflow was already invoked with this key.
        // Look up the event in Directus instead of failing.
        if (err instanceof restate.TerminalError && err.code === 409) {
          log({ level: "info", message: "Workflow already invoked, checking Directus for existing event", url: request.url });
          const existing = await ctx.run("lookupExisting", () =>
            findEventByOriginalUrl(normalizedUrl)
          );
          if (existing) {
            return existing;
          }
          // Workflow ran but event not in Directus (maybe it was skipped or failed)
          return { status: "already_processing" as const, url: request.url };
        }
        throw err;
      }
    },

    processBatch: async (ctx: restate.Context) => {
      ctx
        .serviceSendClient<BatchService>({ name: "BatchService" })
        .processAll();

      return { acknowledged: true, message: "Batch processing started" };
    },

    listEvents: async (ctx: restate.Context) => {
      const filterHeader = ctx.request().headers.get("x-dancee-filter");
      let extraFilter: Record<string, unknown> | undefined;
      if (filterHeader) {
        try {
          const parsed = JSON.parse(filterHeader) as Record<string, unknown>;
          extraFilter = sanitizeFilter(parsed);
        } catch {
          log({ level: "warn", message: "listEvents: x-dancee-filter header contains invalid JSON, ignoring filter", header: filterHeader });
        }
      }

      const includeOriginal = ctx.request().headers.get("x-dancee-include") === "original_description";
      const lang = ctx.request().headers.get("x-dancee-lang"); // e.g. "cs", "en", "es"

      const events = await listPublishedEvents(extraFilter);

      return events.map((event) => {
        const { original_description, translations, ...rest } = event;

        // If a language is requested, find the matching translation and flatten
        // its fields (title, description) onto the event object.
        let translatedFields: Record<string, unknown> = {};
        if (lang && Array.isArray(translations)) {
          const match = translations.find(
            (t) => typeof t === "object" && t !== null && "languages_code" in t && t.languages_code === lang,
          );
          if (match && typeof match === "object" && "title" in match) {
            const { languages_code, events_id, id: _tid, ...fields } = match as Record<string, unknown>;
            translatedFields = fields;
          }
        }

        return {
          ...rest,
          ...translatedFields,
          ...(includeOriginal ? { original_description } : {}),
          // Keep translations array only when no specific language is requested
          ...(lang ? {} : { translations }),
        };
      });
    },
  },
});

export type ApiService = typeof apiService;
