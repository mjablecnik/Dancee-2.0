import dotenv from 'dotenv';

dotenv.config();

export interface ServerConfig {
  port: number;
  host: string;
  nodeEnv: string;
  workflowServiceUrl: string;
  cmsServiceUrl: string;
  corsOrigins: string[];
}

function parseCorsOrigins(corsOriginsEnv: string | undefined): string[] {
  if (!corsOriginsEnv || corsOriginsEnv.trim() === '') return ['*'];
  const trimmed = corsOriginsEnv.trim();
  if (trimmed === '*') return ['*'];
  return trimmed.split(',').map(o => o.trim()).filter(o => o.length > 0);
}

export const appConfig: ServerConfig = {
  port: parseInt(process.env.PORT || '3003', 10),
  host: process.env.HOST || 'localhost',
  nodeEnv: process.env.NODE_ENV || 'development',
  workflowServiceUrl: process.env.WORKFLOW_SERVICE_URL || 'http://localhost:8080',
  cmsServiceUrl: process.env.CMS_SERVICE_URL || 'http://localhost:8055',
  corsOrigins: parseCorsOrigins(process.env.CORS_ORIGINS),
};

function isValidUrl(urlString: string): boolean {
  try {
    const url = new URL(urlString);
    return url.protocol === 'http:' || url.protocol === 'https:';
  } catch {
    return false;
  }
}

function validateConfig(): void {
  const errors: string[] = [];

  if (isNaN(appConfig.port) || appConfig.port < 1 || appConfig.port > 65535) {
    errors.push(`Invalid PORT: ${process.env.PORT}. Must be a number between 1 and 65535.`);
  }
  if (!appConfig.host?.trim()) errors.push('HOST cannot be empty');
  if (!isValidUrl(appConfig.workflowServiceUrl)) {
    errors.push(`Invalid WORKFLOW_SERVICE_URL: ${appConfig.workflowServiceUrl}`);
  }
  if (!isValidUrl(appConfig.cmsServiceUrl)) {
    errors.push(`Invalid CMS_SERVICE_URL: ${appConfig.cmsServiceUrl}`);
  }

  if (errors.length > 0) {
    throw new Error(`Configuration validation failed:\n${errors.join('\n')}`);
  }
}

validateConfig();

export function isDevelopment(): boolean {
  return appConfig.nodeEnv === 'development';
}

export function isProduction(): boolean {
  return appConfig.nodeEnv === 'production';
}

export function getServerAddress(): string {
  return `http://${appConfig.host}:${appConfig.port}`;
}
