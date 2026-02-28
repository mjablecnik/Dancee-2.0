import { appConfig } from './app.config';

/**
 * Service definition interface
 * Defines metadata for a backend service
 */
export interface ServiceDefinition {
  id: string;
  name: string;
  version: string;
  description: string;
  baseUrl: string;
  specFile: string;
  enabled: boolean;
}

/**
 * UI configuration interface
 * Defines Swagger UI display settings
 */
export interface UIConfig {
  title: string;
  description: string;
  defaultService: string;
  theme: 'light' | 'dark' | 'auto';
}

/**
 * Service configuration interface
 * Contains all service definitions and UI settings
 */
export interface ServiceConfig {
  services: ServiceDefinition[];
  ui: UIConfig;
}

/**
 * Service configuration
 * Defines all backend services and UI settings
 */
export const serviceConfig: ServiceConfig = {
  services: [
    {
      id: 'dancee-events',
      name: 'Dancee Events API',
      version: '1.0.0',
      description: 'Event management and favorites API',
      baseUrl: appConfig.eventsServiceUrl,
      specFile: 'events.openapi.yaml',
      enabled: true,
    },
    {
      id: 'dancee-scraper',
      name: 'Dancee Scraper API',
      version: '1.0.0',
      description: 'Facebook event scraping API',
      baseUrl: appConfig.scraperServiceUrl,
      specFile: 'scraper.openapi.yaml',
      enabled: true,
    },
    {
      id: 'test-api',
      name: 'Test API',
      version: '1.0.0',
      description: 'Test API for health check validation',
      baseUrl: 'http://localhost:8080',
      specFile: 'test.openapi.yaml',
      enabled: true,
    },
  ],
  ui: {
    title: 'Dancee API Documentation',
    description: 'Centralized API documentation for all Dancee backend services',
    defaultService: 'dancee-events',
    theme: 'auto',
  },
};

/**
 * Get all enabled services
 */
export function getEnabledServices(): ServiceDefinition[] {
  return serviceConfig.services.filter(service => service.enabled);
}

/**
 * Get service by ID
 */
export function getServiceById(serviceId: string): ServiceDefinition | undefined {
  return serviceConfig.services.find(service => service.id === serviceId);
}

/**
 * Validate service configuration
 * Throws error if configuration is invalid
 */
export function validateServiceConfig(): void {
  const errors: string[] = [];

  // Check for duplicate service IDs
  const serviceIds = serviceConfig.services.map(s => s.id);
  const duplicates = serviceIds.filter((id, index) => serviceIds.indexOf(id) !== index);
  if (duplicates.length > 0) {
    errors.push(`Duplicate service IDs found: ${duplicates.join(', ')}`);
  }

  // Validate each service
  serviceConfig.services.forEach(service => {
    // Validate service ID format (kebab-case)
    if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(service.id)) {
      errors.push(`Invalid service ID format: ${service.id}. Must be kebab-case.`);
    }

    // Validate required fields
    if (!service.name || service.name.trim() === '') {
      errors.push(`Service ${service.id} is missing name`);
    }

    if (!service.version || service.version.trim() === '') {
      errors.push(`Service ${service.id} is missing version`);
    }

    if (!service.description || service.description.trim() === '') {
      errors.push(`Service ${service.id} is missing description`);
    }

    if (!service.baseUrl || service.baseUrl.trim() === '') {
      errors.push(`Service ${service.id} is missing baseUrl`);
    }

    if (!service.specFile || service.specFile.trim() === '') {
      errors.push(`Service ${service.id} is missing specFile`);
    }
  });

  // Validate at least one service is enabled
  if (getEnabledServices().length === 0) {
    errors.push('At least one service must be enabled');
  }

  // Validate UI configuration
  if (!serviceConfig.ui.title || serviceConfig.ui.title.trim() === '') {
    errors.push('UI title cannot be empty');
  }

  if (!serviceConfig.ui.defaultService || serviceConfig.ui.defaultService.trim() === '') {
    errors.push('UI defaultService cannot be empty');
  }

  // Validate default service exists
  const defaultService = getServiceById(serviceConfig.ui.defaultService);
  if (!defaultService) {
    errors.push(`Default service ${serviceConfig.ui.defaultService} not found in services list`);
  }

  if (errors.length > 0) {
    throw new Error(`Service configuration validation failed:\n${errors.join('\n')}`);
  }
}

// Validate configuration on module load
validateServiceConfig();
