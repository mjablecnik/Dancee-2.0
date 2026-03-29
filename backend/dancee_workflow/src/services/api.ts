import * as restate from "@restatedev/restate-sdk";
import { listEvents } from "../clients/directus-client";
import { config } from "../core/config";
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
      let filter: Record<string, unknown> | undefined;
      const filterHeader = ctx.request().headers.get("x-dancee-filter");
      if (filterHeader) {
        try {
          filter = JSON.parse(filterHeader) as Record<string, unknown>;
        } catch {
          // Invalid JSON in filter header — fall through to default
        }
      }
      const events = await listEvents(filter ?? { status: { _eq: "published" } });
      return events;
    },
  },
});

export type ApiService = typeof apiService;
