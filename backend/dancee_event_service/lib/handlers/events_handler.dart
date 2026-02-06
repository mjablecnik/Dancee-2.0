import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../services/event_service.dart';

/// HTTP handler for dance event endpoints.
class EventsHandler {
  final EventService _eventService;

  EventsHandler(this._eventService);

  /// Handles GET /api/events requests to list all dance events.
  Future<Response> listEvents(Request request) async {
    try {
      final events = await _eventService.getAllEvents();
      final jsonEvents = events.map((event) => event.toJson()).toList();
      
      return Response.ok(
        jsonEncode(jsonEvents),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in listEvents: $e');
      return _errorResponse(500, 'Internal server error');
    }
  }

  Response _errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
