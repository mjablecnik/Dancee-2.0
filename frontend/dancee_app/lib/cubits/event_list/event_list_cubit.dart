import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import 'event_list_state.dart';

/// Cubit for managing event list screen state.
///
/// This cubit handles loading, searching, and filtering events.
/// Events are automatically grouped by date (today, tomorrow, upcoming)
/// for UI convenience.
class EventListCubit extends Cubit<EventListState> {
  final EventRepository repository;

  EventListCubit(this.repository) : super(const EventListInitial());

  /// Loads all events and groups them by date.
  ///
  /// Events are grouped into:
  /// - Today: Events starting today
  /// - Tomorrow: Events starting tomorrow
  /// - Upcoming: Events starting after tomorrow
  ///
  /// Emits [EventListLoading] while loading, then either
  /// [EventListLoaded] on success or [EventListError] on failure.
  Future<void> loadEvents() async {
    emit(const EventListLoading());
    try {
      final events = await repository.getAllEvents();
      
      // Group events by date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      final todayEvents = events.where((e) {
        final eventDate = DateTime(
          e.startTime.year,
          e.startTime.month,
          e.startTime.day,
        );
        return eventDate.isAtSameMomentAs(today) && !e.isPast;
      }).toList();
      
      final tomorrowEvents = events.where((e) {
        final eventDate = DateTime(
          e.startTime.year,
          e.startTime.month,
          e.startTime.day,
        );
        return eventDate.isAtSameMomentAs(tomorrow) && !e.isPast;
      }).toList();
      
      final upcomingEvents = events.where((e) {
        final eventDate = DateTime(
          e.startTime.year,
          e.startTime.month,
          e.startTime.day,
        );
        return eventDate.isAfter(tomorrow) && !e.isPast;
      }).toList();
      
      emit(EventListLoaded(
        allEvents: events,
        todayEvents: todayEvents,
        tomorrowEvents: tomorrowEvents,
        upcomingEvents: upcomingEvents,
      ));
    } catch (e) {
      emit(EventListError('Failed to load events: ${e.toString()}'));
    }
  }

  /// Searches events by query string and groups results by date.
  ///
  /// Performs case-insensitive search on event title, venue name, and description.
  /// If query is empty, loads all events instead.
  ///
  /// Emits [EventListLoading] while searching, then either
  /// [EventListLoaded] with filtered results or [EventListError] on failure.
  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      await loadEvents();
      return;
    }
    
    emit(const EventListLoading());
    try {
      final events = await repository.searchEvents(query);
      
      // Group search results by date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      final todayEvents = events.where((e) {
        final eventDate = DateTime(
          e.startTime.year,
          e.startTime.month,
          e.startTime.day,
        );
        return eventDate.isAtSameMomentAs(today) && !e.isPast;
      }).toList();
      
      final tomorrowEvents = events.where((e) {
        final eventDate = DateTime(
          e.startTime.year,
          e.startTime.month,
          e.startTime.day,
        );
        return eventDate.isAtSameMomentAs(tomorrow) && !e.isPast;
      }).toList();
      
      final upcomingEvents = events.where((e) {
        final eventDate = DateTime(
          e.startTime.year,
          e.startTime.month,
          e.startTime.day,
        );
        return eventDate.isAfter(tomorrow) && !e.isPast;
      }).toList();
      
      emit(EventListLoaded(
        allEvents: events,
        todayEvents: todayEvents,
        tomorrowEvents: tomorrowEvents,
        upcomingEvents: upcomingEvents,
      ));
    } catch (e) {
      emit(EventListError('Search failed: ${e.toString()}'));
    }
  }

  /// Toggles the favorite status of an event.
  ///
  /// Updates the repository and reloads all events to reflect the change.
  ///
  /// On error, emits [EventListError] without changing the current state.
  Future<void> toggleFavorite(String eventId) async {
    try {
      await repository.toggleFavorite(eventId);
      await loadEvents(); // Reload to reflect changes
    } catch (e) {
      emit(EventListError('Failed to toggle favorite: ${e.toString()}'));
    }
  }
}
