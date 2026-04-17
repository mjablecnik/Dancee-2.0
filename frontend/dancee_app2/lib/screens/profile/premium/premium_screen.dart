import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';
import 'sections/faq_section.dart';
import 'sections/features_section.dart';
import 'sections/final_cta_section.dart';
import 'sections/plans_section.dart';
import 'sections/premium_hero_section.dart';
import 'sections/testimonials_section.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _PremiumHeader(onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PremiumHeroSection(),
                  PlansSection(),
                  FeaturesSection(),
                  TestimonialsSection(),
                  FaqSection(),
                  FinalCtaSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        leftItems: [
          AppNavBarItem(icon: FontAwesomeIcons.house, label: 'Domů', onTap: () => context.go('/events')),
          AppNavBarItem(icon: FontAwesomeIcons.magnifyingGlass, label: 'Hledat'),
        ],
        rightItems: [
          AppNavBarItem(icon: FontAwesomeIcons.heart, label: 'Uložené'),
          AppNavBarItem(icon: FontAwesomeIcons.user, label: 'Profil', onTap: () => context.go('/profile')),
        ],
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _PremiumHeader({required this.onBack});

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: appText),
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => AppGradients.premium.createShader(bounds),
            child: const Text(
              'Dancee Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSize2xl,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
