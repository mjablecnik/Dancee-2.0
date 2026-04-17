import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/profile_menu_item.dart';

class AccountSection extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;

  const AccountSection({
    super.key,
    required this.onEditProfile,
    required this.onChangePassword,
  });

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
            icon: FontAwesomeIcons.user,
            iconBgColor: appPrimary.withValues(alpha: 0.2),
            iconColor: appPrimary,
            title: 'Upravit profil',
            onTap: onEditProfile,
            showDivider: true,
          ),
          ProfileMenuItem(
            icon: FontAwesomeIcons.lock,
            iconBgColor: appWarning.withValues(alpha: 0.2),
            iconColor: appWarning,
            title: 'Změnit heslo',
            onTap: onChangePassword,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
