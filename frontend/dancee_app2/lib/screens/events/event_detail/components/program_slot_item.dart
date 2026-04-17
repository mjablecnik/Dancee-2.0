import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class ProgramSlotData {
  final String time;
  final String title;
  final String description;
  final String? extra;
  final Color? extraColor;

  const ProgramSlotData({
    required this.time,
    required this.title,
    required this.description,
    this.extra,
    this.extraColor,
  });
}

class ProgramSlotItem extends StatelessWidget {
  final ProgramSlotData slot;

  const ProgramSlotItem({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            slot.time,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.title,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                slot.description,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
              ),
              if (slot.extra != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  slot.extra!,
                  style: TextStyle(
                    color: slot.extraColor,
                    fontSize: AppTypography.fontSizeSm,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
