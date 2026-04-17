import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildHeroImage(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildCourseTitle(),
                        const SizedBox(height: 24),
                        _buildKeyInfo(),
                        const SizedBox(height: 24),
                        _buildDescription(),
                        const SizedBox(height: 24),
                        _buildCourseDetails(),
                        const SizedBox(height: 24),
                        _buildInstructor(),
                        const SizedBox(height: 24),
                        _buildWhatYouLearn(),
                        const SizedBox(height: 24),
                        _buildRegistrationCta(),
                        const SizedBox(height: 16),
                        _buildAdditionalActions(),
                      ],
                    ),
                  ),
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
          const Text(
            'Detail kurzu',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appSurface,
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.ellipsisVertical, size: 16, color: appText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 256,
      child: Stack(
        children: [
          Image.network(
            'https://storage.googleapis.com/uxpilot-auth.appspot.com/0044a4f9d3-b46f198ea48e475a16aa.png',
            height: 256,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  appBg,
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: appPrimary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                '2 500 Kč',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: appSurface.withValues(alpha: 0.9),
                border: Border.all(color: appBorder),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Začátečníci',
                style: TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Salsa Cubana pro začátečníky',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize4xl,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _styleChip('Salsa', appPrimary),
          ],
        ),
      ],
    );
  }

  Widget _styleChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: AppTypography.fontSizeSm,
          fontWeight: AppTypography.fontWeightSemiBold,
        ),
      ),
    );
  }

  Widget _buildKeyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _keyInfoRow(
            icon: FontAwesomeIcons.calendar,
            title: '15. Leden - 30. Duben 2025',
            subtitle: 'Každé úterý 19:00 - 20:30',
          ),
          const SizedBox(height: 12),
          _keyInfoRow(
            icon: FontAwesomeIcons.locationDot,
            title: 'Dance Studio Praha',
            subtitle: 'Wenceslas Square 14, Praha 1',
          ),
          const SizedBox(height: 12),
          _keyInfoRow(
            icon: FontAwesomeIcons.userTie,
            title: 'Carlos Rodriguez',
            subtitle: 'Certifikovaný lektor salsy',
          ),
          const SizedBox(height: 12),
          _keyInfoRow(
            icon: FontAwesomeIcons.tag,
            title: '2 500 Kč',
            subtitle: 'Za celý kurz (15 lekcí)',
          ),
        ],
      ),
    );
  }

  Widget _keyInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FaIcon(icon, size: 18, color: appPrimary),
        const SizedBox(width: 12),
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
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Popis kurzu',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Objevte krásu kubánské salsy v našem kurzu určeném pro úplné začátečníky. Naučíte se základní kroky, rytmus a techniky, které vám umožní tancovat s jistotou na jakékoli taneční akci.',
          style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd, height: 1.6),
        ),
        SizedBox(height: 12),
        Text(
          'Kurz je veden zkušeným lektorem Carlosem Rodriguezem, který má více než 10 let zkušeností s výukou latinsko-amerických tanců. Každá lekce je strukturovaná tak, aby postupně budovala vaše dovednosti.',
          style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd, height: 1.6),
        ),
        SizedBox(height: 12),
        Text(
          'Žádné předchozí zkušenosti nejsou potřeba. Přijďte si užít skvělou atmosféru a poznat nové přátele!',
          style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildCourseDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Podrobnosti kurzu',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              _detailRow('Délka kurzu', '15 lekcí'),
              const SizedBox(height: 12),
              _detailRow('Délka lekce', '90 minut'),
              const SizedBox(height: 12),
              _detailRow('Maximální počet', '20 osob'),
              const SizedBox(height: 12),
              _detailRow('Úroveň', 'Začátečníci'),
              const SizedBox(height: 12),
              _detailRow('Věková skupina', '18+ let'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd, fontWeight: AppTypography.fontWeightMedium),
        ),
        Text(
          value,
          style: const TextStyle(color: appText, fontSize: AppTypography.fontSizeMd, fontWeight: AppTypography.fontWeightSemiBold),
        ),
      ],
    );
  }

  Widget _buildInstructor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'O lektorovi',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.network(
                  'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-8.jpg',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carlos Rodriguez',
                      style: TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeXl,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Profesionální tanečník a lektor s více než 10 let zkušeností. Specializuje se na kubánskou salsu a bachatu. Vyučoval v prestižních studiích po celé Evropě.',
                      style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd, height: 1.5),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              '10+',
                              style: TextStyle(
                                color: appPrimary,
                                fontSize: AppTypography.fontSize2xl,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'let zkušeností',
                              style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
                            ),
                          ],
                        ),
                        SizedBox(width: 24),
                        Column(
                          children: [
                            Text(
                              '500+',
                              style: TextStyle(
                                color: appPrimary,
                                fontSize: AppTypography.fontSize2xl,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'studentů',
                              style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhatYouLearn() {
    const items = [
      'Základní kroky kubánské salsy',
      'Rytmus a timing v salse',
      'Základní otočky a figury',
      'Vedení a následování partnera',
      'Taneční etiketa a sociální tanec',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Co se naučíte',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        for (final item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: FaIcon(FontAwesomeIcons.check, size: 14, color: appSuccess),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item, style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd)),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildRegistrationCta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appPrimary.withValues(alpha: 0.1),
        border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Cena kurzu',
                    style: TextStyle(color: appText, fontSize: AppTypography.fontSizeMd, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '2 500 Kč',
                    style: TextStyle(
                      color: appPrimary,
                      fontSize: AppTypography.fontSize4xl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Platba na místě nebo převodem',
                    style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Volná místa',
                    style: TextStyle(color: appSuccess, fontSize: AppTypography.fontSizeMd, fontWeight: AppTypography.fontWeightMedium),
                  ),
                  Text(
                    '12/20',
                    style: TextStyle(
                      color: appSuccess,
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appPrimary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                AppShadows.primary,
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.userPlus, size: 16, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Registrovat se na kurz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalActions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.shareNodes, size: 14, color: appText),
                  SizedBox(width: 8),
                  Text(
                    'Sdílet kurz',
                    style: TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: 14, color: appText),
                  SizedBox(width: 8),
                  Text(
                    'Původní zdroj',
                    style: TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
          _navItem(FontAwesomeIcons.bookOpen, 'Kurzy', true, () => context.go('/courses')),
          _navItem(FontAwesomeIcons.user, 'Profil', false, null),
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
          child: FaIcon(FontAwesomeIcons.graduationCap, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
