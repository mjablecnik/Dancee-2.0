import { SwaggerAuthMiddleware } from './swagger-auth.middleware';
import { Request, Response } from 'express';

describe('SwaggerAuthMiddleware', () => {
  let middleware: SwaggerAuthMiddleware;
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let nextFunction: jest.Mock;

  beforeEach(() => {
    middleware = new SwaggerAuthMiddleware();
    mockRequest = {
      headers: {},
      originalUrl: '/api', // Default to Swagger route
      url: '/api',
    };
    mockResponse = {
      status: jest.fn().mockReturnThis(),
      send: jest.fn().mockReturnThis(),
      setHeader: jest.fn(),
    };
    nextFunction = jest.fn();
  });

  afterEach(() => {
    delete process.env.NODE_ENV;
    delete process.env.SWAGGER_USER;
    delete process.env.SWAGGER_PASSWORD;
  });

  describe('Development Environment', () => {
    it('should allow access without authentication in development', () => {
      process.env.NODE_ENV = 'development';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });

    it('should allow access without NODE_ENV set', () => {
      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });
  });

  describe('Production Environment', () => {
    beforeEach(() => {
      process.env.NODE_ENV = 'production';
      process.env.SWAGGER_USER = 'testuser';
      process.env.SWAGGER_PASSWORD = 'testpass';
    });

    it('should return 401 when no authorization header is provided', () => {
      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(mockResponse.setHeader).toHaveBeenCalledWith(
        'WWW-Authenticate',
        'Basic realm="Swagger Documentation"',
      );
      expect(mockResponse.status).toHaveBeenCalledWith(401);
      expect(mockResponse.send).toHaveBeenCalledWith('Authentication required');
      expect(nextFunction).not.toHaveBeenCalled();
    });

    it('should return 401 when authorization header is malformed', () => {
      mockRequest.headers = {
        authorization: 'Bearer token123',
      };

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(401);
      expect(nextFunction).not.toHaveBeenCalled();
    });

    it('should return 401 when credentials are incorrect', () => {
      const wrongCredentials =
        Buffer.from('wrong:credentials').toString('base64');
      mockRequest.headers = {
        authorization: `Basic ${wrongCredentials}`,
      };

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(401);
      expect(nextFunction).not.toHaveBeenCalled();
    });

    it('should allow access with correct credentials', () => {
      const correctCredentials =
        Buffer.from('testuser:testpass').toString('base64');
      mockRequest.headers = {
        authorization: `Basic ${correctCredentials}`,
      };

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });

    it('should use default credentials when env vars are not set', () => {
      delete process.env.SWAGGER_USER;
      delete process.env.SWAGGER_PASSWORD;

      const defaultCredentials =
        Buffer.from('admin:changeme').toString('base64');
      mockRequest.headers = {
        authorization: `Basic ${defaultCredentials}`,
      };

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });
  });

  describe('Path Detection', () => {
    beforeEach(() => {
      process.env.NODE_ENV = 'production';
      process.env.SWAGGER_USER = 'testuser';
      process.env.SWAGGER_PASSWORD = 'testpass';
    });

    it('should protect /api route', () => {
      mockRequest.originalUrl = '/api';
      mockRequest.url = '/api';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(401);
      expect(nextFunction).not.toHaveBeenCalled();
    });

    it('should protect /api/ route', () => {
      mockRequest.originalUrl = '/api/';
      mockRequest.url = '/api/';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(401);
      expect(nextFunction).not.toHaveBeenCalled();
    });

    it('should protect /api/* routes', () => {
      mockRequest.originalUrl = '/api/swagger-ui.css';
      mockRequest.url = '/api/swagger-ui.css';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(401);
      expect(nextFunction).not.toHaveBeenCalled();
    });

    it('should allow /events/list route without authentication', () => {
      mockRequest.originalUrl = '/events/list';
      mockRequest.url = '/events/list';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });

    it('should allow /events/favorites route without authentication', () => {
      mockRequest.originalUrl = '/events/favorites';
      mockRequest.url = '/events/favorites';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });

    it('should allow /scraper routes without authentication', () => {
      mockRequest.originalUrl = '/scraper/event/123';
      mockRequest.url = '/scraper/event/123';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });

    it('should allow /api-json route without authentication', () => {
      mockRequest.originalUrl = '/api-json';
      mockRequest.url = '/api-json';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });

    it('should handle query strings correctly', () => {
      mockRequest.originalUrl = '/events/list?page=1&limit=10';
      mockRequest.url = '/events/list?page=1&limit=10';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });

    it('should use req.url as fallback when originalUrl is not available', () => {
      mockRequest.originalUrl = undefined;
      mockRequest.url = '/events/list';

      middleware.use(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction,
      );

      expect(nextFunction).toHaveBeenCalled();
      expect(mockResponse.status).not.toHaveBeenCalled();
    });
  });
});
