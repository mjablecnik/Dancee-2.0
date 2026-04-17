import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';
import '../../../../shared/elements/forms/app_checkbox.dart';
import '../../../../shared/elements/forms/app_input_field.dart';
import '../../../../shared/elements/forms/app_password_field.dart';
import '../components/password_strength_indicator.dart';

class RegisterFormSection extends StatefulWidget {
  const RegisterFormSection({super.key});

  @override
  State<RegisterFormSection> createState() => _RegisterFormSectionState();
}

class _RegisterFormSectionState extends State<RegisterFormSection> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeTerms = false;
  bool _newsletter = false;
  int _passwordStrength = 0;
  bool _passwordsMatch = true;
  bool _confirmTouched = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final p = _passwordController.text;
    int strength = 0;
    if (p.length >= 8) strength++;
    if (p.contains(RegExp(r'[a-z]')) && p.contains(RegExp(r'[A-Z]'))) strength++;
    if (p.contains(RegExp(r'\d'))) strength++;
    if (p.contains(RegExp(r'[^a-zA-Z\d]'))) strength++;
    setState(() {
      _passwordStrength = strength;
      if (_confirmTouched) {
        _passwordsMatch =
            _passwordController.text == _confirmPasswordController.text;
      }
    });
  }

  void _onConfirmChanged() {
    setState(() {
      _confirmTouched = true;
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInputField(
          label: 'Jméno',
          hintText: 'Tvoje jméno',
          icon: const FaIcon(FontAwesomeIcons.user, color: appMuted, size: 16),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppInputField(
          label: 'Příjmení',
          hintText: 'Tvoje příjmení',
          icon: const FaIcon(FontAwesomeIcons.user, color: appMuted, size: 16),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppInputField(
          label: 'E-mail',
          hintText: 'tvuj@email.cz',
          keyboardType: TextInputType.emailAddress,
          icon: const FaIcon(FontAwesomeIcons.envelope, color: appMuted, size: 16),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppPasswordField(
          label: 'Heslo',
          controller: _passwordController,
        ),
        const SizedBox(height: AppSpacing.sm),
        PasswordStrengthIndicator(
          strength: _passwordStrength,
          isEmpty: _passwordController.text.isEmpty,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppPasswordField(
          label: 'Potvrzení hesla',
          controller: _confirmPasswordController,
        ),
        if (_confirmTouched) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _passwordsMatch ? 'Hesla se shodují' : 'Hesla se neshodují',
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              color: _passwordsMatch ? appSuccess : appError,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        GestureDetector(
          onTap: () => setState(() => _agreeTerms = !_agreeTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCheckbox(
                checked: _agreeTerms,
                onChanged: (val) => setState(() => _agreeTerms = val),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: appMuted,
                      fontSize: AppTypography.fontSizeMd,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: 'Souhlasím s '),
                      TextSpan(
                        text: 'Podmínkami používání',
                        style: TextStyle(color: appPrimary),
                      ),
                      TextSpan(text: ' a '),
                      TextSpan(
                        text: 'Zásadami ochrany osobních údajů',
                        style: TextStyle(color: appPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => setState(() => _newsletter = !_newsletter),
          child: Row(
            children: [
              AppCheckbox(
                checked: _newsletter,
                onChanged: (val) => setState(() => _newsletter = val),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text(
                  'Chci dostávat novinky o tanečních akcích',
                  style: TextStyle(
                    color: appMuted,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        GradientButton(
          label: 'Vytvořit účet',
          onTap: () => context.go('/onboarding'),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        const Row(
          children: [
            Expanded(child: Divider(color: appBorder)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'nebo se zaregistruj s',
                style: TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
            ),
            Expanded(child: Divider(color: appBorder)),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        _SocialButton(
          icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20),
          label: 'Pokračovat s Google',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        _SocialButton(
          icon: const FaIcon(FontAwesomeIcons.apple, color: appText, size: 20),
          label: 'Pokračovat s Apple',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Už máš účet?',
              style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Přihlaš se',
                style: TextStyle(
                  color: appPrimary,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ),
          ],
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
