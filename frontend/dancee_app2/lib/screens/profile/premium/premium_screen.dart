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
import 'sections/premium_header_section.dart';
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
          PremiumHeaderSection(onBack: () => context.pop()),
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
