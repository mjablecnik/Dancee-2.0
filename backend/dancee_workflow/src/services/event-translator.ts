import OpenAI from "openai";
import { ZodError } from "zod";
import { config } from "../core/config";
import { parseJsonResponse } from "../core/schemas";
import { getTranslationPrompt } from "../core/prompts";
import { z } from "zod";
import type { EventPart, EventInfo } from "../core/schemas";

const openai = new OpenAI({
  baseURL: "https://openrouter.ai/api/v1",
  apiKey: config.openRouterApiKey,
});

const TranslatedPartSchema = z.object({
  name: z.string(),
  description: z.string(),
});

const TranslatedInfoSchema = z.object({
  key: z.string(),
});

const TranslatedEventContentSchema = z.object({
  title: z.string(),
  description: z.string(),
  parts_translations: z.array(TranslatedPartSchema),
  info_translations: z.array(TranslatedInfoSchema),
});

export type TranslatedEventContent = z.infer<typeof TranslatedEventContentSchema>;

export interface EventContentInput {
  title: string;
  description: string;
  parts: EventPart[];
  info: EventInfo[];
}

export async function translateEventContent(
  content: EventContentInput,
  targetLanguage: string,
): Promise<TranslatedEventContent> {
  const input = {
    title: content.title,
    description: content.description,
    parts_translations: content.parts.map((p) => ({ name: p.name, description: p.description })),
    info_translations: content.info.map((i) => ({ key: i.key })),
  };

  let lastError: unknown;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await openai.chat.completions.create({
        model: config.openRouterModel,
        messages: [
          { role: "system", content: getTranslationPrompt(targetLanguage) },
          { role: "user", content: JSON.stringify(input) },
        ],
      });
      const raw = response.choices[0]?.message?.content ?? "";
      const parsed = parseJsonResponse(raw);
      return TranslatedEventContentSchema.parse(parsed);
    } catch (err) {
      if (!(err instanceof SyntaxError || err instanceof ZodError)) throw err;
      lastError = err;
    }
  }
  throw lastError;
}
