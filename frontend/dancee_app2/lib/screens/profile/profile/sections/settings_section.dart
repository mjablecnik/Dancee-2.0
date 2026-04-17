import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/profile_menu_item.dart';

class SettingsSection extends StatelessWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;

  const SettingsSection({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
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
            icon: FontAwesomeIcons.globe,
            iconBgColor: appSuccess.withValues(alpha: 0.2),
            iconColor: appSuccess,
            title: 'Jazyk',
            trailing: const Text(
              'Čeština',
              style: TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeMd,
              ),
            ),
            onTap: null,
            showDivider: true,
          ),
          ProfileMenuItem(
            icon: FontAwesomeIcons.bell,
            iconBgColor: appAccent.withValues(alpha: 0.2),
            iconColor: appAccent,
            title: 'Oznámení',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
              activeColor: Colors.white,
              activeTrackColor: appPrimary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: appBorder,
            ),
            onTap: null,
            showDivider: false,
            verticalPadding: AppSpacing.sm,
          ),
        ],
      ),
    );
  }
}
