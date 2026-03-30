import { config } from "../core/config";
import { getOpenAI } from "../core/openai";
import { parseJsonResponse } from "../core/schemas";
import { getTranslationPrompt } from "../core/prompts";
import { retryOnJsonError } from "./event-parser";
import { z } from "zod";
import type { EventPart, EventInfo } from "../core/schemas";

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

  return retryOnJsonError(async () => {
    const response = await getOpenAI().chat.completions.create({
      model: config.openRouterModel,
      temperature: config.llmTemperature,
      messages: [
        { role: "system", content: getTranslationPrompt(targetLanguage) },
        { role: "user", content: JSON.stringify(input) },
      ],
    });
    const raw = response.choices[0]?.message?.content ?? "";
    const parsed = parseJsonResponse(raw);
    const result = TranslatedEventContentSchema.parse(parsed);
    if (result.parts_translations.length !== content.parts.length) {
      throw new SyntaxError(
        `Translation parts_translations length mismatch: expected ${content.parts.length}, got ${result.parts_translations.length}`,
      );
    }
    if (result.info_translations.length !== content.info.length) {
      throw new SyntaxError(
        `Translation info_translations length mismatch: expected ${content.info.length}, got ${result.info_translations.length}`,
      );
    }
    return result;
  });
}
