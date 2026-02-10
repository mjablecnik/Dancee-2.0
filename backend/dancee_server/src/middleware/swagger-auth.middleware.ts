import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

/**
 * Middleware for protecting Swagger documentation with HTTP Basic Authentication
 * Only active in production environment
 */
@Injectable()
export class SwaggerAuthMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Only protect Swagger routes, not the events API or other endpoints
    // Use req.originalUrl instead of req.path to get the full URL path
    // req.path can be "/" when middleware is applied globally in NestJS
    const fullUrl = req.originalUrl || req.url;
    // Remove query string if present
    const path = fullUrl.split('?')[0];

    console.log('SwaggerAuthMiddleware: Checking fullUrl:', fullUrl);
    console.log('SwaggerAuthMiddleware: Checking path:', path);
    console.log('SwaggerAuthMiddleware: Checking env:', process.env.NODE_ENV);
    
    // Swagger is mounted at /api and serves static files from /api/*
    // We want to protect /api and /api/* but NOT /api-json
    const isSwaggerRoute =
      path === '/api' ||
      path === '/api/' ||
      (path.startsWith('/api/') && !path.startsWith('/api-json'));

    // If not a Swagger route, allow access
    if (!isSwaggerRoute) {
      return next();
    }

    // Skip authentication in development
    if (process.env.NODE_ENV !== 'production') {
      return next();
    }

    // Get credentials from environment variables
    const swaggerUser = process.env.SWAGGER_USER || 'admin';
    const swaggerPassword = process.env.SWAGGER_PASSWORD || 'changeme';

    // Parse Authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Basic ')) {
      return this.requestAuth(res);
    }

    // Decode Base64 credentials
    const base64Credentials = authHeader.split(' ')[1];
    const credentials = Buffer.from(base64Credentials, 'base64').toString(
      'utf-8',
    );
    const [username, password] = credentials.split(':');

    // Verify credentials
    if (username === swaggerUser && password === swaggerPassword) {
      return next();
    }

    return this.requestAuth(res);
  }

  /**
   * Send 401 Unauthorized response with WWW-Authenticate header
   */
  private requestAuth(res: Response) {
    res.setHeader('WWW-Authenticate', 'Basic realm="Swagger Documentation"');
    res.status(401).send('Authentication required');
  }
}
