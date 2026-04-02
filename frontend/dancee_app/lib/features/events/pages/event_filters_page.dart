import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/service_locator.dart';
import '../../../i18n/translations.g.dart';
import '../data/entities.dart';
import '../logic/event_filter.dart';
import '../logic/event_list.dart';

part 'event_filters_page.g.dart';

/// Route definition for the event filters page.
///
/// Accepts an optional [scrollTo] query parameter to auto-scroll to a section
/// ('date' or 'location') on open.
@TypedGoRoute<EventFiltersRoute>(path: '/events/filters')
class EventFiltersRoute extends GoRouteData {
  final String? scrollTo;

  const EventFiltersRoute({this.scrollTo});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(child: EventFiltersPage(scrollTo: scrollTo));
  }
}

/// Page for filtering and sorting dance events.
///
/// Maintains a local draft [FilterState] for live preview. Filters are only
/// pushed to [EventFilterCubit] when the user taps "Apply filters".
class EventFiltersPage extends StatefulWidget {
  final String? scrollTo;

  const EventFiltersPage({super.key, this.scrollTo});

  @override
  State<EventFiltersPage> createState() => _EventFiltersPageState();
}

class _EventFiltersPageState extends State<EventFiltersPage> {
  late FilterState _draft;
  final _scrollController = ScrollController();
  final _locationSectionKey = GlobalKey();
  final _dateSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _draft = getIt<EventFilterCubit>().state.filters;
    if (widget.scrollTo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSection(widget.scrollTo!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Event> get _allEvents {
    final s = getIt<EventListCubit>().state;
    if (s is EventListLoaded) return s.allEvents;
    return const [];
  }

  void _scrollToSection(String section) {
    GlobalKey? key;
    if (section == 'date') key = _dateSectionKey;
    if (section == 'location') key = _locationSectionKey;
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateDraft(FilterState newDraft) {
    setState(() => _draft = newDraft);
  }

  Future<void> _pickDateFrom() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _draft.dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _updateDraft(_draft.copyWith(dateFrom: date));
    }
  }

  Future<void> _pickDateTo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _draft.dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _updateDraft(_draft.copyWith(dateTo: date));
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = _allEvents;
    final danceTypes = extractDanceTypes(allEvents);
    final regions = extractRegions(allEvents);
    final matchingCount = filterEvents(allEvents, _draft).length;
    final activeCount = getActiveFilterCount(_draft);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          EventFiltersHeaderSection(
            onBackPressed: () => context.pop(),
            onResetPressed: () => _updateDraft(const FilterState()),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                ActiveFiltersSummary(
                  activeCount: activeCount,
                  matchingCount: matchingCount,
                ),
                const SizedBox(height: 24),
                DanceTypeFilterSection(
                  danceTypes: danceTypes,
                  selectedTypes: _draft.selectedDanceTypes,
                  allEvents: allEvents,
                  filters: _draft,
                  onToggle: (type) {
                    final newSet = Set<String>.from(_draft.selectedDanceTypes);
                    if (newSet.contains(type)) {
                      newSet.remove(type);
                    } else {
                      newSet.add(type);
                    }
                    _updateDraft(_draft.copyWith(selectedDanceTypes: newSet));
                  },
                  onClear: () =>
                      _updateDraft(_draft.copyWith(selectedDanceTypes: const {})),
                ),
                const SizedBox(height: 24),
                LocationFilterSection(
                  key: _locationSectionKey,
                  regions: regions,
                  selectedRegions: _draft.selectedRegions,
                  allEvents: allEvents,
                  filters: _draft,
                  onToggle: (region) {
                    final newSet = Set<String>.from(_draft.selectedRegions);
                    if (newSet.contains(region)) {
                      newSet.remove(region);
                    } else {
                      newSet.add(region);
                    }
                    _updateDraft(_draft.copyWith(selectedRegions: newSet));
                  },
                  onClear: () =>
                      _updateDraft(_draft.copyWith(selectedRegions: const {})),
                ),
                const SizedBox(height: 24),
                DateRangeFilterSection(
                  key: _dateSectionKey,
                  dateFrom: _draft.dateFrom,
                  dateTo: _draft.dateTo,
                  onDateFromTap: _pickDateFrom,
                  onDateToTap: _pickDateTo,
                  onTodayPreset: () {
                    final (from, to) = todayPreset(DateTime.now());
                    _updateDraft(_draft.copyWith(dateFrom: from, dateTo: to));
                  },
                  onTomorrowPreset: () {
                    final (from, to) = tomorrowPreset(DateTime.now());
                    _updateDraft(_draft.copyWith(dateFrom: from, dateTo: to));
                  },
                  onThisWeekPreset: () {
                    final (from, to) = thisWeekPreset(DateTime.now());
                    _updateDraft(_draft.copyWith(dateFrom: from, dateTo: to));
                  },
                  onWeekendPreset: () {
                    final (from, to) = weekendPreset(DateTime.now());
                    _updateDraft(_draft.copyWith(dateFrom: from, dateTo: to));
                  },
                  onClear: () => _updateDraft(
                      _draft.copyWith(dateFrom: null, dateTo: null)),
                ),
                const SizedBox(height: 24),
                SaveFilterSection(
                  onSave: () async {
                    getIt<EventFilterCubit>().applyFilters(_draft);
                    await getIt<EventFilterCubit>().saveFilters();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.eventFilters.saveFilter),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: FilterFooterActions(
        matchingCount: matchingCount,
        onClearAll: () => _updateDraft(const FilterState()),
        onApply: () {
          getIt<EventFilterCubit>().applyFilters(_draft);
          context.pop();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Section
// ---------------------------------------------------------------------------

/// Gradient header with back button, title, and reset button.
class EventFiltersHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onResetPressed;

  const EventFiltersHeaderSection({
    super.key,
    required this.onBackPressed,
    required this.onResetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  HeaderIconButton(
                    icon: Icons.arrow_back,
                    onPressed: onBackPressed,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          t.eventFilters.title,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.eventFilters.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  HeaderIconButton(
                    icon: Icons.refresh,
                    onPressed: onResetPressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular icon button used in the header.
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active Filters Summary
// ---------------------------------------------------------------------------

/// Summary card showing the number of active filters and matching events.
class ActiveFiltersSummary extends StatelessWidget {
  final int activeCount;
  final int matchingCount;

  const ActiveFiltersSummary({
    super.key,
    required this.activeCount,
    required this.matchingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list,
                        color: Color(0xFF6366F1), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      t.eventFilters.activeFilters,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  t.eventFilters.eventsShown(count: matchingCount),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: activeCount > 0
                  ? const Color(0xFF6366F1)
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$activeCount',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dance Type Filter Section
// ---------------------------------------------------------------------------

/// Section with checkboxes for filtering by dance style.
class DanceTypeFilterSection extends StatelessWidget {
  final List<String> danceTypes;
  final Set<String> selectedTypes;
  final List<Event> allEvents;
  final FilterState filters;
  final void Function(String) onToggle;
  final VoidCallback onClear;

  const DanceTypeFilterSection({
    super.key,
    required this.danceTypes,
    required this.selectedTypes,
    required this.allEvents,
    required this.filters,
    required this.onToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.music_note,
          title: t.eventFilters.danceType,
          onClear: onClear,
        ),
        const SizedBox(height: 12),
        if (danceTypes.isEmpty)
          _EmptyOptionMessage(message: t.eventFilters.noResults)
        else
          ...danceTypes.map((type) {
            final isSelected = selectedTypes.contains(type);
            final count = countEventsForDanceType(allEvents, type, filters);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DanceTypeOption(
                label: type,
                icon: _danceTypeIcon(type),
                iconColor: _danceTypeColor(type),
                isSelected: isSelected,
                count: count,
                onTap: () => onToggle(type),
              ),
            );
          }),
      ],
    );
  }
}

/// A single dance type checkbox option row.
class DanceTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const DanceTypeOption({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEEF2FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location Filter Section
// ---------------------------------------------------------------------------

/// Section with checkboxes for filtering by Czech region.
class LocationFilterSection extends StatelessWidget {
  final List<String> regions;
  final Set<String> selectedRegions;
  final List<Event> allEvents;
  final FilterState filters;
  final void Function(String) onToggle;
  final VoidCallback onClear;

  const LocationFilterSection({
    super.key,
    required this.regions,
    required this.selectedRegions,
    required this.allEvents,
    required this.filters,
    required this.onToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.location_on,
          title: t.eventFilters.location,
          onClear: onClear,
        ),
        const SizedBox(height: 12),
        if (regions.isEmpty)
          _EmptyOptionMessage(message: t.eventFilters.noResults)
        else
          ...regions.map((region) {
            final isSelected = selectedRegions.contains(region);
            final count = countEventsForRegion(allEvents, region, filters);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LocationOption(
                label: region,
                isSelected: isSelected,
                count: count,
                onTap: () => onToggle(region),
              ),
            );
          }),
      ],
    );
  }
}

/// A single location checkbox-style option row.
class LocationOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const LocationOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date Range Filter Section
// ---------------------------------------------------------------------------

/// Section with date pickers and quick-select date buttons.
class DateRangeFilterSection extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final VoidCallback onDateFromTap;
  final VoidCallback onDateToTap;
  final VoidCallback onTodayPreset;
  final VoidCallback onTomorrowPreset;
  final VoidCallback onThisWeekPreset;
  final VoidCallback onWeekendPreset;
  final VoidCallback onClear;

  const DateRangeFilterSection({
    super.key,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateFromTap,
    required this.onDateToTap,
    required this.onTodayPreset,
    required this.onTomorrowPreset,
    required this.onThisWeekPreset,
    required this.onWeekendPreset,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.calendar_month,
          title: t.eventFilters.date,
          onClear: onClear,
        ),
        const SizedBox(height: 12),
        DateInputField(
          label: t.eventFilters.dateFrom,
          value: dateFrom,
          onTap: onDateFromTap,
        ),
        const SizedBox(height: 12),
        DateInputField(
          label: t.eventFilters.dateTo,
          value: dateTo,
          onTap: onDateToTap,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.today,
                label: t.eventFilters.dateToday,
                iconColor: const Color(0xFF6366F1),
                gradientColors: const [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
                borderColor: const Color(0xFFBFDBFE),
                onPressed: onTodayPreset,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.event,
                label: t.eventFilters.dateTomorrow,
                iconColor: const Color(0xFF8B5CF6),
                gradientColors: const [Color(0xFFF5F3FF), Color(0xFFFDF2F8)],
                borderColor: const Color(0xFFD8B4FE),
                onPressed: onTomorrowPreset,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.date_range,
                label: t.eventFilters.dateThisWeek,
                iconColor: const Color(0xFFEC4899),
                gradientColors: const [Color(0xFFFDF2F8), Color(0xFFFFF1F2)],
                borderColor: const Color(0xFFFBCFE8),
                onPressed: onThisWeekPreset,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.event_available,
                label: t.eventFilters.dateWeekend,
                iconColor: Colors.green,
                gradientColors: const [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
                borderColor: const Color(0xFFBBF7D0),
                onPressed: onWeekendPreset,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A labeled date input field with calendar icon and optional selected date.
class DateInputField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const DateInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = value != null
        ? DateFormat('dd.MM.yyyy').format(value!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value != null
                    ? const Color(0xFF6366F1)
                    : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.calendar_today,
                    color: value != null
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade400,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatted ?? t.eventFilters.datePlaceholder,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: value != null
                        ? const Color(0xFF0F172A)
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A quick-select button for common date ranges (today, tomorrow, etc.).
class DateQuickSelectButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final List<Color> gradientColors;
  final Color borderColor;
  final VoidCallback onPressed;

  const DateQuickSelectButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.gradientColors,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Save Filter Section
// ---------------------------------------------------------------------------

/// Card prompting the user to save the current filter configuration.
class SaveFilterSection extends StatelessWidget {
  final Future<void> Function() onSave;

  const SaveFilterSection({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark, color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.eventFilters.saveFilter,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      t.eventFilters.saveFilterDescription,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSave,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, color: Color(0xFFB45309), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    t.eventFilters.saveFilterButton,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer Actions
// ---------------------------------------------------------------------------

/// Fixed bottom bar with "Clear all" and "Apply filters" buttons.
class FilterFooterActions extends StatelessWidget {
  final int matchingCount;
  final VoidCallback onClearAll;
  final VoidCallback onApply;

  const FilterFooterActions({
    super.key,
    required this.matchingCount,
    required this.onClearAll,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClearAllButton(onPressed: onClearAll),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ApplyFiltersButton(
                    matchingCount: matchingCount,
                    onPressed: onApply,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  t.eventFilters.showEvents(count: matchingCount),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Clear all" button in the footer.
class ClearAllButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ClearAllButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.close, size: 16),
            const SizedBox(width: 6),
            Text(
              t.eventFilters.clearAll,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Apply filters" gradient button in the footer.
class ApplyFiltersButton extends StatelessWidget {
  final int matchingCount;
  final VoidCallback onPressed;

  const ApplyFiltersButton({
    super.key,
    required this.matchingCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              t.eventFilters.showEvents(count: matchingCount),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Components
// ---------------------------------------------------------------------------

/// Reusable header row for each filter section (title + clear button).
class FilterSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onClear;

  const FilterSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onClear,
          child: Text(
            t.eventFilters.clear,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small message shown when there are no options to display.
class _EmptyOptionMessage extends StatelessWidget {
  final String message;

  const _EmptyOptionMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dance type icon/color helpers
// ---------------------------------------------------------------------------

IconData _danceTypeIcon(String danceType) {
  switch (danceType.toLowerCase()) {
    case 'salsa':
      return Icons.local_fire_department;
    case 'bachata':
      return Icons.favorite;
    case 'kizomba':
      return Icons.nightlight_round;
    case 'zouk':
      return Icons.water;
    case 'tango':
      return Icons.local_florist;
    case 'swing':
      return Icons.face;
    case 'forró':
    case 'forro':
      return Icons.album;
    case 'merengue':
      return Icons.wb_sunny;
    case 'reggaeton':
      return Icons.bolt;
    case 'urban kiz':
      return Icons.location_city;
    case 'lindy hop':
      return Icons.album;
    default:
      return Icons.music_note;
  }
}

Color _danceTypeColor(String danceType) {
  switch (danceType.toLowerCase()) {
    case 'salsa':
      return Colors.red;
    case 'bachata':
      return Colors.pink;
    case 'kizomba':
      return Colors.purple;
    case 'zouk':
      return Colors.teal;
    case 'tango':
      return Colors.blueGrey;
    case 'swing':
      return Colors.orange;
    case 'forró':
    case 'forro':
      return Colors.green;
    case 'merengue':
      return Colors.amber;
    case 'reggaeton':
      return Colors.lime;
    case 'urban kiz':
      return Colors.deepPurple;
    case 'lindy hop':
      return Colors.yellow;
    default:
      return const Color(0xFF6366F1);
  }
}
