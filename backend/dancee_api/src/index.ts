/**
 * Application Entry Point
 * Centralized API Documentation Service
 * 
 * Requirements: 1.1, 1.4, 1.5
 */

import * as path from 'path';
import { appConfig } from './config/app.config';
import { SpecAggregator } from './aggregator/spec-aggregator';
import { Server } from './server';

/**
 * Main application startup function
 */
async function main() {
  try {
    console.log('Dancee API Documentation Service - Starting...');
    console.log(`Environment: ${appConfig.nodeEnv}`);

    // Initialize SpecAggregator with specs directory
    const specsDirectory = path.join(__dirname, '..', 'specs');
    const specAggregator = new SpecAggregator(specsDirectory);

    // Load all OpenAPI specifications
    await specAggregator.loadSpecs();

    // Create and configure Express server
    const server = new Server(specAggregator);

    // Start the server
    await server.start();

  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Start the application
main();
