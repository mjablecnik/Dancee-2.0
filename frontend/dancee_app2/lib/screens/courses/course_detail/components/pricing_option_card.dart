import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class PricingOptionCard extends StatelessWidget {
  final String price;
  final String priceNote;
  final String spotsAvailable;
  final String spotsTotal;
  final VoidCallback? onRegister;

  const PricingOptionCard({
    super.key,
    required this.price,
    required this.priceNote,
    required this.spotsAvailable,
    required this.spotsTotal,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appPrimary.withValues(alpha: 0.1),
        border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cena kurzu',
                    style: TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: appPrimary,
                      fontSize: AppTypography.fontSize4xl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    priceNote,
                    style: const TextStyle(
                      color: appMuted,
                      fontSize: AppTypography.fontSizeSm,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Volná místa',
                    style: TextStyle(
                      color: appSuccess,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                  ),
                  Text(
                    '$spotsAvailable/$spotsTotal',
                    style: const TextStyle(
                      color: appSuccess,
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: onRegister,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: appPrimary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [AppShadows.primary],
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.userPlus, size: 16, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Registrovat se na kurz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.fontSizeXl,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
