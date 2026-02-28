/**
 * Unit tests for services routes
 * Tests the GET /api/services endpoint
 */

import { Request, Response } from 'express';
import { createServicesRouter } from './services.routes';
import { SpecAggregator } from '../aggregator/spec-aggregator';
import { ServiceInfo } from '../aggregator/spec-aggregator';

// Mock SpecAggregator
class MockSpecAggregator extends SpecAggregator {
  private mockServices: ServiceInfo[] = [];

  constructor(services: ServiceInfo[] = []) {
    super('');
    this.mockServices = services;
  }

  getServiceList(): ServiceInfo[] {
    return this.mockServices;
  }
}

describe('Services Routes', () => {
  describe('GET /api/services', () => {
    it('should return array of services when services are available', () => {
      // Arrange
      const mockServices: ServiceInfo[] = [
        {
          id: 'test-service-1',
          name: 'Test Service 1',
          version: '1.0.0',
          description: 'Test service description',
          baseUrl: 'http://localhost:8080',
          specPath: '/api/spec/test-service-1',
        },
        {
          id: 'test-service-2',
          name: 'Test Service 2',
          version: '2.0.0',
          description: 'Another test service',
          baseUrl: 'http://localhost:8081',
          specPath: '/api/spec/test-service-2',
        },
      ];

      const mockAggregator = new MockSpecAggregator(mockServices);
      const router = createServicesRouter(mockAggregator);

      // Create mock request and response
      const mockReq = {} as Request;
      const mockRes = {
        json: jest.fn(),
      } as unknown as Response;

      // Act
      // Get the route handler
      const routeStack = (router as any).stack;
      const servicesRoute = routeStack.find((layer: any) => 
        layer.route && layer.route.path === '/api/services'
      );
      const handler = servicesRoute.route.stack[0].handle;
      
      handler(mockReq, mockRes);

      // Assert
      expect(mockRes.json).toHaveBeenCalledWith(mockServices);
      expect(mockRes.json).toHaveBeenCalledTimes(1);
    });

    it('should return empty array when no services are available', () => {
      // Arrange
      const mockAggregator = new MockSpecAggregator([]);
      const router = createServicesRouter(mockAggregator);

      // Create mock request and response
      const mockReq = {} as Request;
      const mockRes = {
        json: jest.fn(),
      } as unknown as Response;

      // Act
      const routeStack = (router as any).stack;
      const servicesRoute = routeStack.find((layer: any) => 
        layer.route && layer.route.path === '/api/services'
      );
      const handler = servicesRoute.route.stack[0].handle;
      
      handler(mockReq, mockRes);

      // Assert
      expect(mockRes.json).toHaveBeenCalledWith([]);
      expect(mockRes.json).toHaveBeenCalledTimes(1);
    });

    it('should include all required fields in service objects', () => {
      // Arrange
      const mockService: ServiceInfo = {
        id: 'test-service',
        name: 'Test Service',
        version: '1.0.0',
        description: 'Test description',
        baseUrl: 'http://localhost:8080',
        specPath: '/api/spec/test-service',
      };

      const mockAggregator = new MockSpecAggregator([mockService]);
      const router = createServicesRouter(mockAggregator);

      // Create mock request and response
      const mockReq = {} as Request;
      let capturedResponse: any;
      const mockRes = {
        json: jest.fn((data) => {
          capturedResponse = data;
        }),
      } as unknown as Response;

      // Act
      const routeStack = (router as any).stack;
      const servicesRoute = routeStack.find((layer: any) => 
        layer.route && layer.route.path === '/api/services'
      );
      const handler = servicesRoute.route.stack[0].handle;
      
      handler(mockReq, mockRes);

      // Assert
      expect(capturedResponse).toHaveLength(1);
      const service = capturedResponse[0];
      expect(service).toHaveProperty('id');
      expect(service).toHaveProperty('name');
      expect(service).toHaveProperty('version');
      expect(service).toHaveProperty('description');
      expect(service).toHaveProperty('baseUrl');
      expect(service).toHaveProperty('specPath');
    });
  });
});
