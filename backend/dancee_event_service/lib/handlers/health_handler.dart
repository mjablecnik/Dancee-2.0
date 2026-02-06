import 'dart:convert';

import 'package:shelf/shelf.dart';

/// HTTP handler for the health check endpoint.

/// Handles GET /health requests to check service health status.
Response healthHandler(Request request) {
  return Response.ok(
    jsonEncode({
      'status': 'ok',
      'service': 'dancee_event_service',
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
