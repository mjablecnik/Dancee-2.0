import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/entities/dance_style.dart';
import '../../data/repositories/dance_style_repository.dart';
import '../states/filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit({required DanceStyleRepository danceStyleRepository})
      : _danceStyleRepository = danceStyleRepository,
        super(const FilterState());

  final DanceStyleRepository _danceStyleRepository;
  List<DanceStyle> _allDanceStyles = [];

  /// All loaded dance styles — available for UI and filter expansion logic.
  List<DanceStyle> get allDanceStyles => _allDanceStyles;

  /// Fetches dance styles from CMS with [languageCode] translations.
  Future<void> loadDanceStyles(String languageCode) async {
    try {
      _allDanceStyles = await _danceStyleRepository.getDanceStyles(languageCode);
    } catch (_) {
      // Non-fatal — filter UI degrades gracefully without dance styles
    }
  }

  void setDanceStyles(Set<String> codes) {
    emit(state.copyWith(selectedDanceStyles: codes));
  }

  void setLocations(Set<String> regions) {
    emit(state.copyWith(selectedRegions: regions));
  }

  void clearAll() {
    emit(const FilterState());
  }
}
