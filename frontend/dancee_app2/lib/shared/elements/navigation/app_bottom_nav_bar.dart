import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

class AppNavBarItem {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const AppNavBarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final List<AppNavBarItem> leftItems;
  final List<AppNavBarItem> rightItems;
  final VoidCallback? onFabTap;

  const AppBottomNavBar({
    super.key,
    required this.leftItems,
    required this.rightItems,
    this.onFabTap,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...leftItems.map(_buildNavItem),
          _buildFab(),
          ...rightItems.map(_buildNavItem),
        ],
      ),
    );
  }

  Widget _buildNavItem(AppNavBarItem item) {
    final color = item.isActive ? appPrimary : appMuted;
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(item.icon, size: 22, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.label,
            style: TextStyle(
              color: color,
              fontSize: AppTypography.fontSizeXs,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: onFabTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: appPrimary,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: appBg, width: 4),
            boxShadow: [AppShadows.primary],
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.plus, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
