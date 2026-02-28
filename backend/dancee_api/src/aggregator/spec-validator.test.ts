/**
 * Unit tests for OpenAPI Specification Validator
 */

import { validateSpec, isValidSpec, validateSpecOrThrow, OpenAPISpec } from './spec-validator';

describe('spec-validator', () => {
  describe('validateSpec', () => {
    it('should validate a minimal valid OpenAPI 3.0 spec', () => {
      const spec = {
        openapi: '3.0.0',
        info: {
          title: 'Test API',
          version: '1.0.0',
        },
        paths: {
          '/test': {
            get: {
              summary: 'Test endpoint',
            },
          },
        },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should validate a complete OpenAPI 3.0 spec with all optional fields', () => {
      const spec: OpenAPISpec = {
        openapi: '3.0.0',
        info: {
          title: 'Complete API',
          version: '1.0.0',
          description: 'A complete API specification',
          contact: {
            name: 'API Team',
            email: 'api@example.com',
          },
        },
        servers: [
          {
            url: 'http://localhost:3000',
            description: 'Development server',
          },
          {
            url: 'https://api.example.com',
            description: 'Production server',
          },
        ],
        paths: {
          '/users': {
            get: {
              summary: 'Get users',
            },
          },
        },
        components: {
          schemas: {
            User: {
              type: 'object',
              properties: {
                id: { type: 'string' },
                name: { type: 'string' },
              },
            },
          },
          responses: {
            NotFound: {
              description: 'Resource not found',
            },
          },
          parameters: {
            userId: {
              name: 'userId',
              in: 'path',
              required: true,
              schema: { type: 'string' },
            },
          },
        },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should accept OpenAPI 3.0.x versions', () => {
      const versions = ['3.0.0', '3.0.1', '3.0.2', '3.0.3'];

      versions.forEach(version => {
        const spec = {
          openapi: version,
          info: { title: 'Test', version: '1.0.0' },
          paths: { '/test': {} },
        };

        const result = validateSpec(spec);
        expect(result.valid).toBe(true);
      });
    });

    it('should reject non-object specs', () => {
      const invalidSpecs = [null, undefined, 'string', 123, [], true];

      invalidSpecs.forEach(spec => {
        const result = validateSpec(spec);
        expect(result.valid).toBe(false);
        expect(result.errors).toContain('Specification must be a valid object');
      });
    });

    it('should reject spec without openapi field', () => {
      const spec = {
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Missing required field: openapi');
    });

    it('should reject spec with non-string openapi field', () => {
      const spec = {
        openapi: 3.0,
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "openapi" must be a string');
    });

    it('should reject unsupported OpenAPI versions', () => {
      const unsupportedVersions = ['2.0', '1.0', '4.0.0', '3.1.0'];

      unsupportedVersions.forEach(version => {
        const spec = {
          openapi: version,
          info: { title: 'Test', version: '1.0.0' },
          paths: { '/test': {} },
        };

        const result = validateSpec(spec);
        expect(result.valid).toBe(false);
        expect(result.errors.some(err => err.includes('Unsupported OpenAPI version'))).toBe(true);
      });
    });

    it('should reject spec without info field', () => {
      const spec = {
        openapi: '3.0.0',
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Missing required field: info');
    });

    it('should reject spec with non-object info field', () => {
      const spec = {
        openapi: '3.0.0',
        info: 'invalid',
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info" must be an object');
    });

    it('should reject spec without info.title', () => {
      const spec = {
        openapi: '3.0.0',
        info: { version: '1.0.0' },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Missing required field: info.title');
    });

    it('should reject spec with non-string info.title', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 123, version: '1.0.0' },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info.title" must be a string');
    });

    it('should reject spec with empty info.title', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: '   ', version: '1.0.0' },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info.title" cannot be empty');
    });

    it('should reject spec without info.version', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test' },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Missing required field: info.version');
    });

    it('should reject spec with non-string info.version', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: 1.0 },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info.version" must be a string');
    });

    it('should reject spec with empty info.version', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '  ' },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info.version" cannot be empty');
    });

    it('should reject spec with non-string info.description', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0', description: 123 },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info.description" must be a string');
    });

    it('should reject spec with non-object info.contact', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0', contact: 'invalid' },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info.contact" must be an object');
    });

    it('should reject spec with non-string info.contact.name', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0', contact: { name: 123 } },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info.contact.name" must be a string');
    });

    it('should reject spec with non-string info.contact.email', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0', contact: { email: 123 } },
        paths: { '/test': {} },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "info.contact.email" must be a string');
    });

    it('should reject spec without paths field', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Missing required field: paths');
    });

    it('should reject spec with non-object paths field', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: 'invalid',
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "paths" must be an object');
    });

    it('should reject spec with array paths field', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: [],
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "paths" must be an object');
    });

    it('should reject spec with empty paths object', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: {},
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "paths" cannot be empty - at least one path must be defined');
    });

    it('should reject spec with non-array servers field', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        servers: 'invalid',
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "servers" must be an array');
    });

    it('should reject spec with non-object server in servers array', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        servers: ['invalid'],
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Server at index 0 must be an object');
    });

    it('should reject spec with server missing url', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        servers: [{ description: 'Test server' }],
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Server at index 0 is missing required field: url');
    });

    it('should reject spec with server having non-string url', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        servers: [{ url: 123 }],
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Server at index 0: field "url" must be a string');
    });

    it('should reject spec with server having non-string description', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        servers: [{ url: 'http://localhost', description: 123 }],
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Server at index 0: field "description" must be a string');
    });

    it('should reject spec with non-object components field', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        components: 'invalid',
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "components" must be an object');
    });

    it('should reject spec with array components field', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        components: [],
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "components" must be an object');
    });

    it('should reject spec with non-object components.schemas', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        components: { schemas: 'invalid' },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "components.schemas" must be an object');
    });

    it('should reject spec with array components.schemas', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        components: { schemas: [] },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "components.schemas" must be an object');
    });

    it('should reject spec with non-object components.responses', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        components: { responses: 'invalid' },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "components.responses" must be an object');
    });

    it('should reject spec with non-object components.parameters', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
        components: { parameters: 'invalid' },
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Field "components.parameters" must be an object');
    });

    it('should collect multiple validation errors', () => {
      const spec = {
        openapi: '2.0',
        info: { title: '', version: '' },
        paths: {},
      };

      const result = validateSpec(spec);
      expect(result.valid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(1);
      expect(result.errors.some(err => err.includes('Unsupported OpenAPI version'))).toBe(true);
      expect(result.errors.some(err => err.includes('info.title'))).toBe(true);
      expect(result.errors.some(err => err.includes('info.version'))).toBe(true);
      expect(result.errors.some(err => err.includes('paths'))).toBe(true);
    });
  });

  describe('isValidSpec', () => {
    it('should return true for valid spec', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
      };

      expect(isValidSpec(spec)).toBe(true);
    });

    it('should return false for invalid spec', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test' },
        paths: {},
      };

      expect(isValidSpec(spec)).toBe(false);
    });
  });

  describe('validateSpecOrThrow', () => {
    it('should not throw for valid spec', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test', version: '1.0.0' },
        paths: { '/test': {} },
      };

      expect(() => validateSpecOrThrow(spec)).not.toThrow();
    });

    it('should throw error for invalid spec', () => {
      const spec = {
        openapi: '3.0.0',
        info: { title: 'Test' },
        paths: {},
      };

      expect(() => validateSpecOrThrow(spec)).toThrow('OpenAPI specification validation failed');
    });

    it('should include all validation errors in thrown error message', () => {
      const spec = {
        openapi: '2.0',
        info: { title: '' },
        paths: {},
      };

      try {
        validateSpecOrThrow(spec);
        fail('Should have thrown an error');
      } catch (error: any) {
        expect(error.message).toContain('Unsupported OpenAPI version');
        expect(error.message).toContain('info.title');
        expect(error.message).toContain('info.version');
        expect(error.message).toContain('paths');
      }
    });
  });
});
