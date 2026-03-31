import * as restate from "@restatedev/restate-sdk";
import {
  getGroupsOrderedByUpdatedAt,
  updateGroupTimestamp,
  findEventByOriginalUrl,
  createError,
} from "../clients/directus-client";
import { scrapeEventList, buildFacebookEventUrl } from "../clients/scraper-client";
import { captureError } from "../core/config";
import { log } from "../core/logger";
import { normalizeEventUrl } from "../core/utils";
import type { EventWorkflow } from "./workflow";

export const batchService = restate.service({
  name: "BatchService",
  handlers: {
    processAll: async (ctx: restate.Context) => {
      const groups = await ctx.run("getGroups", () => getGroupsOrderedByUpdatedAt());

      let eventsScheduled = 0;
      let schedulingErrors = 0;

      for (const group of groups) {
        const groupId = String(group.id ?? group.url);
        try {
          const events = await ctx.run(`scrapeGroup_${groupId}`, () =>
            scrapeEventList(group.url)
          );

          log({ level: "info", message: `Processing group: ${events.length} event(s) found from scraper`, url: group.url });

          // Track URLs already seen in this batch run to avoid scheduling
          // duplicate workflows for sibling (recurring) events.
          const seenUrls = new Set<string>();

          let groupScheduled = 0;
          for (const event of events) {
            const rawUrl = event.url ?? buildFacebookEventUrl(event.id);
            const eventUrl = normalizeEventUrl(rawUrl);

            // Skip if we already processed this normalised URL in this batch
            if (seenUrls.has(eventUrl)) {
              log({ level: "info", message: "Skipping sibling event (already seen in batch)", url: eventUrl });
              continue;
            }
            seenUrls.add(eventUrl);

            // Duplicate check errors propagate to Restate for retry — a transient
            // Directus failure here should not cause the event to be permanently skipped.
            const existing = await ctx.run(`checkEvent_${event.id}`, () =>
              findEventByOriginalUrl(eventUrl)
            );

            if (!existing) {
              const workflowKey = ctx.rand.uuidv4();
              // Fire-and-forget pattern (Requirement 10.5 trade-off):
              // workflowSendClient schedules the EventWorkflow asynchronously without
              // awaiting completion. Per-event execution errors are handled inside the
              // EventWorkflow's own catch block, which writes failures to the Directus
              // errors collection and re-throws to let Restate retry. Scheduling errors
              // (e.g. a Restate infrastructure failure) are caught here and tracked in
              // Directus explicitly to satisfy Requirement 10.5.
              try {
                ctx
                  .workflowSendClient<EventWorkflow>({ name: "EventWorkflow" }, workflowKey)
                  .run(eventUrl);
                eventsScheduled++;
                groupScheduled++;
              } catch (scheduleErr) {
                schedulingErrors++;
                const error = scheduleErr instanceof Error ? scheduleErr : new Error(String(scheduleErr));
                captureError(error, { eventUrl, step: "scheduleEventWorkflow" });
                await ctx.run(`scheduleError_${event.id}`, () =>
                  createError({ url: eventUrl, message: error.message })
                );
              }
            }
          }

          log({ level: "info", message: `Group processed: scheduled ${groupScheduled} new workflow(s) out of ${events.length} event(s)`, url: group.url });

          if (group.id !== undefined) {
            const groupTimestamp = await ctx.run(`groupTimestamp_${groupId}`, () => new Date().toISOString());
            await ctx.run(`updateGroup_${groupId}`, () =>
              updateGroupTimestamp(group.id!, groupTimestamp)
            );
          } else {
            log({ level: "warn", message: `Skipping timestamp update for group without id: ${group.url}` });
          }
        } catch (err) {
          log({ level: "error", message: `Failed to process group`, url: group.url, error: String(err) });
          captureError(err instanceof Error ? err : new Error(String(err)), { groupId, step: "processGroup" });
          await ctx.run(`groupError_${groupId}`, () =>
            createError({ url: group.url, message: String(err) })
          );
        }
      }

      return { groups: groups.length, eventsScheduled, schedulingErrors };
    },

    processSingle: async (ctx: restate.Context, groupUrl: string) => {
      let events: Awaited<ReturnType<typeof scrapeEventList>>;
      try {
        events = await ctx.run("scrapeGroup", () => scrapeEventList(groupUrl));
      } catch (err) {
        const error = err instanceof Error ? err : new Error(String(err));
        log({ level: "error", message: "Failed to scrape group", url: groupUrl, error: error.message });
        captureError(error, { groupUrl, step: "scrapeGroup" });
        await ctx.run("scrapeGroupError", () =>
          createError({ url: groupUrl, message: error.message })
        );
        throw err;
      }

      log({ level: "info", message: `Processing single group: ${events.length} event(s) found`, url: groupUrl });

      const seenUrls = new Set<string>();
      let eventsScheduled = 0;

      for (const event of events) {
        const rawUrl = event.url ?? buildFacebookEventUrl(event.id);
        const eventUrl = normalizeEventUrl(rawUrl);

        if (seenUrls.has(eventUrl)) continue;
        seenUrls.add(eventUrl);

        let existing;
        try {
          existing = await ctx.run(`checkEvent_${event.id}`, () =>
            findEventByOriginalUrl(eventUrl)
          );
        } catch (err) {
          const error = err instanceof Error ? err : new Error(String(err));
          log({ level: "error", message: "Failed to check duplicate event", url: eventUrl, error: error.message });
          captureError(error, { eventUrl, step: "checkEvent" });
          await ctx.run(`checkEventError_${event.id}`, () =>
            createError({ url: eventUrl, message: `Duplicate check failed: ${error.message}` })
          );
          continue;
        }

        if (!existing) {
          const workflowKey = ctx.rand.uuidv4();
          try {
            ctx
              .workflowSendClient<EventWorkflow>({ name: "EventWorkflow" }, workflowKey)
              .run(eventUrl);
            eventsScheduled++;
          } catch (err) {
            const error = err instanceof Error ? err : new Error(String(err));
            captureError(error, { eventUrl, step: "scheduleEventWorkflow" });
            await ctx.run(`scheduleError_${event.id}`, () =>
              createError({ url: eventUrl, message: error.message })
            );
          }
        }
      }

      return { eventsFound: events.length, eventsScheduled };
    },
  },
});

export type BatchService = typeof batchService;
