import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class FeaturedCourseCard extends StatelessWidget {
  final String imageUrl;
  final String levelLabel;
  final Color levelColor;
  final String title;
  final String instructor;
  final String dateRange;
  final String styleLabel;
  final Color styleColor;
  final String price;
  final VoidCallback? onTap;

  const FeaturedCourseCard({
    super.key,
    required this.imageUrl,
    required this.levelLabel,
    required this.levelColor,
    required this.title,
    required this.instructor,
    required this.dateRange,
    required this.styleLabel,
    required this.styleColor,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: appCard,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageStack(),
            _buildCardBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageStack() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.round)),
          child: Image.network(
            imageUrl,
            height: 140,
            width: 280,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.round)),
              gradient: AppGradients.heroOverlay,
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              levelLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardBody() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.userTie, size: 14, color: appPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                instructor,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm - 2),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.calendar, size: 14, color: appMuted),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateRange,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  styleLabel,
                  style: TextStyle(
                    color: styleColor,
                    fontSize: AppTypography.fontSizeXs,
                    fontWeight: AppTypography.fontWeightSemiBold,
                  ),
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
