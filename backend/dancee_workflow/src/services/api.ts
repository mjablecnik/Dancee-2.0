import * as restate from "@restatedev/restate-sdk";
import { listPublishedEvents } from "../clients/directus-client";
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

      // Use a deterministic workflow key derived from the normalised URL.
      // This way Restate deduplicates: if the same URL was already processed
      // (or is in progress), it returns the existing result instead of
      // starting a new workflow. If the previous run failed, Restate resumes
      // from the last successful step.
      const normalizedUrl = normalizeEventUrl(request.url);
      const workflowKey = normalizedUrl
        .replace(/[^a-zA-Z0-9]/g, "_")
        .slice(0, 128);
      const result = await ctx
        .workflowClient<EventWorkflow>({ name: "EventWorkflow" }, workflowKey)
        .run(request.url);

      return result;
    },

    processBatch: async (ctx: restate.Context) => {
      ctx
        .serviceSendClient<BatchService>({ name: "BatchService" })
        .processAll();

      return { acknowledged: true, message: "Batch processing started" };
    },

    listEvents: async (ctx: restate.Context) => {
      // Always enforce the published-only restriction via listPublishedEvents.
      // The extraFilter is merged inside listPublishedEvents using _and so that
      // status:published is always enforced regardless of caller input.
      const filterHeader = ctx.request().headers.get("x-dancee-filter");
      let extraFilter: Record<string, unknown> | undefined;
      if (filterHeader) {
        try {
          const parsed = JSON.parse(filterHeader) as Record<string, unknown>;
          extraFilter = sanitizeFilter(parsed);
        } catch {
          // Invalid JSON in filter header — fall through to published-only default
          log({ level: "warn", message: "listEvents: x-dancee-filter header contains invalid JSON, ignoring filter", header: filterHeader });
        }
      }

      const includeOriginal = ctx.request().headers.get("x-dancee-include") === "original_description";

      const events = await listPublishedEvents(extraFilter);

      // Strip the potentially large original_description by default.
      // Clients can request it via the x-dancee-include: original_description header.
      if (!includeOriginal) {
        return events.map(({ original_description, ...rest }) => rest);
      }

      return events;
    },
  },
});

export type ApiService = typeof apiService;
