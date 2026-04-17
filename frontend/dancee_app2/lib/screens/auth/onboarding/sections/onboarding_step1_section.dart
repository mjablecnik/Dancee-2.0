import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';

class OnboardingStep1Section extends StatelessWidget {
  final List<bool> selectedDances;
  final ValueChanged<int> onDanceTap;
  final VoidCallback onNext;

  const OnboardingStep1Section({
    super.key,
    required this.selectedDances,
    required this.onDanceTap,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const dances = [
      (FontAwesomeIcons.fire, 'Salsa'),
      (FontAwesomeIcons.heart, 'Bachata'),
      (FontAwesomeIcons.water, 'Zouk'),
      (FontAwesomeIcons.moon, 'Kizomba'),
      (FontAwesomeIcons.spa, 'Tango'),
      (FontAwesomeIcons.music, 'Swing'),
      (FontAwesomeIcons.bolt, 'Hip Hop'),
      (FontAwesomeIcons.star, 'Jiné'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jaké tance tě baví?',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize4xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce',
            style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: GridView.builder(
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.6,
              ),
              itemCount: dances.length,
              itemBuilder: (context, index) {
                final (icon, name) = dances[index];
                final selected = selectedDances[index];
                return GestureDetector(
                  onTap: () => onDanceTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? appPrimary.withValues(alpha: 0.1)
                          : appSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: selected ? appPrimary : appBorder,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          icon,
                          size: 24,
                          color: selected ? appPrimary : appMuted,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          name,
                          style: TextStyle(
                            color: selected ? appPrimary : appText,
                            fontSize: AppTypography.fontSizeMd,
                            fontWeight: AppTypography.fontWeightSemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Pokračovat',
            onTap: onNext,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
