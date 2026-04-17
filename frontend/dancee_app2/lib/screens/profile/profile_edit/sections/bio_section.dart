import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class BioSection extends StatelessWidget {
  final String initialBio;

  const BioSection({
    super.key,
    this.initialBio = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popis',
              style: TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              initialValue: initialBio,
              maxLines: 3,
              style: const TextStyle(color: appText),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Napište něco o sobě...',
                hintStyle: TextStyle(color: appMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
