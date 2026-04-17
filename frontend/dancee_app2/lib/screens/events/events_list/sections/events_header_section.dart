import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class EventsHeaderSection extends StatelessWidget {
  final String location;
  final VoidCallback? onLocationTap;

  const EventsHeaderSection({
    super.key,
    required this.location,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationRow(context),
          const SizedBox(height: AppSpacing.xl),
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokalita',
              style: TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: onLocationTap,
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.locationDot, color: appPrimary, size: 16),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(
                    location,
                    style: const TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  const FaIcon(FontAwesomeIcons.chevronDown, color: appMuted, size: 12),
                ],
              ),
            ),
          ],
        ),
        _buildNotificationBell(),
      ],
    );
  }

  Widget _buildNotificationBell() {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(AppRadius.round),
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.bell, size: 18, color: appText),
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(AppRadius.xs),
              border: Border.all(color: appSurface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickFilterPill(FontAwesomeIcons.calendarDay, 'Dnes'),
          const SizedBox(width: AppSpacing.sm),
          _buildQuickFilterPill(FontAwesomeIcons.calendarWeek, 'Tento týden'),
          const SizedBox(width: AppSpacing.sm),
          _buildQuickFilterPill(null, 'Tento měsíc'),
          const SizedBox(width: AppSpacing.sm),
          _buildQuickFilterPill(null, 'Tento víkend'),
        ],
      ),
    );
  }

  Widget _buildQuickFilterPill(IconData? icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            FaIcon(icon, size: 12, color: appText),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Text(
            label,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }
}
