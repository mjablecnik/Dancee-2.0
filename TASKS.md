# TASKS.md — Dancee App v2 Internationalization & Data Layer Tasks

All tasks derived from DATA_SPEC.md. Ordered so dependencies are created first.

---

## Phase 1 — Setup i18n Infrastructure

- [x] 1. [HIGH] Install `slang_flutter` and `slang_build_runner` dependencies in pubspec.yaml, add `shared_preferences` for locale persistence
- [x] 2. [HIGH] Create translation file structure: `lib/i18n/strings.i18n.json` (English base) and `lib/i18n/strings_cs.i18n.json` (Czech) with all ~200 translation keys organized by section (common, nav, auth, onboarding, events, courses, profile, premium, contact)
- [x] 3. [HIGH] Set up i18n provider in `lib/main.dart` — wrap `MaterialApp.router` with `TranslationProvider`, initialize locale from `shared_preferences`, run `build_runner` to generate `strings.g.dart`

---

## Phase 2 — Create Repository/Data Layer

- [x] 4. [HIGH] Create `lib/data/event_repository.dart` — provides `getFeaturedEvents()`, `getUpcomingEvents()`, `getEventDetail(id)`, `getDanceStyles()`, `getDanceStyleFilters()`, `getExperienceLevels()` with mocked data extracted from events_list, event_detail, filter_dance, and onboarding screens
- [x] 5. [HIGH] Create `lib/data/course_repository.dart` — provides `getFeaturedCourses()`, `getAllCourses()`, `getCourseDetail(id)` with mocked data extracted from courses_list and course_detail screens
- [x] 6. [HIGH] Create `lib/data/city_repository.dart` — provides `getPopularCities()`, `getAllCities()` with mocked data extracted from filter_location screens
- [x] 7. [HIGH] Create `lib/data/user_repository.dart` — provides `getCurrentUser()`, `getAppVersion()`, `getDeviceInfo()` with mocked data extracted from profile screens
- [x] 8. [HIGH] Create `lib/data/premium_repository.dart` — provides `getPlans()`, `getFeatures()`, `getTestimonials()`, `getFaqs()` with mocked data extracted from premium screens

---

## Phase 3 — Extract Static UI Strings to i18n

- [x] 9. [MEDIUM] Extract hardcoded strings from `lib/main.dart` to translation keys — 1 string (`common.appName`)
- [x] 10. [MEDIUM] Extract hardcoded strings from `lib/shared/sections/auth_header_section.dart` to translation keys — 2 strings (appName, tagline)
- [x] 11. [MEDIUM] Extract hardcoded strings from `lib/shared/sections/dance_styles_filter_section.dart` to translation keys — 3 strings (danceStyles, showAll, label)
- [x] 12. [MEDIUM] Extract hardcoded strings from `lib/shared/elements/forms/app_password_field.dart` to translation keys — 1 string (password placeholder)
- [x] 13. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/login/login_screen.dart` to translation keys — 2 strings (title, subtitle)
- [x] 14. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/login/sections/login_form_section.dart` to translation keys — 15 strings (form labels, buttons, social login, terms)
- [x] 15. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/register/register_screen.dart` to translation keys — 2 strings (title, subtitle)
- [x] 16. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/register/sections/register_form_section.dart` to translation keys — 16 strings (form labels, validation, social login, terms)
- [x] 17. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/register/components/password_strength_indicator.dart` to translation keys — 5 strings (strength labels, hint)
- [x] 18. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/forgot_password/forgot_password_screen.dart` to translation keys — 2 strings (title, subtitle)
- [x] 19. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/forgot_password/sections/forgot_password_form_section.dart` to translation keys — 9 strings (form, info box, help buttons)
- [x] 20. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/onboarding/sections/onboarding_header_section.dart` to translation keys — 1 string (skip)
- [x] 21. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/onboarding/sections/onboarding_step1_section.dart` to translation keys — 3 strings (title, subtitle, continue)
- [x] 22. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/onboarding/sections/onboarding_step2_section.dart` to translation keys — 4 strings (title, subtitle, back, continue)
- [x] 23. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/onboarding/sections/onboarding_step3_section.dart` to translation keys — 8 strings (title, subtitle, radii, city, location, back, finish)
- [x] 24. [MEDIUM] Extract hardcoded strings from `lib/screens/auth/onboarding/components/radius_selector.dart` to translation keys — 1 string (search radius label)
- [x] 25. [MEDIUM] Extract hardcoded strings from `lib/screens/events/events_list/events_list_screen.dart` to translation keys — 4 nav labels
- [x] 26. [MEDIUM] Extract hardcoded strings from `lib/screens/events/events_list/sections/events_header_section.dart` to translation keys — 5 strings (location label, quick filters)
- [x] 27. [MEDIUM] Extract hardcoded strings from `lib/screens/events/events_list/sections/featured_events_section.dart` to translation keys — 1 string (section title)
- [x] 28. [MEDIUM] Extract hardcoded strings from `lib/screens/events/events_list/sections/upcoming_events_section.dart` to translation keys — 2 strings (section title, date sort)
- [x] 29. [MEDIUM] Extract hardcoded strings from `lib/screens/events/event_detail/event_detail_screen.dart` to translation keys — 5 strings (header, nav labels)
- [x] 30. [MEDIUM] Extract hardcoded strings from `lib/screens/events/event_detail/sections/action_buttons_section.dart` to translation keys — 3 strings (save, share, map)
- [x] 31. [MEDIUM] Extract hardcoded strings from `lib/screens/events/event_detail/sections/additional_info_section.dart` to translation keys — 5 strings (title, labels, buttons)
- [x] 32. [MEDIUM] Extract hardcoded strings from `lib/screens/events/event_detail/sections/event_program_section.dart` to translation keys — 1 string (section title)
- [x] 33. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_dance/filter_dance_screen.dart` to translation keys — 1 string (selected count pattern)
- [x] 34. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_dance/sections/filter_dance_header_section.dart` to translation keys — 2 strings (title, clear)
- [x] 35. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_dance/sections/selected_styles_section.dart` to translation keys — 1 string (label)
- [x] 36. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_dance/sections/filter_bottom_actions_section.dart` to translation keys — 1 string (apply filter)
- [x] 37. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_location/filter_location_screen.dart` to translation keys — 4 nav labels
- [x] 38. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_location/sections/filter_location_header_section.dart` to translation keys — 2 strings (title, search hint)
- [x] 39. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_location/sections/current_location_section.dart` to translation keys — 2 strings (title, subtitle)
- [x] 40. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_location/sections/popular_cities_section.dart` to translation keys — 1 string (section title) + `'Aktuální'` badge
- [x] 41. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_location/sections/all_cities_section.dart` to translation keys — 1 string (section title)
- [x] 42. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/courses_list/courses_list_screen.dart` to translation keys — 4 nav labels
- [x] 43. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/courses_list/sections/courses_header_section.dart` to translation keys — 2 strings (title, subtitle)
- [x] 44. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/courses_list/sections/featured_courses_section.dart` to translation keys — 2 strings (title, show all)
- [x] 45. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/courses_list/sections/all_courses_section.dart` to translation keys — 2 strings (title, date sort)
- [x] 46. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/course_detail/course_detail_screen.dart` to translation keys — 5 strings (header, description title, nav labels)
- [x] 47. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/course_detail/sections/course_schedule_section.dart` to translation keys — 2 strings (details title, what you learn)
- [x] 48. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/course_detail/sections/course_instructor_section.dart` to translation keys — 1 string (about instructor)
- [x] 49. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/course_detail/sections/course_pricing_section.dart` to translation keys — 2 strings (share course, original source)
- [x] 50. [MEDIUM] Extract hardcoded strings from `lib/screens/courses/course_detail/components/pricing_option_card.dart` to translation keys — 3 strings (course price, available spots, register)
- [x] 51. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile/profile_screen.dart` to translation keys — 9 strings (title, section labels, nav labels)
- [x] 52. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile/sections/account_section.dart` to translation keys — 2 strings (edit profile, change password)
- [x] 53. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile/sections/settings_section.dart` to translation keys — 3 strings (language, czech, notifications)
- [x] 54. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile/sections/support_section.dart` to translation keys — 2 strings (contact author, rate app)
- [x] 55. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile/sections/app_info_section.dart` to translation keys — 3 strings (version, terms, privacy)
- [x] 56. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile/sections/logout_section.dart` to translation keys — 2 strings (logout, delete account)
- [x] 57. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile/components/premium_banner.dart` to translation keys — 2 strings (title, subtitle)
- [x] 58. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/change_password/change_password_screen.dart` to translation keys — 1 string (title)
- [x] 59. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/change_password/sections/security_banner_section.dart` to translation keys — 2 strings (title, detail)
- [x] 60. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/change_password/sections/password_form_section.dart` to translation keys — 16 strings (labels, hints, buttons, requirements)
- [x] 61. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/change_password/components/password_strength_bar.dart` to translation keys — 4 strings (strength labels)
- [x] 62. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/author_contact/author_contact_screen.dart` to translation keys — 1 string (title)
- [x] 63. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/author_contact/sections/author_info_section.dart` to translation keys — 3 strings (team name, email, description)
- [x] 64. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/author_contact/sections/contact_form_section.dart` to translation keys — 15 strings (form labels, hints, buttons, info)
- [x] 65. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/author_contact/components/device_info_card.dart` to translation keys — 2 strings (device info, auto attached)
- [x] 66. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/premium/sections/premium_header_section.dart` to translation keys — 1 string (title)
- [x] 67. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/premium/sections/premium_hero_section.dart` to translation keys — 2 strings (title, subtitle)
- [x] 68. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/premium/sections/features_section.dart` to translation keys — 1 string (section title)
- [x] 69. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/premium/sections/testimonials_section.dart` to translation keys — 1 string (section title)
- [x] 70. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/premium/sections/faq_section.dart` to translation keys — 1 string (section title)
- [x] 71. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/premium/sections/final_cta_section.dart` to translation keys — 4 strings (title, subtitle, button, note)
- [x] 72. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile_edit/profile_edit_screen.dart` to translation keys — 10 strings (title, section labels, notification keys/subtitles)
- [x] 73. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile_edit/sections/profile_photo_section.dart` to translation keys — 1 string (change photo)
- [x] 74. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile_edit/sections/personal_info_section.dart` to translation keys — 4 strings (field labels)
- [x] 75. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile_edit/sections/bio_section.dart` to translation keys — 2 strings (label, hint)
- [x] 76. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile_edit/sections/dance_preferences_section.dart` to translation keys — 1 string (instruction text)
- [x] 77. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile_edit/sections/experience_level_section.dart` to translation keys — 1 string (your level label)
- [x] 78. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile_edit/sections/social_links_section.dart` to translation keys — 4 strings (labels, hints)
- [x] 79. [MEDIUM] Extract hardcoded strings from `lib/screens/profile/profile_edit/sections/save_button_section.dart` to translation keys — 1 string (save changes)
- [x] 80. [MEDIUM] Extract hardcoded strings from `lib/screens/events/filter_location/components/popular_city_card.dart` to translation keys — 1 string ('Aktuální' badge)

---

## Phase 4 — Replace API Data with Repository Calls

- [x] 81. [MEDIUM] Replace hardcoded event data in `featured_events_section.dart` with `EventRepository.getFeaturedEvents()` calls
- [x] 82. [MEDIUM] Replace hardcoded event data in `upcoming_events_section.dart` with `EventRepository.getUpcomingEvents()` calls
- [x] 83. [MEDIUM] Replace hardcoded event detail data in `event_detail_screen.dart` with `EventRepository.getEventDetail(id)` calls
- [x] 84. [MEDIUM] Replace hardcoded dance style data in `onboarding_step1_section.dart` with `EventRepository.getDanceStyles()` calls
- [x] 85. [MEDIUM] Replace hardcoded experience level data in `onboarding_step2_section.dart` with `EventRepository.getExperienceLevels()` calls
- [x] 86. [MEDIUM] Replace hardcoded dance style filter data in `events_list_screen.dart` and `courses_list_screen.dart` with `EventRepository.getDanceStyleFilters()` calls
- [x] 87. [MEDIUM] Replace hardcoded dance style list data in `dance_styles_list_section.dart` with `EventRepository.getDanceStyles()` calls
- [x] 88. [MEDIUM] Replace hardcoded course data in `featured_courses_section.dart` with `CourseRepository.getFeaturedCourses()` calls
- [x] 89. [MEDIUM] Replace hardcoded course data in `all_courses_section.dart` with `CourseRepository.getAllCourses()` calls
- [x] 90. [MEDIUM] Replace hardcoded course detail data in `course_detail_screen.dart` with `CourseRepository.getCourseDetail(id)` calls
- [x] 91. [MEDIUM] Replace hardcoded city data in `popular_cities_section.dart` with `CityRepository.getPopularCities()` calls
- [x] 92. [MEDIUM] Replace hardcoded city data in `all_cities_section.dart` with `CityRepository.getAllCities()` calls
- [x] 93. [MEDIUM] Replace hardcoded user data in `profile_screen.dart` with `UserRepository.getCurrentUser()` calls
- [x] 94. [MEDIUM] Replace hardcoded user data in `profile_edit_screen.dart` with `UserRepository.getCurrentUser()` calls
- [x] 95. [MEDIUM] Replace hardcoded premium data in `features_section.dart` with `PremiumRepository.getFeatures()` calls
- [x] 96. [MEDIUM] Replace hardcoded premium data in `plans_section.dart` with `PremiumRepository.getPlans()` calls
- [x] 97. [MEDIUM] Replace hardcoded premium data in `testimonials_section.dart` with `PremiumRepository.getTestimonials()` calls
- [x] 98. [MEDIUM] Replace hardcoded premium data in `faq_section.dart` with `PremiumRepository.getFaqs()` calls
- [x] 99. [MEDIUM] Replace hardcoded device info in `contact_form_section.dart` with `UserRepository.getDeviceInfo()` calls
- [x] 100. [MEDIUM] Replace hardcoded app version in `app_info_section.dart` with `UserRepository.getAppVersion()` calls

---

## Phase 5 — Language Switching

- [x] 101. [MEDIUM] Update `settings_section.dart` to show a language switcher (en/cs toggle) using `LocaleSettings.setLocale()` from slang, persist choice with `shared_preferences`
- [x] 102. [MEDIUM] Update the `'Čeština'` trailing text in settings to dynamically show the current language name

---

## Final

- [x] 103. [LOW] Verify all strings are translated — run `slang-analyze` equivalent check, grep for remaining hardcoded Czech text in all `.dart` files
- [x] 104. [LOW] Verify language switching works — toggle between en/cs, confirm all screens update, confirm persistence across app restart
- [x] 105. [LOW] Verify no visual or functional regressions — all screens render identically in Czech, English translations are complete and natural
