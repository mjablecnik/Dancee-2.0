import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../shared/components/back_button_header.dart';
import '../../../shared/elements/labels/section_label.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';
import 'sections/bio_section.dart';
import 'sections/dance_preferences_section.dart';
import 'sections/experience_level_section.dart';
import 'sections/notifications_section.dart';
import 'sections/personal_info_section.dart';
import 'sections/profile_photo_section.dart';
import 'sections/save_button_section.dart';
import 'sections/social_links_section.dart';

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

  late Map<String, bool> _notifications;
  late Map<String, String> _notificationSubtitles;

  @override
  void initState() {
    super.initState();
    _notifications = {
      t.profile.editProfile.notifications.newEvents: true,
      t.profile.editProfile.notifications.eventReminders: true,
      t.profile.editProfile.notifications.marketing: false,
    };
    _notificationSubtitles = {
      t.profile.editProfile.notifications.newEvents: t.profile.editProfile.notificationSubtitles.newEvents,
      t.profile.editProfile.notifications.eventReminders: t.profile.editProfile.notificationSubtitles.eventReminders,
      t.profile.editProfile.notifications.marketing: t.profile.editProfile.notificationSubtitles.marketing,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          BackButtonHeader(
            title: t.profile.editProfile.title,
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
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: t.profile.editProfile.sections.personalInfo),
                  ),
                  const PersonalInfoSection(
                    initialName: 'Tereza Nováková',
                    initialEmail: 'tereza.novakova@email.cz',
                    initialPhone: '+420 123 456 789',
                    initialCity: 'Praha',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: t.profile.editProfile.sections.aboutMe),
                  ),
                  BioSection(
                    initialBio: 'Miluji tanec a poznávání nových lidí. Tancuji už 5 let a stále se učím nové styly.',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: t.profile.editProfile.sections.favoriteDances),
                  ),
                  DancePreferencesSection(
                    preferences: _dancePrefs,
                    onChanged: (prefs) => setState(() => _dancePrefs
                      ..clear()
                      ..addAll(prefs)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: t.profile.editProfile.sections.level),
                  ),
                  ExperienceLevelSection(
                    levels: const ['Začátečník', 'Mírně pokročilý', 'Pokročilý', 'Expert'],
                    selectedLevel: _level,
                    onChanged: (level) => setState(() => _level = level),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: t.profile.editProfile.sections.socialNetworks),
                  ),
                  const SocialLinksSection(),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.md),
                    child: SectionLabel(title: t.profile.editProfile.sections.notifications),
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
      bottomSheet: SaveButtonSection(onSave: () => context.pop()),
      bottomNavigationBar: AppBottomNavBar(
        leftItems: [
          AppNavBarItem(icon: FontAwesomeIcons.house, label: t.nav.home, onTap: () => context.go('/events')),
          AppNavBarItem(icon: FontAwesomeIcons.magnifyingGlass, label: t.nav.search, onTap: () => context.go('/events')),
        ],
        rightItems: [
          AppNavBarItem(icon: FontAwesomeIcons.heart, label: t.nav.saved, onTap: () => context.go('/events')),
          AppNavBarItem(icon: FontAwesomeIcons.user, label: t.nav.profile, isActive: true, onTap: () => context.go('/profile')),
        ],
      ),
    );
  }
}
