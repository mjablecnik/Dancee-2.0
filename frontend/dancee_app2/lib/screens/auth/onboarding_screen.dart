import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

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
  int _selectedRadius = 1; // 0=10km, 1=25km, 2=50km, 3=Celá republika

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

  void _goToStep(int step) {
    setState(() => _currentStep = step);
  }

  void _finish() {
    context.go('/events');
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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  child: _buildHeader(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.music,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            TextButton(
              onPressed: _finish,
              child: const Text(
                'Přeskočit',
                style: TextStyle(
                  color: appMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: List.generate(3, (index) {
            final isActive = index < _currentStep;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [appPrimary, appAccent],
                        )
                      : null,
                  color: isActive ? null : appBorder,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    final dances = [
      (FontAwesomeIcons.fire, 'Salsa'),
      (FontAwesomeIcons.heart, 'Bachata'),
      (FontAwesomeIcons.water, 'Zouk'),
      (FontAwesomeIcons.moon, 'Kizomba'),
      (FontAwesomeIcons.spa, 'Tango'),
      (FontAwesomeIcons.music, 'Swing'),
      (FontAwesomeIcons.bolt, 'Hip Hop'),
      (FontAwesomeIcons.star, 'Jiné'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jaké tance tě baví?',
            style: TextStyle(
              color: appText,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce',
            style: TextStyle(color: appMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: dances.length,
              itemBuilder: (context, index) {
                final (icon, name) = dances[index];
                final selected = _selectedDances[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDances[index] = !_selectedDances[index];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? appPrimary.withValues(alpha: 0.1)
                          : appSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? appPrimary : appBorder,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          icon,
                          size: 24,
                          color: selected ? appPrimary : appMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: TextStyle(
                            color: selected ? appPrimary : appText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _GradientButton(
            label: 'Pokračovat',
            onTap: () => _goToStep(2),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final levels = [
      (FontAwesomeIcons.seedling, appSuccess, 'Začátečník',
          'Teprve začínám s tancem'),
      (FontAwesomeIcons.chartLine, appPrimary, 'Mírně pokročilý',
          'Mám základní zkušenosti'),
      (FontAwesomeIcons.fire, appAccent, 'Pokročilý',
          'Tančím pravidelně několik let'),
      (FontAwesomeIcons.crown, const Color(0xFFEAB308), 'Expert',
          'Profesionální úroveň'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jaká je tvoje úroveň?',
            style: TextStyle(
              color: appText,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pomůže nám to doporučit ti vhodné akce a kurzy',
            style: TextStyle(color: appMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final (icon, iconColor, title, subtitle) = levels[index];
                final selected = _selectedLevel == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLevel = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: selected
                          ? appPrimary.withValues(alpha: 0.1)
                          : appSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? appPrimary : appBorder,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: appCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: FaIcon(icon,
                                size: 20, color: iconColor),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: appText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                    color: appMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? appPrimary : appBorder,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: appPrimary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: 'Zpět',
                  onTap: () => _goToStep(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _GradientButton(
                  label: 'Pokračovat',
                  onTap: () => _goToStep(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final radii = ['10 km', '25 km', '50 km', 'Celá republika'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Kde se nacházíš?',
            style: TextStyle(
              color: appText,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Najdeme pro tebe nejbližší taneční akce ve tvém okolí',
            style: TextStyle(color: appMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: appBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Město',
                          style: TextStyle(
                            color: appMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: appCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: appBorder),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const FaIcon(
                                FontAwesomeIcons.locationDot,
                                color: appPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style:
                                      const TextStyle(color: appText),
                                  decoration: const InputDecoration(
                                    hintText: 'Např. Praha, Brno...',
                                    hintStyle:
                                        TextStyle(color: appMuted),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: appBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vyhledat akce v okruhu',
                          style: TextStyle(
                            color: appMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(radii.length, (index) {
                          final selected = _selectedRadius == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedRadius = index),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: index < radii.length - 1
                                      ? 12
                                      : 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selected
                                            ? appPrimary
                                            : appBorder,
                                        width: 2,
                                      ),
                                    ),
                                    child: selected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration:
                                                  const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: appPrimary,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    radii[index],
                                    style: const TextStyle(
                                      color: appText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: appPrimary.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationCrosshairs,
                            color: appPrimary,
                            size: 18,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Použít aktuální polohu',
                            style: TextStyle(
                              color: appPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: 'Zpět',
                  onTap: () => _goToStep(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _GradientButton(
                  label: 'Dokončit',
                  onTap: _finish,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
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
        gradient: const LinearGradient(
          colors: [appPrimary, appAccent],
        ),
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: appText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
