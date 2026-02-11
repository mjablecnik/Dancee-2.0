import 'package:equatable/equatable.dart';

import '../../models/event.dart';

/// Base class for all Favorites states.
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any favorites are loaded.
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

/// State while favorites are being loaded.
class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// State when no favorite events exist.
class FavoritesEmpty extends FavoritesState {
  const FavoritesEmpty();
}

/// State when favorite events are successfully loaded.
///
/// Events are pre-separated for UI convenience:
/// - upcomingEvents: Favorite events that haven't happened yet
/// - pastEvents: Favorite events that have already happened
class FavoritesLoaded extends FavoritesState {
  final List<Event> upcomingEvents;
  final List<Event> pastEvents;

  const FavoritesLoaded({
    required this.upcomingEvents,
    required this.pastEvents,
  });

  @override
  List<Object?> get props => [upcomingEvents, pastEvents];
}

/// State when an error occurs during favorites loading.
class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
