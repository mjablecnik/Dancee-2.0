/**
 * OpenAPI Specification Validator
 * Validates OpenAPI 3.0 specifications for compliance and required fields
 */

/**
 * Validation result interface
 */
export interface ValidationResult {
  valid: boolean;
  errors: string[];
}

/**
 * OpenAPI 3.0 specification interface (minimal required fields)
 */
export interface OpenAPISpec {
  openapi: string;
  info: {
    title: string;
    version: string;
    description?: string;
    contact?: {
      name?: string;
      email?: string;
    };
  };
  servers?: Array<{
    url: string;
    description?: string;
  }>;
  paths: Record<string, any>;
  components?: {
    schemas?: Record<string, any>;
    responses?: Record<string, any>;
    parameters?: Record<string, any>;
  };
}

/**
 * Validate OpenAPI specification for OpenAPI 3.0 compliance
 * Checks required fields and basic structure
 * 
 * @param spec - The OpenAPI specification object to validate
 * @returns ValidationResult with valid flag and array of error messages
 */
export function validateSpec(spec: any): ValidationResult {
  const errors: string[] = [];

  // Check if spec is an object (not null, not array, not primitive)
  if (!spec || typeof spec !== 'object' || Array.isArray(spec)) {
    return {
      valid: false,
      errors: ['Specification must be a valid object'],
    };
  }

  // Validate 'openapi' field (required)
  if (!spec.openapi) {
    errors.push('Missing required field: openapi');
  } else if (typeof spec.openapi !== 'string') {
    errors.push('Field "openapi" must be a string');
  } else if (!spec.openapi.startsWith('3.0')) {
    errors.push(`Unsupported OpenAPI version: ${spec.openapi}. Only OpenAPI 3.0.x is supported.`);
  }

  // Validate 'info' field (required)
  if (!spec.info) {
    errors.push('Missing required field: info');
  } else if (typeof spec.info !== 'object') {
    errors.push('Field "info" must be an object');
  } else {
    // Validate info.title (required)
    if (!spec.info.title) {
      errors.push('Missing required field: info.title');
    } else if (typeof spec.info.title !== 'string') {
      errors.push('Field "info.title" must be a string');
    } else if (spec.info.title.trim() === '') {
      errors.push('Field "info.title" cannot be empty');
    }

    // Validate info.version (required)
    if (!spec.info.version) {
      errors.push('Missing required field: info.version');
    } else if (typeof spec.info.version !== 'string') {
      errors.push('Field "info.version" must be a string');
    } else if (spec.info.version.trim() === '') {
      errors.push('Field "info.version" cannot be empty');
    }

    // Validate info.description (optional)
    if (spec.info.description !== undefined && typeof spec.info.description !== 'string') {
      errors.push('Field "info.description" must be a string');
    }

    // Validate info.contact (optional)
    if (spec.info.contact !== undefined) {
      if (typeof spec.info.contact !== 'object') {
        errors.push('Field "info.contact" must be an object');
      } else {
        if (spec.info.contact.name !== undefined && typeof spec.info.contact.name !== 'string') {
          errors.push('Field "info.contact.name" must be a string');
        }
        if (spec.info.contact.email !== undefined && typeof spec.info.contact.email !== 'string') {
          errors.push('Field "info.contact.email" must be a string');
        }
      }
    }
  }

  // Validate 'paths' field (required)
  if (!spec.paths) {
    errors.push('Missing required field: paths');
  } else if (typeof spec.paths !== 'object' || Array.isArray(spec.paths)) {
    errors.push('Field "paths" must be an object');
  } else if (Object.keys(spec.paths).length === 0) {
    errors.push('Field "paths" cannot be empty - at least one path must be defined');
  }

  // Validate 'servers' field (optional but recommended)
  if (spec.servers !== undefined) {
    if (!Array.isArray(spec.servers)) {
      errors.push('Field "servers" must be an array');
    } else {
      spec.servers.forEach((server: any, index: number) => {
        if (typeof server !== 'object') {
          errors.push(`Server at index ${index} must be an object`);
        } else {
          if (!server.url) {
            errors.push(`Server at index ${index} is missing required field: url`);
          } else if (typeof server.url !== 'string') {
            errors.push(`Server at index ${index}: field "url" must be a string`);
          }
          if (server.description !== undefined && typeof server.description !== 'string') {
            errors.push(`Server at index ${index}: field "description" must be a string`);
          }
        }
      });
    }
  }

  // Validate 'components' field (optional)
  if (spec.components !== undefined) {
    if (typeof spec.components !== 'object' || Array.isArray(spec.components)) {
      errors.push('Field "components" must be an object');
    } else {
      // Validate components.schemas (optional)
      if (spec.components.schemas !== undefined) {
        if (typeof spec.components.schemas !== 'object' || Array.isArray(spec.components.schemas)) {
          errors.push('Field "components.schemas" must be an object');
        }
      }

      // Validate components.responses (optional)
      if (spec.components.responses !== undefined) {
        if (typeof spec.components.responses !== 'object' || Array.isArray(spec.components.responses)) {
          errors.push('Field "components.responses" must be an object');
        }
      }

      // Validate components.parameters (optional)
      if (spec.components.parameters !== undefined) {
        if (typeof spec.components.parameters !== 'object' || Array.isArray(spec.components.parameters)) {
          errors.push('Field "components.parameters" must be an object');
        }
      }
    }
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

/**
 * Check if a specification is valid OpenAPI 3.0
 * Convenience function that returns boolean
 * 
 * @param spec - The OpenAPI specification object to validate
 * @returns true if valid, false otherwise
 */
export function isValidSpec(spec: any): boolean {
  return validateSpec(spec).valid;
}

/**
 * Validate and throw error if invalid
 * Useful for fail-fast validation
 * 
 * @param spec - The OpenAPI specification object to validate
 * @throws Error with validation errors if spec is invalid
 */
export function validateSpecOrThrow(spec: any): void {
  const result = validateSpec(spec);
  if (!result.valid) {
    throw new Error(`OpenAPI specification validation failed:\n${result.errors.join('\n')}`);
  }
}
