import 'package:dancee_app2/screens/events/events_list/components/dance_style_chips_row.dart';
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
        const DanceStyleChipsRow(),
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
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSize3xl,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            GestureDetector(
              onTap: onShowAll,
              child: Text(
                t.common.showAll,
                style: const TextStyle(
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
        style: const TextStyle(
          color: appMuted,
          fontSize: AppTypography.fontSizeSm,
          fontWeight: AppTypography.fontWeightSemiBold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
