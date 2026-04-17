import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/feature_item.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const List<(String, String)> _features = [
    ('Neomezené oblíbené akce', 'Ukládejte si neomezený počet tanečních akcí'),
    ('Pokročilé filtry', 'Filtrujte podle více kritérií najednou'),
    ('Upozornění na nové akce', 'Buďte první, kdo se dozví o nových eventtech'),
    ('Offline režim', 'Přístup k uloženým akcím bez internetu'),
    ('Prioritní podpora', 'Rychlejší odpovědi na vaše dotazy'),
    ('Žádné reklamy', 'Užívejte si aplikaci bez přerušení'),
    ('Exkluzivní odznaky', 'Speciální odznaky na vašem profilu'),
    ('Kalendářová integrace', 'Synchronizace s vaším kalendářem'),
  ];

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
        children: [
          Text(
            t.premium.featuresTitle,
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: FeatureItem(
                title: feature.$1,
                description: feature.$2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
