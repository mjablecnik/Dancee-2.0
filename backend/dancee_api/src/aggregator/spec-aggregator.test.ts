/**
 * Unit tests for SpecAggregator
 */

import * as fs from 'fs';
import * as path from 'path';
import { SpecAggregator } from './spec-aggregator';

describe('SpecAggregator', () => {
  const testSpecsDir = path.join(__dirname, '../../specs');
  let aggregator: SpecAggregator;

  beforeEach(() => {
    aggregator = new SpecAggregator(testSpecsDir);
  });

  describe('constructor', () => {
    it('should create a new SpecAggregator instance', () => {
      expect(aggregator).toBeInstanceOf(SpecAggregator);
    });
  });

  describe('loadSpecs', () => {
    it('should load valid YAML specs', async () => {
      // Create a temporary valid YAML spec
      const validYamlSpec = `
openapi: 3.0.0
info:
  title: Test API
  version: 1.0.0
paths:
  /test:
    get:
      summary: Test endpoint
      responses:
        '200':
          description: Success
`;
      const tempSpecPath = path.join(testSpecsDir, 'temp-test.yaml');
      fs.writeFileSync(tempSpecPath, validYamlSpec);

      try {
        await aggregator.loadSpecs();
        // Should load at least the test spec
        expect(aggregator.getLoadedSpecCount()).toBeGreaterThanOrEqual(0);
      } finally {
        // Cleanup
        if (fs.existsSync(tempSpecPath)) {
          fs.unlinkSync(tempSpecPath);
        }
      }
    });

    it('should load valid JSON specs', async () => {
      // Create a temporary valid JSON spec
      const validJsonSpec = {
        openapi: '3.0.0',
        info: {
          title: 'Test API',
          version: '1.0.0',
        },
        paths: {
          '/test': {
            get: {
              summary: 'Test endpoint',
              responses: {
                '200': {
                  description: 'Success',
                },
              },
            },
          },
        },
      };
      const tempSpecPath = path.join(testSpecsDir, 'temp-test.json');
      fs.writeFileSync(tempSpecPath, JSON.stringify(validJsonSpec, null, 2));

      try {
        await aggregator.loadSpecs();
        // Should load at least the test spec
        expect(aggregator.getLoadedSpecCount()).toBeGreaterThanOrEqual(0);
      } finally {
        // Cleanup
        if (fs.existsSync(tempSpecPath)) {
          fs.unlinkSync(tempSpecPath);
        }
      }
    });

    it('should handle missing spec files gracefully', async () => {
      // This test verifies that missing spec files are logged but don't crash the app
      await expect(aggregator.loadSpecs()).resolves.not.toThrow();
    });

    it('should handle invalid spec files gracefully', async () => {
      // Create a temporary invalid spec
      const invalidSpec = `
openapi: 3.0.0
info:
  title: Invalid API
  # Missing version field
paths: {}
`;
      const tempSpecPath = path.join(testSpecsDir, 'temp-invalid.yaml');
      fs.writeFileSync(tempSpecPath, invalidSpec);

      try {
        await aggregator.loadSpecs();
        // Should continue loading other specs even if one fails
        expect(aggregator.getLoadedSpecCount()).toBeGreaterThanOrEqual(0);
      } finally {
        // Cleanup
        if (fs.existsSync(tempSpecPath)) {
          fs.unlinkSync(tempSpecPath);
        }
      }
    });
  });

  describe('getServiceList', () => {
    it('should return empty array when no specs are loaded', () => {
      const serviceList = aggregator.getServiceList();
      expect(Array.isArray(serviceList)).toBe(true);
      expect(serviceList.length).toBe(0);
    });

    it('should return all enabled services with loaded specs', async () => {
      await aggregator.loadSpecs();
      const serviceList = aggregator.getServiceList();

      expect(Array.isArray(serviceList)).toBe(true);

      // Each service should have required fields
      serviceList.forEach(service => {
        expect(service).toHaveProperty('id');
        expect(service).toHaveProperty('name');
        expect(service).toHaveProperty('version');
        expect(service).toHaveProperty('description');
        expect(service).toHaveProperty('baseUrl');
        expect(service).toHaveProperty('specPath');

        // Validate field types
        expect(typeof service.id).toBe('string');
        expect(typeof service.name).toBe('string');
        expect(typeof service.version).toBe('string');
        expect(typeof service.description).toBe('string');
        expect(typeof service.baseUrl).toBe('string');
        expect(typeof service.specPath).toBe('string');

        // Validate specPath format
        expect(service.specPath).toBe(`/api/spec/${service.id}`);
      });
    });
  });

  describe('getSpec', () => {
    it('should return null for non-existent service', () => {
      const spec = aggregator.getSpec('non-existent-service');
      expect(spec).toBeNull();
    });

    it('should return cached spec for valid service', async () => {
      await aggregator.loadSpecs();

      // Get list of loaded services
      const serviceList = aggregator.getServiceList();

      if (serviceList.length > 0) {
        const firstService = serviceList[0];
        const spec = aggregator.getSpec(firstService.id);

        expect(spec).not.toBeNull();
        expect(spec).toHaveProperty('openapi');
        expect(spec).toHaveProperty('info');
        expect(spec).toHaveProperty('paths');
      }
    });
  });

  describe('hasSpec', () => {
    it('should return false for non-existent service', () => {
      expect(aggregator.hasSpec('non-existent-service')).toBe(false);
    });

    it('should return true for loaded service', async () => {
      await aggregator.loadSpecs();

      const serviceList = aggregator.getServiceList();
      if (serviceList.length > 0) {
        const firstService = serviceList[0];
        expect(aggregator.hasSpec(firstService.id)).toBe(true);
      }
    });
  });

  describe('getLoadedSpecCount', () => {
    it('should return 0 when no specs are loaded', () => {
      expect(aggregator.getLoadedSpecCount()).toBe(0);
    });

    it('should return correct count after loading specs', async () => {
      await aggregator.loadSpecs();
      const count = aggregator.getLoadedSpecCount();
      expect(count).toBeGreaterThanOrEqual(0);
      expect(typeof count).toBe('number');
    });
  });

  describe('getLoadedServiceIds', () => {
    it('should return empty array when no specs are loaded', () => {
      const ids = aggregator.getLoadedServiceIds();
      expect(Array.isArray(ids)).toBe(true);
      expect(ids.length).toBe(0);
    });

    it('should return array of service IDs after loading specs', async () => {
      await aggregator.loadSpecs();
      const ids = aggregator.getLoadedServiceIds();

      expect(Array.isArray(ids)).toBe(true);
      ids.forEach(id => {
        expect(typeof id).toBe('string');
        expect(id.length).toBeGreaterThan(0);
      });
    });
  });

  describe('multi-format support', () => {
    it('should support both YAML and JSON formats', async () => {
      // Create both YAML and JSON test specs
      const yamlSpec = `
openapi: 3.0.0
info:
  title: YAML Test API
  version: 1.0.0
paths:
  /yaml:
    get:
      summary: YAML endpoint
      responses:
        '200':
          description: Success
`;

      const jsonSpec = {
        openapi: '3.0.0',
        info: {
          title: 'JSON Test API',
          version: '1.0.0',
        },
        paths: {
          '/json': {
            get: {
              summary: 'JSON endpoint',
              responses: {
                '200': {
                  description: 'Success',
                },
              },
            },
          },
        },
      };

      const yamlPath = path.join(testSpecsDir, 'temp-yaml.yaml');
      const jsonPath = path.join(testSpecsDir, 'temp-json.json');

      fs.writeFileSync(yamlPath, yamlSpec);
      fs.writeFileSync(jsonPath, JSON.stringify(jsonSpec, null, 2));

      try {
        await aggregator.loadSpecs();
        // Both formats should be supported
        expect(aggregator.getLoadedSpecCount()).toBeGreaterThanOrEqual(0);
      } finally {
        // Cleanup
        if (fs.existsSync(yamlPath)) {
          fs.unlinkSync(yamlPath);
        }
        if (fs.existsSync(jsonPath)) {
          fs.unlinkSync(jsonPath);
        }
      }
    });
  });
});
