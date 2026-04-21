import 'package:equatable/equatable.dart';

class FilterState extends Equatable {
  const FilterState({
    this.selectedDanceStyles = const {},
    this.selectedRegions = const {},
  });

  final Set<String> selectedDanceStyles;
  final Set<String> selectedRegions;

  bool get hasActiveFilters =>
      selectedDanceStyles.isNotEmpty || selectedRegions.isNotEmpty;

  FilterState copyWith({
    Set<String>? selectedDanceStyles,
    Set<String>? selectedRegions,
  }) {
    return FilterState(
      selectedDanceStyles: selectedDanceStyles ?? this.selectedDanceStyles,
      selectedRegions: selectedRegions ?? this.selectedRegions,
    );
  }

  @override
  List<Object?> get props => [selectedDanceStyles, selectedRegions];
}
