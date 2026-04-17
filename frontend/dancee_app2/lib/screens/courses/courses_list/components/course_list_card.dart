import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class CourseTag {
  final String label;
  final Color color;

  const CourseTag(this.label, this.color);
}

class CourseListCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String instructor;
  final String dateRange;
  final List<CourseTag> tags;
  final String price;
  final VoidCallback? onTap;

  const CourseListCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.instructor,
    required this.dateRange,
    required this.tags,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRow(),
            const SizedBox(height: AppSpacing.md),
            _buildDateRow(),
            const SizedBox(height: AppSpacing.sm),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeXl,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.userTie, size: 12, color: appPrimary),
                  const SizedBox(width: AppSpacing.sm - 2),
                  Text(
                    instructor,
                    style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.network(
            imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        const FaIcon(FontAwesomeIcons.calendar, size: 12, color: appMuted),
        const SizedBox(width: AppSpacing.sm),
        Text(
          dateRange,
          style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: tags
              .map((tag) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: appCard,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        tag.label,
                        style: TextStyle(
                          color: tag.color,
                          fontSize: AppTypography.fontSizeXs,
                          fontWeight: AppTypography.fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ))
              .toList(),
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
    );
  }
}
