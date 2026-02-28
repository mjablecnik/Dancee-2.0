/**
 * Test script for services endpoint
 * Tests the GET /api/services endpoint implementation
 */

import * as path from 'path';
import { SpecAggregator } from './src/aggregator/spec-aggregator';
import { Server } from './src/server';

async function testServicesEndpoint() {
  console.log('Testing services endpoint...\n');

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
    console.log('\nTesting GET /api/services endpoint...');
    const response = await fetch('http://localhost:3003/api/services');
    const services = await response.json();

    console.log('\nResponse Status:', response.status);
    console.log('Response Body:', JSON.stringify(services, null, 2));

    // Verify response
    if (response.status === 200) {
      console.log('\n✓ Status code is 200');
    } else {
      console.log('\n✗ Expected status 200, got', response.status);
    }

    if (Array.isArray(services)) {
      console.log('✓ Response is an array');
      console.log(`✓ Array contains ${services.length} service(s)`);

      // Check each service has required fields
      if (services.length > 0) {
        const requiredFields = ['id', 'name', 'version', 'description', 'baseUrl', 'specPath'];
        const firstService = services[0];
        
        console.log('\nChecking required fields in first service:');
        for (const field of requiredFields) {
          if (field in firstService) {
            console.log(`✓ Field '${field}' present:`, firstService[field]);
          } else {
            console.log(`✗ Field '${field}' missing`);
          }
        }
      }
    } else {
      console.log('✗ Response is not an array');
    }

    // Measure response time
    const startTime = Date.now();
    await fetch('http://localhost:3003/api/services');
    const responseTime = Date.now() - startTime;
    
    console.log(`\nResponse time: ${responseTime}ms`);
    if (responseTime < 100) {
      console.log('✓ Response time < 100ms (requirement met)');
    } else {
      console.log('✗ Response time >= 100ms (requirement not met)');
    }

    // Test empty services scenario
    console.log('\n\nTesting empty services scenario...');
    const emptyAggregator = new SpecAggregator(path.join(__dirname, 'nonexistent'));
    await emptyAggregator.loadSpecs();
    const emptyServer = new Server(emptyAggregator);
    
    // Stop first server
    await server.stop();
    
    // Start empty server
    await emptyServer.start();
    
    const emptyResponse = await fetch('http://localhost:3003/api/services');
    const emptyServices = await emptyResponse.json();
    
    console.log('Empty services response:', JSON.stringify(emptyServices, null, 2));
    
    if (emptyResponse.status === 200 && Array.isArray(emptyServices) && emptyServices.length === 0) {
      console.log('✓ Returns empty array with 200 status when no services available');
    } else {
      console.log('✗ Empty services test failed');
    }

    // Stop server
    await emptyServer.stop();

    console.log('\n✓ All tests completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('\n✗ Test failed:', error);
    process.exit(1);
  }
}

// Run tests
testServicesEndpoint();
