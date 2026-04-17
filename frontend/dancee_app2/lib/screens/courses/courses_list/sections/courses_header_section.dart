import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class CoursesHeaderSection extends StatelessWidget {
  final VoidCallback? onFilterTap;

  const CoursesHeaderSection({super.key, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Taneční kurzy',
                style: TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize4xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Najdi svůj kurz',
                style: TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.sliders, size: 18, color: appText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
