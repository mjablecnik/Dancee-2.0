import { ZodError } from "zod";
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
  throw lastError;
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
): Promise<{ title: string; description: string; parts: EventPart[] }> {
  const prompt = getEventPartsExtractionPrompt("Czech");
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
    return ExtractedPartsSchema.parse(parsed);
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
