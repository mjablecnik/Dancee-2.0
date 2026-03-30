import OpenAI from "openai";
import { config } from "./config";

// Lazy-initialized client: created on first use so that config is read at call time
// rather than at module load time. This avoids stale credentials if the config is
// loaded lazily or changes after module initialization.
let _openai: OpenAI | undefined;

export function getOpenAI(): OpenAI {
  if (!_openai) {
    _openai = new OpenAI({
      baseURL: "https://openrouter.ai/api/v1",
      apiKey: config.openRouterApiKey,
    });
  }
  return _openai;
}
