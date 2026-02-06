import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/event_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'di/service_locator.dart';
import 'l10n/app_localizations.dart';

void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dancee App',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('cs'),
        Locale('es'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final ValueNotifier<int> _reloadTrigger = ValueNotifier<int>(0);

  @override
  void dispose() {
    _reloadTrigger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const EventListScreen(),
          FavoritesScreen(reloadTrigger: _reloadTrigger),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.calendar_today, (ctx) => AppLocalizations.of(ctx)!.events, 0),
              _buildNavItem(Icons.favorite, (ctx) => AppLocalizations.of(ctx)!.favorites, 1),
              _buildNavItem(Icons.settings, (ctx) => AppLocalizations.of(ctx)!.settings, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String Function(BuildContext) labelBuilder, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index < 2) { // Only Events and Favorites are implemented
          setState(() {
            _currentIndex = index;
          });
          // Reload favorites when switching to favorites tab
          if (index == 1) {
            _reloadTrigger.value++;
          }
        }
      },
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              labelBuilder(context),
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
