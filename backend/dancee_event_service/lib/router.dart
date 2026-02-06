import 'package:shelf_router/shelf_router.dart';

import 'handlers/events_handler.dart';
import 'handlers/favorites_handler.dart';
import 'handlers/health_handler.dart';

/// Configures all API routes for the dancee_event_service.
Router configureRoutes(
  EventsHandler eventsHandler,
  FavoritesHandler favoritesHandler,
) {
  final router = Router();

  router.get('/health', healthHandler);
  router.get('/api/events', eventsHandler.listEvents);
  router.get('/api/favorites', favoritesHandler.listFavorites);
  router.post('/api/favorites', favoritesHandler.addFavorite);
  router.delete('/api/favorites/<eventId>', favoritesHandler.removeFavorite);

  return router;
}
