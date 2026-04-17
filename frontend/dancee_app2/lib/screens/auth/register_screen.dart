import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeTerms = false;
  bool _newsletter = false;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _passwordStrength = 0;
  bool _passwordsMatch = true;
  bool _confirmTouched = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmChanged);
  }

  @override
  void dispose() {
    _animController.dispose();
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
        _passwordsMatch = _passwordController.text == _confirmPasswordController.text;
      }
    });
  }

  void _onConfirmChanged() {
    setState(() {
      _confirmTouched = true;
      _passwordsMatch = _passwordController.text == _confirmPasswordController.text;
    });
  }

  Color _strengthColor() {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return appError;
      case 2:
        return appAmber;
      default:
        return appSuccess;
    }
  }

  String _strengthLabel() {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return 'Slabé heslo';
      case 2:
        return 'Středně silné';
      case 3:
        return 'Silné heslo';
      default:
        return 'Velmi silné';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Stack(
        children: [
          _BackgroundCircles(animation: _floatAnim),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              AppShadows.primaryLg,
            ],
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.music,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
          child: const Text(
            'Dancee',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppTypography.fontSize5xl,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Objevuj taneční svět',
          style: TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Vytvoř si účet',
          style: TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize3xl,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Zaregistruj se a začni objevovat taneční akce',
          textAlign: TextAlign.center,
          style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('Jméno'),
        const SizedBox(height: 8),
        _buildInputField(
          icon: const FaIcon(FontAwesomeIcons.user, color: appMuted, size: 16),
          hintText: 'Tvoje jméno',
        ),
        const SizedBox(height: 16),
        _buildLabel('Příjmení'),
        const SizedBox(height: 8),
        _buildInputField(
          icon: const FaIcon(FontAwesomeIcons.user, color: appMuted, size: 16),
          hintText: 'Tvoje příjmení',
        ),
        const SizedBox(height: 16),
        _buildLabel('E-mail'),
        const SizedBox(height: 8),
        _buildInputField(
          icon: const FaIcon(FontAwesomeIcons.envelope, color: appMuted, size: 16),
          hintText: 'tvuj@email.cz',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildLabel('Heslo'),
        const SizedBox(height: 8),
        _buildPasswordInput(),
        const SizedBox(height: 8),
        _buildStrengthIndicator(),
        const SizedBox(height: 16),
        _buildLabel('Potvrzení hesla'),
        const SizedBox(height: 8),
        _buildConfirmPasswordInput(),
        if (_confirmTouched) ...[
          const SizedBox(height: 4),
          Text(
            _passwordsMatch ? 'Hesla se shodují' : 'Hesla se neshodují',
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              color: _passwordsMatch ? appSuccess : appError,
            ),
          ),
        ],
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() => _agreeTerms = !_agreeTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(_agreeTerms),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd, height: 1.5),
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
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _newsletter = !_newsletter),
          child: Row(
            children: [
              _buildCheckbox(_newsletter),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Chci dostávat novinky o tanečních akcích',
                  style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _GradientButton(
          label: 'Vytvořit účet',
          onTap: () => context.go('/onboarding'),
        ),
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: Divider(color: appBorder)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'nebo se zaregistruj s',
                style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
              ),
            ),
            Expanded(child: Divider(color: appBorder)),
          ],
        ),
        const SizedBox(height: 24),
        _buildSocialButton(
          icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20),
          label: 'Pokračovat s Google',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          icon: const FaIcon(FontAwesomeIcons.apple, color: appText, size: 20),
          label: 'Pokračovat s Apple',
          onTap: () {},
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Už máš účet?',
              style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            const SizedBox(width: 4),
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
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: appText,
        fontSize: AppTypography.fontSizeMd,
        fontWeight: AppTypography.fontWeightSemiBold,
      ),
    );
  }

  Widget _buildCheckbox(bool checked) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
          color: checked ? appPrimary : appBorder,
          width: 2,
        ),
        color: checked ? appPrimary : appSurface,
      ),
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }

  Widget _buildInputField({
    required Widget icon,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(color: appText),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: appMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixIcon != null) ...[
            suffixIcon,
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const FaIcon(FontAwesomeIcons.lock, color: appMuted, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              style: const TextStyle(color: appText),
              decoration: const InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(color: appMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showPassword = !_showPassword),
            child: FaIcon(
              _showPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
              color: appMuted,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const FaIcon(FontAwesomeIcons.lock, color: appMuted, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              style: const TextStyle(color: appText),
              decoration: const InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(color: appMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            child: FaIcon(
              _showConfirmPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
              color: appMuted,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    final color = _passwordController.text.isEmpty ? appBorder : _strengthColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            final filled = index < _passwordStrength;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled ? color : appBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _passwordController.text.isEmpty ? 'Alespoň 8 znaků' : _strengthLabel(),
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            color: _passwordController.text.isEmpty ? appMuted : color,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
              const SizedBox(width: 12),
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

class _BackgroundCircles extends StatelessWidget {
  final Animation<double> animation;

  const _BackgroundCircles({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 80 + animation.value,
              left: 40,
              child: _buildCircle(128, appPrimary.withValues(alpha: 0.2)),
            ),
            Positioned(
              top: 240 - animation.value,
              right: 32,
              child: _buildCircle(96, appAccent.withValues(alpha: 0.2)),
            ),
            Positioned(
              bottom: 160 + animation.value * 0.5,
              left: 24,
              child: _buildCircle(80, appSuccess.withValues(alpha: 0.2)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 1.5,
            spreadRadius: size * 0.5,
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          AppShadows.primaryLg,
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSizeXl,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
