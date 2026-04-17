# DATA_SPEC.md — Dancee App v2 Internationalization & Data Layer Specification

## 1. Overview

**Framework**: Flutter (Dart)
**Current state**: All user-facing text is hardcoded in Czech across ~95 source files (excluding core/theme/color files)
**Total hardcoded strings**: ~450+ user-facing strings
**Languages to support**: English (en, default), Czech (cs)

The app has zero i18n infrastructure. Every label, button, heading, placeholder, error message, navigation item, and mock data string is hardcoded directly in Dart widget files.

## 2. Chosen i18n Library

**Library**: `slang_flutter` (already used in the main `dancee_app` project)

### Why slang
- Type-safe translations via code generation
- JSON-based translation files
- Global `t` accessor (no context needed)
- Supports parameterized strings
- Already the standard in the parent project

### Setup
```yaml
# pubspec.yaml additions
dependencies:
  slang_flutter: ^3.31.0

dev_dependencies:
  slang_build_runner: ^3.31.0
  build_runner: ^2.4.0
```

### Translation File Structure
```
lib/i18n/
├── strings.i18n.json        # English (base)
├── strings_cs.i18n.json     # Czech
└── strings.g.dart           # Generated (by build_runner)
```

### Key Naming Convention
Pattern: `section.subsection.element`

Examples:
- `nav.home` → "Home" / "Domů"
- `auth.login.title` → "Welcome back!" / "Vítej zpět!"
- `events.detail.buyTickets` → "Buy tickets" / "Koupit vstupenky"
- `profile.settings.language` → "Language" / "Jazyk"

Rules:
- camelCase for all segments
- Feature prefix matches screen area (auth, events, courses, profile, premium)
- Shared UI uses `common.*` or `nav.*`
- Form labels use `*.form.fieldName`
- Buttons use `*.buttonName`

## 3. Repository Layer Design

Repositories provide mocked data that currently lives inline in widget files. Each returns typed data objects.

### Repositories to Create

| Repository | Location | Data Provided |
|---|---|---|
| `EventRepository` | `lib/data/event_repository.dart` | Featured events, upcoming events, event detail, dance styles |
| `CourseRepository` | `lib/data/course_repository.dart` | Featured courses, all courses, course detail |
| `CityRepository` | `lib/data/city_repository.dart` | Popular cities, all cities |
| `UserRepository` | `lib/data/user_repository.dart` | User profile, testimonials |
| `PremiumRepository` | `lib/data/premium_repository.dart` | Plans, features, FAQs |

Each repository is a simple class with methods returning `Future<List<T>>` or `Future<T>`, making it trivial to swap mocks for real API calls later.

## 4. Language Switching Mechanism

- Add a `LanguageSwitcher` widget to the Settings section of the Profile screen
- Use `LocaleSettings.setLocale(AppLocale.cs)` / `LocaleSettings.setLocale(AppLocale.en)`
- Persist choice via `shared_preferences`
- Wrap `MaterialApp.router` with `TranslationProvider` from slang

## 5. File-by-File String Inventory

### Legend
- **[UI]** = Static UI string → extract to i18n translation key
- **[API]** = Mock/dynamic data → extract to repository

---

### lib/main.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Dancee'` (app title) | [UI] | `common.appName` |

### lib/shared/sections/auth_header_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Dancee'` | [UI] | `common.appName` |
| `'Objevuj taneční svět'` | [UI] | `auth.tagline` |

### lib/shared/sections/dance_styles_filter_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Taneční styly'` | [UI] | `events.danceStyles` |
| `'Zobrazit vše'` | [UI] | `common.showAll` |
| `'TANEČNÍ STYLY'` | [UI] | `events.danceStylesLabel` |

### lib/shared/sections/description_section.dart
No hardcoded strings (title/paragraphs are parameters).

### lib/shared/sections/auth_footer_section.dart
No hardcoded strings (text/linkText are parameters).

### lib/shared/sections/hero_image_section.dart
No hardcoded strings (price/label are parameters).

### lib/shared/sections/detail_header_section.dart
No hardcoded strings (title is parameter).

### lib/shared/sections/key_info_section.dart
No hardcoded strings (items are parameters).

### lib/shared/components/back_button_header.dart
No hardcoded strings (title is parameter).

### lib/shared/elements/navigation/app_bottom_nav_bar.dart
No hardcoded strings (labels are parameters).

### lib/shared/elements/forms/app_password_field.dart
| String | Type | Key / Repository |
|---|---|---|
| `'••••••••'` (default hint) | [UI] | `common.form.passwordPlaceholder` |

### lib/shared/elements/forms/app_input_field.dart
No hardcoded strings (all parameterized).

### lib/shared/elements/labels/section_label.dart
No hardcoded strings (title is parameter).

### lib/shared/elements/labels/style_chip.dart
No hardcoded strings (label is parameter).

### lib/shared/elements/labels/price_badge.dart
No hardcoded strings (price is parameter).

### lib/shared/elements/buttons/outline_button.dart
No hardcoded strings (label is parameter).

### lib/shared/elements/buttons/gradient_button.dart
No hardcoded strings (label is parameter).

### lib/shared/elements/buttons/text_link_button.dart
No hardcoded strings (text/linkText are parameters).

### lib/shared/elements/forms/app_checkbox.dart
No hardcoded strings.

### lib/shared/elements/forms/app_radio_button.dart
No hardcoded strings.

### lib/shared/components/background_circles.dart
No hardcoded strings.

---

### lib/screens/auth/login/login_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Vítej zpět!'` | [UI] | `auth.login.title` |
| `'Přihlaš se a pokračuj v objevování tanečních akcí'` | [UI] | `auth.login.subtitle` |

### lib/screens/auth/login/sections/login_form_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'E-mail'` | [UI] | `common.form.email` |
| `'tvuj@email.cz'` | [UI] | `common.form.emailHint` |
| `'Heslo'` | [UI] | `common.form.password` |
| `'Zůstat přihlášen'` | [UI] | `auth.login.stayLoggedIn` |
| `'Zapomenuté heslo?'` | [UI] | `auth.login.forgotPassword` |
| `'Přihlásit se'` | [UI] | `auth.login.submit` |
| `'nebo pokračuj s'` | [UI] | `auth.orContinueWith` |
| `'Pokračovat s Google'` | [UI] | `auth.continueWithGoogle` |
| `'Pokračovat s Apple'` | [UI] | `auth.continueWithApple` |
| `'Nemáš ještě účet?'` | [UI] | `auth.login.noAccount` |
| `'Zaregistruj se'` | [UI] | `auth.login.register` |
| `'Pokračováním souhlasíš s našimi '` | [UI] | `auth.termsPrefix` |
| `'Podmínkami používání'` | [UI] | `auth.termsOfUse` |
| `' a '` | [UI] | `auth.and` |
| `'Zásadami ochrany osobních údajů'` | [UI] | `auth.privacyPolicy` |

### lib/screens/auth/register/register_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Vytvoř si účet'` | [UI] | `auth.register.title` |
| `'Zaregistruj se a začni objevovat taneční akce'` | [UI] | `auth.register.subtitle` |

### lib/screens/auth/register/sections/register_form_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Jméno'` | [UI] | `common.form.firstName` |
| `'Tvoje jméno'` | [UI] | `common.form.firstNameHint` |
| `'Příjmení'` | [UI] | `common.form.lastName` |
| `'Tvoje příjmení'` | [UI] | `common.form.lastNameHint` |
| `'E-mail'` | [UI] | `common.form.email` |
| `'tvuj@email.cz'` | [UI] | `common.form.emailHint` |
| `'Heslo'` | [UI] | `common.form.password` |
| `'Potvrzení hesla'` | [UI] | `common.form.confirmPassword` |
| `'Hesla se shodují'` | [UI] | `auth.register.passwordsMatch` |
| `'Hesla se neshodují'` | [UI] | `auth.register.passwordsMismatch` |
| `'Souhlasím s '` | [UI] | `auth.agreeWith` |
| `'Podmínkami používání'` | [UI] | `auth.termsOfUse` |
| `' a '` | [UI] | `auth.and` |
| `'Zásadami ochrany osobních údajů'` | [UI] | `auth.privacyPolicy` |
| `'Chci dostávat novinky o tanečních akcích'` | [UI] | `auth.register.newsletter` |
| `'Vytvořit účet'` | [UI] | `auth.register.submit` |
| `'nebo se zaregistruj s'` | [UI] | `auth.orRegisterWith` |
| `'Pokračovat s Google'` | [UI] | `auth.continueWithGoogle` |
| `'Pokračovat s Apple'` | [UI] | `auth.continueWithApple` |
| `'Už máš účet?'` | [UI] | `auth.register.hasAccount` |
| `'Přihlaš se'` | [UI] | `auth.register.login` |

### lib/screens/auth/register/components/password_strength_indicator.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Slabé heslo'` | [UI] | `auth.passwordStrength.weak` |
| `'Středně silné'` | [UI] | `auth.passwordStrength.medium` |
| `'Silné heslo'` | [UI] | `auth.passwordStrength.strong` |
| `'Velmi silné'` | [UI] | `auth.passwordStrength.veryStrong` |
| `'Alespoň 8 znaků'` | [UI] | `auth.passwordStrength.hint` |

### lib/screens/auth/forgot_password/forgot_password_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Zapomenuté heslo?'` | [UI] | `auth.forgotPassword.title` |
| `'Zadej svůj e-mail a pošleme ti odkaz pro obnovení hesla'` | [UI] | `auth.forgotPassword.subtitle` |

### lib/screens/auth/forgot_password/sections/forgot_password_form_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'E-mail'` | [UI] | `common.form.email` |
| `'tvuj@email.cz'` | [UI] | `common.form.emailHint` |
| `'Odeslat odkaz'` | [UI] | `auth.forgotPassword.submit` |
| `'Zkontroluj svou e-mailovou schránku'` | [UI] | `auth.forgotPassword.checkInbox` |
| `'Po odeslání obdržíš e-mail s odkazem pro obnovení hesla. Odkaz je platný 24 hodin.'` | [UI] | `auth.forgotPassword.checkInboxDetail` |
| `'Vzpomněl sis na heslo?'` | [UI] | `auth.forgotPassword.rememberPassword` |
| `'Přihlásit se'` | [UI] | `auth.forgotPassword.login` |
| `'Potřebuješ pomoc?'` | [UI] | `auth.forgotPassword.needHelp` |
| `'Podpora'` | [UI] | `common.support` |
| `'FAQ'` | [UI] | `common.faq` |

### lib/screens/auth/onboarding/sections/onboarding_header_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Přeskočit'` | [UI] | `common.skip` |

### lib/screens/auth/onboarding/sections/onboarding_step1_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Jaké tance tě baví?'` | [UI] | `onboarding.step1.title` |
| `'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce'` | [UI] | `onboarding.step1.subtitle` |
| `'Salsa'`, `'Bachata'`, `'Zouk'`, `'Kizomba'`, `'Tango'`, `'Swing'`, `'Hip Hop'`, `'Jiné'` | [API] | `EventRepository.getDanceStyles()` |
| `'Pokračovat'` | [UI] | `common.continue_` |

### lib/screens/auth/onboarding/sections/onboarding_step2_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Jaká je tvoje úroveň?'` | [UI] | `onboarding.step2.title` |
| `'Pomůže nám to doporučit ti vhodné akce a kurzy'` | [UI] | `onboarding.step2.subtitle` |
| `'Začátečník'` / `'Teprve začínám s tancem'` | [API] | `EventRepository.getExperienceLevels()` |
| `'Mírně pokročilý'` / `'Mám základní zkušenosti'` | [API] | `EventRepository.getExperienceLevels()` |
| `'Pokročilý'` / `'Tančím pravidelně několik let'` | [API] | `EventRepository.getExperienceLevels()` |
| `'Expert'` / `'Profesionální úroveň'` | [API] | `EventRepository.getExperienceLevels()` |
| `'Zpět'` | [UI] | `common.back` |
| `'Pokračovat'` | [UI] | `common.continue_` |

### lib/screens/auth/onboarding/sections/onboarding_step3_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Kde se nacházíš?'` | [UI] | `onboarding.step3.title` |
| `'Najdeme pro tebe nejbližší taneční akce ve tvém okolí'` | [UI] | `onboarding.step3.subtitle` |
| `'10 km'`, `'25 km'`, `'50 km'`, `'Celá republika'` | [UI] | `onboarding.step3.radius10km`, etc. |
| `'Město'` | [UI] | `common.form.city` |
| `'Např. Praha, Brno...'` | [UI] | `onboarding.step3.cityHint` |
| `'Vyhledat akce v okruhu'` | [UI] | `onboarding.step3.searchRadius` |
| `'Použít aktuální polohu'` | [UI] | `onboarding.step3.useCurrentLocation` |
| `'Zpět'` | [UI] | `common.back` |
| `'Dokončit'` | [UI] | `common.finish` |

### lib/screens/auth/onboarding/components/radius_selector.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Vyhledat akce v okruhu'` | [UI] | `onboarding.step3.searchRadius` |

---

### lib/screens/events/events_list/events_list_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Vše'`, `'Salsa'`, `'Bachata'`, `'Kizomba'`, `'Zouk'` | [API] | `EventRepository.getDanceStyleFilters()` |
| `'Praha, CZ'` | [API] | User's selected location |
| Nav labels: `'Domů'`, `'Hledat'`, `'Uložené'`, `'Profil'` | [UI] | `nav.home`, `nav.search`, `nav.saved`, `nav.profile` |

### lib/screens/events/events_list/sections/events_header_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Lokalita'` | [UI] | `events.location` |
| `'Dnes'` | [UI] | `events.filters.today` |
| `'Tento týden'` | [UI] | `events.filters.thisWeek` |
| `'Tento měsíc'` | [UI] | `events.filters.thisMonth` |
| `'Tento víkend'` | [UI] | `events.filters.thisWeekend` |

### lib/screens/events/events_list/sections/featured_events_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Doporučené akce'` | [UI] | `events.featuredEvents` |
| All event data (imageUrl, title, date, location, price, tags) | [API] | `EventRepository.getFeaturedEvents()` |

### lib/screens/events/events_list/sections/upcoming_events_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Nadcházející akce'` | [UI] | `events.upcomingEvents` |
| `'Datum'` | [UI] | `common.date` |
| All event data (imageUrl, title, location, date, style) | [API] | `EventRepository.getUpcomingEvents()` |

### lib/screens/events/event_detail/event_detail_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Detail akce'` | [UI] | `events.detail.header` |
| Nav labels: `'Domů'`, `'Hledat'`, `'Uložené'`, `'Profil'` | [UI] | `nav.*` |
| All event detail data (title, chips, key info, description, program, prices) | [API] | `EventRepository.getEventDetail(id)` |
| `'Popis akce'` | [UI] | `events.detail.description` |

### lib/screens/events/event_detail/sections/event_title_section.dart
No hardcoded strings (all parameterized).

### lib/screens/events/event_detail/sections/action_buttons_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Uložit'` | [UI] | `common.save` |
| `'Sdílet'` | [UI] | `common.share` |
| `'Mapa'` | [UI] | `common.map` |

### lib/screens/events/event_detail/sections/additional_info_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Dodatečné informace'` | [UI] | `events.detail.additionalInfo` |
| `'Vstupné'` | [UI] | `events.detail.admission` |
| `'Dresscode'` | [UI] | `events.detail.dresscode` |
| `'Koupit vstupenky'` | [UI] | `events.detail.buyTickets` |
| `'Původní zdroj'` | [UI] | `events.detail.originalSource` |

### lib/screens/events/event_detail/sections/event_program_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Program akce'` | [UI] | `events.detail.program` |

### lib/screens/events/event_detail/components/program_slot_item.dart
No hardcoded strings (all parameterized).

### lib/screens/events/event_detail/components/program_day_card.dart
No hardcoded strings (all parameterized).

---

### lib/screens/events/filter_dance/filter_dance_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| Dance style names: `'Salsa'`..`'Forró'` | [API] | `EventRepository.getDanceStyles()` |
| `'0 vybraných'`, `'1 vybraný'`, `'N vybrané'`, `'N vybraných'` | [UI] | `events.filter.selectedCount(count)` |

### lib/screens/events/filter_dance/sections/filter_dance_header_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Taneční styly'` | [UI] | `events.danceStyles` |
| `'Vymazat'` | [UI] | `common.clear` |

### lib/screens/events/filter_dance/sections/selected_styles_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'VYBRANÉ STYLY'` | [UI] | `events.filter.selectedStyles` |

### lib/screens/events/filter_dance/sections/dance_styles_list_section.dart
| String | Type | Key / Repository |
|---|---|---|
| All dance style data (name, subtitle, icon, colors) | [API] | `EventRepository.getDanceStyles()` |

### lib/screens/events/filter_dance/sections/filter_bottom_actions_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Použít filtr'` / `'Použít filtr (N)'` | [UI] | `events.filter.apply` / `events.filter.applyCount(count)` |

---

### lib/screens/events/filter_location/filter_location_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| Nav labels: `'Domů'`, `'Hledat'`, `'Uložené'`, `'Profil'` | [UI] | `nav.*` |

### lib/screens/events/filter_location/sections/filter_location_header_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Vybrat lokalitu'` | [UI] | `events.filter.selectLocation` |
| `'Hledat město nebo oblast...'` | [UI] | `events.filter.searchCityHint` |

### lib/screens/events/filter_location/sections/current_location_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Použít moji polohu'` | [UI] | `events.filter.useMyLocation` |
| `'Automaticky najde akce ve vašem okolí'` | [UI] | `events.filter.useMyLocationSubtitle` |

### lib/screens/events/filter_location/sections/popular_cities_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Oblíbená města'` | [UI] | `events.filter.popularCities` |
| All city data (name, eventCount, colors, icons, isCurrent) | [API] | `CityRepository.getPopularCities()` |
| `'Aktuální'` badge | [UI] | `common.current` |

### lib/screens/events/filter_location/sections/all_cities_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Všechna města'` | [UI] | `events.filter.allCities` |
| All city data (name, count) | [API] | `CityRepository.getAllCities()` |

---

### lib/screens/courses/courses_list/courses_list_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Vše'`, `'Salsa'`, `'Bachata'`, `'Kizomba'`, `'Zouk'`, `'Swing'` | [API] | `EventRepository.getDanceStyleFilters()` |
| Nav labels: `'Domů'`, `'Hledat'`, `'Kurzy'`, `'Profil'` | [UI] | `nav.*` |

### lib/screens/courses/courses_list/sections/courses_header_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Taneční kurzy'` | [UI] | `courses.title` |
| `'Najdi svůj kurz'` | [UI] | `courses.subtitle` |

### lib/screens/courses/courses_list/sections/featured_courses_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Doporučené kurzy'` | [UI] | `courses.featuredCourses` |
| `'Zobrazit vše'` | [UI] | `common.showAll` |
| All course data (imageUrl, level, title, instructor, dateRange, style, price) | [API] | `CourseRepository.getFeaturedCourses()` |

### lib/screens/courses/courses_list/sections/all_courses_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Všechny kurzy'` | [UI] | `courses.allCourses` |
| `'Datum'` | [UI] | `common.date` |
| All course data | [API] | `CourseRepository.getAllCourses()` |

### lib/screens/courses/courses_list/components/featured_course_card.dart
No hardcoded strings (all parameterized).

### lib/screens/courses/courses_list/components/course_list_card.dart
No hardcoded strings (all parameterized).

### lib/screens/courses/course_detail/course_detail_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Detail kurzu'` | [UI] | `courses.detail.header` |
| `'Popis kurzu'` | [UI] | `courses.detail.description` |
| Nav labels | [UI] | `nav.*` |
| All course detail data (title, chips, key info, description, schedule, instructor, pricing) | [API] | `CourseRepository.getCourseDetail(id)` |

### lib/screens/courses/course_detail/sections/course_title_section.dart
No hardcoded strings (all parameterized).

### lib/screens/courses/course_detail/sections/course_schedule_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Podrobnosti kurzu'` | [UI] | `courses.detail.details` |
| `'Co se naučíte'` | [UI] | `courses.detail.whatYouLearn` |

### lib/screens/courses/course_detail/sections/course_instructor_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'O lektorovi'` | [UI] | `courses.detail.aboutInstructor` |

### lib/screens/courses/course_detail/sections/course_pricing_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Sdílet kurz'` | [UI] | `courses.detail.shareCourse` |
| `'Původní zdroj'` | [UI] | `events.detail.originalSource` |

### lib/screens/courses/course_detail/components/pricing_option_card.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Cena kurzu'` | [UI] | `courses.detail.coursePrice` |
| `'Volná místa'` | [UI] | `courses.detail.availableSpots` |
| `'Registrovat se na kurz'` | [UI] | `courses.detail.register` |

### lib/screens/courses/course_detail/components/instructor_card.dart
No hardcoded strings (all parameterized).

### lib/screens/courses/course_detail/components/schedule_card.dart
No hardcoded strings (all parameterized).

---

### lib/screens/profile/profile/profile_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Profil'` | [UI] | `profile.title` |
| Nav labels | [UI] | `nav.*` |
| Section labels: `'Účet'`, `'Nastavení'`, `'Podpora'`, `'O aplikaci'`, `'Nebezpečná zóna'` | [UI] | `profile.sections.*` |
| User data (name, email, avatar, dance tags) | [API] | `UserRepository.getCurrentUser()` |

### lib/screens/profile/profile/sections/profile_card_section.dart
No hardcoded strings (all parameterized).

### lib/screens/profile/profile/sections/account_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Upravit profil'` | [UI] | `profile.account.editProfile` |
| `'Změnit heslo'` | [UI] | `profile.account.changePassword` |

### lib/screens/profile/profile/sections/settings_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Jazyk'` | [UI] | `profile.settings.language` |
| `'Čeština'` | [UI] | `profile.settings.czech` |
| `'Oznámení'` | [UI] | `profile.settings.notifications` |

### lib/screens/profile/profile/sections/support_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Napsat autorovi'` | [UI] | `profile.support.contactAuthor` |
| `'Ohodnotit aplikaci'` | [UI] | `profile.support.rateApp` |

### lib/screens/profile/profile/sections/app_info_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Verze aplikace'` | [UI] | `profile.appInfo.version` |
| `'1.2.5 (Build 125)'` | [API] | `UserRepository.getAppVersion()` |
| `'Podmínky použití'` | [UI] | `profile.appInfo.termsOfUse` |
| `'Ochrana soukromí'` | [UI] | `profile.appInfo.privacy` |

### lib/screens/profile/profile/sections/logout_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Odhlásit se'` | [UI] | `profile.danger.logout` |
| `'Smazat účet'` | [UI] | `profile.danger.deleteAccount` |

### lib/screens/profile/profile/components/premium_banner.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Dancee Premium'` | [UI] | `premium.title` |
| `'Odemkněte všechny funkce'` | [UI] | `premium.bannerSubtitle` |

### lib/screens/profile/profile/components/profile_menu_item.dart
No hardcoded strings (all parameterized).

### lib/screens/profile/profile/components/profile_stat_item.dart
No hardcoded strings (all parameterized).

### lib/screens/profile/profile/components/dance_tag.dart
No hardcoded strings (all parameterized).

---

### lib/screens/profile/change_password/change_password_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Změnit heslo'` | [UI] | `profile.changePassword.title` |

### lib/screens/profile/change_password/sections/security_banner_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Zabezpečte svůj účet'` | [UI] | `profile.changePassword.secureAccount` |
| `'Silné heslo musí obsahovat alespoň 8 znaků, velká a malá písmena, čísla a speciální znaky.'` | [UI] | `profile.changePassword.secureAccountDetail` |

### lib/screens/profile/change_password/sections/password_form_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Současné heslo'` | [UI] | `profile.changePassword.currentPassword` |
| `'Zadejte současné heslo'` | [UI] | `profile.changePassword.currentPasswordHint` |
| `'Nové heslo'` | [UI] | `profile.changePassword.newPassword` |
| `'Zadejte nové heslo'` | [UI] | `profile.changePassword.newPasswordHint` |
| `'Potvrdit nové heslo'` | [UI] | `profile.changePassword.confirmPassword` |
| `'Zadejte nové heslo znovu'` | [UI] | `profile.changePassword.confirmPasswordHint` |
| `'Hesla se neshodují'` | [UI] | `auth.register.passwordsMismatch` |
| `'Uložit nové heslo'` | [UI] | `profile.changePassword.save` |
| `'Zrušit'` | [UI] | `common.cancel` |
| `'POŽADAVKY NA HESLO'` | [UI] | `profile.changePassword.requirements` |
| `'Minimálně 8 znaků'` | [UI] | `profile.changePassword.req8chars` |
| `'Alespoň jedno velké písmeno (A-Z)'` | [UI] | `profile.changePassword.reqUppercase` |
| `'Alespoň jedno malé písmeno (a-z)'` | [UI] | `profile.changePassword.reqLowercase` |
| `'Alespoň jedno číslo (0-9)'` | [UI] | `profile.changePassword.reqNumber` |
| `'Alespoň jeden speciální znak (!@#$%^&*)'` | [UI] | `profile.changePassword.reqSpecial` |
| `'Zapomněli jste heslo?'` | [UI] | `profile.changePassword.forgotPassword` |

### lib/screens/profile/change_password/components/password_strength_bar.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Síla hesla: Velmi slabé'` | [UI] | `profile.changePassword.strengthVeryWeak` |
| `'Síla hesla: Slabé'` | [UI] | `profile.changePassword.strengthWeak` |
| `'Síla hesla: Střední'` | [UI] | `profile.changePassword.strengthMedium` |
| `'Síla hesla: Silné'` | [UI] | `profile.changePassword.strengthStrong` |

### lib/screens/profile/change_password/components/password_requirement_row.dart
No hardcoded strings (text is parameter).

---

### lib/screens/profile/author_contact/author_contact_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Napsat autorovi'` | [UI] | `profile.support.contactAuthor` |

### lib/screens/profile/author_contact/sections/author_info_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Tým Dancee'` | [UI] | `contact.teamName` |
| `'hello@dancee.app'` | [UI] | `contact.email` |
| `'Rádi si přečteme vaše zpětné vazby...'` | [UI] | `contact.description` |

### lib/screens/profile/author_contact/sections/contact_form_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Předmět zprávy'` | [UI] | `contact.form.subject` |
| `'Zpětná vazba'` | [UI] | `contact.form.feedback` |
| `'Nahlásit problém'` | [UI] | `contact.form.reportBug` |
| `'Návrh na vylepšení'` | [UI] | `contact.form.featureRequest` |
| `'Ostatní'` | [UI] | `contact.form.other` |
| `'Název zprávy'` | [UI] | `contact.form.title` |
| `'Stručně popište váš problém nebo návrh'` | [UI] | `contact.form.titleHint` |
| `'Zpráva'` | [UI] | `contact.form.message` |
| `'Podrobně popište váš problém...'` | [UI] | `contact.form.messageHint` |
| `'Váš e-mail pro odpověď'` | [UI] | `contact.form.replyEmail` |
| `'Odesílání...'` | [UI] | `contact.form.sending` |
| `'Odesláno!'` | [UI] | `contact.form.sent` |
| `'Odeslat zprávu'` | [UI] | `contact.form.submit` |
| `'Doba odezvy'` | [UI] | `contact.responseTime` |
| `'Obvykle odpovídáme do 24 hodin v pracovní dny. Děkujeme za trpělivost!'` | [UI] | `contact.responseTimeDetail` |
| Device info data (app version, device, OS) | [API] | `UserRepository.getDeviceInfo()` |

### lib/screens/profile/author_contact/components/device_info_card.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Informace o zařízení'` | [UI] | `contact.deviceInfo` |
| `'Automaticky přiloženo'` | [UI] | `contact.autoAttached` |

### lib/screens/profile/author_contact/components/subject_option.dart
No hardcoded strings (all parameterized).

---

### lib/screens/profile/premium/premium_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| Nav labels | [UI] | `nav.*` |

### lib/screens/profile/premium/sections/premium_header_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Dancee Premium'` | [UI] | `premium.title` |

### lib/screens/profile/premium/sections/premium_hero_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Odemkněte plný potenciál'` | [UI] | `premium.heroTitle` |
| `'Získejte přístup ke všem prémiové funkcím a zlepšete své taneční zážitky'` | [UI] | `premium.heroSubtitle` |

### lib/screens/profile/premium/sections/features_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Co získáte s Premium'` | [UI] | `premium.featuresTitle` |
| All 8 feature items (title + description) | [API] | `PremiumRepository.getFeatures()` |

### lib/screens/profile/premium/sections/plans_section.dart
| String | Type | Key / Repository |
|---|---|---|
| All plan data (title, subtitle, price, originalPrice, note, ctaLabel, badge) | [API] | `PremiumRepository.getPlans()` |

### lib/screens/profile/premium/sections/testimonials_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Co říkají naši uživatelé'` | [UI] | `premium.testimonialsTitle` |
| All testimonial data (avatarUrl, name, quote) | [API] | `PremiumRepository.getTestimonials()` |

### lib/screens/profile/premium/sections/faq_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Časté otázky'` | [UI] | `premium.faqTitle` |
| All FAQ data (question + answer) | [API] | `PremiumRepository.getFaqs()` |

### lib/screens/profile/premium/sections/final_cta_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Připraveni začít?'` | [UI] | `premium.ctaTitle` |
| `'Připojte se k tisícům spokojených tanečníků'` | [UI] | `premium.ctaSubtitle` |
| `'Získat Premium nyní'` | [UI] | `premium.ctaButton` |
| `'7 dní zdarma · Zrušte kdykoliv'` | [UI] | `premium.ctaNote` |

### lib/screens/profile/premium/components/faq_item.dart
No hardcoded strings (all parameterized).

### lib/screens/profile/premium/components/feature_item.dart
No hardcoded strings (all parameterized).

### lib/screens/profile/premium/components/plan_card.dart
No hardcoded strings (all parameterized).

### lib/screens/profile/premium/components/testimonial_card.dart
No hardcoded strings (all parameterized).

---

### lib/screens/profile/profile_edit/profile_edit_screen.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Upravit profil'` | [UI] | `profile.editProfile.title` |
| Section labels: `'Osobní údaje'`, `'O mně'`, `'Oblíbené tance'`, `'Úroveň'`, `'Sociální sítě'`, `'Oznámení'` | [UI] | `profile.editProfile.sections.*` |
| Nav labels | [UI] | `nav.*` |
| User data (name, email, phone, city, bio, avatar, dance prefs, level) | [API] | `UserRepository.getCurrentUser()` |
| Dance preferences: `'Salsa'`..`'Swing'` | [API] | `EventRepository.getDanceStyles()` |
| Level: `'Mírně pokročilý'` | [API] | `EventRepository.getExperienceLevels()` |
| Notification keys: `'Nové akce'`, `'Připomínky akcí'`, `'Marketingové zprávy'` | [UI] | `profile.editProfile.notifications.*` |
| Notification subtitles | [UI] | `profile.editProfile.notificationSubtitles.*` |

### lib/screens/profile/profile_edit/sections/profile_photo_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Změnit fotku'` | [UI] | `profile.editProfile.changePhoto` |

### lib/screens/profile/profile_edit/sections/personal_info_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Jméno a příjmení'` | [UI] | `common.form.fullName` |
| `'E-mail'` | [UI] | `common.form.email` |
| `'Telefon'` | [UI] | `common.form.phone` |
| `'Město'` | [UI] | `common.form.city` |

### lib/screens/profile/profile_edit/sections/bio_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Popis'` | [UI] | `profile.editProfile.bio` |
| `'Napište něco o sobě...'` | [UI] | `profile.editProfile.bioHint` |

### lib/screens/profile/profile_edit/sections/dance_preferences_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Vyberte své oblíbené tanční styly'` | [UI] | `profile.editProfile.selectDanceStyles` |

### lib/screens/profile/profile_edit/sections/experience_level_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Vaše taneční úroveň'` | [UI] | `profile.editProfile.yourLevel` |
| Level names: `'Začátečník'`, `'Mírně pokročilý'`, `'Pokročilý'`, `'Expert'` | [API] | `EventRepository.getExperienceLevels()` |

### lib/screens/profile/profile_edit/sections/social_links_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Instagram'` | [UI] | `profile.editProfile.instagram` |
| `'@vase_uzivatelske_jmeno'` | [UI] | `profile.editProfile.instagramHint` |
| `'Facebook'` | [UI] | `profile.editProfile.facebook` |
| `'facebook.com/vase.jmeno'` | [UI] | `profile.editProfile.facebookHint` |

### lib/screens/profile/profile_edit/sections/notifications_section.dart
No hardcoded strings (all parameterized from parent).

### lib/screens/profile/profile_edit/sections/save_button_section.dart
| String | Type | Key / Repository |
|---|---|---|
| `'Uložit změny'` | [UI] | `common.saveChanges` |

---

## 6. Summary Statistics

| Category | Count |
|---|---|
| Files with hardcoded UI strings | ~55 |
| Files with hardcoded API/mock data | ~15 |
| Files with no hardcoded strings (parameterized) | ~45 |
| Total unique UI translation keys needed | ~200 |
| Total API data extraction points | ~25 |
| Repositories to create | 5 |
