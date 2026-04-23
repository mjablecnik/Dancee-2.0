import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/auth_cubit.dart';
import '../../../logic/states/auth_state.dart';
import '../../../shared/components/background_circles.dart';
import '../../../shared/elements/buttons/gradient_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;

  bool _notVerifiedYet = false;

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
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr != prev,
      listener: (context, state) {
        state.maybeMap(
          authenticated: (s) {
            if (s.emailVerified) {
              if (s.isNewUser) {
                context.go('/onboarding');
              } else {
                context.go('/events');
              }
            } else {
              setState(() => _notVerifiedYet = true);
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeMap(loading: (_) => true, orElse: () => false);
        final email = state.maybeMap(
          authenticated: (s) => s.email ?? '',
          orElse: () => '',
        );

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xxxl),
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildEmailCard(email),
                      if (_notVerifiedYet) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _buildNotVerifiedMessage(),
                      ],
                      if (state.maybeMap(error: (_) => true, orElse: () => false)) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _buildErrorMessage(state),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      GradientButton(
                        label: t.auth.emailVerification.checkVerified,
                        onTap: () => context.read<AuthCubit>().reloadUser(),
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildResendButton(context, isLoading),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSignOutButton(context, isLoading),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(AppRadius.round),
            boxShadow: [AppShadows.primaryLg],
          ),
          child: const Center(
            child: Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          t.auth.emailVerification.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize4xl,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailCard(String email) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: appBorder),
      ),
      child: Text(
        t.auth.emailVerification.subtitle(email: email),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: appMuted,
          fontSize: AppTypography.fontSizeMd,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildNotVerifiedMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appError.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: appError, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              t.auth.emailVerification.notVerifiedYet,
              style: const TextStyle(
                color: appError,
                fontSize: AppTypography.fontSizeMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(AuthState state) {
    final message = state.maybeMap(
      error: (s) => s.message,
      orElse: () => '',
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appError.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: appError, fontSize: AppTypography.fontSizeMd),
      ),
    );
  }

  Widget _buildResendButton(BuildContext context, bool isLoading) {
    return OutlinedButton(
      onPressed: isLoading ? null : () => context.read<AuthCubit>().sendEmailVerification(),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: appBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        minimumSize: const Size.fromHeight(56),
      ),
      child: Text(
        t.auth.emailVerification.resend,
        style: const TextStyle(
          color: appText,
          fontSize: AppTypography.fontSizeXl,
          fontWeight: AppTypography.fontWeightSemiBold,
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, bool isLoading) {
    return TextButton(
      onPressed: isLoading ? null : () => context.read<AuthCubit>().signOut(),
      child: Text(
        t.auth.emailVerification.signOut,
        style: const TextStyle(
          color: appMuted,
          fontSize: AppTypography.fontSizeMd,
        ),
      ),
    );
  }
}
