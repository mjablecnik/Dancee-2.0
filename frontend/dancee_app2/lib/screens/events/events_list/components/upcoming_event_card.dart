import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class UpcomingEventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String date;
  final String style;
  final Color styleColor;
  final bool isFavorited;
  final VoidCallback? onTap;

  const UpcomingEventCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.style,
    required this.styleColor,
    required this.isFavorited,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.network(
                    imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32, top: 4),
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
                            fontWeight: AppTypography.fontWeightBold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.locationDot, size: 12, color: appPrimary),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  color: appMuted,
                                  fontSize: AppTypography.fontSizeSm,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: appCard,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  color: appText,
                                  fontSize: AppTypography.fontSizeSm,
                                  fontWeight: AppTypography.fontWeightMedium,
                                ),
                              ),
                            ),
                            Text(
                              style.toUpperCase(),
                              style: TextStyle(
                                color: styleColor,
                                fontSize: AppTypography.fontSizeXs,
                                fontWeight: AppTypography.fontWeightBold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Center(
                  child: FaIcon(
                    isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                    size: 14,
                    color: isFavorited ? Colors.red : appMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
