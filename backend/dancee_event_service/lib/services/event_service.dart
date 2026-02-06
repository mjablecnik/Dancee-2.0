import 'package:dancee_shared/dancee_shared.dart';
import '../repositories/event_repository.dart';

/// Service layer for managing dance events.
class EventService {
  final EventRepository _repository;

  EventService(this._repository);

  /// Retrieves all available dance events.
  Future<List<Event>> getAllEvents() async {
    return _repository.getAllEvents();
  }
}
