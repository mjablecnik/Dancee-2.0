import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';
import '../../../../shared/elements/forms/app_checkbox.dart';
import '../../../../shared/elements/forms/app_input_field.dart';
import '../../../../shared/elements/forms/app_password_field.dart';

class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  bool _stayLoggedIn = false;

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
        const SizedBox(height: AppSpacing.lg),
        AppPasswordField(label: t.common.form.password),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            AppCheckbox(
              checked: _stayLoggedIn,
              onChanged: (val) => setState(() => _stayLoggedIn = val),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              t.auth.login.stayLoggedIn,
              style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                t.auth.login.forgotPassword,
                style: const TextStyle(
                  color: appPrimary,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        GradientButton(
          label: t.auth.login.submit,
          onTap: () => context.go('/events'),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Row(
          children: [
            const Expanded(child: Divider(color: appBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                t.auth.orContinueWith,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
              ),
            ),
            const Expanded(child: Divider(color: appBorder)),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        _SocialButton(
          icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20),
          label: t.auth.continueWithGoogle,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        _SocialButton(
          icon: const FaIcon(FontAwesomeIcons.apple, color: appText, size: 20),
          label: t.auth.continueWithApple,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.auth.login.noAccount,
              style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: () => context.go('/register'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                t.auth.login.register,
                style: const TextStyle(
                  color: appPrimary,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(color: appBorder),
        const SizedBox(height: AppSpacing.lg),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              height: 1.5,
            ),
            children: [
              TextSpan(text: t.auth.termsPrefix),
              TextSpan(
                text: t.auth.termsOfUse,
                style: const TextStyle(color: appPrimary),
              ),
              TextSpan(text: t.auth.and),
              TextSpan(
                text: t.auth.privacyPolicy,
                style: const TextStyle(color: appPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: appBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeLg,
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
