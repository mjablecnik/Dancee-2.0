import { appConfig } from './app.config';

export interface ServiceDefinition {
  id: string;
  name: string;
  version: string;
  description: string;
  baseUrl: string;
  specFile: string;
  enabled: boolean;
}

export interface UIConfig {
  title: string;
  description: string;
  defaultService: string;
  theme: 'light' | 'dark' | 'auto';
}

export interface ServiceConfig {
  services: ServiceDefinition[];
  ui: UIConfig;
}

export const serviceConfig: ServiceConfig = {
  services: [
    {
      id: 'dancee-workflow',
      name: 'Dancee Workflow API',
      version: '1.0.0',
      description: 'Facebook event processing pipeline — scraping, AI parsing, translation, geocoding',
      baseUrl: appConfig.workflowServiceUrl,
      specFile: 'workflow.openapi.yaml',
      enabled: true,
    },
    {
      id: 'dancee-cms',
      name: 'Dancee CMS API',
      version: '1.0.0',
      description: 'Directus headless CMS — event data, venues, groups',
      baseUrl: appConfig.cmsServiceUrl,
      specFile: 'cms.openapi.yaml',
      enabled: true,
    },
  ],
  ui: {
    title: 'Dancee API Documentation',
    description: 'Centralized API documentation for all Dancee backend services',
    defaultService: 'dancee-workflow',
    theme: 'auto',
  },
};

export function getEnabledServices(): ServiceDefinition[] {
  return serviceConfig.services.filter(service => service.enabled);
}

export function getServiceById(serviceId: string): ServiceDefinition | undefined {
  return serviceConfig.services.find(service => service.id === serviceId);
}

export function validateServiceConfig(): void {
  const errors: string[] = [];

  const serviceIds = serviceConfig.services.map(s => s.id);
  const duplicates = serviceIds.filter((id, index) => serviceIds.indexOf(id) !== index);
  if (duplicates.length > 0) {
    errors.push(`Duplicate service IDs found: ${duplicates.join(', ')}`);
  }

  serviceConfig.services.forEach(service => {
    if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(service.id)) {
      errors.push(`Invalid service ID format: ${service.id}. Must be kebab-case.`);
    }
    if (!service.name?.trim()) errors.push(`Service ${service.id} is missing name`);
    if (!service.version?.trim()) errors.push(`Service ${service.id} is missing version`);
    if (!service.description?.trim()) errors.push(`Service ${service.id} is missing description`);
    if (!service.baseUrl?.trim()) errors.push(`Service ${service.id} is missing baseUrl`);
    if (!service.specFile?.trim()) errors.push(`Service ${service.id} is missing specFile`);
  });

  if (getEnabledServices().length === 0) {
    errors.push('At least one service must be enabled');
  }

  if (!serviceConfig.ui.title?.trim()) errors.push('UI title cannot be empty');
  if (!serviceConfig.ui.defaultService?.trim()) errors.push('UI defaultService cannot be empty');

  const defaultService = getServiceById(serviceConfig.ui.defaultService);
  if (!defaultService) {
    errors.push(`Default service ${serviceConfig.ui.defaultService} not found in services list`);
  }

  if (errors.length > 0) {
    throw new Error(`Service configuration validation failed:\n${errors.join('\n')}`);
  }
}

validateServiceConfig();
