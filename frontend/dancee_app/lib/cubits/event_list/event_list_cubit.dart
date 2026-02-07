import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import '../../core/exceptions/api_exception.dart';
import '../../i18n/translations.g.dart';
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
    } on ApiException catch (e) {
      emit(EventListError(t.errors.loadEventsError));
    } catch (e) {
      emit(EventListError(t.errors.genericError));
    }
  }

  /// Searches events by query string and groups results by date.
  ///
  /// Performs case-insensitive search on event title, venue name, and description.
  /// Searches locally in cached state.allEvents (no API call).
  /// If query is empty, loads all events instead.
  ///
  /// Emits [EventListLoaded] with filtered results.
  Future<void> searchEvents(String query) async {
    // If query is empty, reload all events
    if (query.isEmpty) {
      await loadEvents();
      return;
    }
    
    // Get current state - if not loaded, return
    final currentState = state;
    if (currentState is! EventListLoaded) return;
    
    // Search locally in cached allEvents
    final lowerQuery = query.toLowerCase();
    final filteredEvents = currentState.allEvents.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
             event.venue.name.toLowerCase().contains(lowerQuery) ||
             event.description.toLowerCase().contains(lowerQuery);
    }).toList();
    
    // Group filtered results by date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    final todayEvents = filteredEvents.where((e) {
      final eventDate = DateTime(
        e.startTime.year,
        e.startTime.month,
        e.startTime.day,
      );
      return eventDate.isAtSameMomentAs(today) && !e.isPast;
    }).toList();
    
    final tomorrowEvents = filteredEvents.where((e) {
      final eventDate = DateTime(
        e.startTime.year,
        e.startTime.month,
        e.startTime.day,
      );
      return eventDate.isAtSameMomentAs(tomorrow) && !e.isPast;
    }).toList();
    
    final upcomingEvents = filteredEvents.where((e) {
      final eventDate = DateTime(
        e.startTime.year,
        e.startTime.month,
        e.startTime.day,
      );
      return eventDate.isAfter(tomorrow) && !e.isPast;
    }).toList();
    
    // Emit EventListLoaded with filtered results
    emit(EventListLoaded(
      allEvents: filteredEvents,
      todayEvents: todayEvents,
      tomorrowEvents: tomorrowEvents,
      upcomingEvents: upcomingEvents,
    ));
  }

  /// Toggles the favorite status of an event.
  ///
  /// Updates the repository and updates the state locally without reloading.
  /// This prevents the UI from flickering when toggling favorites.
  ///
  /// On error, emits [EventListError] without changing the current state.
  Future<void> toggleFavorite(String eventId) async {
    final currentState = state;
    if (currentState is! EventListLoaded) return;
    
    try {
      // Find the event to get its current favorite status
      final event = currentState.allEvents.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw ApiException(message: 'Event not found'),
      );
      
      // Call repository with current favorite status
      await repository.toggleFavorite(eventId, event.isFavorite);
      
      // Update the event in all lists locally
      final updatedAllEvents = currentState.allEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(isFavorite: !event.isFavorite);
        }
        return event;
      }).toList();
      
      final updatedTodayEvents = currentState.todayEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(isFavorite: !event.isFavorite);
        }
        return event;
      }).toList();
      
      final updatedTomorrowEvents = currentState.tomorrowEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(isFavorite: !event.isFavorite);
        }
        return event;
      }).toList();
      
      final updatedUpcomingEvents = currentState.upcomingEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(isFavorite: !event.isFavorite);
        }
        return event;
      }).toList();
      
      // Emit new state with updated events
      emit(EventListLoaded(
        allEvents: updatedAllEvents,
        todayEvents: updatedTodayEvents,
        tomorrowEvents: updatedTomorrowEvents,
        upcomingEvents: updatedUpcomingEvents,
      ));
    } on ApiException catch (e) {
      emit(EventListError(t.errors.toggleFavoriteError));
    } catch (e) {
      emit(EventListError(t.errors.genericError));
    }
  }
}
