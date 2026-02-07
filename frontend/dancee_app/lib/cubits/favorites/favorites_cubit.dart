import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dancee_shared/dancee_shared.dart';
import '../../repositories/event_repository.dart';
import '../../core/exceptions/api_exception.dart';
import '../../i18n/translations.g.dart';
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
    } on ApiException {
      emit(FavoritesError(t.errors.loadFavoritesError));
    } catch (e) {
      emit(FavoritesError(t.errors.genericError));
    }
  }

  /// Toggles the favorite status of an event.
  ///
  /// Gets the event from state to determine currentIsFavorite,
  /// calls repository.toggleFavorite(eventId, currentIsFavorite),
  /// and reloads favorites from API to ensure consistency.
  ///
  /// On error, emits [FavoritesError] with translated error message.
  Future<void> toggleFavorite(String eventId) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;
    
    try {
      // Find the event in state to determine current favorite status
      final event = currentState.upcomingEvents
          .cast<Event?>()
          .firstWhere((e) => e?.id == eventId, orElse: () => null) ??
          currentState.pastEvents
          .cast<Event?>()
          .firstWhere((e) => e?.id == eventId, orElse: () => null);
      
      if (event == null) {
        emit(FavoritesError(t.errors.genericError));
        return;
      }
      
      // Call repository with current favorite status
      await repository.toggleFavorite(eventId, event.isFavorite);
      
      // Reload favorites from API to ensure consistency
      await loadFavorites();
    } on ApiException {
      emit(FavoritesError(t.errors.toggleFavoriteError));
    } catch (e) {
      emit(FavoritesError(t.errors.genericError));
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
      // Find the event in state to determine current favorite status
      final event = currentState.pastEvents
          .cast<Event?>()
          .firstWhere((e) => e?.id == eventId, orElse: () => null);
      
      if (event == null) {
        emit(FavoritesError(t.errors.genericError));
        return;
      }
      
      // Remove from repository with current favorite status
      await repository.toggleFavorite(eventId, event.isFavorite);
      
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
    } on ApiException {
      emit(FavoritesError(t.errors.toggleFavoriteError));
    } catch (e) {
      emit(FavoritesError(t.errors.genericError));
    }
  }
}
