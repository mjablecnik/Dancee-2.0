import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/testimonial_card.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Co říkají naši uživatelé',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          TestimonialCard(
            avatarUrl:
                'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-2.jpg',
            name: 'Martin Dvořák',
            quote:
                '"Premium předplatné mi úplně změnilo způsob, jak objevuji taneční akce. Upozornění jsou skvělá!"',
          ),
          SizedBox(height: AppSpacing.md),
          TestimonialCard(
            avatarUrl:
                'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg',
            name: 'Jana Svobodová',
            quote:
                '"Nejlepší investice pro tanečníka! Pokročilé filtry mi ušetřily spoustu času."',
          ),
        ],
      ),
    );
  }
}
