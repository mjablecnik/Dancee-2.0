/**
 * Minimal structured logger that outputs JSON lines to stderr/stdout.
 * Fields: level, message, and any optional context (url, reason, etc.).
 * JSON output makes logs machine-parseable for monitoring and alerting.
 */

type LogLevel = "info" | "warn" | "error";

export interface LogEntry {
  level: LogLevel;
  message: string;
  url?: string;
  reason?: string;
  [key: string]: unknown;
}

export function log(entry: LogEntry): void {
  const output = JSON.stringify(entry);
  if (entry.level === "error") {
    console.error(output);
  } else if (entry.level === "warn") {
    console.warn(output);
  } else {
    console.log(output);
  }
}
