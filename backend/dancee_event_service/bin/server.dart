import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'package:dancee_event_service/router.dart';
import 'package:dancee_event_service/handlers/events_handler.dart';
import 'package:dancee_event_service/handlers/favorites_handler.dart';
import 'package:dancee_event_service/services/event_service.dart';
import 'package:dancee_event_service/services/favorites_service.dart';
import 'package:dancee_event_service/repositories/event_repository.dart';
import 'package:dancee_event_service/repositories/favorites_repository.dart';
import 'package:dancee_event_service/middleware/cors_middleware.dart';

/// Main entry point for the Dancee Event Service REST API.
void main(List<String> args) async {
  final eventRepository = EventRepository();
  final favoritesRepository = FavoritesRepository();

  final eventService = EventService(eventRepository);
  final favoritesService = FavoritesService(favoritesRepository, eventRepository);

  final eventsHandler = EventsHandler(eventService);
  final favoritesHandler = FavoritesHandler(favoritesService);

  final router = configureRoutes(eventsHandler, favoritesHandler);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router.call);

  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);

  print('Server listening on port ${server.port}');
  print('Available endpoints:');
  print('  GET    /health                      - Health check');
  print('  GET    /api/events                  - List all dance events');
  print('  GET    /api/favorites?userId=<id>   - List user\'s favorite events');
  print('  POST   /api/favorites               - Add event to favorites');
  print('  DELETE /api/favorites/<eventId>?userId=<id> - Remove event from favorites');
}
