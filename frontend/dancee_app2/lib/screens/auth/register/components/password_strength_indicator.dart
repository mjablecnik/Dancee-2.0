import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int strength;
  final bool isEmpty;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    required this.isEmpty,
  });

  Color _strengthColor() {
    switch (strength) {
      case 0:
      case 1:
        return appError;
      case 2:
        return appAmber;
      default:
        return appSuccess;
    }
  }

  String _strengthLabel() {
    switch (strength) {
      case 0:
      case 1:
        return 'Slabé heslo';
      case 2:
        return 'Středně silné';
      case 3:
        return 'Silné heslo';
      default:
        return 'Velmi silné';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isEmpty ? appBorder : _strengthColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            final filled = index < strength;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? AppSpacing.xs : 0),
                decoration: BoxDecoration(
                  color: filled ? color : appBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isEmpty ? 'Alespoň 8 znaků' : _strengthLabel(),
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            color: isEmpty ? appMuted : color,
          ),
        ),
      ],
    );
  }
}
