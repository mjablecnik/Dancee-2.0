import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/profile_menu_item.dart';

class SettingsSection extends StatefulWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;

  const SettingsSection({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
  });

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  Future<void> _showLanguageDialog() async {
    final current = LocaleSettings.currentLocale;
    await showDialog<AppLocale>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: appSurface,
        title: Text(
          t.profile.settings.language,
          style: const TextStyle(color: appText),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, AppLocale.en),
            child: Row(
              children: [
                if (current == AppLocale.en)
                  const Icon(Icons.check, color: appPrimary, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text('English', style: TextStyle(color: current == AppLocale.en ? appPrimary : appText)),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, AppLocale.cs),
            child: Row(
              children: [
                if (current == AppLocale.cs)
                  const Icon(Icons.check, color: appPrimary, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text('Čeština', style: TextStyle(color: current == AppLocale.cs ? appPrimary : appText)),
              ],
            ),
          ),
        ],
      ),
    ).then((selected) async {
      if (selected != null && selected != LocaleSettings.currentLocale) {
        LocaleSettings.setLocale(selected);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('locale', selected.languageCode);
        if (mounted) setState(() {});
      }
    });
  }

  String _currentLanguageName() {
    return LocaleSettings.currentLocale == AppLocale.cs
        ? t.profile.settings.czech
        : t.profile.settings.english;
  }

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
            title: t.profile.settings.language,
            trailing: Text(
              _currentLanguageName(),
              style: const TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeMd,
              ),
            ),
            onTap: _showLanguageDialog,
            showDivider: true,
          ),
          ProfileMenuItem(
            icon: FontAwesomeIcons.bell,
            iconBgColor: appAccent.withValues(alpha: 0.2),
            iconColor: appAccent,
            title: t.profile.settings.notifications,
            trailing: Switch(
              value: widget.notificationsEnabled,
              onChanged: widget.onNotificationsChanged,
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
