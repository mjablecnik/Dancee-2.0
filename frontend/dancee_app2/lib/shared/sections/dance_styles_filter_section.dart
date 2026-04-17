import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import '../../i18n/strings.g.dart';

class DanceStylesFilterSection extends StatelessWidget {
  final List<String> styles;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// When provided, shows a large bold heading with a "Zobrazit vše" link.
  /// When null, shows a compact uppercase muted label instead.
  final VoidCallback? onShowAll;

  const DanceStylesFilterSection({
    super.key,
    required this.styles,
    required this.selectedIndex,
    required this.onSelected,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(height: onShowAll != null ? AppSpacing.lg : AppSpacing.md),
        _buildChips(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (onShowAll != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              t.events.danceStyles,
              style: TextStyle(
                color: appText,
                fontSize: AppTypography.fontSize3xl,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            GestureDetector(
              onTap: onShowAll,
              child: Text(
                t.common.showAll,
                style: TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text(
        t.events.danceStylesLabel,
        style: TextStyle(
          color: appMuted,
          fontSize: AppTypography.fontSizeSm,
          fontWeight: AppTypography.fontWeightSemiBold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: List.generate(styles.length, (index) {
          final isActive = selectedIndex == index;
          final isLast = index == styles.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.md),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? appPrimary : appSurface,
                  border: Border.all(
                    color: isActive ? appPrimary : appBorder,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: isActive ? [AppShadows.primary] : null,
                ),
                child: Text(
                  styles[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : appText,
                    fontSize: AppTypography.fontSizeMd,
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
