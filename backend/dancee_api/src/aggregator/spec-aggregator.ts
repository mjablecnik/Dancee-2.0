/**
 * OpenAPI Specification Aggregator
 * Manages loading, validation, and serving of OpenAPI specifications
 */

import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';
import { validateSpec, OpenAPISpec } from './spec-validator';
import { serviceConfig, ServiceDefinition } from '../config/services.config';

/**
 * Service information interface
 * Contains metadata about a backend service
 */
export interface ServiceInfo {
  id: string;
  name: string;
  version: string;
  description: string;
  baseUrl: string;
  specPath: string;
}

/**
 * Spec Aggregator class
 * Manages OpenAPI specifications for all backend services
 */
export class SpecAggregator {
  private specs: Map<string, OpenAPISpec> = new Map();
  private specsDirectory: string;

  /**
   * Create a new SpecAggregator
   * @param specsDirectory - Path to directory containing OpenAPI spec files
   */
  constructor(specsDirectory: string) {
    this.specsDirectory = specsDirectory;
  }

  /**
   * Load all OpenAPI specifications from the specs directory
   * Validates each spec and caches valid specs in memory
   * Logs errors for invalid specs and excludes them from service list
   */
  async loadSpecs(): Promise<void> {
    console.log(`Loading OpenAPI specifications from ${this.specsDirectory}...`);

    // Get all enabled services from configuration
    const enabledServices = serviceConfig.services.filter(service => service.enabled);

    for (const service of enabledServices) {
      try {
        await this.loadSpec(service);
      } catch (error) {
        console.error(`Failed to load spec for service ${service.id}:`, error);
        // Continue loading other specs even if one fails
      }
    }

    console.log(`Successfully loaded ${this.specs.size} OpenAPI specification(s)`);
  }

  /**
   * Load a single OpenAPI specification for a service
   * @param service - Service definition
   */
  private async loadSpec(service: ServiceDefinition): Promise<void> {
    const specPath = path.join(this.specsDirectory, service.specFile);

    // Check if spec file exists
    if (!fs.existsSync(specPath)) {
      throw new Error(`Spec file not found: ${specPath}`);
    }

    // Read spec file
    const fileContent = fs.readFileSync(specPath, 'utf8');

    // Parse spec based on file extension
    let spec: any;
    const ext = path.extname(service.specFile).toLowerCase();

    if (ext === '.yaml' || ext === '.yml') {
      spec = yaml.load(fileContent);
    } else if (ext === '.json') {
      spec = JSON.parse(fileContent);
    } else {
      throw new Error(`Unsupported spec file format: ${ext}. Only .yaml, .yml, and .json are supported.`);
    }

    // Validate spec
    const validationResult = validateSpec(spec);
    if (!validationResult.valid) {
      throw new Error(
        `OpenAPI specification validation failed for ${service.id}:\n${validationResult.errors.join('\n')}`
      );
    }

    // Cache the validated spec
    this.specs.set(service.id, spec as OpenAPISpec);
    console.log(`✓ Loaded and validated spec for ${service.id}`);
  }

  /**
   * Get list of all services with successfully loaded specs
   * @returns Array of service information objects
   */
  getServiceList(): ServiceInfo[] {
    const serviceList: ServiceInfo[] = [];

    // Only include services that have successfully loaded specs
    for (const service of serviceConfig.services) {
      if (this.specs.has(service.id)) {
        serviceList.push({
          id: service.id,
          name: service.name,
          version: service.version,
          description: service.description,
          baseUrl: service.baseUrl,
          specPath: `/api/spec/${service.id}`,
        });
      }
    }

    return serviceList;
  }

  /**
   * Get OpenAPI specification for a specific service
   * @param serviceId - Service identifier
   * @returns OpenAPI spec or null if not found
   */
  getSpec(serviceId: string): OpenAPISpec | null {
    return this.specs.get(serviceId) || null;
  }

  /**
   * Check if a service spec is loaded
   * @param serviceId - Service identifier
   * @returns true if spec is loaded, false otherwise
   */
  hasSpec(serviceId: string): boolean {
    return this.specs.has(serviceId);
  }

  /**
   * Get count of loaded specs
   * @returns Number of loaded specs
   */
  getLoadedSpecCount(): number {
    return this.specs.size;
  }

  /**
   * Get all loaded service IDs
   * @returns Array of service IDs
   */
  getLoadedServiceIds(): string[] {
    return Array.from(this.specs.keys());
  }

  /**
   * Get service information for a specific service
   * @param serviceId - Service identifier
   * @returns Service info or null if not found
   */
  getServiceInfo(serviceId: string): ServiceInfo | null {
    if (!this.specs.has(serviceId)) {
      return null;
    }

    const service = serviceConfig.services.find(s => s.id === serviceId);
    if (!service) {
      return null;
    }

    return {
      id: service.id,
      name: service.name,
      version: service.version,
      description: service.description,
      baseUrl: service.baseUrl,
      specPath: `/api/spec/${service.id}`,
    };
  }
}
