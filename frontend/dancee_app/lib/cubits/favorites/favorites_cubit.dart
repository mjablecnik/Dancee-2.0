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
  /// Updates the repository and updates the state locally without reloading.
  /// This prevents the UI from flickering when toggling favorites.
  ///
  /// On error, emits [FavoritesError] without changing the current state.
  Future<void> toggleFavorite(String eventId) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;
    
    try {
      await repository.toggleFavorite(eventId);
      
      // Update the event in both lists locally
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
      
      // Remove unfavorited events from the lists
      final filteredUpcoming = updatedUpcoming.where((e) => e.isFavorite).toList();
      final filteredPast = updatedPast.where((e) => e.isFavorite).toList();
      
      // Check if there are any favorites left
      if (filteredUpcoming.isEmpty && filteredPast.isEmpty) {
        emit(const FavoritesEmpty());
        return;
      }
      
      // Emit new state with updated events
      emit(FavoritesLoaded(
        upcomingEvents: filteredUpcoming,
        pastEvents: filteredPast,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to toggle favorite: ${e.toString()}'));
    }
  }
}
