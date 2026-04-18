import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class ActionButtonsSection extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onMap;

  const ActionButtonsSection({
    super.key,
    this.onSave,
    this.onShare,
    this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildSaveButton()),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildOutlineButton(
          icon: FontAwesomeIcons.shareNodes,
          label: t.common.share,
          onTap: onShare,
        )),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildOutlineButton(
          icon: FontAwesomeIcons.mapLocationDot,
          label: t.common.map,
          onTap: onMap,
        )),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: onSave,
      child: Container(
        decoration: BoxDecoration(
          color: appPrimary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [AppShadows.primary],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.heart, size: 14, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Text(
                t.common.save,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, size: 14, color: appText),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
