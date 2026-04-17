import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

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
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Účet'),
                  const SizedBox(height: 12),
                  _buildAccountSection(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Nastavení'),
                  const SizedBox(height: 12),
                  _buildSettingsSection(),
                  const SizedBox(height: 24),
                  _buildPremiumSection(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Podpora'),
                  const SizedBox(height: 12),
                  _buildSupportSection(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('O aplikaci'),
                  const SizedBox(height: 12),
                  _buildAppInfoSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Nebezpečná zóna'),
                  const SizedBox(height: 12),
                  _buildDangerZone(),
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
            'Profil',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.pen, size: 16, color: appText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: appPrimary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.network(
                'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tereza Nováková',
                  style: TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSize2xl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'tereza.novakova@email.cz',
                  style: TextStyle(
                    color: appMuted,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _danceTag('Salsa', appPrimary),
                    _danceTag('Bachata', appAccent),
                    _danceTag('Zouk', appTeal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _danceTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: appMuted,
        fontSize: AppTypography.fontSizeSm,
        fontWeight: AppTypography.fontWeightSemiBold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: FontAwesomeIcons.user,
            iconBgColor: appPrimary.withValues(alpha: 0.2),
            iconColor: appPrimary,
            title: 'Upravit profil',
            onTap: () => context.push('/profile/edit'),
            showDivider: true,
          ),
          _menuRow(
            icon: FontAwesomeIcons.lock,
            iconBgColor: appWarning.withValues(alpha: 0.2),
            iconColor: appWarning,
            title: 'Změnit heslo',
            onTap: () => context.push('/profile/change-password'),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: FontAwesomeIcons.globe,
            iconBgColor: appSuccess.withValues(alpha: 0.2),
            iconColor: appSuccess,
            title: 'Jazyk',
            trailingWidget: const Text(
              'Čeština',
              style: TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeMd,
              ),
            ),
            onTap: null,
            showDivider: true,
          ),
          _menuRowWithToggle(
            icon: FontAwesomeIcons.bell,
            iconBgColor: appAccent.withValues(alpha: 0.2),
            iconColor: appAccent,
            title: 'Oznámení',
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile/premium'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appPrimary.withValues(alpha: 0.2),
              appAccent.withValues(alpha: 0.2),
              appPink.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.crown, size: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dancee Premium',
                    style: TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Odemkněte všechny funkce',
                    style: TextStyle(
                      color: appMuted,
                      fontSize: AppTypography.fontSizeMd,
                    ),
                  ),
                ],
              ),
            ),
            const FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: appMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: FontAwesomeIcons.message,
            iconBgColor: appPrimary.withValues(alpha: 0.2),
            iconColor: appPrimary,
            title: 'Napsat autorovi',
            onTap: () => context.push('/profile/author-contact'),
            showDivider: true,
          ),
          _menuRow(
            icon: FontAwesomeIcons.star,
            iconBgColor: appGold.withValues(alpha: 0.2),
            iconColor: appGold,
            title: 'Ohodnotit aplikaci',
            onTap: null,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: FontAwesomeIcons.circleInfo,
            iconBgColor: appBorder,
            iconColor: appMuted,
            title: 'Verze aplikace',
            trailingWidget: const Text(
              '1.2.5 (Build 125)',
              style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            onTap: null,
            showDivider: true,
          ),
          _menuRow(
            icon: FontAwesomeIcons.shieldHalved,
            iconBgColor: appBorder,
            iconColor: appMuted,
            title: 'Podmínky použití',
            onTap: null,
            showDivider: true,
          ),
          _menuRow(
            icon: FontAwesomeIcons.userShield,
            iconBgColor: appBorder,
            iconColor: appMuted,
            title: 'Ochrana soukromí',
            onTap: null,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          _dangerRow(
            icon: FontAwesomeIcons.rightFromBracket,
            title: 'Odhlásit se',
            showDivider: true,
          ),
          _dangerRow(
            icon: FontAwesomeIcons.trash,
            title: 'Smazat účet',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    Widget? trailingWidget,
    required VoidCallback? onTap,
    required bool showDivider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: FaIcon(icon, size: 15, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeLg,
                        fontWeight: AppTypography.fontWeightMedium,
                      ),
                    ),
                  ),
                  if (trailingWidget != null) trailingWidget,
                  if (trailingWidget == null && onTap != null)
                    const FaIcon(FontAwesomeIcons.chevronRight, size: 13, color: appMuted),
                ],
              ),
            ),
            if (showDivider)
              const Divider(height: 1, color: appBorder, indent: 66),
          ],
        ),
      ),
    );
  }

  Widget _menuRowWithToggle({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(icon, size: 15, color: iconColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: appPrimary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: appBorder,
          ),
        ],
      ),
    );
  }

  Widget _dangerRow({
    required IconData icon,
    required String title,
    required bool showDivider,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(icon, size: 15, color: Colors.red),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, color: appBorder, indent: 66),
        ],
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
          _navFab(context),
          _navItem(FontAwesomeIcons.heart, 'Uložené', false, null),
          _navItem(FontAwesomeIcons.user, 'Profil', true, null),
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

  Widget _navFab(BuildContext context) {
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
