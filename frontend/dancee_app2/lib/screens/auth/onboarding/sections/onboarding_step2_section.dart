import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';
import '../../../../shared/elements/buttons/outline_button.dart';

class OnboardingStep2Section extends StatelessWidget {
  final int selectedLevel;
  final ValueChanged<int> onLevelSelected;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const OnboardingStep2Section({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const levels = [
      (FontAwesomeIcons.seedling, appSuccess, 'Začátečník', 'Teprve začínám s tancem'),
      (FontAwesomeIcons.chartLine, appPrimary, 'Mírně pokročilý', 'Mám základní zkušenosti'),
      (FontAwesomeIcons.fire, appAccent, 'Pokročilý', 'Tančím pravidelně několik let'),
      (FontAwesomeIcons.crown, appYellow, 'Expert', 'Profesionální úroveň'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jaká je tvoje úroveň?',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize4xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Pomůže nám to doporučit ti vhodné akce a kurzy',
            style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final (icon, iconColor, title, subtitle) = levels[index];
                final selected = selectedLevel == index;
                return GestureDetector(
                  onTap: () => onLevelSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppSpacing.xl),
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
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: appCard,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Center(
                            child: FaIcon(icon, size: 20, color: iconColor),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: appText,
                                  fontSize: AppTypography.fontSizeLg,
                                  fontWeight: AppTypography.fontWeightSemiBold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: appMuted,
                                  fontSize: AppTypography.fontSizeSm,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? appPrimary : appBorder,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: appPrimary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                  label: 'Pokračovat',
                  onTap: onNext,
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
