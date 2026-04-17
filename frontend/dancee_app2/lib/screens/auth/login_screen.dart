import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;

  bool _showPassword = false;
  bool _stayLoggedIn = false;

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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 48),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [appPrimary, appAccent],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: appPrimary.withValues(alpha:0.5),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.music,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [appPrimary, appAccent],
          ).createShader(bounds),
          child: const Text(
            'Dancee',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Objevuj taneční svět',
          style: TextStyle(
            color: appMuted,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Vítej zpět!',
          style: TextStyle(
            color: appText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Přihlaš se a pokračuj v objevování tanečních akcí',
          textAlign: TextAlign.center,
          style: TextStyle(color: appMuted),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('E-mail'),
        const SizedBox(height: 8),
        _buildInputField(
          icon: const FaIcon(
            FontAwesomeIcons.envelope,
            color: appMuted,
            size: 16,
          ),
          hintText: 'tvuj@email.cz',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildLabel('Heslo'),
        const SizedBox(height: 8),
        _buildPasswordField(),
        const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _stayLoggedIn = !_stayLoggedIn),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _stayLoggedIn ? appPrimary : appBorder,
                        width: 2,
                      ),
                      color: _stayLoggedIn ? appPrimary : appSurface,
                    ),
                    child: _stayLoggedIn
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Zůstat přihlášen',
                    style: TextStyle(color: appMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Zapomenuté heslo?',
                style: TextStyle(
                  color: appPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _GradientButton(
          label: 'Přihlásit se',
          onTap: () => context.go('/events'),
        ),
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: Divider(color: appBorder)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'nebo pokračuj s',
                style: TextStyle(color: appMuted, fontSize: 14),
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
              'Nemáš ještě účet?',
              style: TextStyle(color: appMuted, fontSize: 14),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: () => context.go('/register'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Zaregistruj se',
                style: TextStyle(
                  color: appPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: appBorder),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(color: appMuted, fontSize: 12, height: 1.5),
            children: [
              TextSpan(text: 'Pokračováním souhlasíš s našimi '),
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
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: appText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInputField({
    required Widget icon,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
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

  Widget _buildPasswordField() {
    return _buildInputField(
      icon: const FaIcon(FontAwesomeIcons.lock, color: appMuted, size: 16),
      hintText: '••••••••',
      obscureText: !_showPassword,
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _showPassword = !_showPassword),
        child: FaIcon(
          _showPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
          color: appMuted,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
              child: _buildCircle(128, appPrimary.withValues(alpha:0.2)),
            ),
            Positioned(
              top: 240 - animation.value,
              right: 32,
              child: _buildCircle(96, appAccent.withValues(alpha:0.2)),
            ),
            Positioned(
              bottom: 160 + animation.value * 0.5,
              left: 24,
              child: _buildCircle(80, appSuccess.withValues(alpha:0.2)),
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
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [appPrimary, appAccent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appPrimary.withValues(alpha:0.5),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
