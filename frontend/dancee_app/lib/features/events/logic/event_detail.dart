import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/entities.dart';
import '../data/event_repository.dart';
import 'event_list.dart';

part 'event_detail.freezed.dart';

// ============================================================================
// State
// ============================================================================

/// State for the EventDetailCubit.
///
/// Uses freezed for immutability and union types:
/// - [initial]: Before the event is loaded
/// - [loaded]: Event successfully found, with optional toggling flag
/// - [error]: Event not found or EventListCubit state not loaded
@freezed
class EventDetailState with _$EventDetailState {
  const factory EventDetailState.initial() = EventDetailInitial;

  const factory EventDetailState.loaded({
    required Event event,
    @Default(false) bool isTogglingFavorite,
  }) = EventDetailLoaded;

  const factory EventDetailState.error(String message) = EventDetailError;
}

// ============================================================================
// Cubit
// ============================================================================

/// Cubit for managing the event detail page state.
///
/// Reads the event from [EventListCubit] state, handles optimistic
/// favorite toggling via [EventRepository], and launches external
/// map/URL navigation via url_launcher.
class EventDetailCubit extends Cubit<EventDetailState> {
  final EventRepository _repository;
  final EventListCubit _eventListCubit;
  final String eventId;

  EventDetailCubit({
    required EventRepository repository,
    required EventListCubit eventListCubit,
    required this.eventId,
  })  : _repository = repository,
        _eventListCubit = eventListCubit,
        super(const EventDetailState.initial());

  /// Finds the event by [eventId] from [EventListCubit.state.allEvents].
  ///
  /// Emits [EventDetailLoaded] if found, [EventDetailError] if the
  /// EventListCubit state is not loaded or the event ID doesn't exist.
  void loadEvent() {
    final listState = _eventListCubit.state;

    if (listState is! EventListLoaded) {
      emit(const EventDetailState.error('Event not found'));
      return;
    }

    try {
      final event = listState.allEvents.firstWhere(
        (e) => e.id == eventId,
      );
      emit(EventDetailState.loaded(event: event));
    } catch (_) {
      emit(const EventDetailState.error('Event not found'));
    }
  }

  /// Toggles the favorite status with optimistic UI update.
  ///
  /// 1. Immediately flips isFavorite in local state
  /// 2. Calls [EventRepository.toggleFavorite] with original status
  /// 3. On success: syncs back to [EventListCubit] via loadEvents()
  /// 4. On failure: reverts local state to original value
  Future<void> toggleFavorite() async {
    final currentState = state;
    if (currentState is! EventDetailLoaded) return;

    final originalEvent = currentState.event;
    final originalIsFavorite = originalEvent.isFavorite;

    // Optimistically flip isFavorite
    emit(EventDetailState.loaded(
      event: originalEvent.copyWith(isFavorite: !originalIsFavorite),
      isTogglingFavorite: true,
    ));

    try {
      await _repository.toggleFavorite(eventId, originalIsFavorite);

      // Sync back to EventListCubit
      await _eventListCubit.loadEvents();

      // Keep the local optimistic state, just clear the toggling flag
      if (state is EventDetailLoaded) {
        final loaded = state as EventDetailLoaded;
        emit(EventDetailState.loaded(
          event: loaded.event,
          isTogglingFavorite: false,
        ));
      }
    } catch (e) {
      developer.log(
        'Failed to toggle favorite: $e',
        name: 'EventDetailCubit',
        level: 900,
      );

      // Revert to original favorite status
      emit(EventDetailState.loaded(
        event: originalEvent.copyWith(isFavorite: originalIsFavorite),
        isTogglingFavorite: false,
      ));
    }
  }

  /// Opens an external map application with directions to the venue.
  ///
  /// Uses coordinates when available, falls back to encoded address string.
  /// Builds a Google Maps directions URL.
  Future<void> openMap(Venue venue) async {
    try {
      final Uri uri;
      if (venue.latitude != null && venue.longitude != null) {
        uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${venue.latitude},${venue.longitude}',
        );
      } else {
        uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(venue.address.fullAddress)}',
        );
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log(
        'Failed to open map: $e',
        name: 'EventDetailCubit',
        level: 900,
      );
    }
  }

  /// Opens an external URL via url_launcher.
  ///
  /// Used for info items of type URL.
  Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log(
        'Failed to open URL: $e',
        name: 'EventDetailCubit',
        level: 900,
      );
    }
  }
}
