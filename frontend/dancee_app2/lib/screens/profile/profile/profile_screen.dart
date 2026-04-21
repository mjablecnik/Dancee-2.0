import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/user_repository.dart';
import '../../../i18n/strings.g.dart';
import '../../../shared/components/back_button_header.dart';
import '../../../shared/elements/labels/section_label.dart';
import 'components/premium_banner.dart';
import 'sections/account_section.dart';
import 'sections/app_info_section.dart';
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
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: appBg,
      child: Column(
        children: [
          BackButtonHeader(
            title: t.profile.title,
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
            child: FutureBuilder<UserData>(
              future: const UserRepository().getCurrentUser(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    top: AppSpacing.xxl,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileCardSection(
                        name: user?.name ?? '',
                        email: user?.email ?? '',
                        avatarUrl: user?.avatarUrl ?? '',
                        danceTags: user?.danceTags
                                .map((tag) => (label: tag.label, color: tag.color))
                                .toList() ??
                            const [],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SectionLabel(title: t.profile.sections.account),
                      const SizedBox(height: AppSpacing.md),
                      AccountSection(
                        onEditProfile: () => context.push('/profile/edit'),
                        onChangePassword: () => context.push('/profile/change-password'),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SectionLabel(title: t.profile.sections.settings),
                      const SizedBox(height: AppSpacing.md),
                      const SettingsSection(),
                      const SizedBox(height: AppSpacing.xxl),
                      PremiumBanner(onTap: () => context.push('/profile/premium')),
                      const SizedBox(height: AppSpacing.xxl),
                      SectionLabel(title: t.profile.sections.support),
                      const SizedBox(height: AppSpacing.md),
                      SupportSection(
                        onContactAuthor: () => context.push('/profile/author-contact'),
                        onRateApp: null,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SectionLabel(title: t.profile.sections.appInfo),
                      const SizedBox(height: AppSpacing.md),
                      const AppInfoSection(),
                      const SizedBox(height: AppSpacing.xxl),
                      SectionLabel(title: t.profile.sections.dangerZone),
                      const SizedBox(height: AppSpacing.md),
                      LogoutSection(
                        onLogout: () {},
                        onDeleteAccount: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
