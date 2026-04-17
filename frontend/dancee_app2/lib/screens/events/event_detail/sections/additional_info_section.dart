import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dodatečné informace',
          style: TextStyle(
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
              _buildInfoRow(label: 'Vstupné', value: priceRange),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow(label: 'Dresscode', value: dresscode),
              const SizedBox(height: AppSpacing.lg),
              _buildBuyTicketsButton(),
              const SizedBox(height: AppSpacing.sm),
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.ticket, size: 14, color: Colors.white),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Koupit vstupenky',
              style: TextStyle(
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: 14, color: appText),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Původní zdroj',
              style: TextStyle(
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
