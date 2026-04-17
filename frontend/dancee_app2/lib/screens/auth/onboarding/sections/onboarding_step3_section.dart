import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';
import '../../../../shared/elements/buttons/outline_button.dart';
import '../components/radius_selector.dart';

class OnboardingStep3Section extends StatelessWidget {
  final int selectedRadius;
  final ValueChanged<int> onRadiusSelected;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const OnboardingStep3Section({
    super.key,
    required this.selectedRadius,
    required this.onRadiusSelected,
    required this.onBack,
    required this.onFinish,
  });

  static const _radii = ['10 km', '25 km', '50 km', 'Celá republika'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Kde se nacházíš?',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize4xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Najdeme pro tebe nejbližší taneční akce ve tvém okolí',
            style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CityInputField(),
                  const SizedBox(height: AppSpacing.md),
                  RadiusSelector(
                    radii: _radii,
                    selectedIndex: selectedRadius,
                    onSelected: onRadiusSelected,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _UseCurrentLocationButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  label: 'Zpět',
                  onTap: onBack,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: GradientButton(
                  label: 'Dokončit',
                  onTap: onFinish,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _CityInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Město',
            style: TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: appCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: appBorder),
            ),
            child: const Row(
              children: [
                SizedBox(width: AppSpacing.lg),
                FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: appPrimary,
                  size: 14,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: appText),
                    decoration: InputDecoration(
                      hintText: 'Např. Praha, Brno...',
                      hintStyle: TextStyle(color: appMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UseCurrentLocationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.locationCrosshairs,
              color: appPrimary,
              size: 18,
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              'Použít aktuální polohu',
              style: TextStyle(
                color: appPrimary,
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
