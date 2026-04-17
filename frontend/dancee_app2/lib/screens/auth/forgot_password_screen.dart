import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: appSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: appBorder),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            color: appText,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 48),
                        _buildForm(context),
                      ],
                    ),
                  ),
                ),
              ],
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
                color: appPrimary.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.key,
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
        const SizedBox(height: 24),
        const Text(
          'Zapomenuté heslo?',
          style: TextStyle(
            color: appText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Zadej svůj e-mail a pošleme ti odkaz pro obnovení hesla',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appMuted,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'E-mail',
          style: TextStyle(
            color: appText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const FaIcon(FontAwesomeIcons.envelope, color: appMuted, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: appText),
                  decoration: const InputDecoration(
                    hintText: 'tvuj@email.cz',
                    hintStyle: TextStyle(color: appMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [appPrimary, appAccent],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: appPrimary.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: const Center(
                child: Text(
                  'Odeslat odkaz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.circleInfo, color: appPrimary, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zkontroluj svou e-mailovou schránku',
                      style: TextStyle(
                        color: appText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Po odeslání obdržíš e-mail s odkazem pro obnovení hesla. Odkaz je platný 24 hodin.',
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
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Vzpomněl sis na heslo?',
              style: TextStyle(color: appMuted, fontSize: 14),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Přihlásit se',
                style: TextStyle(
                  color: appPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            const Expanded(child: Divider(color: appBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Potřebuješ pomoc?',
                style: const TextStyle(color: appMuted, fontSize: 14),
              ),
            ),
            const Expanded(child: Divider(color: appBorder)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.headset, color: appPrimary, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Podpora',
                          style: TextStyle(
                            color: appText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.circleQuestion, color: appAccent, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'FAQ',
                          style: TextStyle(
                            color: appText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
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
