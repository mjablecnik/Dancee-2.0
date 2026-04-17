import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';
import '../../../../shared/elements/forms/app_input_field.dart';

class ForgotPasswordFormSection extends StatelessWidget {
  const ForgotPasswordFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInputField(
          label: t.common.form.email,
          hintText: t.common.form.emailHint,
          keyboardType: TextInputType.emailAddress,
          icon: const FaIcon(FontAwesomeIcons.envelope, color: appMuted, size: 16),
        ),
        const SizedBox(height: AppSpacing.xxl),
        GradientButton(
          label: t.auth.forgotPassword.submit,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.xxl),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: appBorder),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: appPrimary,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.auth.forgotPassword.checkInbox,
                      style: const TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      t.auth.forgotPassword.checkInboxDetail,
                      style: const TextStyle(
                        color: appMuted,
                        fontSize: AppTypography.fontSizeSm,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.auth.forgotPassword.rememberPassword,
              style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                t.auth.forgotPassword.login,
                style: const TextStyle(
                  color: appPrimary,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Row(
          children: [
            const Expanded(child: Divider(color: appBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                t.auth.forgotPassword.needHelp,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
              ),
            ),
            const Expanded(child: Divider(color: appBorder)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _HelpButton(
                icon: const FaIcon(FontAwesomeIcons.headset, color: appPrimary, size: 16),
                label: t.common.support,
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _HelpButton(
                icon: const FaIcon(FontAwesomeIcons.circleQuestion, color: appAccent, size: 16),
                label: t.common.faq,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _HelpButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _HelpButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
