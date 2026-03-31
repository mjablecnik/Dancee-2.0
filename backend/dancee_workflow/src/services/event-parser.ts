import { ZodError } from "zod";
import { TerminalError } from "@restatedev/restate-sdk";
import { config } from "../core/config";
import { getOpenAI } from "../core/openai";
import {
  parseEventType,
  filterEventInfo,
  parseJsonResponse,
  EventPartSchema,
  type EventType,
  type EventPart,
  type EventInfo,
} from "../core/schemas";
import {
  getEventTypeClassificationPrompt,
  getEventPartsExtractionPrompt,
  getEventInfoExtractionPrompt,
} from "../core/prompts";
import { z } from "zod";

export function isJsonOrValidationError(err: unknown): boolean {
  return err instanceof SyntaxError || err instanceof ZodError;
}

export async function retryOnJsonError<T>(fn: () => Promise<T>, maxAttempts = 3): Promise<T> {
  let lastError: unknown;
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (!isJsonOrValidationError(err)) throw err;
      lastError = err;
    }
  }
  // All retry attempts exhausted — this is a permanent parse failure
  const message = lastError instanceof Error ? lastError.message : String(lastError);
  throw new TerminalError(`Parse failed after ${maxAttempts} attempts: ${message}`);
}

export async function classifyEventType(description: string): Promise<EventType> {
  const response = await getOpenAI().chat.completions.create({
    model: config.openRouterModel,
    temperature: config.llmTemperature,
    messages: [
      { role: "system", content: getEventTypeClassificationPrompt() },
      { role: "user", content: description },
    ],
  });
  const raw = response.choices[0]?.message?.content?.trim() ?? "";
  return parseEventType(raw);
}

const ExtractedPartsSchema = z.object({
  title: z.string(),
  description: z.string(),
  parts: z.array(EventPartSchema),
});

export async function extractEventParts(
  description: string,
  eventStartTime: string,
  eventEndTime: string | null,
): Promise<{ title: string; description: string; parts: EventPart[] }> {
  const prompt = getEventPartsExtractionPrompt("Czech", eventStartTime, eventEndTime);
  return retryOnJsonError(async () => {
    const response = await getOpenAI().chat.completions.create({
      model: config.openRouterModel,
      temperature: config.llmTemperature,
      messages: [
        { role: "system", content: prompt },
        { role: "user", content: description },
      ],
    });
    const raw = response.choices[0]?.message?.content ?? "";
    const parsed = parseJsonResponse(raw);
    const result = ExtractedPartsSchema.parse(parsed);

    // Post-processing: validate part times are consistent with event times
    result.parts = validatePartTimes(result.parts, eventStartTime, eventEndTime);

    return result;
  });
}

/**
 * Validates and fixes part date_time_range values.
 * If a part's time is clearly outside the event's time range (wrong year/month),
 * set it to null rather than keeping a hallucinated date.
 */
function validatePartTimes(
  parts: EventPart[],
  eventStartTime: string,
  eventEndTime: string | null,
): EventPart[] {
  const eventStart = new Date(eventStartTime);
  // Allow parts up to 7 days after event start (for festivals)
  const maxEnd = eventEndTime
    ? new Date(new Date(eventEndTime).getTime() + 24 * 60 * 60 * 1000)
    : new Date(eventStart.getTime() + 7 * 24 * 60 * 60 * 1000);
  // Allow parts to start up to 1 day before event start (setup/pre-party)
  const minStart = new Date(eventStart.getTime() - 24 * 60 * 60 * 1000);

  return parts.map((part) => {
    let start = part.date_time_range.start;
    let end = part.date_time_range.end;

    if (start) {
      const d = new Date(start);
      if (isNaN(d.getTime()) || d < minStart || d > maxEnd) {
        start = null;
      }
    }

    if (end) {
      const d = new Date(end);
      if (isNaN(d.getTime()) || d < minStart || d > maxEnd) {
        end = null;
      }
    }

    return { ...part, date_time_range: { start, end } };
  });
}

// NOTE: The retry logic below is not required by the spec (Requirement 5 does not
// mention retries for event info extraction). It is intentionally included here for
// defensive resilience: if the LLM returns malformed JSON (SyntaxError from
// parseJsonResponse), retrying gives the model another chance before failing the
// entire workflow step. This mirrors the retry behaviour of extractEventParts.
export async function extractEventInfo(description: string): Promise<EventInfo[]> {
  const prompt = getEventInfoExtractionPrompt();
  return retryOnJsonError(async () => {
    const response = await getOpenAI().chat.completions.create({
      model: config.openRouterModel,
      temperature: config.llmTemperature,
      messages: [
        { role: "system", content: prompt },
        { role: "user", content: description },
      ],
    });
    const raw = response.choices[0]?.message?.content ?? "";
    const parsed = parseJsonResponse(raw);
    return filterEventInfo(parsed as unknown[]);
  });
}
