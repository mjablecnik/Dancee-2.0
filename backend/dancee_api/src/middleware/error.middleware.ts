import { Request, Response, NextFunction } from 'express';

/**
 * Error response interface for consistent error formatting.
 */
interface ErrorResponse {
  error: string;
  message: string;
}

/**
 * Global error handling middleware for the API documentation service.
 * 
 * Catches all unhandled errors and returns appropriate HTTP responses.
 * Ensures no sensitive information is exposed in error messages.
 * Logs errors for debugging purposes.
 * 
 * Requirements: 7.2, 7.5
 */
export function errorMiddleware(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  // Log the full error for debugging (includes stack trace)
  console.error('Error occurred:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    timestamp: new Date().toISOString(),
  });

  // Return generic error message to client (no sensitive information)
  const errorResponse: ErrorResponse = {
    error: 'Internal Server Error',
    message: 'An unexpected error occurred. Please try again later.',
  };

  res.status(500).json(errorResponse);
}
