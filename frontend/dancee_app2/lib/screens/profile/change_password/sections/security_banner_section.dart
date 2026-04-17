import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class SecurityBannerSection extends StatelessWidget {
  const SecurityBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appWarning.withValues(alpha: 0.1),
            appWarning.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: appWarning.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appWarning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.shieldHalved, size: 18, color: appWarning),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zabezpečte svůj účet',
                  style: TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                    fontWeight: AppTypography.fontWeightSemiBold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Silné heslo musí obsahovat alespoň 8 znaků, velká a malá písmena, čísla a speciální znaky.',
                  style: TextStyle(
                    color: appMuted,
                    fontSize: AppTypography.fontSizeSm,
                    height: 1.5,
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
