import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [AppShadows.primaryLg],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSizeXl,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
