import * as restate from "@restatedev/restate-sdk";
import {
  getGroupsOrderedByUpdatedAt,
  updateGroupTimestamp,
  findEventByOriginalUrl,
  createError,
  findErrorByUrl,
} from "../clients/directus-client";
import { scrapeEventList } from "../clients/scraper-client";
import { captureError } from "../core/config";
import type { EventWorkflow } from "./workflow";

export const batchService = restate.service({
  name: "BatchService",
  handlers: {
    processAll: async (ctx: restate.Context) => {
      const groups = await ctx.run("getGroups", () => getGroupsOrderedByUpdatedAt());

      for (const group of groups) {
        const groupId = String(group.id ?? group.url);
        try {
          const events = await ctx.run(`scrapeGroup_${groupId}`, () =>
            scrapeEventList(group.url)
          );

          for (const event of events) {
            const eventUrl = event.url ?? `https://www.facebook.com/events/${event.id}`;

            // Duplicate check errors propagate to Restate for retry — a transient
            // Directus failure here should not cause the event to be permanently skipped.
            const existing = await ctx.run(`checkEvent_${event.id}`, () =>
              findEventByOriginalUrl(eventUrl)
            );

            if (!existing) {
              try {
                const workflowKey = ctx.rand.uuidv4();
                ctx
                  .workflowSendClient<EventWorkflow>({ name: "EventWorkflow" }, workflowKey)
                  .run(eventUrl);
              } catch (err) {
                console.error(`Failed to process event ${eventUrl}:`, err);
                captureError(err instanceof Error ? err : new Error(String(err)), {
                  groupId,
                  eventUrl,
                  step: "processEvent",
                });
                const existingError = await ctx.run(`checkError_${event.id}`, () =>
                  findErrorByUrl(eventUrl)
                );
                if (!existingError) {
                  const errorDatetime = await ctx.run(`errorDatetime_${event.id}`, () => new Date().toISOString());
                  await ctx.run(`createError_${event.id}`, () =>
                    createError({
                      url: eventUrl,
                      message: err instanceof Error ? err.message : String(err),
                      datetime: errorDatetime,
                    })
                  );
                }
              }
            }
          }

          if (group.id !== undefined) {
            const groupTimestamp = await ctx.run(`groupTimestamp_${groupId}`, () => new Date().toISOString());
            await ctx.run(`updateGroup_${groupId}`, () =>
              updateGroupTimestamp(group.id!, groupTimestamp)
            );
          } else {
            console.warn(`Skipping timestamp update for group without id: ${group.url}`);
          }
        } catch (err) {
          console.error(`Failed to process group ${group.url}:`, err);
          captureError(err instanceof Error ? err : new Error(String(err)), { groupId, step: "processGroup" });
        }
      }

      return { processed: groups.length };
    },
  },
});

export type BatchService = typeof batchService;
