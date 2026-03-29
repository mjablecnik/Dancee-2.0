import * as dotenv from "dotenv";
import * as Sentry from "@sentry/node";

dotenv.config();

export const config = {
  openRouterApiKey: process.env.OPENROUTER_API_KEY ?? "",
  openRouterModel: process.env.OPENROUTER_MODEL ?? "google/gemini-2.0-flash-001",
  directusBaseUrl: process.env.DIRECTUS_BASE_URL ?? "",
  directusAccessToken: process.env.DIRECTUS_ACCESS_TOKEN ?? "",
  scraperBaseUrl: process.env.SCRAPER_BASE_URL ?? "",
  nominatimBaseUrl: process.env.NOMINATIM_BASE_URL ?? "https://nominatim.openstreetmap.org",
  sentryDsn: process.env.SENTRY_DSN ?? "",
  corsOrigins: process.env.CORS_ORIGINS ?? "*",
  appPort: parseInt(process.env.APP_PORT ?? "9080", 10),
};

export function initSentry(): void {
  if (!config.sentryDsn) {
    console.warn("Sentry DSN is not set. Sentry integration will be disabled.");
    return;
  }
  Sentry.init({ dsn: config.sentryDsn });
}

export function captureError(error: Error, context: Record<string, string>): void {
  Sentry.withScope((scope) => {
    for (const [key, value] of Object.entries(context)) {
      scope.setTag(key, value);
    }
    Sentry.captureException(error);
  });
}
