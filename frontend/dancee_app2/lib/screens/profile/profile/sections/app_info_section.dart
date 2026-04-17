import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/profile_menu_item.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

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
