import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class AdditionalInfoSection extends StatelessWidget {
  final String priceRange;
  final String dresscode;
  final VoidCallback? onBuyTickets;
  final VoidCallback? onSource;

  const AdditionalInfoSection({
    super.key,
    required this.priceRange,
    required this.dresscode,
    this.onBuyTickets,
    this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrice = priceRange.isNotEmpty;
    final hasDresscode = dresscode.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.events.detail.additionalInfo,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              if (hasPrice)
                _buildInfoRow(label: t.events.detail.admission, value: priceRange),
              if (hasPrice && hasDresscode)
                const SizedBox(height: AppSpacing.md),
              if (hasDresscode)
                _buildInfoRow(label: t.events.detail.dresscode, value: dresscode),
              if ((hasPrice || hasDresscode) && (onBuyTickets != null || onSource != null))
                const SizedBox(height: AppSpacing.lg),
              if (onBuyTickets != null) ...[
                _buildBuyTicketsButton(),
                if (onSource != null) const SizedBox(height: AppSpacing.sm),
              ],
              if (onSource != null)
                _buildSourceButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightSemiBold,
          ),
        ),
      ],
    );
  }

  Widget _buildBuyTicketsButton() {
    return GestureDetector(
      onTap: onBuyTickets,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: appPrimary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.ticket, size: 14, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Text(
              t.events.detail.buyTickets,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton() {
    return GestureDetector(
      onTap: onSource,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: 14, color: appText),
            const SizedBox(width: AppSpacing.sm),
            Text(
              t.events.detail.originalSource,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
