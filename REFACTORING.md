# Dancee App v2 — UI Refactoring Analysis

## Framework

**Flutter (Dart)** — detected from `pubspec.yaml`, `lib/main.dart`, and `.metadata`.

Dependencies: `flutter`, `go_router`, `flutter_bloc`, `google_fonts` (Inter), `font_awesome_flutter`.

## Current Structure

```
lib/
├── main.dart
├── core/
│   ├── colors.dart          # 10 color constants
│   └── theme.dart           # Minimal ThemeData (scaffold bg, colorScheme, textTheme, inputDecoration)
└── screens/
    ├── auth/
    │   ├── login_screen.dart           (~440 lines)
    │   ├── register_screen.dart        (~490 lines)
    │   ├── forgot_password_screen.dart (~450 lines)
    │   └── onboarding_screen.dart      (~720 lines)
    ├── events/
    │   ├── events_list_screen.dart     (~700 lines)
    │   ├── event_detail_screen.dart    (~790 lines)
    │   ├── filter_dance_screen.dart    (~400 lines)
    │   └── filter_location_screen.dart (~420 lines)
    ├── courses/
    │   ├── courses_list_screen.dart    (~740 lines)
    │   └── course_detail_screen.dart   (~730 lines)
    └── profile/
        ├── profile_screen.dart         (~660 lines)
        ├── profile_edit_screen.dart    (~700 lines)
        ├── change_password_screen.dart (~430 lines)
        ├── premium_screen.dart         (~740 lines)
        └── author_contact_screen.dart  (~520 lines)
```

**Total**: 15 screen files, ~9,000 lines of UI code.

### Key Problems

1. **No design tokens** — 104 inline `Color(0x...)` values, 265 inline `fontSize`, 179 inline `BorderRadius.circular()`, 56 inline `BoxShadow` across all files. The existing `colors.dart` defines 10 constants but dozens more colors are hardcoded per-file.
2. **Massive monolithic screens** — every screen is a single class with 5–15 private `_build*` methods. No separate widget classes.
3. **Duplicated bottom navigation** — identical `_buildBottomNav`, `_navItem`, `_navFab` code copy-pasted across 8 screens.
4. **Duplicated UI patterns** — gradient buttons, outline buttons, input fields, checkboxes, radio buttons, section headers, back-button headers all reimplemented per screen.
5. **No shared components** — zero reuse between screens.

---

## Theme / Design Token Analysis

### Colors

| Current Constant | Hex Value | Proposed Token Name | Usage |
|---|---|---|---|
| `appBg` | `#0F172A` | `appBg` (keep) | Scaffold background |
| `appSurface` | `#1E293B` | `appSurface` (keep) | Card/container surfaces |
| `appCard` | `#111827` | `appCard` (keep) | Bottom nav, deeper cards |
| `appPrimary` | `#3B82F6` | `appPrimary` (keep) | Primary actions, links |
| `appAccent` | `#A855F7` | `appAccent` (keep) | Secondary accent, gradients |
| `appSuccess` | `#22C55E` | `appSuccess` (keep) | Success states, beginner level |
| `appText` | `#F8FAFC` | `appText` (keep) | Primary text |
| `appMuted` | `#94A3B8` | `appMuted` (keep) | Secondary/hint text |
| `appBorder` | `#334155` | `appBorder` (keep) | Borders, dividers |
| — | `#EC4899` | `appPink` | Gradient endpoint, dance style |
| — | `#EF4444` | `appError` | Error states, password weak |
| — | `#F97316` | `appWarning` | Warning states, orange icons |
| — | `#F59E0B` | `appAmber` | Medium password strength |
| — | `#EAB308` | `appYellow` | Expert level, FAQ, feature |
| — | `#34D399` | `appTeal` | Zouk style chip color |
| — | `#C084FC` | `appLavender` | Kizomba style chip color |
| — | `#60A5FA` | `appLightBlue` | Semba style chip color |
| — | `#FACC15` | `appGold` | Course style color |
| — | `#8B5CF6` | `appViolet` | Dance style gradient |
| — | `#2563EB` | `appPrimaryDark` | Gradient endpoint |
| — | `#10B981` | `appEmerald` | City gradient |
| — | `#0D9488` | `appTealDark` | City gradient endpoint |
| — | `#16A34A` | `appSuccessDark` | Sent state button |

Also used: `Colors.white`, `Colors.black`, `Colors.red`, `Colors.transparent`.

### Gradients

| Proposed Token | Colors | Usage |
|---|---|---|
| `gradientPrimary` | `[appPrimary, appAccent]` | Primary CTA buttons (login, register, onboarding) |
| `gradientPremium` | `[appPrimary, appAccent, appPink]` | Premium hero, plan badges |
| `gradientHeroOverlay` | `[Colors.black.withOpacity(0.3), Colors.transparent]` | Hero image overlays (event detail, course detail) |

### Font Sizes

| Proposed Token | Value | Usage |
|---|---|---|
| `fontSizeXs` | `10` | Nav bar labels |
| `fontSizeSm` | `12` | Badges, labels, section labels, hints |
| `fontSizeMd` | `14` | Body text, subtitles, form hints |
| `fontSizeLg` | `15` | Button labels, list item text |
| `fontSizeXl` | `16` | Form submit buttons, medium headings |
| `fontSize2xl` | `18` | Screen titles in headers |
| `fontSize3xl` | `20` | Section headings, filter titles |
| `fontSize4xl` | `24` | Page main headings, event/course titles |
| `fontSize5xl` | `28` | Hero headings (register, premium) |
| `fontSize6xl` | `36` | Auth hero titles (login, forgot password) |

### Font Weights

| Proposed Token | Value | Usage |
|---|---|---|
| `fontWeightNormal` | `FontWeight.w400` | Body text |
| `fontWeightMedium` | `FontWeight.w500` | Labels, nav items, form labels |
| `fontWeightSemiBold` | `FontWeight.w600` | Buttons, card titles, section headers |
| `fontWeightBold` | `FontWeight.w700` | Page headings, hero text |

### Spacing

| Proposed Token | Value | Usage |
|---|---|---|
| `spaceXs` | `4` | Tight gaps (icon-to-label) |
| `spaceSm` | `8` | Small gaps, label-to-field |
| `spaceMd` | `12` | List item separators, chip gaps |
| `spaceLg` | `16` | Section padding, card internal padding |
| `spaceXl` | `20` | Screen horizontal padding |
| `space2xl` | `24` | Section vertical spacing |
| `space3xl` | `32` | Large section gaps |

### Border Radii

| Proposed Token | Value | Usage |
|---|---|---|
| `radiusXs` | `4` | Tiny badges, checkboxes |
| `radiusSm` | `6` | Small tags |
| `radiusMd` | `8` | Tags, small cards |
| `radiusLg` | `12` | Input fields, buttons, cards |
| `radiusXl` | `16` | Large cards, containers, sections |
| `radiusRound` | `20` | Header back buttons, rounded cards |
| `radiusFull` | `50` | Circular chips, pills, avatars |

### Shadows

| Proposed Token | Definition | Usage |
|---|---|---|
| `shadowPrimary` | `BoxShadow(color: appPrimary.withOpacity(0.5), blurRadius: 20, spreadRadius: -5)` | FAB, active nav items |
| `shadowPrimaryLg` | `BoxShadow(color: appPrimary.withOpacity(0.5), blurRadius: 20, offset: Offset(0, 5))` | Gradient CTA buttons |
| `shadowCard` | `BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)` | Elevated cards |

### Proposed Theme File

**Location**: `lib/core/theme.dart` (expand existing file)

The theme file should export:
- All color constants (expand `colors.dart`)
- `AppSpacing` class with spacing constants
- `AppRadius` class with border radius constants
- `AppTypography` class with text style presets
- `AppShadows` class with shadow presets
- `AppGradients` class with gradient presets
- `AppTheme.theme` ThemeData (already exists, expand)

Components reference tokens via direct import: `import '../../core/theme.dart';`

---

## Page Decomposition

### 1. Login Screen (`login_screen.dart`)

**Sections:**
- `AuthHeaderSection` — gradient circle background + logo icon + app title + subtitle *(shared with register, forgot password)*
- `LoginFormSection` — email field, password field, forgot password link, login button
- `AuthFooterSection` — "Don't have an account? Register" link *(shared with register)*

**Components (page-specific):**
- `LoginFormSection` composes shared elements (AppInputField, AppPasswordField, GradientButton, TextLinkButton)

### 2. Register Screen (`register_screen.dart`)

**Sections:**
- `AuthHeaderSection` *(shared)*
- `RegisterFormSection` — name, email, password, confirm password, terms checkbox, register button, password strength indicator
- `AuthFooterSection` *(shared)*

**Components (page-specific):**
- `PasswordStrengthIndicator` — strength bars + label

### 3. Forgot Password Screen (`forgot_password_screen.dart`)

**Sections:**
- `AuthHeaderSection` *(shared)*
- `ForgotPasswordFormSection` — email field, reset button, info text
- `AuthFooterSection` *(shared — "Back to login")*

### 4. Onboarding Screen (`onboarding_screen.dart`)

**Sections:**
- `OnboardingHeaderSection` — step indicator dots + progress
- `OnboardingStep1Section` — dance style selection grid
- `OnboardingStep2Section` — experience level selection
- `OnboardingStep3Section` — location + radius selection

**Components (page-specific):**
- `DanceStyleCard` — selectable card with icon, name, subtitle
- `ExperienceLevelCard` — selectable card with icon, title, subtitle, radio
- `RadiusSelector` — radio list for search radius
- `BackgroundCircles` — animated decorative circles

### 5. Events List Screen (`events_list_screen.dart`)

**Sections:**
- `EventsHeaderSection` — location selector + notification bell + quick filter pills
- `DanceStylesFilterSection` — horizontal scrollable style chips *(shared with courses list)*
- `FeaturedEventsSection` — horizontal scroll of featured event cards
- `UpcomingEventsSection` — vertical list of upcoming event cards

**Components (page-specific):**
- `FeaturedEventCard` — large card with image, title, date, location, price, tags, favorite
- `UpcomingEventCard` — compact horizontal card with image, title, date, location, tag
- `QuickFilterPill` — small pill button for time filters

### 6. Event Detail Screen (`event_detail_screen.dart`)

**Sections:**
- `DetailHeaderSection` — back button + title + overflow menu *(shared with course detail)*
- `HeroImageSection` — image with gradient overlay, favorite, price badge *(shared with course detail)*
- `EventTitleSection` — title + style chips
- `KeyInfoSection` — date, location, organizer info card *(shared with course detail)*
- `ActionButtonsSection` — save, share, map buttons
- `DescriptionSection` — expandable text description *(shared with course detail)*
- `EventProgramSection` — collapsible program with day cards and time slots
- `AdditionalInfoSection` — price range, dress code, buy tickets, source link

**Components (page-specific):**
- `ProgramDayCard` — day header with time slot list
- `ProgramSlotItem` — single time slot row

### 7. Filter Dance Screen (`filter_dance_screen.dart`)

**Sections:**
- `FilterDanceHeaderSection` — back + title + count + clear
- `DanceStylesListSection` — full list with checkboxes
- `SelectedStylesSection` — selected tags with remove
- `FilterBottomActionsSection` — apply button with count

### 8. Filter Location Screen (`filter_location_screen.dart`)

**Sections:**
- `FilterLocationHeaderSection` — back + title + search field
- `CurrentLocationSection` — "Use my location" button
- `PopularCitiesSection` — gradient city cards
- `AllCitiesSection` — simple city list with event counts

**Components (page-specific):**
- `PopularCityCard` — gradient card with icon + city name + event count

### 9. Courses List Screen (`courses_list_screen.dart`)

**Sections:**
- `CoursesHeaderSection` — title + subtitle + search
- `DanceStylesFilterSection` *(shared with events list)*
- `FeaturedCoursesSection` — horizontal scroll of featured course cards
- `AllCoursesSection` — vertical list of all course cards

**Components (page-specific):**
- `FeaturedCourseCard` — large card with image, title, instructor, rating, price, tags
- `CourseListCard` — compact card with image, title, instructor, schedule, level, price

### 10. Course Detail Screen (`course_detail_screen.dart`)

**Sections:**
- `DetailHeaderSection` *(shared with event detail)*
- `HeroImageSection` *(shared with event detail)*
- `CourseTitleSection` — title + style chips + rating
- `KeyInfoSection` *(shared with event detail)*
- `DescriptionSection` *(shared with event detail)*
- `CourseScheduleSection` — schedule cards with day/time
- `CourseInstructorSection` — instructor card with avatar, bio
- `CoursePricingSection` — pricing options cards

**Components (page-specific):**
- `ScheduleCard` — day + time card
- `InstructorCard` — avatar + name + bio
- `PricingOptionCard` — price + description + CTA

### 11. Profile Screen (`profile_screen.dart`)

**Sections:**
- `ProfileHeaderSection` — back button + title
- `ProfileCardSection` — avatar, name, email, stats, dance tags
- `AccountSection` — account menu items (edit, password, premium)
- `SettingsSection` — settings menu items (language, notifications, theme)
- `SupportSection` — support menu items (contact, rate, about)
- `LogoutSection` — logout + delete account

**Components (page-specific):**
- `ProfileStatItem` — stat number + label
- `DanceTag` — colored tag chip
- `ProfileMenuItem` — icon + title + subtitle + chevron

### 12. Profile Edit Screen (`profile_edit_screen.dart`)

**Sections:**
- `EditHeaderSection` — back + title + save check
- `ProfilePhotoSection` — avatar with camera overlay
- `PersonalInfoSection` — name, email, phone, city fields
- `BioSection` — multiline text field
- `DancePreferencesSection` — checkbox grid of dance styles
- `ExperienceLevelSection` — radio list of levels
- `SocialLinksSection` — Instagram + Facebook fields
- `NotificationsSection` — toggle switches

### 13. Change Password Screen (`change_password_screen.dart`)

**Sections:**
- `ChangePasswordHeaderSection` — back + title
- `SecurityBannerSection` — warning banner with icon
- `PasswordFormSection` — current, new, confirm password fields + strength indicator + requirements

**Components (page-specific):**
- `PasswordStrengthBar` — 4-segment colored bar
- `PasswordRequirementRow` — check/x icon + requirement text

### 14. Premium Screen (`premium_screen.dart`)

**Sections:**
- `PremiumHeaderSection` — gradient title
- `PremiumHeroSection` — crown icon + gradient text + subtitle
- `PlansSection` — yearly + monthly plan cards
- `FeaturesSection` — 8 feature items with icons
- `TestimonialsSection` — testimonial cards with avatars
- `FaqSection` — expandable FAQ items
- `FinalCtaSection` — call-to-action with trial info

**Components (page-specific):**
- `PlanCard` — price, period, badge, CTA
- `FeatureItem` — icon + title + description
- `TestimonialCard` — avatar + name + role + quote + stars
- `FaqItem` — expandable question/answer (already a StatefulWidget)

### 15. Author Contact Screen (`author_contact_screen.dart`)

**Sections:**
- `ContactHeaderSection` — back + title
- `AuthorInfoSection` — team avatar + name + email + response time
- `ContactFormSection` — subject selector + title + message + email + device info + submit

**Components (page-specific):**
- `SubjectOption` — radio + icon + label
- `DeviceInfoCard` — device info rows with badge

---

## Shared Elements (used across 3+ screens)

| Element | Used By | Purpose |
|---|---|---|
| `AppBottomNavBar` | 8 screens (events list, event detail, filter location, courses list, course detail, profile, profile edit, premium) | Bottom navigation with 5 items + FAB |
| `GradientButton` | login, register, forgot password, onboarding, premium, change password | Primary CTA with gradient background |
| `OutlineButton` | onboarding, change password | Secondary action with border |
| `AppInputField` | login, register, forgot password, profile edit, author contact, onboarding, filter location | Labeled text input with surface background |
| `AppPasswordField` | login, register, change password | Password input with visibility toggle |
| `AppCheckbox` | register, profile edit, filter dance | Custom styled checkbox |
| `AppRadioButton` | onboarding, profile edit | Custom styled radio button |
| `BackButtonHeader` | event detail, course detail, filter dance, filter location, change password, author contact, profile edit | Back arrow + title + optional trailing action |
| `StyleChip` | events list, event detail, courses list, course detail, profile | Colored dance style tag |
| `SectionLabel` | profile edit, profile (uppercase muted label) | Section divider label |
| `PriceBadge` | events list, event detail, courses list, course detail | Price tag overlay on cards |

## Shared Sections (used across 2+ screens)

| Section | Used By |
|---|---|
| `AuthHeaderSection` | login, register, forgot password |
| `DanceStylesFilterSection` | events list, courses list |
| `DetailHeaderSection` | event detail, course detail |
| `HeroImageSection` | event detail, course detail |
| `KeyInfoSection` | event detail, course detail |
| `DescriptionSection` | event detail, course detail |

---

## Proposed Folder Structure

```
lib/
├── main.dart
├── core/
│   ├── colors.dart              # All color tokens (expanded)
│   └── theme.dart               # AppTheme, AppTypography, AppSpacing, AppRadius, AppShadows, AppGradients
├── shared/
│   ├── elements/
│   │   ├── buttons/
│   │   │   ├── gradient_button.dart
│   │   │   ├── outline_button.dart
│   │   │   └── text_link_button.dart
│   │   ├── forms/
│   │   │   ├── app_input_field.dart
│   │   │   ├── app_password_field.dart
│   │   │   ├── app_checkbox.dart
│   │   │   └── app_radio_button.dart
│   │   ├── labels/
│   │   │   ├── style_chip.dart
│   │   │   ├── price_badge.dart
│   │   │   └── section_label.dart
│   │   └── navigation/
│   │       └── app_bottom_nav_bar.dart
│   ├── components/
│   │   └── back_button_header.dart
│   └── sections/
│       ├── auth_header_section.dart
│       ├── auth_footer_section.dart
│       ├── dance_styles_filter_section.dart
│       ├── detail_header_section.dart
│       ├── hero_image_section.dart
│       ├── key_info_section.dart
│       └── description_section.dart
├── screens/
│   ├── auth/
│   │   ├── login/
│   │   │   ├── login_screen.dart
│   │   │   └── sections/
│   │   │       └── login_form_section.dart
│   │   ├── register/
│   │   │   ├── register_screen.dart
│   │   │   ├── sections/
│   │   │   │   └── register_form_section.dart
│   │   │   └── components/
│   │   │       └── password_strength_indicator.dart
│   │   ├── forgot_password/
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── sections/
│   │   │       └── forgot_password_form_section.dart
│   │   └── onboarding/
│   │       ├── onboarding_screen.dart
│   │       ├── sections/
│   │       │   ├── onboarding_step1_section.dart
│   │       │   ├── onboarding_step2_section.dart
│   │       │   └── onboarding_step3_section.dart
│   │       └── components/
│   │           ├── dance_style_card.dart
│   │           ├── experience_level_card.dart
│   │           ├── radius_selector.dart
│   │           └── background_circles.dart
│   ├── events/
│   │   ├── events_list/
│   │   │   ├── events_list_screen.dart
│   │   │   ├── sections/
│   │   │   │   ├── events_header_section.dart
│   │   │   │   ├── featured_events_section.dart
│   │   │   │   └── upcoming_events_section.dart
│   │   │   └── components/
│   │   │       ├── featured_event_card.dart
│   │   │       ├── upcoming_event_card.dart
│   │   │       └── quick_filter_pill.dart
│   │   ├── event_detail/
│   │   │   ├── event_detail_screen.dart
│   │   │   ├── sections/
│   │   │   │   ├── event_title_section.dart
│   │   │   │   ├── action_buttons_section.dart
│   │   │   │   ├── event_program_section.dart
│   │   │   │   └── additional_info_section.dart
│   │   │   └── components/
│   │   │       ├── program_day_card.dart
│   │   │       └── program_slot_item.dart
│   │   ├── filter_dance/
│   │   │   ├── filter_dance_screen.dart
│   │   │   └── sections/
│   │   │       ├── dance_styles_list_section.dart
│   │   │       ├── selected_styles_section.dart
│   │   │       └── filter_bottom_actions_section.dart
│   │   └── filter_location/
│   │       ├── filter_location_screen.dart
│   │       ├── sections/
│   │       │   ├── current_location_section.dart
│   │       │   ├── popular_cities_section.dart
│   │       │   └── all_cities_section.dart
│   │       └── components/
│   │           └── popular_city_card.dart
│   ├── courses/
│   │   ├── courses_list/
│   │   │   ├── courses_list_screen.dart
│   │   │   ├── sections/
│   │   │   │   ├── courses_header_section.dart
│   │   │   │   ├── featured_courses_section.dart
│   │   │   │   └── all_courses_section.dart
│   │   │   └── components/
│   │   │       ├── featured_course_card.dart
│   │   │       └── course_list_card.dart
│   │   └── course_detail/
│   │       ├── course_detail_screen.dart
│   │       ├── sections/
│   │       │   ├── course_title_section.dart
│   │       │   ├── course_schedule_section.dart
│   │       │   ├── course_instructor_section.dart
│   │       │   └── course_pricing_section.dart
│   │       └── components/
│   │           ├── schedule_card.dart
│   │           ├── instructor_card.dart
│   │           └── pricing_option_card.dart
│   └── profile/
│       ├── profile/
│       │   ├── profile_screen.dart
│       │   ├── sections/
│       │   │   ├── profile_card_section.dart
│       │   │   ├── account_section.dart
│       │   │   ├── settings_section.dart
│       │   │   ├── support_section.dart
│       │   │   └── logout_section.dart
│       │   └── components/
│       │       ├── profile_stat_item.dart
│       │       ├── dance_tag.dart
│       │       └── profile_menu_item.dart
│       ├── profile_edit/
│       │   ├── profile_edit_screen.dart
│       │   └── sections/
│       │       ├── profile_photo_section.dart
│       │       ├── personal_info_section.dart
│       │       ├── bio_section.dart
│       │       ├── dance_preferences_section.dart
│       │       ├── experience_level_section.dart
│       │       ├── social_links_section.dart
│       │       └── notifications_section.dart
│       ├── change_password/
│       │   ├── change_password_screen.dart
│       │   ├── sections/
│       │   │   ├── security_banner_section.dart
│       │   │   └── password_form_section.dart
│       │   └── components/
│       │       ├── password_strength_bar.dart
│       │       └── password_requirement_row.dart
│       ├── premium/
│       │   ├── premium_screen.dart
│       │   ├── sections/
│       │   │   ├── premium_hero_section.dart
│       │   │   ├── plans_section.dart
│       │   │   ├── features_section.dart
│       │   │   ├── testimonials_section.dart
│       │   │   ├── faq_section.dart
│       │   │   └── final_cta_section.dart
│       │   └── components/
│       │       ├── plan_card.dart
│       │       ├── feature_item.dart
│       │       ├── testimonial_card.dart
│       │       └── faq_item.dart
│       └── author_contact/
│           ├── author_contact_screen.dart
│           ├── sections/
│           │   ├── author_info_section.dart
│           │   └── contact_form_section.dart
│           └── components/
│               ├── subject_option.dart
│               └── device_info_card.dart
```

---

## Component Props Reference

### Shared Elements

**GradientButton** — `label: String`, `onTap: VoidCallback`, `gradient: Gradient?` (defaults to primary)
**OutlineButton** — `label: String`, `onTap: VoidCallback`
**TextLinkButton** — `text: String`, `linkText: String`, `onLinkTap: VoidCallback`
**AppInputField** — `label: String`, `value: String?`, `hintText: String?`, `keyboardType: TextInputType`, `controller: TextEditingController?`, `icon: IconData?`
**AppPasswordField** — `label: String`, `hintText: String?`, `controller: TextEditingController?`, `onChanged: ValueChanged<String>?`
**AppCheckbox** — `checked: bool`, `onChanged: ValueChanged<bool>`
**AppRadioButton** — `selected: bool`, `onTap: VoidCallback`
**StyleChip** — `label: String`, `color: Color`
**PriceBadge** — `price: String`
**SectionLabel** — `title: String`
**AppBottomNavBar** — `activeIndex: int`, `onItemTap: Function(int)`, `onFabTap: VoidCallback`

### Shared Components

**BackButtonHeader** — `title: String`, `onBack: VoidCallback`, `trailing: Widget?`

### Shared Sections

**AuthHeaderSection** — `title: String`, `subtitle: String`
**AuthFooterSection** — `text: String`, `linkText: String`, `onLinkTap: VoidCallback`
**DanceStylesFilterSection** — `styles: List<String>`, `selectedIndex: int`, `onSelected: ValueChanged<int>`, `onShowAll: VoidCallback?`
**DetailHeaderSection** — `title: String`, `onBack: VoidCallback`, `actions: List<Widget>?`
**HeroImageSection** — `imageUrl: String`, `isFavorite: bool`, `onFavoriteTap: VoidCallback`, `priceBadge: String?`
**KeyInfoSection** — `items: List<KeyInfoItem>` (each: `icon`, `label`, `value`)
**DescriptionSection** — `title: String`, `text: String`
