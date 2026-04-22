import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/course_cubit.dart';
import '../../../logic/cubits/event_cubit.dart';
import '../../../logic/cubits/filter_cubit.dart';
import 'sections/filter_location_header_section.dart';
import '../filter_dance/sections/filter_bottom_actions_section.dart';

/// Internal sentinel key used to represent the "Abroad" filter option.
/// Events whose venue country is not in [_czCountryValues] are grouped under
/// this key. It is never shown as raw text — the UI translates it to
/// [t.events.filter.abroad].
const kAbroadRegionKey = '__abroad__';

/// Known country values used in Directus data for Czech Republic venues.
const _czCountryValues = {'CZ', 'Česká republika', 'Česko', 'Czech Republic', 'Czechia'};

class FilterLocationScreen extends StatefulWidget {
  const FilterLocationScreen({super.key});

  @override
  State<FilterLocationScreen> createState() => _FilterLocationScreenState();
}

class _FilterLocationScreenState extends State<FilterLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allRegions = [];
  Map<String, bool> _selected = {}; // key = region string

  @override
  void initState() {
    super.initState();
    _deriveRegions();
    _searchController.addListener(() => setState(() {}));
  }

  void _deriveRegions() {
    final czRegions = <String>{};
    var hasAbroad = false;

    final eventState = context.read<EventCubit>().state;
    eventState.maybeMap(
      loaded: (s) {
        for (final event in s.allEvents) {
          final venue = event.venue;
          if (venue == null) continue;
          if (_czCountryValues.contains(venue.country)) {
            final region = venue.region;
            if (region.isNotEmpty) czRegions.add(region);
          } else {
            hasAbroad = true;
          }
        }
      },
      orElse: () {},
    );

    final courseState = context.read<CourseCubit>().state;
    courseState.maybeMap(
      loaded: (s) {
        for (final course in s.allCourses) {
          final venue = course.venue;
          if (venue == null) continue;
          if (_czCountryValues.contains(venue.country)) {
            final region = venue.region;
            if (region.isNotEmpty) czRegions.add(region);
          } else {
            hasAbroad = true;
          }
        }
      },
      orElse: () {},
    );

    final sortedRegions = czRegions.toList()..sort();
    if (hasAbroad) sortedRegions.add(kAbroadRegionKey);

    final alreadySelected = context.read<FilterCubit>().state.selectedRegions;

    setState(() {
      _allRegions = sortedRegions;
      _selected = {
        for (final r in sortedRegions) r: alreadySelected.contains(r),
      };
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _selectedCount => _selected.values.where((v) => v).length;

  List<String> get _filteredRegions {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _allRegions;
    return _allRegions.where((r) => r.toLowerCase().contains(query)).toList();
  }

  void _apply() {
    final regions = _selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toSet();
    context.read<FilterCubit>().setLocations(regions);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRegions;
    final selectedRegionNames = _selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          FilterLocationHeaderSection(
            controller: _searchController,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                        child: Text(
                          t.events.filter.noResults,
                          style: const TextStyle(
                            fontSize: AppTypography.fontSizeMd,
                            color: appMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    _RegionsListSection(
                      regions: filtered,
                      selected: _selected,
                      onToggle: (region) => setState(
                        () => _selected[region] = !(_selected[region] ?? false),
                      ),
                    ),
                  if (selectedRegionNames.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _SelectedRegionsSection(
                      selectedRegions: selectedRegionNames,
                      onRemove: (region) =>
                          setState(() => _selected[region] = false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: FilterBottomActionsSection(
        selectedCount: _selectedCount,
        onApply: _apply,
      ),
    );
  }
}

class _RegionsListSection extends StatelessWidget {
  final List<String> regions;
  final Map<String, bool> selected;
  final ValueChanged<String> onToggle;

  const _RegionsListSection({
    required this.regions,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(regions.length, (index) {
          final region = regions[index];
          final isLast = index == regions.length - 1;
          final isChecked = selected[region] ?? false;
          return _RegionRow(
            region: region,
            isChecked: isChecked,
            isLast: isLast,
            onToggle: () => onToggle(region),
          );
        }),
      ),
    );
  }
}

class _RegionRow extends StatelessWidget {
  final String region;
  final bool isChecked;
  final bool isLast;
  final VoidCallback onToggle;

  const _RegionRow({
    required this.region,
    required this.isChecked,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: appBorder)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appPrimary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.locationDot, color: appPrimary, size: 16),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                region == kAbroadRegionKey ? t.events.filter.abroad : region,
                style: const TextStyle(
                  fontSize: AppTypography.fontSizeXl,
                  fontWeight: AppTypography.fontWeightSemiBold,
                  color: appText,
                ),
              ),
            ),
            _Checkbox(isChecked: isChecked, onToggle: onToggle),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onToggle;

  const _Checkbox({required this.isChecked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isChecked ? appPrimary : appSurface,
          border: Border.all(
            color: isChecked ? appPrimary : appBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: isChecked
            ? const Icon(FontAwesomeIcons.check, size: 12, color: Colors.white)
            : null,
      ),
    );
  }
}

class _SelectedRegionsSection extends StatelessWidget {
  final List<String> selectedRegions;
  final ValueChanged<String> onRemove;

  const _SelectedRegionsSection({
    required this.selectedRegions,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.events.filter.selectedRegions,
          style: const TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: AppTypography.fontWeightSemiBold,
            color: appMuted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: selectedRegions
              .map((region) => _SelectedTag(
                    label: region == kAbroadRegionKey
                        ? t.events.filter.abroad
                        : region,
                    onRemove: () => onRemove(region),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SelectedTag extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _SelectedTag({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm - 2),
      decoration: BoxDecoration(
        color: appPrimary.withValues(alpha: 0.2),
        border: Border.all(color: appPrimary.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeMd,
              fontWeight: AppTypography.fontWeightMedium,
              color: appPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(FontAwesomeIcons.xmark, size: 12, color: appPrimary),
          ),
        ],
      ),
    );
  }
}
