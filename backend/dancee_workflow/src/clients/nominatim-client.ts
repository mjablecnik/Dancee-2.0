import { config } from "../core/config";
import { NominatimResponseSchema, type NominatimResponse } from "../core/schemas";

// Module-level mutable state for the 1 req/s throttle (Nominatim usage policy).
// IMPORTANT: Because this state is shared across all calls within a module instance,
// parallel tests that both call reverseGeocode can interfere with each other.
// Tests must call `resetThrottle()` in a `beforeEach` hook to reset this state
// between test cases. The resetThrottle export exists solely for this purpose.
let lastRequestTime = 0;

export function resetThrottle(): void {
  lastRequestTime = 0;
}

async function throttle(): Promise<void> {
  const now = Date.now();
  const elapsed = now - lastRequestTime;
  const minInterval = 1000;
  if (elapsed < minInterval) {
    await new Promise((resolve) => setTimeout(resolve, minInterval - elapsed));
  }
  lastRequestTime = Date.now();
}

export async function reverseGeocode(lat: number, lng: number): Promise<NominatimResponse> {
  await throttle();
  const params = new URLSearchParams({
    lat: lat.toString(),
    lon: lng.toString(),
    format: "json",
  });
  const url = `${config.nominatimBaseUrl}/reverse?${params.toString()}`;
  const response = await fetch(url, {
    headers: { "User-Agent": "dancee_workflow/1.0" },
    signal: AbortSignal.timeout(config.nominatimTimeoutMs),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Nominatim API error ${response.status}: ${text}`);
  }
  const data = await response.json();
  return NominatimResponseSchema.parse(data);
}
