import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:dancee_event_service/middleware/cors_middleware.dart';

void main() {
  group('CORS Middleware', () {
    late Handler testHandler;

    setUp(() {
      // Create a simple test handler that returns a basic response
      testHandler = (Request request) {
        return Response.ok('Test response');
      };
    });

    test('should handle OPTIONS preflight request with 200 status', () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('OPTIONS', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.statusCode, equals(200));
    });

    test('should add Access-Control-Allow-Origin header to OPTIONS response',
        () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('OPTIONS', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.headers['access-control-allow-origin'], equals('*'));
    });

    test('should add Access-Control-Allow-Methods header to OPTIONS response',
        () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('OPTIONS', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.headers['access-control-allow-methods'],
          equals('GET, POST, DELETE, OPTIONS'));
    });

    test('should add Access-Control-Allow-Headers header to OPTIONS response',
        () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('OPTIONS', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.headers['access-control-allow-headers'],
          equals('Content-Type, Authorization'));
    });

    test('should add CORS headers to GET request response', () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('GET', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.headers['access-control-allow-origin'], equals('*'));
      expect(response.headers['access-control-allow-methods'],
          equals('GET, POST, DELETE, OPTIONS'));
      expect(response.headers['access-control-allow-headers'],
          equals('Content-Type, Authorization'));
    });

    test('should add CORS headers to POST request response', () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('POST', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.headers['access-control-allow-origin'], equals('*'));
      expect(response.headers['access-control-allow-methods'],
          equals('GET, POST, DELETE, OPTIONS'));
      expect(response.headers['access-control-allow-headers'],
          equals('Content-Type, Authorization'));
    });

    test('should add CORS headers to DELETE request response', () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('DELETE', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.headers['access-control-allow-origin'], equals('*'));
      expect(response.headers['access-control-allow-methods'],
          equals('GET, POST, DELETE, OPTIONS'));
      expect(response.headers['access-control-allow-headers'],
          equals('Content-Type, Authorization'));
    });

    test('should preserve original response body for non-OPTIONS requests',
        () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('GET', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      final body = await response.readAsString();
      expect(body, equals('Test response'));
    });

    test('should preserve original response status for non-OPTIONS requests',
        () async {
      final middleware = corsMiddleware();
      final handler = middleware(testHandler);

      final request = Request('GET', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.statusCode, equals(200));
    });

    test('should handle error responses with CORS headers', () async {
      // Create a handler that returns an error
      final errorHandler = (Request request) {
        return Response.internalServerError(body: 'Error occurred');
      };

      final middleware = corsMiddleware();
      final handler = middleware(errorHandler);

      final request = Request('GET', Uri.parse('http://localhost/test'));
      final response = await handler(request);

      expect(response.statusCode, equals(500));
      expect(response.headers['access-control-allow-origin'], equals('*'));
    });
  });
}
