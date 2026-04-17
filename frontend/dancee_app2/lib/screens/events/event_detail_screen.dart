import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _programExpanded = true;

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
                        _buildEventTitle(),
                        const SizedBox(height: 24),
                        _buildKeyInfo(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                        const SizedBox(height: 24),
                        _buildDescription(),
                        const SizedBox(height: 24),
                        _buildAdditionalInfo(),
                        const SizedBox(height: 24),
                        _buildProgram(),
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
            'Detail akce',
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
            'https://storage.googleapis.com/uxpilot-auth.appspot.com/1887dced68-d1676f788ddb2c7f66cf.png',
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.solidHeart, size: 18, color: Colors.red),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: appPrimary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                'Od 350 Kč',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prague Latin Festival 2025 - Mega Edition',
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
            _styleChip('Bachata', appAccent),
            _styleChip('Zouk', appTeal),
            _styleChip('Kizomba', appLavender),
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
            title: '12. Říjen - 14. Říjen 2025',
            subtitle: 'Pátek 18:00 - Neděle 02:00',
          ),
          const SizedBox(height: 12),
          _keyInfoRow(
            icon: FontAwesomeIcons.locationDot,
            title: 'Kongresové centrum Praha',
            subtitle: '5. května 65, Praha 4',
          ),
          const SizedBox(height: 12),
          _keyInfoRow(
            icon: FontAwesomeIcons.userTie,
            title: 'Prague Latin Events',
            subtitle: 'Organizátor',
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: appPrimary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                AppShadows.primary,
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.heart, size: 14, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Uložit',
                    style: TextStyle(
                      color: Colors.white,
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
                  FaIcon(FontAwesomeIcons.shareNodes, size: 14, color: appText),
                  SizedBox(width: 8),
                  Text(
                    'Sdílet',
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
                  FaIcon(FontAwesomeIcons.mapLocationDot, size: 14, color: appText),
                  SizedBox(width: 8),
                  Text(
                    'Mapa',
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

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Popis akce',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Největší latinsko-americký taneční festival v České republice se vrací! Tři dny plné workshopů s mezinárodními lektory, sociálních tanečních večírků a nezapomenutelné atmosféry.',
          style: TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
            height: 1.6,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Připravte se na intenzivní víkend plný tance, kde se setkáte s nejlepšími tanečníky a lektory z celého světa. Festival nabízí workshopy pro všechny úrovně - od začátečníků až po pokročilé tanečníky.',
          style: TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dodatečné informace',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Vstupné',
                    style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd, fontWeight: AppTypography.fontWeightMedium),
                  ),
                  Text(
                    '350 - 1200 Kč',
                    style: TextStyle(color: appText, fontSize: AppTypography.fontSizeMd, fontWeight: AppTypography.fontWeightSemiBold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Dresscode',
                    style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd, fontWeight: AppTypography.fontWeightMedium),
                  ),
                  Text(
                    'Elegantní casual',
                    style: TextStyle(color: appText, fontSize: AppTypography.fontSizeMd, fontWeight: AppTypography.fontWeightSemiBold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: appPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    FaIcon(FontAwesomeIcons.ticket, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Koupit vstupenky',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: appSurface,
                  border: Border.all(color: appBorder),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgram() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _programExpanded = !_programExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Program akce',
                style: TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize2xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedRotation(
                turns: _programExpanded ? 0 : -0.25,
                duration: const Duration(milliseconds: 300),
                child: const FaIcon(FontAwesomeIcons.chevronDown, size: 16, color: appText),
              ),
            ],
          ),
        ),
        if (_programExpanded) ...[
          const SizedBox(height: 16),
          _buildDayCard(
            day: 'Pátek 12. Říjen',
            slots: [
              _ProgramSlot(
                time: '18:00',
                title: 'Registrace a Welcome drink',
                description: 'Uvítací nápoj a seznámení',
                extra: null,
                extraColor: null,
              ),
              _ProgramSlot(
                time: '20:00',
                title: 'Opening Party',
                description: 'Úvodní taneční večírek',
                extra: 'DJ: Carlos Rodriguez',
                extraColor: appPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDayCard(
            day: 'Sobota 13. Říjen',
            slots: [
              _ProgramSlot(
                time: '10:00',
                title: 'Salsa Workshop - Začátečníci',
                description: 'Základy salsy pro nové tanečníky',
                extra: 'Lektoři: Maria & José Santos',
                extraColor: appAccent,
              ),
              _ProgramSlot(
                time: '12:00',
                title: 'Bachata Sensual Workshop',
                description: 'Pokročilé techniky bachaty sensual',
                extra: 'Lektoři: Korke & Judith',
                extraColor: appAccent,
              ),
              _ProgramSlot(
                time: '21:00',
                title: 'Saturday Night Fever',
                description: 'Hlavní taneční večírek',
                extra: 'DJ: Alex Sensation, DJ Tumbao',
                extraColor: appPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDayCard(
            day: 'Neděle 14. Říjen',
            slots: [
              _ProgramSlot(
                time: '11:00',
                title: 'Kizomba & Tarraxinha',
                description: 'Intenzivní workshop kizomby',
                extra: 'Lektoři: Moun & Seraphine',
                extraColor: appAccent,
              ),
              _ProgramSlot(
                time: '14:00',
                title: 'Closing Social',
                description: 'Závěrečný taneční social',
                extra: 'DJ: Local Heroes',
                extraColor: appPrimary,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDayCard({required String day, required List<_ProgramSlot> slots}) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: appCard,
              border: Border(bottom: BorderSide(color: appBorder)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              day,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeLg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < slots.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _buildProgramSlot(slots[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSlot(_ProgramSlot slot) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            slot.time,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.title,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slot.description,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
              ),
              if (slot.extra != null) ...[
                const SizedBox(height: 4),
                Text(
                  slot.extra!,
                  style: TextStyle(
                    color: slot.extraColor,
                    fontSize: AppTypography.fontSizeSm,
                  ),
                ),
              ],
            ],
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
          _navItemSaved(),
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

  Widget _navItemSaved() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        FaIcon(FontAwesomeIcons.solidHeart, size: 22, color: Colors.red),
        SizedBox(height: 4),
        Text('Uložené', style: TextStyle(color: Colors.red, fontSize: AppTypography.fontSizeXs, fontWeight: AppTypography.fontWeightMedium)),
      ],
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

class _ProgramSlot {
  final String time;
  final String title;
  final String description;
  final String? extra;
  final Color? extraColor;

  const _ProgramSlot({
    required this.time,
    required this.title,
    required this.description,
    required this.extra,
    required this.extraColor,
  });
}
