import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
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

  Color _strengthColor(int index) {
    if (_passwordStrength == 0 || index >= _passwordStrength) return appBorder;
    switch (_passwordStrength) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return const Color(0xFF22C55E);
      default:
        return appBorder;
    }
  }

  String _strengthLabel() {
    switch (_passwordStrength) {
      case 1:
        return 'Síla hesla: Velmi slabé';
      case 2:
        return 'Síla hesla: Slabé';
      case 3:
        return 'Síla hesla: Střední';
      case 4:
        return 'Síla hesla: Silné';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSecurityBanner(),
                  const SizedBox(height: 24),
                  _buildPasswordForm(),
                  _buildPasswordRequirements(),
                  const SizedBox(height: 24),
                  _buildForgotPasswordLink(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: appBg.withValues(alpha: 0.9),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: appText),
              ),
            ),
          ),
          const Text(
            'Změnit heslo',
            style: TextStyle(
              color: appText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x1AF97316), Color(0x0DF97316)],
        ),
        border: Border.all(color: const Color(0x4DF97316)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x33F97316),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.shieldHalved, size: 18, color: Color(0xFFF97316)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zabezpečte svůj účet',
                  style: TextStyle(
                    color: appText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Silné heslo musí obsahovat alespoň 8 znaků, velká a malá písmena, čísla a speciální znaky.',
                  style: TextStyle(
                    color: appMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      children: [
        _buildPasswordField(
          label: 'Současné heslo',
          placeholder: 'Zadejte současné heslo',
          controller: _currentPasswordController,
          visible: _currentPasswordVisible,
          onToggle: () => setState(() => _currentPasswordVisible = !_currentPasswordVisible),
        ),
        const SizedBox(height: 20),
        _buildNewPasswordField(),
        const SizedBox(height: 20),
        _buildConfirmPasswordField(),
        const SizedBox(height: 28),
        _buildActionButtons(),
        const SizedBox(height: 8),
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !visible,
                  style: const TextStyle(color: appText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(color: Color(0x99475569)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(color: appText, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Zadejte nové heslo',
                    hintStyle: TextStyle(color: Color(0x99475569)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FaIcon(
                    _newPasswordVisible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
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
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: _strengthColor(i),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )),
          ),
          const SizedBox(height: 6),
          Text(
            _strengthLabel(),
            style: const TextStyle(color: appMuted, fontSize: 12),
          ),
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  onChanged: _checkMatch,
                  style: const TextStyle(color: appText, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Zadejte nové heslo znovu',
                    hintStyle: TextStyle(color: Color(0x99475569)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FaIcon(
                    _confirmPasswordVisible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
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
            style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: appPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: appPrimary.withValues(alpha: 0.4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.check, size: 14, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Uložit nové heslo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: appText,
              side: const BorderSide(color: appBorder),
              backgroundColor: appSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Zrušit',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        _buildRequirementRow('Minimálně 8 znaků'),
        const SizedBox(height: 10),
        _buildRequirementRow('Alespoň jedno velké písmeno (A-Z)'),
        const SizedBox(height: 10),
        _buildRequirementRow('Alespoň jedno malé písmeno (a-z)'),
        const SizedBox(height: 10),
        _buildRequirementRow('Alespoň jedno číslo (0-9)'),
        const SizedBox(height: 10),
        _buildRequirementRow('Alespoň jeden speciální znak (!@#\$%^&*)'),
      ],
    );
  }

  Widget _buildRequirementRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FaIcon(FontAwesomeIcons.circleCheck, size: 14, color: appMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: appMuted, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
