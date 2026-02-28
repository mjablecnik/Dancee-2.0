/**
 * Health Check Routes
 * Provides health status endpoint for monitoring service availability
 * 
 * Requirements: 5.1, 5.2, 5.3, 5.4
 */

import { Router, Request, Response } from 'express';
import { SpecAggregator } from '../aggregator/spec-aggregator';

/**
 * Health status response interface
 */
interface HealthStatus {
  status: 'ok' | 'degraded';
  services: Record<string, string>;
}

/**
 * Create health check router
 * @param specAggregator - Spec aggregator instance
 * @returns Express router with health check endpoint
 */
export function createHealthRouter(specAggregator: SpecAggregator): Router {
  const router = Router();

  /**
   * GET /health
   * Health check endpoint
   * 
   * Returns overall service status and individual spec loading status
   * Response time target: < 50ms
   * 
   * Requirements: 5.1, 5.2, 5.3, 5.4
   */
  router.get('/health', (_req: Request, res: Response) => {
    const loadedServices = specAggregator.getLoadedServiceIds();
    const serviceStatus: Record<string, string> = {};

    // Get status for each loaded service
    for (const serviceId of loadedServices) {
      serviceStatus[serviceId] = 'loaded';
    }

    // Determine overall status
    const status: 'ok' | 'degraded' = loadedServices.length > 0 ? 'ok' : 'degraded';

    const healthStatus: HealthStatus = {
      status,
      services: serviceStatus,
    };

    res.status(200).json(healthStatus);
  });

  return router;
}
