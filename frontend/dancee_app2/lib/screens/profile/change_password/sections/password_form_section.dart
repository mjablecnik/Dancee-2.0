import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/password_strength_bar.dart';
import '../components/password_requirement_row.dart';

class PasswordFormSection extends StatefulWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const PasswordFormSection({
    super.key,
    this.onSave,
    this.onCancel,
  });

  @override
  State<PasswordFormSection> createState() => _PasswordFormSectionState();
}

class _PasswordFormSectionState extends State<PasswordFormSection> {
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _passwordStrength = 0;
  bool _passwordMismatch = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _evaluateStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'\d'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;
    setState(() {
      _passwordStrength = password.isEmpty ? 0 : strength;
    });
  }

  void _checkMatch(String confirm) {
    setState(() {
      _passwordMismatch =
          confirm.isNotEmpty && confirm != _newPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPasswordField(
          label: 'Současné heslo',
          placeholder: 'Zadejte současné heslo',
          controller: _currentPasswordController,
          visible: _currentPasswordVisible,
          onToggle: () =>
              setState(() => _currentPasswordVisible = !_currentPasswordVisible),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildNewPasswordField(),
        const SizedBox(height: AppSpacing.xl),
        _buildConfirmPasswordField(),
        const SizedBox(height: 28),
        _buildActionButtons(context),
        const SizedBox(height: AppSpacing.sm),
        _buildPasswordRequirements(),
        const SizedBox(height: AppSpacing.xxl),
        _buildForgotPasswordLink(context),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !visible,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(color: appMuted.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: FaIcon(
                    visible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                    size: 16,
                    color: appMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nové heslo',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: !_newPasswordVisible,
                  onChanged: (val) {
                    _evaluateStrength(val);
                    if (_confirmPasswordController.text.isNotEmpty) {
                      _checkMatch(_confirmPasswordController.text);
                    }
                  },
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Zadejte nové heslo',
                    hintStyle: TextStyle(color: appMuted.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _newPasswordVisible = !_newPasswordVisible),
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: FaIcon(
                    _newPasswordVisible
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 16,
                    color: appMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_passwordStrength > 0) ...[
          const SizedBox(height: 10),
          PasswordStrengthBar(strength: _passwordStrength),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Potvrdit nové heslo',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  onChanged: _checkMatch,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Zadejte nové heslo znovu',
                    hintStyle: TextStyle(color: appMuted.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(
                    () => _confirmPasswordVisible = !_confirmPasswordVisible),
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: FaIcon(
                    _confirmPasswordVisible
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 16,
                    color: appMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_passwordMismatch) ...[
          const SizedBox(height: 6),
          const Text(
            'Hesla se neshodují',
            style: TextStyle(
              color: appError,
              fontSize: AppTypography.fontSizeSm,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onSave ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: appPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              elevation: 4,
              shadowColor: appPrimary.withValues(alpha: 0.4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.check, size: 14, color: Colors.white),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Uložit nové heslo',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: AppTypography.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onCancel ?? () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: appText,
              side: const BorderSide(color: appBorder),
              backgroundColor: appSurface,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
            child: const Text(
              'Zrušit',
              style: TextStyle(
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: appBorder, height: 48),
        const Text(
          'POŽADAVKY NA HESLO',
          style: TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeSm,
            fontWeight: AppTypography.fontWeightSemiBold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const PasswordRequirementRow(text: 'Minimálně 8 znaků'),
        const SizedBox(height: 10),
        const PasswordRequirementRow(text: 'Alespoň jedno velké písmeno (A-Z)'),
        const SizedBox(height: 10),
        const PasswordRequirementRow(text: 'Alespoň jedno malé písmeno (a-z)'),
        const SizedBox(height: 10),
        const PasswordRequirementRow(text: 'Alespoň jedno číslo (0-9)'),
        const SizedBox(height: 10),
        const PasswordRequirementRow(
            text: r'Alespoň jeden speciální znak (!@#$%^&*)'),
      ],
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.push('/forgot-password'),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.circleQuestion, size: 14, color: appPrimary),
            SizedBox(width: 6),
            Text(
              'Zapomněli jste heslo?',
              style: TextStyle(
                color: appPrimary,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
