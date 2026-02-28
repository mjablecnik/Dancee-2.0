import cors from 'cors';
import { CorsOptions } from 'cors';
import { appConfig } from '../config/app.config';

/**
 * CORS middleware configuration for the API documentation service.
 * 
 * In development mode, allows requests from all origins.
 * In production, restricts to configured origins.
 * 
 * Allows standard HTTP methods and headers needed for API testing.
 */
export const corsMiddleware = cors(getCorsOptions());

/**
 * Get CORS configuration options based on environment.
 * 
 * @returns CORS options for the cors middleware
 */
function getCorsOptions(): CorsOptions {
  const isDevelopment = appConfig.nodeEnv === 'development';

  return {
    // Allow all origins in development, restrict in production
    origin: isDevelopment ? '*' : appConfig.corsOrigins,
    
    // Allow standard HTTP methods for RESTful APIs
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    
    // Allow standard headers including Content-Type and Authorization
    allowedHeaders: ['Content-Type', 'Authorization'],
    
    // Enable credentials if needed
    credentials: false,
    
    // Cache preflight requests for 24 hours
    maxAge: 86400,
  };
}
