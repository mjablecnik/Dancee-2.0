import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(),
                  _buildPlansSection(),
                  _buildFeaturesSection(),
                  _buildTestimonialsSection(),
                  _buildFaqSection(),
                  _buildFinalCta(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppGradients.premium,
                borderRadius: BorderRadius.circular(48),
                boxShadow: [
                  AppShadows.primary,
                ],
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.crown, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => AppGradients.premium.createShader(bounds),
              child: const Text(
                'Odemkněte plný potenciál',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.fontSize5xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Získejte přístup ke všem prémiové funkcím a zlepšete své taneční zážitky',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeMd,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          // Yearly plan (popular)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appPrimary.withValues(alpha: 0.1),
                  appAccent.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Roční předplatné',
                      style: TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSize3xl,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Nejlepší hodnota',
                      style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                          child: const Text(
                            '499 Kč',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTypography.fontSize6xl,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '999 Kč',
                          style: TextStyle(
                            color: appMuted,
                            fontSize: AppTypography.fontSizeMd,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pouze 42 Kč/měsíc · Ušetříte 50%',
                      style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          AppShadows.primary,
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: const Text(
                          'Vybrat roční plán',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTypography.fontSizeLg,
                            fontWeight: AppTypography.fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text(
                      'POPULÁRNÍ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.fontSizeXs,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Monthly plan
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Měsíční předplatné',
                  style: TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSize3xl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Flexibilní možnost',
                  style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
                const SizedBox(height: 16),
                const Text(
                  '99 Kč',
                  style: TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSize6xl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fakturováno měsíčně',
                  style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: appCard,
                    border: Border.all(color: appBorder),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: const Text(
                      'Vybrat měsíční plán',
                      style: TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeLg,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      ('Neomezené oblíbené akce', 'Ukládejte si neomezený počet tanečních akcí'),
      ('Pokročilé filtry', 'Filtrujte podle více kritérií najednou'),
      ('Upozornění na nové akce', 'Buďte první, kdo se dozví o nových eventtech'),
      ('Offline režim', 'Přístup k uloženým akcím bez internetu'),
      ('Prioritní podpora', 'Rychlejší odpovědi na vaše dotazy'),
      ('Žádné reklamy', 'Užívejte si aplikaci bez přerušení'),
      ('Exkluzivní odznaky', 'Speciální odznaky na vašem profilu'),
      ('Kalendářová integrace', 'Synchronizace s vaším kalendářem'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Co získáte s Premium',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appSurface,
                    border: Border.all(color: appBorder),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Center(
                          child: FaIcon(FontAwesomeIcons.check, size: 14, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.$1,
                              style: const TextStyle(
                                color: appText,
                                fontSize: AppTypography.fontSizeMd,
                                fontWeight: AppTypography.fontWeightSemiBold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feature.$2,
                              style: const TextStyle(
                                color: appMuted,
                                fontSize: AppTypography.fontSizeMd,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Co říkají naši uživatelé',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTestimonialCard(
            avatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-2.jpg',
            name: 'Martin Dvořák',
            quote: '"Premium předplatné mi úplně změnilo způsob, jak objevuji taneční akce. Upozornění jsou skvělá!"',
          ),
          const SizedBox(height: 12),
          _buildTestimonialCard(
            avatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg',
            name: 'Jana Svobodová',
            quote: '"Nejlepší investice pro tanečníka! Pokročilé filtry mi ušetřily spoustu času."',
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String avatarUrl,
    required String name,
    required String quote,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.round),
                child: Image.network(
                  avatarUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (i) => const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: FaIcon(
                          FontAwesomeIcons.solidStar,
                          size: 11,
                          color: appGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeMd,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    final faqs = [
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Časté otázky',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FaqItem(question: faq.$1, answer: faq.$2),
              )),
        ],
      ),
    );
  }

  Widget _buildFinalCta() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appPrimary.withValues(alpha: 0.1),
              appAccent.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppGradients.premium.createShader(bounds),
              child: const FaIcon(
                FontAwesomeIcons.solidStarHalfStroke,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Připraveni začít?',
              style: TextStyle(
                color: appText,
                fontSize: AppTypography.fontSize3xl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Připojte se k tisícům spokojených tanečníků',
              textAlign: TextAlign.center,
              style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  AppShadows.primary,
                ],
              ),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text(
                  'Získat Premium nyní',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: AppTypography.fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '7 dní zdarma · Zrušte kdykoliv',
              style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: appCard,
        border: Border(top: BorderSide(color: appBorder)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(FontAwesomeIcons.house, 'Domů', false, () => context.go('/events')),
          _navItem(FontAwesomeIcons.magnifyingGlass, 'Hledat', false, null),
          _navFab(),
          _navItem(FontAwesomeIcons.heart, 'Uložené', false, null),
          _navItem(FontAwesomeIcons.user, 'Profil', false, () => context.go('/profile')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    final color = isActive ? appPrimary : appMuted;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: AppTypography.fontSizeXs, fontWeight: AppTypography.fontWeightMedium)),
        ],
      ),
    );
  }

  Widget _navFab() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: appPrimary,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: appBg, width: 4),
          boxShadow: [
            AppShadows.primary,
          ],
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.plus, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ),
                  FaIcon(
                    _expanded ? FontAwesomeIcons.chevronUp : FontAwesomeIcons.chevronDown,
                    size: 13,
                    color: appMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
