import 'package:equatable/equatable.dart';
import '../../models/event.dart';

/// Base class for all EventList states.
abstract class EventListState extends Equatable {
  const EventListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any events are loaded.
class EventListInitial extends EventListState {
  const EventListInitial();
}

/// State while events are being loaded.
class EventListLoading extends EventListState {
  const EventListLoading();
}

/// State when events are successfully loaded.
///
/// Events are pre-grouped by date for UI convenience:
/// - todayEvents: Events happening today
/// - tomorrowEvents: Events happening tomorrow
/// - upcomingEvents: Events happening after tomorrow
class EventListLoaded extends EventListState {
  final List<Event> allEvents;
  final List<Event> todayEvents;
  final List<Event> tomorrowEvents;
  final List<Event> upcomingEvents;

  const EventListLoaded({
    required this.allEvents,
    required this.todayEvents,
    required this.tomorrowEvents,
    required this.upcomingEvents,
  });

  @override
  List<Object?> get props => [allEvents, todayEvents, tomorrowEvents, upcomingEvents];
}

/// State when an error occurs during event loading.
class EventListError extends EventListState {
  final String message;

  const EventListError(this.message);

  @override
  List<Object?> get props => [message];
}
