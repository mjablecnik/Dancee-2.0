import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';

enum NavTab { events, courses, saved, profile }

class AppBottomNavBar extends StatelessWidget {
  final NavTab currentTab;

  const AppBottomNavBar({super.key, required this.currentTab});

  static const _tabs = [
    NavTab.events,
    NavTab.courses,
    // NavTab placeholder for FAB — commented out per requirement
    NavTab.saved,
    NavTab.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: appCard,
        border: Border(top: BorderSide(color: appBorder)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _tabs.map((tab) => _buildNavItem(context, tab)).toList(),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavTab tab) {
    final isActive = tab == currentTab;
    final color = isActive ? appPrimary : appMuted;

    return GestureDetector(
      onTap: isActive ? null : () => _navigate(context, tab),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(_iconFor(tab), size: 22, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _labelFor(tab),
              style: TextStyle(
                color: color,
                fontSize: AppTypography.fontSizeXs,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(NavTab tab) {
    switch (tab) {
      case NavTab.events:
        return FontAwesomeIcons.music;
      case NavTab.courses:
        return FontAwesomeIcons.bookOpen;
      case NavTab.saved:
        return FontAwesomeIcons.heart;
      case NavTab.profile:
        return FontAwesomeIcons.user;
    }
  }

  String _labelFor(NavTab tab) {
    switch (tab) {
      case NavTab.events:
        return t.nav.events;
      case NavTab.courses:
        return t.nav.courses;
      case NavTab.saved:
        return t.nav.saved;
      case NavTab.profile:
        return t.nav.profile;
    }
  }

  void _navigate(BuildContext context, NavTab tab) {
    switch (tab) {
      case NavTab.events:
        context.go('/events');
      case NavTab.courses:
        context.go('/courses');
      case NavTab.saved:
        context.go('/saved');
      case NavTab.profile:
        context.go('/profile');
    }
  }
}
