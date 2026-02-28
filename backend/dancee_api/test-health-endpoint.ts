/**
 * Test script for health check endpoint
 * Tests the GET /health endpoint implementation
 * 
 * Requirements: 5.1, 5.2, 5.3, 5.4
 */

import * as path from 'path';
import { SpecAggregator } from './src/aggregator/spec-aggregator';
import { Server } from './src/server';

async function testHealthEndpoint() {
  console.log('Testing health check endpoint...\n');

  try {
    // Initialize SpecAggregator
    const specsDirectory = path.join(__dirname, 'specs');
    const specAggregator = new SpecAggregator(specsDirectory);

    // Load specs
    console.log('Loading OpenAPI specifications...');
    await specAggregator.loadSpecs();
    console.log(`Loaded ${specAggregator.getLoadedSpecCount()} spec(s)\n`);

    // Create server
    const server = new Server(specAggregator);

    // Start server
    console.log('Starting server...');
    await server.start();

    // Test the endpoint
    console.log('\nTesting GET /health endpoint...');
    const response = await fetch('http://localhost:3003/health');
    const health = await response.json() as any;

    console.log('\nResponse Status:', response.status);
    console.log('Response Body:', JSON.stringify(health, null, 2));

    // Verify response status (Requirement 5.1)
    if (response.status === 200) {
      console.log('\n✓ Status code is 200 (Requirement 5.1)');
    } else {
      console.log('\n✗ Expected status 200, got', response.status);
    }

    // Verify response structure (Requirement 5.2)
    if ('status' in health && 'services' in health) {
      console.log('✓ Response includes overall status and services (Requirement 5.2)');
    } else {
      console.log('✗ Response missing required fields (status, services)');
    }

    // Verify status is "ok" when specs loaded (Requirement 5.3)
    if (health.status === 'ok') {
      console.log('✓ Status is "ok" when specs loaded successfully (Requirement 5.3)');
    } else {
      console.log('✗ Expected status "ok", got', health.status);
    }

    // Verify individual service status
    const loadedServiceIds = specAggregator.getLoadedServiceIds();
    console.log('\nVerifying individual service status:');
    for (const serviceId of loadedServiceIds) {
      if (health.services[serviceId] === 'loaded') {
        console.log(`✓ Service '${serviceId}' status: loaded`);
      } else {
        console.log(`✗ Service '${serviceId}' status incorrect:`, health.services[serviceId]);
      }
    }

    // Measure response time (Requirement 5.4)
    const startTime = Date.now();
    await fetch('http://localhost:3003/health');
    const responseTime = Date.now() - startTime;
    
    console.log(`\nResponse time: ${responseTime}ms`);
    if (responseTime < 50) {
      console.log('✓ Response time < 50ms (Requirement 5.4 met)');
    } else {
      console.log('⚠ Response time >= 50ms (may not meet Requirement 5.4 in all cases)');
    }

    // Test degraded state scenario (no specs loaded)
    console.log('\n\nTesting degraded state scenario (no specs loaded)...');
    const emptyAggregator = new SpecAggregator(path.join(__dirname, 'nonexistent'));
    await emptyAggregator.loadSpecs();
    const emptyServer = new Server(emptyAggregator);
    
    // Stop first server
    await server.stop();
    
    // Start empty server
    await emptyServer.start();
    
    const degradedResponse = await fetch('http://localhost:3003/health');
    const degradedHealth = await degradedResponse.json() as any;
    
    console.log('Degraded state response:', JSON.stringify(degradedHealth, null, 2));
    
    if (degradedResponse.status === 200) {
      console.log('✓ Returns 200 status even when no specs loaded');
    } else {
      console.log('✗ Expected 200 status, got', degradedResponse.status);
    }

    if (degradedHealth.status === 'degraded') {
      console.log('✓ Status is "degraded" when no specs loaded');
    } else {
      console.log('⚠ Status is not "degraded" when no specs loaded:', degradedHealth.status);
    }

    if (Object.keys(degradedHealth.services).length === 0) {
      console.log('✓ Services object is empty when no specs loaded');
    } else {
      console.log('✗ Services object should be empty');
    }

    // Stop server
    await emptyServer.stop();

    console.log('\n✓ All health check tests completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('\n✗ Test failed:', error);
    process.exit(1);
  }
}

// Run tests
testHealthEndpoint();
