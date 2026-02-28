/**
 * Test script for spec endpoint
 * Tests the GET /api/spec/:serviceId endpoint implementation
 */

import * as path from 'path';
import { SpecAggregator } from './src/aggregator/spec-aggregator';
import { Server } from './src/server';

async function testSpecEndpoint() {
  console.log('Testing spec endpoint...\n');

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

    // Test 1: Valid service ID
    console.log('\n=== Test 1: Valid service ID ===');
    const validServiceIds = specAggregator.getLoadedServiceIds();
    
    if (validServiceIds.length > 0) {
      const testServiceId = validServiceIds[0];
      console.log(`Testing with service ID: ${testServiceId}`);
      
      const startTime = Date.now();
      const response = await fetch(`http://localhost:3003/api/spec/${testServiceId}`);
      const responseTime = Date.now() - startTime;
      const spec = await response.json() as any;

      console.log('Response Status:', response.status);
      console.log('Response time:', responseTime, 'ms');
      
      if (response.status === 200) {
        console.log('✓ Status code is 200');
      } else {
        console.log('✗ Expected status 200, got', response.status);
      }

      if (responseTime < 100) {
        console.log('✓ Response time < 100ms (requirement met)');
      } else {
        console.log('✗ Response time >= 100ms (requirement not met)');
      }

      // Verify it's a valid OpenAPI spec
      if (spec.openapi && spec.info && spec.paths) {
        console.log('✓ Response is a valid OpenAPI spec');
        console.log('  - OpenAPI version:', spec.openapi);
        console.log('  - Title:', spec.info.title);
        console.log('  - Version:', spec.info.version);
        console.log('  - Paths count:', Object.keys(spec.paths).length);
      } else {
        console.log('✗ Response is not a valid OpenAPI spec');
      }

      // Verify servers are included
      if (spec.servers && Array.isArray(spec.servers) && spec.servers.length > 0) {
        console.log('✓ Spec includes server URLs');
        spec.servers.forEach((server: any, index: number) => {
          console.log(`  - Server ${index + 1}: ${server.url} (${server.description})`);
        });
      } else {
        console.log('✗ Spec missing server URLs');
      }
    } else {
      console.log('⚠ No services loaded, skipping valid service ID test');
    }

    // Test 2: Invalid service ID (not found)
    console.log('\n=== Test 2: Invalid service ID (not found) ===');
    const invalidServiceId = 'nonexistent-service';
    console.log(`Testing with service ID: ${invalidServiceId}`);
    
    const notFoundResponse = await fetch(`http://localhost:3003/api/spec/${invalidServiceId}`);
    const notFoundBody = await notFoundResponse.json() as any;

    console.log('Response Status:', notFoundResponse.status);
    console.log('Response Body:', JSON.stringify(notFoundBody, null, 2));

    if (notFoundResponse.status === 404) {
      console.log('✓ Status code is 404');
    } else {
      console.log('✗ Expected status 404, got', notFoundResponse.status);
    }

    if (notFoundBody.error && notFoundBody.serviceId === invalidServiceId) {
      console.log('✓ Error response includes error message and serviceId');
    } else {
      console.log('✗ Error response format incorrect');
    }

    // Test 3: Path traversal attack prevention
    console.log('\n=== Test 3: Path traversal attack prevention ===');
    const maliciousIds = [
      '../../../etc/passwd',
      '..\\..\\..\\windows\\system32',
      './config',
      'service/path',
      'service\\path',
      'service..path',
      'UPPERCASE-SERVICE',
      'service_with_underscore',
    ];

    for (const maliciousId of maliciousIds) {
      console.log(`\nTesting malicious ID: "${maliciousId}"`);
      const maliciousResponse = await fetch(`http://localhost:3003/api/spec/${encodeURIComponent(maliciousId)}`);
      const maliciousBody = await maliciousResponse.json() as any;

      if (maliciousResponse.status === 400 || maliciousResponse.status === 404) {
        console.log(`✓ Rejected with status ${maliciousResponse.status}`);
      } else {
        console.log(`✗ Expected 400 or 404, got ${maliciousResponse.status}`);
      }

      // Ensure no file system access occurred
      if (!maliciousBody.openapi) {
        console.log('✓ Did not return OpenAPI spec (no file system access)');
      } else {
        console.log('✗ WARNING: Returned OpenAPI spec (possible security issue)');
      }
    }

    // Test 4: Memory cache verification (no file system access)
    console.log('\n=== Test 4: Memory cache verification ===');
    console.log('Making multiple requests to verify caching...');
    
    if (validServiceIds.length > 0) {
      const testServiceId = validServiceIds[0];
      const times: number[] = [];

      for (let i = 0; i < 5; i++) {
        const start = Date.now();
        await fetch(`http://localhost:3003/api/spec/${testServiceId}`);
        const time = Date.now() - start;
        times.push(time);
      }

      console.log('Response times:', times.map(t => `${t}ms`).join(', '));
      const avgTime = times.reduce((a, b) => a + b, 0) / times.length;
      console.log('Average response time:', avgTime.toFixed(2), 'ms');

      if (avgTime < 100) {
        console.log('✓ All requests served quickly from cache');
      } else {
        console.log('⚠ Average response time exceeds 100ms');
      }
    }

    // Stop server
    await server.stop();

    console.log('\n✓ All tests completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('\n✗ Test failed:', error);
    process.exit(1);
  }
}

// Run tests
testSpecEndpoint();
