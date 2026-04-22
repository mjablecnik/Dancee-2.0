import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/dance_style_chips_row.dart';

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
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.lg,
            ),
            child: _HeaderLocationRow(location: location, onLocationTap: onLocationTap),
          ),
        ],
      ),
    );
  }
}

class _HeaderLocationRow extends StatelessWidget {
  final String location;
  final VoidCallback? onLocationTap;

  const _HeaderLocationRow({required this.location, this.onLocationTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.events.location,
              style: const TextStyle(
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
        const _HeaderNotificationBell(),
      ],
    );
  }
}

class _HeaderNotificationBell extends StatelessWidget {
  const _HeaderNotificationBell();

  @override
  Widget build(BuildContext context) {
    return const Visibility(
      visible: false,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: SizedBox(width: 40, height: 40),
    );
  }
}
