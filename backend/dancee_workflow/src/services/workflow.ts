import * as restate from "@restatedev/restate-sdk";
import { scrapeEvent } from "../clients/scraper-client";
import { findEventByOriginalUrl, createEvent, createError, createSkippedEvent } from "../clients/directus-client";
import { classifyEventType, extractEventParts, extractEventInfo } from "./event-parser";
import { translateEventContent } from "./event-translator";
import { resolveVenue } from "./venue-resolver";
import { computeDances, SUPPORTED_EVENT_TYPES, toIsoOrNull } from "../core/schemas";
import { convertToLocalTime } from "../core/timezone";
import { captureError } from "../core/config";
import { log } from "../core/logger";
import { normalizeEventUrl } from "../core/utils";
import type { DirectusEvent, DirectusEventTranslation, ErrorType } from "../core/schemas";

/**
 * Determines the error type based on the workflow step name and error message.
 */
function classifyErrorType(stepName: string, message: string): ErrorType {
  if (stepName === "scrape") {
    // Distinguish between "no data" (scrape_failed) and "bad data shape" (parse_failed)
    const lower = message.toLowerCase();
    if (lower.includes("parse") || lower.includes("invalid_union") || lower.includes("expected")) {
      return "parse_failed";
    }
    return "scrape_failed";
  }
  if (stepName === "classify" || stepName === "extractParts" || stepName === "extractInfo") {
    return "llm_parse_failed";
  }
  return "workflow_failed";
}

/**
 * Wraps ctx.run with consistent captureError + rethrow handling.
 * All workflow steps that should abort on failure use this helper
 * instead of repeating the same try/catch boilerplate.
 */
async function runStep<T>(
  ctx: restate.WorkflowContext,
  stepName: string,
  eventUrl: string,
  fn: () => Promise<T>,
): Promise<T> {
  try {
    return await ctx.run(stepName, fn);
  } catch (err) {
    const original = err instanceof Error ? err : new Error(String(err));
    captureError(original, {
      workflowRunId: ctx.key,
      eventUrl,
      step: stepName,
    });
    // Enrich the error message with URL context so downstream handlers
    // (Directus error records, logs) always show which URL failed.
    const enriched = new Error(`[${eventUrl}] ${stepName}: ${original.message}`);
    enriched.cause = original;
    (enriched as any).stepName = stepName;
    throw enriched;
  }
}

export function computeTranslationStatus(
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

      try {
      return await runWorkflow(ctx, eventUrl);
      } catch (err) {
        // Track the failure in Directus so the batch service can observe it
        // without needing to await the fire-and-forget workflowSendClient call.
        // createError handles upsert — inserts new or updates existing row for this URL.
        const message = err instanceof Error ? err.message : String(err);
        const stepName = (err as any)?.stepName ?? "unknown";
        const errorType = classifyErrorType(stepName, message);
        await ctx.run("createError", () =>
          createError({
            url: eventUrl,
            message,
            type: errorType,
          })
        );
        throw err;
      }
    },
  },
});

async function runWorkflow(ctx: restate.WorkflowContext, eventUrl: string) {
      // Step 1: Scrape event
      const facebookEvent = await runStep(ctx, "scrape", eventUrl, () => scrapeEvent(eventUrl));
      ctx.set("status", "scraped");

      // Step 1b: Early validation — reject events with invalid startTimestamp before
      // any LLM or external API calls to avoid wasting resources.
      if (facebookEvent.startTimestamp <= 0) {
        throw new restate.TerminalError(
          `[${eventUrl}] Invalid startTimestamp: value must be positive`,
        );
      }

      // Step 1c: Early duplicate check — run right after scraping to avoid
      // wasting LLM calls and external API requests on events we already have.
      const originalUrl = normalizeEventUrl(facebookEvent.url);
      const existing = await runStep(ctx, "checkDuplicate", originalUrl, () =>
        findEventByOriginalUrl(originalUrl)
      );
      if (existing) {
        ctx.set("status", "duplicate");
        log({ level: "info", message: "Event already exists, skipping", url: originalUrl });
        return existing;
      }

      // Step 2: Classify event type
      const description = facebookEvent.description ?? facebookEvent.name;
      const eventType = await runStep(ctx, "classify", eventUrl, () => classifyEventType(description));

      // Step 3: Skip if unsupported type — save to skipped_events so we never
      // scrape/classify this URL again in future batch runs.
      if (!(SUPPORTED_EVENT_TYPES as readonly string[]).includes(eventType)) {
        const skipReason = `Unsupported event type: ${eventType}`;
        await runStep(ctx, "createSkipped", eventUrl, () =>
          createSkippedEvent({
            original_url: normalizeEventUrl(facebookEvent.url),
            reason: skipReason,
            event_type: eventType,
          })
        );
        ctx.set("status", "skipped");
        ctx.set("skipReason", skipReason);
        log({ level: "info", message: `Skipping event: unsupported type "${eventType}"`, url: eventUrl, reason: skipReason });
        return { status: "skipped" as const, reason: skipReason };
      }

      // Compute event times early — needed by parts extraction for date context
      const startTimeUtc = toIsoOrNull(facebookEvent.startTimestamp) as string;
      const endTimeUtc = toIsoOrNull(facebookEvent.endTimestamp ?? undefined);
      const eventTimezone = facebookEvent.timezone ?? "UTC";
      const startTime = convertToLocalTime(startTimeUtc, eventTimezone);
      const endTime = endTimeUtc ? convertToLocalTime(endTimeUtc, eventTimezone) : null;

      // Step 4: Extract event parts (Czech output)
      // If extraction fails after retries, continue with empty parts and mark as incomplete.
      let extracted: { title: string; description: string; parts: import("../core/schemas").EventPart[] };
      let partsIncomplete = false;
      try {
        extracted = await runStep(ctx, "extractParts", eventUrl, () => extractEventParts(description, startTime, endTime));
      } catch (err) {
        log({ level: "warn", message: "extractParts failed, continuing with empty parts", url: eventUrl, error: String(err) });
        extracted = { title: facebookEvent.name, description: description, parts: [] };
        partsIncomplete = true;
      }

      // Step 5: Extract event info
      // If extraction fails after retries, continue with empty info and mark as incomplete.
      let info: import("../core/schemas").EventInfo[];
      let infoIncomplete = false;
      try {
        info = await runStep(ctx, "extractInfo", eventUrl, () => extractEventInfo(description));
      } catch (err) {
        log({ level: "warn", message: "extractInfo failed, continuing with empty info", url: eventUrl, error: String(err) });
        info = [];
        infoIncomplete = true;
      }

      const isIncomplete = partsIncomplete || infoIncomplete;

      // Step 6: Resolve venue
      let venue = null;
      if (facebookEvent.location) {
        venue = await runStep(ctx, "resolveVenue", eventUrl, () => resolveVenue(facebookEvent.location!));
        if (venue !== null && venue.id === undefined) {
          log({
            level: "warn",
            message: "resolveVenue returned a venue without an id for event — venue association will be stored as null. This may indicate a Directus API issue.",
            url: eventUrl,
          });
        }
      }

      // Step 7: Derive organizer
      const organizer = facebookEvent.hosts?.[0]?.name ?? facebookEvent.name;

      // Step 8: Translate to EN and ES
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
          log({ level: "error", message: `Translation to ${lang.code} failed`, url: originalUrl, error: String(err) });
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
      const newEvent: DirectusEvent = {
        title: extracted.title,
        original_description: facebookEvent.description ?? "",
        organizer,
        venue: venue?.id ?? null,
        start_time: startTime,
        end_time: endTime,
        timezone: eventTimezone,
        original_url: originalUrl,
        parts: extracted.parts,
        info,
        dances,
        status: isIncomplete ? "incomplete" : "published",
        translation_status: translationStatus,
        translations,
      };

      const createdEvent = await runStep(ctx, "createEvent", originalUrl, () => createEvent(newEvent));
      ctx.set("status", "completed");
      ctx.set("eventId", String(createdEvent.id ?? ""));

      return createdEvent;
}

export type EventWorkflow = typeof eventWorkflow;
