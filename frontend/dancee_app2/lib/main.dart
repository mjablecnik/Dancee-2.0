import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'i18n/strings.g.dart';
import 'shared/elements/navigation/app_bottom_nav_bar.dart';
import 'shared/elements/navigation/main_shell.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/auth/register/register_screen.dart';
import 'screens/auth/forgot_password/forgot_password_screen.dart';
import 'screens/auth/onboarding/onboarding_screen.dart';
import 'screens/events/events_list/events_list_screen.dart';
import 'screens/events/event_detail/event_detail_screen.dart';
import 'screens/events/filter_dance/filter_dance_screen.dart';
import 'screens/events/filter_location/filter_location_screen.dart';
import 'screens/courses/courses_list/courses_list_screen.dart';
import 'screens/courses/course_detail/course_detail_screen.dart';
import 'screens/profile/profile/profile_screen.dart';
import 'screens/profile/profile_edit/profile_edit_screen.dart';
import 'screens/profile/change_password/change_password_screen.dart';
import 'screens/profile/premium/premium_screen.dart';
import 'screens/profile/author_contact/author_contact_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initLocale();
  runApp(TranslationProvider(child: const DanceeApp()));
}

Future<void> _initLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale');
  if (localeCode != null) {
    final locale = AppLocale.values.firstWhere(
      (l) => l.languageCode == localeCode,
      orElse: () => AppLocale.en,
    );
    LocaleSettings.setLocale(locale);
  } else {
    LocaleSettings.setLocale(AppLocale.en);
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth flow
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Main app — top-level pages wrapped in shell with bottom nav
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.path;
        final NavTab currentTab;
        if (location.startsWith('/courses')) {
          currentTab = NavTab.courses;
        } else if (location.startsWith('/profile')) {
          currentTab = NavTab.profile;
        } else {
          currentTab = NavTab.events;
        }
        return MainShell(currentTab: currentTab, child: child);
      },
      routes: [
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsListScreen(),
        ),
        GoRoute(
          path: '/courses',
          builder: (context, state) => const CoursesListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // Sub-pages — no bottom nav bar
    GoRoute(
      path: '/events/detail',
      builder: (context, state) => const EventDetailScreen(),
    ),
    GoRoute(
      path: '/events/filter-dance',
      builder: (context, state) => const FilterDanceScreen(),
    ),
    GoRoute(
      path: '/events/filter-location',
      builder: (context, state) => const FilterLocationScreen(),
    ),
    GoRoute(
      path: '/courses/detail',
      builder: (context, state) => const CourseDetailScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/profile/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/profile/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/profile/author-contact',
      builder: (context, state) => const AuthorContactScreen(),
    ),
  ],
);

class DanceeApp extends StatelessWidget {
  const DanceeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: t.common.appName,
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocale.values.map((l) => l.flutterLocale).toList(),
    );
  }
}
