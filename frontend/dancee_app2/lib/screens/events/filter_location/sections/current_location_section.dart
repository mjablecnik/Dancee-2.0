import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class CurrentLocationSection extends StatelessWidget {
  final VoidCallback? onTap;

  const CurrentLocationSection({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: appPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.locationCrosshairs, size: 20, color: appPrimary),
            ),
            const SizedBox(width: AppSpacing.lg),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Použít moji polohu',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeLg,
                      fontWeight: AppTypography.fontWeightSemiBold,
                      color: appText,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Automaticky najde akce ve vašem okolí',
                    style: TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
                  ),
                ],
              ),
            ),
            const Icon(FontAwesomeIcons.chevronRight, size: 14, color: appMuted),
          ],
        ),
      ),
    );
  }
}
