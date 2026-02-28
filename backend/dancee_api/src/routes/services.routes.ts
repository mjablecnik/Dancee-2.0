/**
 * Services Routes
 * Handles service listing endpoint
 * 
 * Requirements: 2.1, 2.2, 2.3, 2.4
 */

import { Router, Request, Response } from 'express';
import { SpecAggregator } from '../aggregator/spec-aggregator';

/**
 * Create services router
 * @param specAggregator - Spec aggregator instance for retrieving service list
 * @returns Express router with services routes
 */
export function createServicesRouter(specAggregator: SpecAggregator): Router {
  const router = Router();

  /**
   * GET /api/services
   * Get list of all available backend services
   * 
   * Returns JSON array of all enabled services with:
   * - id: Service identifier
   * - name: Service name
   * - version: Service version
   * - description: Service description
   * - baseUrl: Service base URL
   * - specPath: Path to OpenAPI spec
   * 
   * Returns empty array with 200 status when no services available
   * Response time target: < 100ms
   * 
   * Requirements: 2.1, 2.2, 2.3, 2.4
   */
  router.get('/api/services', (_req: Request, res: Response) => {
    // Get service list from aggregator (cached in memory, fast retrieval)
    const services = specAggregator.getServiceList();
    
    // Return service list (empty array if no services loaded)
    res.json(services);
  });

  return router;
}
