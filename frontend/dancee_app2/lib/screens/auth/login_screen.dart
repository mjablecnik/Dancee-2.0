import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import '../../shared/components/background_circles.dart';
import '../../shared/sections/auth_header_section.dart';
import 'login/sections/login_form_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
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
          BackgroundCircles(animation: _floatAnim),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xxxl,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSpacing.xxxl),
                  AuthHeaderSection(
                    title: 'Vítej zpět!',
                    subtitle: 'Přihlaš se a pokračuj v objevování tanečních akcí',
                  ),
                  SizedBox(height: 48),
                  LoginFormSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
