import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/faq_item.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  static const List<(String, String)> _faqs = [
    (
      'Mohu předplatné kdykoliv zrušit?',
      'Ano, předplatné můžete zrušit kdykoliv. Přístup k Premium funkcím vám zůstane až do konce zaplaceného období.'
    ),
    (
      'Jaké platební metody přijímáte?',
      'Přijímáme platební karty (Visa, Mastercard), Apple Pay, Google Pay a bankovní převody.'
    ),
    (
      'Nabízíte zkušební období?',
      'Ano! Nový uživatelé získají 7 dní Premium zdarma. Můžete zrušit kdykoliv během zkušebního období.'
    ),
    (
      'Co se stane s mými daty po zrušení?',
      'Všechna vaše data zůstanou zachována. Ztratíte pouze přístup k Premium funkcím, ale základní funkce aplikace budou stále dostupné.'
    ),
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
            t.premium.faqTitle,
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._faqs.map(
            (faq) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: FaqItem(question: faq.$1, answer: faq.$2),
            ),
          ),
        ],
      ),
    );
  }
}
