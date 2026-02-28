import dotenv from 'dotenv';

// Load environment variables from .env file
dotenv.config();

/**
 * Server configuration interface
 */
export interface ServerConfig {
  port: number;
  host: string;
  nodeEnv: string;
  eventsServiceUrl: string;
  scraperServiceUrl: string;
  corsOrigins: string[];
}

/**
 * Parse CORS origins from environment variable
 * Supports comma-separated list or wildcard (*)
 */
function parseCorsOrigins(corsOriginsEnv: string | undefined): string[] {
  if (!corsOriginsEnv || corsOriginsEnv.trim() === '') {
    return ['*']; // Default to allow all origins in development
  }

  const trimmed = corsOriginsEnv.trim();
  
  // If wildcard, return as single-element array
  if (trimmed === '*') {
    return ['*'];
  }

  // Split by comma and trim each origin
  return trimmed
    .split(',')
    .map(origin => origin.trim())
    .filter(origin => origin.length > 0);
}

/**
 * Application configuration loaded from environment variables
 * Provides default values for development environment
 */
export const appConfig: ServerConfig = {
  port: parseInt(process.env.PORT || '3003', 10),
  host: process.env.HOST || 'localhost',
  nodeEnv: process.env.NODE_ENV || 'development',
  eventsServiceUrl: process.env.EVENTS_SERVICE_URL || 'http://localhost:8080',
  scraperServiceUrl: process.env.SCRAPER_SERVICE_URL || 'http://localhost:3002',
  corsOrigins: parseCorsOrigins(process.env.CORS_ORIGINS),
};

/**
 * Validate configuration on module load
 * Throws error if critical configuration is missing or invalid
 */
function validateConfig(): void {
  const errors: string[] = [];

  if (isNaN(appConfig.port) || appConfig.port < 1 || appConfig.port > 65535) {
    errors.push(`Invalid PORT: ${process.env.PORT}. Must be a number between 1 and 65535.`);
  }

  if (!appConfig.host || appConfig.host.trim() === '') {
    errors.push('HOST cannot be empty');
  }

  if (!appConfig.eventsServiceUrl || !isValidUrl(appConfig.eventsServiceUrl)) {
    errors.push(`Invalid EVENTS_SERVICE_URL: ${appConfig.eventsServiceUrl}`);
  }

  if (!appConfig.scraperServiceUrl || !isValidUrl(appConfig.scraperServiceUrl)) {
    errors.push(`Invalid SCRAPER_SERVICE_URL: ${appConfig.scraperServiceUrl}`);
  }

  if (errors.length > 0) {
    throw new Error(`Configuration validation failed:\n${errors.join('\n')}`);
  }
}

/**
 * Basic URL validation
 */
function isValidUrl(urlString: string): boolean {
  try {
    const url = new URL(urlString);
    return url.protocol === 'http:' || url.protocol === 'https:';
  } catch {
    return false;
  }
}

// Validate configuration on module load
validateConfig();

/**
 * Check if running in development mode
 */
export function isDevelopment(): boolean {
  return appConfig.nodeEnv === 'development';
}

/**
 * Check if running in production mode
 */
export function isProduction(): boolean {
  return appConfig.nodeEnv === 'production';
}

/**
 * Get formatted server address
 */
export function getServerAddress(): string {
  return `http://${appConfig.host}:${appConfig.port}`;
}
