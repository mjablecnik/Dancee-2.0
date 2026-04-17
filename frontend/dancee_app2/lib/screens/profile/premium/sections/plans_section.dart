import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/plan_card.dart';

class PlansSection extends StatelessWidget {
  const PlansSection({super.key});

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
        children: [
          PlanCard(
            title: 'Roční předplatné',
            subtitle: 'Nejlepší hodnota',
            price: '499 Kč',
            originalPrice: '999 Kč',
            note: 'Pouze 42 Kč/měsíc · Ušetříte 50%',
            ctaLabel: 'Vybrat roční plán',
            badge: 'POPULÁRNÍ',
            isPrimary: true,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          PlanCard(
            title: 'Měsíční předplatné',
            subtitle: 'Flexibilní možnost',
            price: '99 Kč',
            note: 'Fakturováno měsíčně',
            ctaLabel: 'Vybrat měsíční plán',
            isPrimary: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
