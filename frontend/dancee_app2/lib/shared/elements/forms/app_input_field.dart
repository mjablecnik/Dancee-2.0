import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

class AppInputField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Widget? icon;

  const AppInputField({
    super.key,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.controller,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightSemiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: appBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.lg),
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(color: appText),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: appMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
            ],
          ),
        ),
      ],
    );
  }
}
