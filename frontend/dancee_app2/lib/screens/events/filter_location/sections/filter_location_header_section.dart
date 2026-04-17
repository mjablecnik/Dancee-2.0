import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class FilterLocationHeaderSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;

  const FilterLocationHeaderSection({
    super.key,
    required this.controller,
    required this.onBack,
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
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: appSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(FontAwesomeIcons.arrowLeft, size: 16, color: appText),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              const Text(
                'Vybrat lokalitu',
                style: TextStyle(
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: AppTypography.fontWeightBold,
                  color: appText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.lg),
                  child: Icon(FontAwesomeIcons.magnifyingGlass, size: 14, color: appMuted),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSizeMd,
                      color: appText,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Hledat město nebo oblast...',
                      hintStyle: TextStyle(
                        fontSize: AppTypography.fontSizeMd,
                        color: appMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
