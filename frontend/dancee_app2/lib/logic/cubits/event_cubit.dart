import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/entities/dance_style.dart';
import '../../data/entities/event.dart';
import '../../data/repositories/event_repository.dart';
import '../states/event_state.dart';
import '../states/filter_state.dart';

class EventCubit extends Cubit<EventState> {
  EventCubit({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const EventState.initial());

  final EventRepository _eventRepository;
  List<Event> _allEvents = [];
  FilterState _currentFilters = const FilterState();
  List<DanceStyle> _currentDanceStyles = [];

  /// Fetches events from CMS for [languageCode], applies current filters, emits loaded state.
  Future<void> loadEvents(String languageCode) async {
    emit(const EventState.loading());
    try {
      _allEvents = await _eventRepository.getEvents(languageCode);
      _recompute();
    } catch (e) {
      emit(EventState.error(message: e.toString()));
    }
  }

  /// Applies [filters] client-side with parent/child dance style expansion.
  void applyFilters(FilterState filters, List<DanceStyle> allDanceStyles) {
    _currentFilters = filters;
    _currentDanceStyles = allDanceStyles;
    state.maybeMap(
      loaded: (_) => _recompute(),
      orElse: () {},
    );
  }

  /// Returns the number of events that match [styleCode] or any of its child styles.
  ///
  /// Uses [allDanceStyles] to resolve parent-child relationships, so a parent
  /// code like "salsa" also counts events tagged "salsa-on1", "salsa-on2", etc.
  int countEventsForDanceStyle(String styleCode, List<DanceStyle> allDanceStyles) {
    final expandedCodes = <String>{styleCode};
    expandedCodes.addAll(
      allDanceStyles.where((s) => s.parentCode == styleCode).map((s) => s.code),
    );
    return _allEvents
        .where((e) => e.dances.any((d) => expandedCodes.contains(d)))
        .length;
  }

  /// Updates the [isFavorited] flag on the event matching [eventId].
  void updateFavoriteStatus(int eventId, bool isFavorited) {
    _allEvents = _allEvents
        .map((e) => e.id == eventId ? e.copyWith(isFavorited: isFavorited) : e)
        .toList();
    state.maybeMap(
      loaded: (_) => _recompute(),
      orElse: () {},
    );
  }

  void _recompute() {
    final filtered = _filterEvents(_allEvents, _currentFilters, _currentDanceStyles);
    final featured = filtered.where((e) => e.eventType == 'festival').toList();
    emit(EventState.loaded(
      allEvents: _allEvents,
      filteredEvents: filtered,
      featuredEvents: featured,
    ));
  }
}

List<Event> _filterEvents(
  List<Event> events,
  FilterState filters,
  List<DanceStyle> allStyles,
) {
  return events.where((event) {
    if (filters.selectedDanceStyles.isNotEmpty) {
      final expandedCodes = <String>{};
      for (final code in filters.selectedDanceStyles) {
        expandedCodes.add(code);
        expandedCodes.addAll(
          allStyles.where((s) => s.parentCode == code).map((s) => s.code),
        );
      }
      if (!event.dances.any((d) => expandedCodes.contains(d))) return false;
    }
    if (filters.selectedRegions.isNotEmpty) {
      if (event.venue == null ||
          !filters.selectedRegions.contains(event.venue!.region)) {
        return false;
      }
    }
    return true;
  }).toList();
}
