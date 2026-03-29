import OpenAI from "openai";
import { ZodError } from "zod";
import { config } from "../core/config";
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

function isJsonOrValidationError(err: unknown): boolean {
  return err instanceof SyntaxError || err instanceof ZodError;
}

const openai = new OpenAI({
  baseURL: "https://openrouter.ai/api/v1",
  apiKey: config.openRouterApiKey,
});

export async function classifyEventType(description: string): Promise<EventType> {
  const response = await openai.chat.completions.create({
    model: config.openRouterModel,
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
  let lastError: unknown;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await openai.chat.completions.create({
        model: config.openRouterModel,
        messages: [
          { role: "system", content: prompt },
          { role: "user", content: description },
        ],
      });
      const raw = response.choices[0]?.message?.content ?? "";
      const parsed = parseJsonResponse(raw);
      return ExtractedPartsSchema.parse(parsed);
    } catch (err) {
      if (!isJsonOrValidationError(err)) throw err;
      lastError = err;
    }
  }
  throw lastError;
}

export async function extractEventInfo(description: string): Promise<EventInfo[]> {
  const prompt = getEventInfoExtractionPrompt();
  let lastError: unknown;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await openai.chat.completions.create({
        model: config.openRouterModel,
        messages: [
          { role: "system", content: prompt },
          { role: "user", content: description },
        ],
      });
      const raw = response.choices[0]?.message?.content ?? "";
      const parsed = parseJsonResponse(raw);
      return filterEventInfo(parsed as unknown[]);
    } catch (err) {
      if (!isJsonOrValidationError(err)) throw err;
      lastError = err;
    }
  }
  throw lastError;
}
