/**
 * Normalises a Facebook event URL by stripping the `event_time_id` query
 * parameter. Recurring (sibling) events share the same parent event but
 * Facebook appends a unique `event_time_id` to each instance URL. Without
 * normalisation the duplicate check treats every sibling as a new event.
 */
export function normalizeEventUrl(url: string): string {
  try {
    const parsed = new URL(url);
    parsed.searchParams.delete("event_time_id");
    // Remove trailing '?' if no params remain
    return parsed.toString().replace(/\?$/, "");
  } catch {
    return url;
  }
}
