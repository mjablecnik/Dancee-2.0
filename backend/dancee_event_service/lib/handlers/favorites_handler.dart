import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../services/favorites_service.dart';

/// HTTP handler for user favorites endpoints.
class FavoritesHandler {
  final FavoritesService _favoritesService;

  FavoritesHandler(this._favoritesService);

  /// Handles GET /api/favorites requests to list a user's favorite events.
  /// Requires a 'userId' query parameter.
  Future<Response> listFavorites(Request request) async {
    final userId = request.url.queryParameters['userId'];

    if (userId == null || userId.isEmpty) {
      return _errorResponse(400, 'userId query parameter is required');
    }

    try {
      final favoriteEvents = await _favoritesService.getFavorites(userId);
      final jsonEvents = favoriteEvents.map((event) => event.toJson()).toList();

      return Response.ok(
        jsonEncode(jsonEvents),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in listFavorites: $e');
      return _errorResponse(500, 'Internal server error');
    }
  }

  /// Handles POST /api/favorites requests to add an event to user's favorites.
  /// Requires JSON body with 'userId' and 'eventId' fields.
  Future<Response> addFavorite(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final userId = data['userId'] as String?;
      final eventId = data['eventId'] as String?;

      if (userId == null || userId.isEmpty || eventId == null || eventId.isEmpty) {
        return _errorResponse(400, 'userId and eventId are required');
      }

      final result = await _favoritesService.addFavorite(userId, eventId);

      if (!result.success) {
        return _errorResponse(result.statusCode, result.message);
      }

      return Response(
        201,
        body: jsonEncode({
          'message': 'Favorite added successfully',
          'userId': userId,
          'eventId': eventId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException {
      return _errorResponse(400, 'Invalid JSON in request body');
    } catch (e) {
      print('Error in addFavorite: $e');
      return _errorResponse(500, 'Internal server error');
    }
  }

  /// Handles DELETE /api/favorites/:eventId requests to remove an event from favorites.
  /// Requires 'userId' query parameter and 'eventId' path parameter.
  Future<Response> removeFavorite(Request request, String eventId) async {
    final userId = request.url.queryParameters['userId'];

    if (userId == null || userId.isEmpty) {
      return _errorResponse(400, 'userId query parameter is required');
    }

    try {
      final result = await _favoritesService.removeFavorite(userId, eventId);

      if (!result.success) {
        return _errorResponse(result.statusCode, result.message);
      }

      return Response(204);
    } catch (e) {
      print('Error in removeFavorite: $e');
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
