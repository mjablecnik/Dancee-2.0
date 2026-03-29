import * as restate from "@restatedev/restate-sdk";
import { scrapeEvent } from "../clients/scraper-client";
import { findEventByOriginalUrl, createEvent } from "../clients/directus-client";
import { classifyEventType, extractEventParts, extractEventInfo } from "./event-parser";
import { translateEventContent } from "./event-translator";
import { resolveVenue } from "./venue-resolver";
import { computeDances, SUPPORTED_EVENT_TYPES, toIsoOrNull } from "../core/schemas";
import { captureError } from "../core/config";
import type { DirectusEvent, DirectusEventTranslation } from "../core/schemas";

function computeTranslationStatus(
  translations: DirectusEventTranslation[],
): "complete" | "partial" | "missing" {
  const codes = translations.map((t) => t.languages_code);
  const hasCs = codes.includes("cs");
  const hasEn = codes.includes("en");
  const hasEs = codes.includes("es");
  if (hasCs && hasEn && hasEs) return "complete";
  if (hasCs || hasEn || hasEs) return "partial";
  return "missing";
}

export const eventWorkflow = restate.workflow({
  name: "EventWorkflow",
  handlers: {
    run: async (ctx: restate.WorkflowContext, eventUrl: string) => {
      ctx.set("url", eventUrl);
      ctx.set("status", "started");

      // Step 1: Scrape event
      let facebookEvent;
      try {
        facebookEvent = await ctx.run("scrape", () => scrapeEvent(eventUrl));
      } catch (err) {
        captureError(err instanceof Error ? err : new Error(String(err)), {
          workflowRunId: ctx.key,
          eventUrl,
          step: "scrape",
        });
        throw err;
      }
      ctx.set("status", "scraped");

      // Step 2: Classify event type
      const description = facebookEvent.description ?? facebookEvent.name;
      let eventType;
      try {
        eventType = await ctx.run("classify", () => classifyEventType(description));
      } catch (err) {
        captureError(err instanceof Error ? err : new Error(String(err)), {
          workflowRunId: ctx.key,
          eventUrl,
          step: "classify",
        });
        throw err;
      }

      // Step 3: Skip if unsupported type
      if (!(SUPPORTED_EVENT_TYPES as readonly string[]).includes(eventType)) {
        ctx.set("status", "skipped");
        ctx.set("skipReason", `Unsupported event type: ${eventType}`);
        console.log(`Skipping event ${eventUrl}: unsupported type "${eventType}"`);
        return null;
      }

      // Step 4: Extract event parts (Czech output)
      let extracted;
      try {
        extracted = await ctx.run("extractParts", () => extractEventParts(description));
      } catch (err) {
        captureError(err instanceof Error ? err : new Error(String(err)), {
          workflowRunId: ctx.key,
          eventUrl,
          step: "extractParts",
        });
        throw err;
      }

      // Step 5: Extract event info
      let info;
      try {
        info = await ctx.run("extractInfo", () => extractEventInfo(description));
      } catch (err) {
        captureError(err instanceof Error ? err : new Error(String(err)), {
          workflowRunId: ctx.key,
          eventUrl,
          step: "extractInfo",
        });
        throw err;
      }

      // Step 6: Resolve venue
      let venue = null;
      if (facebookEvent.location) {
        try {
          venue = await ctx.run("resolveVenue", () => resolveVenue(facebookEvent.location!));
        } catch (err) {
          captureError(err instanceof Error ? err : new Error(String(err)), {
            workflowRunId: ctx.key,
            eventUrl,
            step: "resolveVenue",
          });
          throw err;
        }
      }

      // Step 7: Derive organizer
      const organizer = facebookEvent.hosts?.[0]?.name ?? facebookEvent.name;

      // Step 8: Check for duplicate
      const originalUrl = facebookEvent.url ?? eventUrl;
      let existing;
      try {
        existing = await ctx.run("checkDuplicate", () =>
          findEventByOriginalUrl(originalUrl)
        );
      } catch (err) {
        captureError(err instanceof Error ? err : new Error(String(err)), {
          workflowRunId: ctx.key,
          eventUrl: originalUrl,
          step: "checkDuplicate",
        });
        throw err;
      }
      if (existing) {
        ctx.set("status", "duplicate");
        console.log(`Event already exists: ${originalUrl}`);
        return existing;
      }

      // Step 9: Translate to EN and ES
      const contentInput = {
        title: extracted.title,
        description: extracted.description,
        parts: extracted.parts,
        info,
      };

      const translations: DirectusEventTranslation[] = [
        {
          languages_code: "cs",
          title: extracted.title,
          description: extracted.description,
          parts_translations: extracted.parts.map((p) => ({
            name: p.name,
            description: p.description,
          })),
          info_translations: info.map((i) => ({ key: i.key })),
        },
      ];

      const translationLanguages = [
        { code: "en", name: "English" },
        { code: "es", name: "Spanish" },
      ];

      for (const lang of translationLanguages) {
        try {
          const translated = await ctx.run(`translate_${lang.code}`, () =>
            translateEventContent(contentInput, lang.name)
          );
          translations.push({
            languages_code: lang.code,
            title: translated.title,
            description: translated.description,
            parts_translations: translated.parts_translations,
            info_translations: translated.info_translations,
          });
        } catch (err) {
          console.error(`Translation to ${lang.code} failed for ${originalUrl}:`, err);
          captureError(err instanceof Error ? err : new Error(String(err)), {
            workflowRunId: ctx.key,
            eventUrl: originalUrl,
            step: `translate_${lang.code}`,
          });
          // Continue with remaining languages
        }
      }

      // Step 10: Compute dances and translation_status
      const dances = computeDances(extracted.parts);
      const translationStatus = computeTranslationStatus(translations);

      // Step 11: Build and store event
      const startTime = toIsoOrNull(facebookEvent.startTimestamp ?? undefined);
      if (startTime === null) {
        throw new restate.TerminalError(`Invalid startTimestamp for event ${originalUrl}`);
      }
      const endTime = toIsoOrNull(facebookEvent.endTimestamp ?? undefined);

      const newEvent: DirectusEvent = {
        original_description: facebookEvent.description ?? "",
        organizer,
        venue: venue?.id ?? null,
        start_time: startTime,
        end_time: endTime,
        timezone: facebookEvent.timezone ?? "UTC",
        original_url: originalUrl,
        parts: extracted.parts,
        info,
        dances,
        status: "published",
        translation_status: translationStatus,
        translations,
      };

      let createdEvent;
      try {
        createdEvent = await ctx.run("createEvent", () => createEvent(newEvent));
      } catch (err) {
        captureError(err instanceof Error ? err : new Error(String(err)), {
          workflowRunId: ctx.key,
          eventUrl: originalUrl,
          step: "createEvent",
        });
        throw err;
      }
      ctx.set("status", "completed");
      ctx.set("eventId", String(createdEvent.id ?? ""));

      return createdEvent;
    },
  },
});

export type EventWorkflow = typeof eventWorkflow;
