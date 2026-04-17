import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import '../../shared/components/back_button_header.dart';
import '../../shared/elements/labels/section_label.dart';
import '../../shared/elements/navigation/app_bottom_nav_bar.dart';
import 'profile_edit/sections/bio_section.dart';
import 'profile_edit/sections/dance_preferences_section.dart';
import 'profile_edit/sections/experience_level_section.dart';
import 'profile_edit/sections/notifications_section.dart';
import 'profile_edit/sections/personal_info_section.dart';
import 'profile_edit/sections/profile_photo_section.dart';
import 'profile_edit/sections/social_links_section.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final Map<String, bool> _dancePrefs = {
    'Salsa': true,
    'Bachata': true,
    'Zouk': true,
    'Kizomba': false,
    'Tango': false,
    'Swing': false,
  };

  String _level = 'Mírně pokročilý';

  final Map<String, bool> _notifications = {
    'Nové akce': true,
    'Připomínky akcí': true,
    'Marketingové zprávy': false,
  };

  final Map<String, String> _notificationSubtitles = {
    'Nové akce': 'Upozornění na nové taneční akce',
    'Připomínky akcí': 'Připomenout uložené akce',
    'Marketingové zprávy': 'Tipy a novinky o tancování',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          BackButtonHeader(
            title: 'Upravit profil',
            onBack: () => context.pop(),
            trailing: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.check, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfilePhotoSection(
                    avatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg',
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: 'Osobní údaje'),
                  ),
                  const PersonalInfoSection(
                    initialName: 'Tereza Nováková',
                    initialEmail: 'tereza.novakova@email.cz',
                    initialPhone: '+420 123 456 789',
                    initialCity: 'Praha',
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: 'O mně'),
                  ),
                  BioSection(
                    initialBio: 'Miluji tanec a poznávání nových lidí. Tancuji už 5 let a stále se učím nové styly.',
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: 'Oblíbené tance'),
                  ),
                  DancePreferencesSection(
                    preferences: _dancePrefs,
                    onChanged: (prefs) => setState(() => _dancePrefs
                      ..clear()
                      ..addAll(prefs)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: 'Úroveň'),
                  ),
                  ExperienceLevelSection(
                    levels: const ['Začátečník', 'Mírně pokročilý', 'Pokročilý', 'Expert'],
                    selectedLevel: _level,
                    onChanged: (level) => setState(() => _level = level),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: 'Sociální sítě'),
                  ),
                  const SocialLinksSection(),
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: 'Oznámení'),
                  ),
                  NotificationsSection(
                    notifications: _notifications,
                    subtitles: _notificationSubtitles,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _SaveButton(onSave: () => context.pop()),
      bottomNavigationBar: AppBottomNavBar(
        leftItems: [
          AppNavBarItem(icon: FontAwesomeIcons.house, label: 'Domů', onTap: () => context.go('/events')),
          AppNavBarItem(icon: FontAwesomeIcons.magnifyingGlass, label: 'Hledat', onTap: () => context.go('/events')),
        ],
        rightItems: [
          AppNavBarItem(icon: FontAwesomeIcons.heart, label: 'Uložené', onTap: () => context.go('/events')),
          AppNavBarItem(icon: FontAwesomeIcons.user, label: 'Profil', isActive: true, onTap: () => context.go('/profile')),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appBg,
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: appPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            elevation: 0,
          ),
          child: const Text(
            'Uložit změny',
            style: TextStyle(
              fontSize: AppTypography.fontSizeXl,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
        ),
      ),
    );
  }
}
