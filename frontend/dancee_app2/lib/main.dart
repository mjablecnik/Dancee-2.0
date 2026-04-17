import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'i18n/strings.g.dart';
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
    // Auth flow — root-level, back button does nothing
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
    // Main app — root pages with sub-routes that push on top
    GoRoute(
      path: '/events',
      builder: (context, state) => const EventsListScreen(),
      routes: [
        GoRoute(
          path: 'detail',
          builder: (context, state) => const EventDetailScreen(),
        ),
        GoRoute(
          path: 'filter-dance',
          builder: (context, state) => const FilterDanceScreen(),
        ),
        GoRoute(
          path: 'filter-location',
          builder: (context, state) => const FilterLocationScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/courses',
      builder: (context, state) => const CoursesListScreen(),
      routes: [
        GoRoute(
          path: 'detail',
          builder: (context, state) => const CourseDetailScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => const ProfileEditScreen(),
        ),
        GoRoute(
          path: 'change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: 'premium',
          builder: (context, state) => const PremiumScreen(),
        ),
        GoRoute(
          path: 'author-contact',
          builder: (context, state) => const AuthorContactScreen(),
        ),
      ],
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
