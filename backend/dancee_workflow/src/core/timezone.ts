import { DateTime, IANAZone, FixedOffsetZone } from "luxon";
import { log } from "./logger";

/**
 * Attempts to parse a timezone string that may not be a valid IANA zone.
 * Handles formats like "UTC+02", "UTC-05", "PDT", "CET", etc.
 * Returns the offset in minutes, or null if unparseable.
 */
function resolveTimezoneOffset(timezone: string): number | null {
  // Common abbreviation → offset (minutes) mapping
  const ABBREVIATIONS: Record<string, number> = {
    PDT: -7 * 60,
    PST: -8 * 60,
    MDT: -6 * 60,
    MST: -7 * 60,
    CDT: -5 * 60,
    CST: -6 * 60,
    EDT: -4 * 60,
    EST: -5 * 60,
    CET: 1 * 60,
    CEST: 2 * 60,
    EET: 2 * 60,
    EEST: 3 * 60,
    WET: 0,
    WEST: 1 * 60,
    GMT: 0,
    BST: 1 * 60,
    IST: 5 * 60 + 30,
    JST: 9 * 60,
    KST: 9 * 60,
    AEST: 10 * 60,
    AEDT: 11 * 60,
  };

  const upper = timezone.toUpperCase();
  if (upper in ABBREVIATIONS) {
    return ABBREVIATIONS[upper];
  }

  // Match "UTC+02", "UTC-5", "UTC+05:30", "UTC+0530"
  const utcMatch = timezone.match(/^UTC([+-])(\d{1,2})(?::?(\d{2}))?$/i);
  if (utcMatch) {
    const sign = utcMatch[1] === "+" ? 1 : -1;
    const hours = parseInt(utcMatch[2], 10);
    const minutes = parseInt(utcMatch[3] ?? "0", 10);
    return sign * (hours * 60 + minutes);
  }

  return null;
}

/**
 * Converts a UTC ISO 8601 string to the local "wall clock" time for the given
 * IANA timezone (e.g. "Europe/Prague", "America/New_York") or a fixed offset
 * string (e.g. "UTC+02", "PDT").
 *
 * Returns an ISO 8601 string WITHOUT offset/Z suffix so that downstream
 * consumers (Directus, Flutter) treat it as a naive local time.
 *
 * If the timezone is invalid or missing, the original UTC string is returned
 * unchanged (stripped of trailing "Z" / offset for consistency).
 */
export function convertToLocalTime(utcIso: string, timezone: string): string {
  if (!timezone || timezone === "UTC") {
    return stripOffset(utcIso);
  }

  // Try IANA zone first (e.g. "Europe/Prague")
  if (IANAZone.isValidZone(timezone)) {
    const dt = DateTime.fromISO(utcIso, { zone: "utc" }).setZone(timezone);
    if (dt.isValid) {
      return dt.toFormat("yyyy-MM-dd'T'HH:mm:ss");
    }
  }

  // Fall back to fixed offset parsing (e.g. "UTC+02", "PDT")
  const offsetMinutes = resolveTimezoneOffset(timezone);
  if (offsetMinutes !== null) {
    const zone = FixedOffsetZone.instance(offsetMinutes);
    const dt = DateTime.fromISO(utcIso, { zone: "utc" }).setZone(zone);
    if (dt.isValid) {
      return dt.toFormat("yyyy-MM-dd'T'HH:mm:ss");
    }
  }

  log({
    level: "warn",
    message: `Unrecognized timezone "${timezone}", skipping conversion`,
  });
  return stripOffset(utcIso);
}

/**
 * Converts a local "wall clock" ISO string back to UTC for the given timezone.
 * Used by the migration script to reverse existing UTC times.
 */
export function convertLocalToUtc(localIso: string, timezone: string): string {
  if (!timezone || timezone === "UTC") {
    return stripOffset(localIso);
  }

  if (IANAZone.isValidZone(timezone)) {
    const dt = DateTime.fromISO(localIso, { zone: timezone }).toUTC();
    if (dt.isValid) {
      return dt.toISO({ suppressMilliseconds: true }) ?? localIso;
    }
  }

  const offsetMinutes = resolveTimezoneOffset(timezone);
  if (offsetMinutes !== null) {
    const zone = FixedOffsetZone.instance(offsetMinutes);
    const dt = DateTime.fromISO(localIso, { zone }).toUTC();
    if (dt.isValid) {
      return dt.toISO({ suppressMilliseconds: true }) ?? localIso;
    }
  }

  return stripOffset(localIso);
}

function stripOffset(iso: string): string {
  // Remove trailing "Z", "+00:00", or any offset like "+02:00"
  return iso.replace(/([+-]\d{2}:\d{2}|Z)$/, "");
}
