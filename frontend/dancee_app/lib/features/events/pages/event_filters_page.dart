import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../i18n/translations.g.dart';

part 'event_filters_page.g.dart';

/// Route definition for the event filters page.
///
/// Simple page (no folder) with [NoTransitionPage] to disable animations.
@TypedGoRoute<EventFiltersRoute>(path: '/events/filters')
class EventFiltersRoute extends GoRouteData {
  const EventFiltersRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: EventFiltersPage());
  }
}

/// Page for filtering and sorting dance events.
///
/// Placeholder implementation based on `.design/event-filters.html`.
/// Contains filter sections for dance type, location, and date range.
class EventFiltersPage extends StatelessWidget {
  const EventFiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          EventFiltersHeaderSection(
            onBackPressed: () => context.pop(),
            onResetPressed: () {},
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: const [
                ActiveFiltersSummary(),
                SizedBox(height: 24),
                DanceTypeFilterSection(),
                SizedBox(height: 24),
                LocationFilterSection(),
                SizedBox(height: 24),
                DateRangeFilterSection(),
                SizedBox(height: 24),
                SaveFilterSection(),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: const FilterFooterActions(),
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
  const ActiveFiltersSummary({super.key});

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
                  t.eventFilters.eventsShown(count: 24),
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
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '2',
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
  const DanceTypeFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.music_note,
          title: t.eventFilters.danceType,
          onClear: () {},
        ),
        const SizedBox(height: 12),
        DanceTypeOption(label: t.eventFilters.salsa, icon: Icons.local_fire_department, iconColor: Colors.red),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.bachata, icon: Icons.favorite, iconColor: Colors.pink),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.kizomba, icon: Icons.nightlight_round, iconColor: Colors.purple),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.zouk, icon: Icons.water, iconColor: Colors.teal),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.tango, icon: Icons.local_florist, iconColor: Colors.blueGrey),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.swing, icon: Icons.face, iconColor: Colors.orange),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.forro, icon: Icons.album, iconColor: Colors.green),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.merengue, icon: Icons.wb_sunny, iconColor: Colors.amber),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.reggaeton, icon: Icons.bolt, iconColor: Colors.lime),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.urbanKiz, icon: Icons.location_city, iconColor: Colors.deepPurple),
        const SizedBox(height: 8),
        DanceTypeOption(label: t.eventFilters.lindyHop, icon: Icons.album, iconColor: Colors.yellow.shade800),
        const SizedBox(height: 12),
        ShowMoreDancesButton(onPressed: () {}),
      ],
    );
  }
}

/// A single dance type checkbox option row.
class DanceTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;

  const DanceTypeOption({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 2),
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
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Button to show more dance type options.
class ShowMoreDancesButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShowMoreDancesButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.eventFilters.showMoreDances,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location Filter Section
// ---------------------------------------------------------------------------

/// Section with radio-style options for filtering by location.
class LocationFilterSection extends StatelessWidget {
  const LocationFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.location_on,
          title: t.eventFilters.location,
          onClear: () {},
        ),
        const SizedBox(height: 12),
        LocationOption(label: t.prague, icon: Icons.apartment, iconColor: const Color(0xFF6366F1)),
        const SizedBox(height: 8),
        LocationOption(label: t.eventFilters.brno, icon: Icons.account_balance, iconColor: Colors.blue.shade700),
        const SizedBox(height: 8),
        LocationOption(label: t.eventFilters.ostrava, icon: Icons.factory, iconColor: Colors.blueGrey),
        const SizedBox(height: 8),
        LocationOption(label: t.eventFilters.plzen, icon: Icons.sports_bar, iconColor: Colors.amber.shade700),
        const SizedBox(height: 8),
        LocationOption(label: t.eventFilters.liberec, icon: Icons.terrain, iconColor: Colors.green.shade700),
        const SizedBox(height: 8),
        LocationOption(label: t.eventFilters.olomouc, icon: Icons.church, iconColor: Colors.indigo),
        const SizedBox(height: 16),
        CustomLocationInput(),
      ],
    );
  }
}

/// A single location radio-style option row.
class LocationOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;

  const LocationOption({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 2),
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
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text input for entering a custom location.
class CustomLocationInput extends StatelessWidget {
  const CustomLocationInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FAFB), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.eventFilters.customLocationLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: t.eventFilters.customLocationHint,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date Range Filter Section
// ---------------------------------------------------------------------------

/// Section with date pickers and quick-select date buttons.
class DateRangeFilterSection extends StatelessWidget {
  const DateRangeFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.calendar_month,
          title: t.eventFilters.date,
          onClear: () {},
        ),
        const SizedBox(height: 12),
        DateInputField(label: t.eventFilters.dateFrom),
        const SizedBox(height: 12),
        DateInputField(label: t.eventFilters.dateTo),
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
                onPressed: () {},
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
                onPressed: () {},
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
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.event_available,
                label: t.eventFilters.dateWeekend,
                iconColor: Colors.green.shade600,
                gradientColors: const [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
                borderColor: const Color(0xFFBBF7D0),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A labeled date input field with calendar icon.
class DateInputField extends StatelessWidget {
  final String label;

  const DateInputField({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
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
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 2),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(Icons.calendar_today,
                    color: Colors.grey.shade400, size: 18),
              ),
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'dd.mm.yyyy',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
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
  const SaveFilterSection({super.key});

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
            onTap: () {},
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
  const FilterFooterActions({super.key});

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
                  child: ClearAllButton(onPressed: () {}),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ApplyFiltersButton(onPressed: () {}),
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
                  t.eventFilters.eventsShown(count: 24),
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
  final VoidCallback onPressed;

  const ApplyFiltersButton({super.key, required this.onPressed});

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
              t.eventFilters.applyFilters,
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
