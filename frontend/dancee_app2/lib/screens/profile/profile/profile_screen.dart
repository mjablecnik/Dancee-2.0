import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../shared/components/back_button_header.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';
import 'components/profile_menu_item.dart';
import 'sections/account_section.dart';
import 'sections/logout_section.dart';
import 'sections/profile_card_section.dart';
import 'sections/settings_section.dart';
import 'sections/support_section.dart';

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
          BackButtonHeader(
            title: 'Profil',
            onBack: () => context.pop(),
            trailing: GestureDetector(
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
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xxl,
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileCardSection(
                    name: 'Tereza Nováková',
                    email: 'tereza.novakova@email.cz',
                    avatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg',
                    danceTags: const [
                      (label: 'Salsa', color: appPrimary),
                      (label: 'Bachata', color: appAccent),
                      (label: 'Zouk', color: appTeal),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _ProfileSectionTitle('Účet'),
                  const SizedBox(height: AppSpacing.md),
                  AccountSection(
                    onEditProfile: () => context.push('/profile/edit'),
                    onChangePassword: () => context.push('/profile/change-password'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _ProfileSectionTitle('Nastavení'),
                  const SizedBox(height: AppSpacing.md),
                  SettingsSection(
                    notificationsEnabled: _notificationsEnabled,
                    onNotificationsChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _PremiumBanner(onTap: () => context.push('/profile/premium')),
                  const SizedBox(height: AppSpacing.xxl),
                  _ProfileSectionTitle('Podpora'),
                  const SizedBox(height: AppSpacing.md),
                  SupportSection(
                    onContactAuthor: () => context.push('/profile/author-contact'),
                    onRateApp: null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _ProfileSectionTitle('O aplikaci'),
                  const SizedBox(height: AppSpacing.md),
                  _AppInfoSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _ProfileSectionTitle('Nebezpečná zóna'),
                  const SizedBox(height: AppSpacing.md),
                  LogoutSection(
                    onLogout: () {},
                    onDeleteAccount: () {},
                  ),
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
          AppNavBarItem(icon: FontAwesomeIcons.user, label: 'Profil', isActive: true),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  final String title;

  const _ProfileSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
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
}

class _PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _PremiumBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
            const SizedBox(width: AppSpacing.lg),
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
                    style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
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
}

class _AppInfoSection extends StatelessWidget {
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
          ProfileMenuItem(
            icon: FontAwesomeIcons.circleInfo,
            iconBgColor: appBorder,
            iconColor: appMuted,
            title: 'Verze aplikace',
            trailing: const Text(
              '1.2.5 (Build 125)',
              style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            onTap: null,
            showDivider: true,
          ),
          ProfileMenuItem(
            icon: FontAwesomeIcons.shieldHalved,
            iconBgColor: appBorder,
            iconColor: appMuted,
            title: 'Podmínky použití',
            onTap: null,
            showDivider: true,
          ),
          ProfileMenuItem(
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
}
