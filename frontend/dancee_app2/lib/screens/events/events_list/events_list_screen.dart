import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';
import '../../../shared/sections/dance_styles_filter_section.dart';
import 'sections/events_header_section.dart';
import 'sections/featured_events_section.dart';
import 'sections/upcoming_events_section.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  int _selectedStyleIndex = 0;
  final List<String> _styles = ['Vše', 'Salsa', 'Bachata', 'Kizomba', 'Zouk'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          EventsHeaderSection(
            location: 'Praha, CZ',
            onLocationTap: () => context.push('/events/filter-location'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 96, top: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DanceStylesFilterSection(
                    styles: _styles,
                    selectedIndex: _selectedStyleIndex,
                    onSelected: (i) => setState(() => _selectedStyleIndex = i),
                    onShowAll: () => context.push('/events/filter-dance'),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  FeaturedEventsSection(
                    onEventTap: () => context.push('/events/detail'),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  UpcomingEventsSection(
                    onEventTap: () => context.push('/events/detail'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        leftItems: [
          const AppNavBarItem(icon: FontAwesomeIcons.house, label: 'Domů'),
          AppNavBarItem(
            icon: FontAwesomeIcons.magnifyingGlass,
            label: 'Hledat',
            isActive: true,
          ),
        ],
        rightItems: [
          const AppNavBarItem(icon: FontAwesomeIcons.heart, label: 'Uložené'),
          AppNavBarItem(
            icon: FontAwesomeIcons.user,
            label: 'Profil',
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }
}
