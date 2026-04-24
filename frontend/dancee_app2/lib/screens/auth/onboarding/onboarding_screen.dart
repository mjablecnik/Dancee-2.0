import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/colors.dart';
import '../../../core/service_locator.dart';
import '../../../core/clients.dart';
import '../../../core/theme.dart';
import '../../../logic/cubits/auth_cubit.dart';
import '../../../shared/components/background_circles.dart';
import 'sections/onboarding_header_section.dart';
import 'sections/onboarding_step1_section.dart';
import 'sections/onboarding_step2_section.dart';
import 'sections/onboarding_step3_section.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;

  int _currentStep = 1;
  final List<bool> _selectedDances = List.filled(8, false);
  int _selectedLevel = -1;
  int _selectedRadius = 1;

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

  void _goToStep(int step) => setState(() => _currentStep = step);

  Future<void> _finish() async {
    await _savePreferences();
    if (mounted) context.go('/events');
  }

  Future<void> _savePreferences() async {
    // Collect selected dance style indices
    final selectedIndices = <int>[];
    for (int i = 0; i < _selectedDances.length; i++) {
      if (_selectedDances[i]) selectedIndices.add(i);
    }
    final danceStylesValue = selectedIndices.join(',');

    // Primary: persist to CMS so preferences survive across devices.
    // Falls back gracefully to local storage if the CMS call fails (e.g. the
    // user_preferences collection is not yet provisioned in Directus).
    try {
      final uid = context.read<AuthCubit>().currentUid;
      if (uid != null) {
        await sl<DirectusClient>().post(
          '/items/user_preferences',
          data: {
            'user_id': uid,
            'dance_style_indices': danceStylesValue,
            'level': _selectedLevel,
            'radius': _selectedRadius,
          },
        );
      }
    } catch (_) {
      // CMS unavailable — SharedPreferences below acts as fallback.
    }

    // Always write to SharedPreferences for fast local reads.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_dance_styles', danceStylesValue);
    await prefs.setInt('onboarding_level', _selectedLevel);
    await prefs.setInt('onboarding_radius', _selectedRadius);
    await prefs.setBool('onboarding_completed', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Stack(
        children: [
          BackgroundCircles(animation: _floatAnim),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.xl,
                  ),
                  child: OnboardingHeaderSection(
                    currentStep: _currentStep,
                    onSkip: _finish,
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_currentStep),
                      child: _buildCurrentStep(),
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

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return OnboardingStep1Section(
          selectedDances: _selectedDances,
          onDanceTap: (i) => setState(() => _selectedDances[i] = !_selectedDances[i]),
          onNext: () => _goToStep(2),
        );
      case 2:
        return OnboardingStep2Section(
          selectedLevel: _selectedLevel,
          onLevelSelected: (i) => setState(() => _selectedLevel = i),
          onBack: () => _goToStep(1),
          onNext: () => _goToStep(3),
        );
      case 3:
        return OnboardingStep3Section(
          selectedRadius: _selectedRadius,
          onRadiusSelected: (i) => setState(() => _selectedRadius = i),
          onBack: () => _goToStep(2),
          onFinish: _finish,
        );
      default:
        return OnboardingStep1Section(
          selectedDances: _selectedDances,
          onDanceTap: (i) => setState(() => _selectedDances[i] = !_selectedDances[i]),
          onNext: () => _goToStep(2),
        );
    }
  }
}
