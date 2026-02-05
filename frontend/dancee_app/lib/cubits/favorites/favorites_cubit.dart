import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import '../../models/event.dart';
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
  /// Updates the repository and reloads all favorites to reflect the change.
  ///
  /// On error, emits [FavoritesError] without changing the current state.
  Future<void> toggleFavorite(String eventId) async {
    try {
      await repository.toggleFavorite(eventId);
      await loadFavorites(); // Reload to reflect changes
    } catch (e) {
      emit(FavoritesError('Failed to toggle favorite: ${e.toString()}'));
    }
  }
}
