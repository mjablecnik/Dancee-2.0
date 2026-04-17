import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/pricing_option_card.dart';

class CoursePricingSection extends StatelessWidget {
  final String price;
  final String priceNote;
  final String spotsAvailable;
  final String spotsTotal;
  final VoidCallback? onRegister;
  final VoidCallback? onShare;
  final VoidCallback? onSource;

  const CoursePricingSection({
    super.key,
    required this.price,
    required this.priceNote,
    required this.spotsAvailable,
    required this.spotsTotal,
    this.onRegister,
    this.onShare,
    this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRegistrationCta(),
        const SizedBox(height: AppSpacing.lg),
        _buildAdditionalActions(),
      ],
    );
  }

  Widget _buildRegistrationCta() {
    return PricingOptionCard(
      price: price,
      priceNote: priceNote,
      spotsAvailable: spotsAvailable,
      spotsTotal: spotsTotal,
      onRegister: onRegister,
    );
  }

  Widget _buildAdditionalActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onShare,
            child: Container(
              decoration: BoxDecoration(
                color: appSurface,
                border: Border.all(color: appBorder),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.shareNodes, size: 14, color: appText),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Sdílet kurz',
                      style: TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: onSource,
            child: Container(
              decoration: BoxDecoration(
                color: appSurface,
                border: Border.all(color: appBorder),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
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
            ),
          ),
        ),
      ],
    );
  }
}
