import * as restate from "@restatedev/restate-sdk";
import { listPublishedEvents } from "../clients/directus-client";
import { config } from "../core/config";
import { log } from "../core/logger";
import type { EventWorkflow } from "./workflow";
import type { BatchService } from "./batch";

export const corsOrigins = config.corsOrigins;

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

      const workflowKey = ctx.rand.uuidv4();
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
          extraFilter = JSON.parse(filterHeader) as Record<string, unknown>;
        } catch {
          // Invalid JSON in filter header — fall through to published-only default
          log({ level: "warn", message: "listEvents: x-dancee-filter header contains invalid JSON, ignoring filter", header: filterHeader });
        }
      }

      const events = await listPublishedEvents(extraFilter);
      return events;
    },
  },
});

export type ApiService = typeof apiService;
