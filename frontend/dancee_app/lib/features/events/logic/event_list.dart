import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/exceptions.dart';
import '../../../i18n/translations.g.dart';
import '../data/entities.dart';
import '../data/event_repository.dart';

part 'event_list.freezed.dart';

// ============================================================================
// State
// ============================================================================

/// State for the EventListCubit.
///
/// Uses freezed for immutability and union types:
/// - [initial]: Before any events are loaded
/// - [loading]: While events are being fetched
/// - [loaded]: Events successfully loaded and grouped by date
/// - [error]: An error occurred during loading or toggling
@freezed
class EventListState with _$EventListState {
  const factory EventListState.initial() = EventListInitial;

  const factory EventListState.loading() = EventListLoading;

  const factory EventListState.loaded({
    required List<Event> allEvents,
    required List<Event> todayEvents,
    required List<Event> tomorrowEvents,
    required List<Event> upcomingEvents,
  }) = EventListLoaded;

  const factory EventListState.error(String message) = EventListError;
}

// ============================================================================
// Cubit
// ============================================================================

/// Cubit for managing event list screen state.
///
/// Handles loading, searching, and toggling favorites for events.
/// Events are automatically grouped by date (today, tomorrow, upcoming).
class EventListCubit extends Cubit<EventListState> {
  final EventRepository _repository;

  EventListCubit(this._repository) : super(const EventListState.initial());

  /// Loads all events from the repository and groups them by date.
  ///
  /// Events are grouped into:
  /// - Today: Events starting today that are not past
  /// - Tomorrow: Events starting tomorrow that are not past
  /// - Upcoming: Events starting after tomorrow that are not past
  Future<void> loadEvents() async {
    emit(const EventListState.loading());
    try {
      final events = await _repository.getAllEvents();
      _emitGrouped(events);
    } on ApiException {
      emit(EventListState.error(t.errors.loadEventsError));
    } catch (_) {
      emit(EventListState.error(t.errors.genericError));
    }
  }

  /// Searches events locally by query string and re-groups results by date.
  ///
  /// Performs case-insensitive search on event title, venue name, and description.
  /// If query is empty, reloads all events from the API.
  /// Only works when the current state is [EventListLoaded].
  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      await loadEvents();
      return;
    }

    final currentState = state;
    if (currentState is! EventListLoaded) return;

    final lowerQuery = query.toLowerCase();
    final filteredEvents = currentState.allEvents.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
          event.venue.name.toLowerCase().contains(lowerQuery) ||
          event.description.toLowerCase().contains(lowerQuery);
    }).toList();

    _emitGrouped(filteredEvents);
  }

  /// Toggles the favorite status of an event.
  ///
  /// Updates the repository first, then updates the local state without
  /// reloading from the API. This prevents UI flickering.
  /// Only works when the current state is [EventListLoaded].
  Future<void> toggleFavorite(String eventId) async {
    final currentState = state;
    if (currentState is! EventListLoaded) return;

    try {
      final event = currentState.allEvents.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw ApiException(message: 'Event not found'),
      );

      await _repository.toggleFavorite(eventId, event.isFavorite);

      // Update favorite status locally in all grouped lists
      List<Event> updateList(List<Event> list) {
        return list.map((e) {
          if (e.id == eventId) {
            return e.copyWith(isFavorite: !e.isFavorite);
          }
          return e;
        }).toList();
      }

      emit(EventListState.loaded(
        allEvents: updateList(currentState.allEvents),
        todayEvents: updateList(currentState.todayEvents),
        tomorrowEvents: updateList(currentState.tomorrowEvents),
        upcomingEvents: updateList(currentState.upcomingEvents),
      ));
    } on ApiException {
      emit(EventListState.error(t.errors.toggleFavoriteError));
    } catch (_) {
      emit(EventListState.error(t.errors.genericError));
    }
  }

  /// Groups events by date and emits a [EventListLoaded] state.
  void _emitGrouped(List<Event> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final todayEvents = events.where((e) {
      final d = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
      return d.isAtSameMomentAs(today) && !e.isPast;
    }).toList();

    final tomorrowEvents = events.where((e) {
      final d = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
      return d.isAtSameMomentAs(tomorrow) && !e.isPast;
    }).toList();

    final upcomingEvents = events.where((e) {
      final d = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
      return d.isAfter(tomorrow) && !e.isPast;
    }).toList();

    emit(EventListState.loaded(
      allEvents: events,
      todayEvents: todayEvents,
      tomorrowEvents: tomorrowEvents,
      upcomingEvents: upcomingEvents,
    ));
  }
}
