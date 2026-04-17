import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/colors.dart';
import '../../../../../core/theme.dart';

class AuthorInfoSection extends StatelessWidget {
  const AuthorInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(FontAwesomeIcons.user, color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tým Dancee',
                    style: TextStyle(
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: FontWeight.bold,
                      color: appText,
                    ),
                  ),
                  Text(
                    'hello@dancee.app',
                    style: TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Rádi si přečteme vaše zpětné vazby, návrhy na vylepšení nebo nahlášení problémů. Odpovíme vám co nejdříve!',
            style: TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
          ),
        ],
      ),
    );
  }
}
