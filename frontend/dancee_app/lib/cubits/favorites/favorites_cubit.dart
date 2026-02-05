import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import 'favorites_state.dart';

/// Cubit for managing favorites screen state.
///
/// This cubit handles loading favorite events and separating them
/// into upcoming and past events for UI convenience.
class FavoritesCubit extends Cubit<FavoritesState> {
  final EventRepository repository;

  FavoritesCubit(this.repository) : super(const FavoritesInitial());

  /// Loads favorite events and separates them into upcoming and past.
  ///
  /// Events are separated based on the isPast flag:
  /// - Upcoming: Events where isPast is false
  /// - Past: Events where isPast is true
  ///
  /// Emits [FavoritesLoading] while loading, then either:
  /// - [FavoritesEmpty] if no favorites exist
  /// - [FavoritesLoaded] with separated events on success
  /// - [FavoritesError] on failure
  Future<void> loadFavorites() async {
    emit(const FavoritesLoading());
    try {
      final favorites = await repository.getFavoriteEvents();
      
      if (favorites.isEmpty) {
        emit(const FavoritesEmpty());
        return;
      }
      
      final upcoming = favorites.where((e) => !e.isPast).toList();
      final past = favorites.where((e) => e.isPast).toList();
      
      emit(FavoritesLoaded(
        upcomingEvents: upcoming,
        pastEvents: past,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: ${e.toString()}'));
    }
  }

  /// Toggles the favorite status of an event.
  ///
  /// Updates the repository and updates the state locally without removing the event.
  /// The event stays visible with updated favorite status until the screen is reloaded.
  /// This allows users to re-favorite events before leaving the screen.
  ///
  /// On error, emits [FavoritesError] without changing the current state.
  Future<void> toggleFavorite(String eventId) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;
    
    try {
      await repository.toggleFavorite(eventId);
      
      // Update the event in both lists locally, keeping all events visible
      final updatedUpcoming = currentState.upcomingEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(isFavorite: !event.isFavorite);
        }
        return event;
      }).toList();
      
      final updatedPast = currentState.pastEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(isFavorite: !event.isFavorite);
        }
        return event;
      }).toList();
      
      // Emit new state with updated events (keeping unfavorited ones visible)
      emit(FavoritesLoaded(
        upcomingEvents: updatedUpcoming,
        pastEvents: updatedPast,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to toggle favorite: ${e.toString()}'));
    }
  }

  /// Filters out unfavorited events from the current state.
  ///
  /// This method removes events where isFavorite is false from the current
  /// displayed list without reloading from repository. Used when user navigates
  /// away from the favorites screen to clean up the view.
  void filterUnfavoritedEvents() {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;
    
    // Filter out events that are not favorited
    final filteredUpcoming = currentState.upcomingEvents
        .where((event) => event.isFavorite)
        .toList();
    final filteredPast = currentState.pastEvents
        .where((event) => event.isFavorite)
        .toList();
    
    // Check if there are any favorites left
    if (filteredUpcoming.isEmpty && filteredPast.isEmpty) {
      emit(const FavoritesEmpty());
      return;
    }
    
    // Emit new state with filtered events
    emit(FavoritesLoaded(
      upcomingEvents: filteredUpcoming,
      pastEvents: filteredPast,
    ));
  }

  /// Removes a past event from favorites immediately.
  ///
  /// This method is used for past events to remove them instantly
  /// when user clicks the delete icon. Updates repository in background.
  Future<void> removePastEvent(String eventId) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;
    
    try {
      // Remove from repository in background
      await repository.toggleFavorite(eventId);
      
      // Remove from current state immediately
      final updatedUpcoming = currentState.upcomingEvents;
      final updatedPast = currentState.pastEvents
          .where((event) => event.id != eventId)
          .toList();
      
      // Check if there are any favorites left
      if (updatedUpcoming.isEmpty && updatedPast.isEmpty) {
        emit(const FavoritesEmpty());
        return;
      }
      
      // Emit new state without the removed event
      emit(FavoritesLoaded(
        upcomingEvents: updatedUpcoming,
        pastEvents: updatedPast,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to remove event: ${e.toString()}'));
    }
  }
}
