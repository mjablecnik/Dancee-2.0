# Dancee App — Page Designs

## Global Design System

All pages share a consistent dark theme mobile-first design (max-width 430px, centered).

### Color Palette
| Token | Hex | Usage |
|---|---|---|
| app-bg | `#0F172A` | Page background |
| app-surface | `#1E293B` | Cards, input backgrounds |
| app-card | `#111827` | Deeper card backgrounds |
| app-primary | `#3B82F6` | Primary actions, links, active states |
| app-accent | `#A855F7` | Secondary accent (purple) |
| app-success | `#22C55E` | Success states, free badges |
| app-text | `#F8FAFC` | Primary text |
| app-muted | `#94A3B8` | Secondary/muted text |
| app-border | `#334155` | Borders, dividers |

### Typography
- **Font**: Inter (Google Fonts), weights 400/500/600/700/800
- **Sizes**: text-[10px] (nav labels), text-xs (12px), text-sm (14px), text-base (16px), text-lg (18px), text-xl (20px), text-2xl (24px), text-3xl (30px), text-4xl (36px)

### Icons
- Font Awesome 6 (Free + Brands), loaded via JS + CSS CDN

### Shared Components
- **Bottom Navigation Bar**: Fixed at bottom, rounded-t-3xl, backdrop-blur, 5 items: Domů (house), Hledat (magnifying-glass), center FAB (+), Uložené (heart), Profil (user). Center FAB is elevated -top-5 with glow shadow and border-4 border-app-bg. Active tab uses text-app-primary, inactive uses text-app-muted.
- **Sticky Header**: sticky top-0 z-50, bg-app-bg/90 backdrop-blur-md, px-5 pt-12 pb-4, border-b border-app-border
- **Back Button**: w-10 h-10 rounded-full bg-app-surface, fa-arrow-left icon

---

## 1. Events List Page
**File**: `.design/events-list.html`
**Title**: Dancee - Taneční akce

### Purpose
Main home/discovery page for browsing dance events. The primary landing page of the app.

### Header
- **Location selector**: Label "Lokalita" (text-sm text-app-muted), button showing "Praha, CZ" with fa-location-dot (primary) + fa-chevron-down. Font-semibold text-lg.
- **Notification bell**: w-10 h-10 rounded-full bg-app-surface, fa-regular fa-bell, red dot indicator (w-2 h-2 bg-red-500 rounded-full) at top-right.

### Quick Date Filters
Horizontal scrollable row of pill buttons (rounded-full, text-xs font-medium):
- Dnes (fa-calendar-day), Tento týden (fa-calendar-week), Tento měsíc, Tento víkend
- Default: bg-app-surface border border-app-border. Hover: bg-app-primary text-white border-app-primary.

### Dance Styles Section
- Title "Taneční styly" (text-xl font-bold) with "Zobrazit vše" link (text-sm text-app-muted)
- Horizontal scrollable pills: Vše (active: bg-app-primary text-white shadow-glow), Salsa, Bachata, Kizomba, Zouk (inactive: bg-app-surface border border-app-border)
- Pill sizing: px-5 py-2.5 text-sm font-medium rounded-full

### Featured Events Slider ("Doporučené akce")
- Title: text-xl font-bold
- Horizontal scrollable cards, w-[280px] each, rounded-[20px], bg-app-card border border-app-border
- **Card structure**:
  - Image: h-[160px] object-cover with gradient overlay (from-app-card via-transparent to-black/30)
  - Heart button: absolute top-3 right-3, w-8 h-8 rounded-full bg-black/40 backdrop-blur-md. Unfavorited: fa-regular fa-heart text-white. Favorited: fa-solid fa-heart text-red-500.
  - Price badge: absolute top-3 left-3, px-2.5 py-1 rounded-md bg-app-primary/90 backdrop-blur-md text-xs font-bold text-white (e.g. "Od 350 Kč"). Free events: bg-app-success/90 "Zdarma".
  - Title: font-bold text-lg line-clamp-2
  - Date: fa-regular fa-calendar, text-sm text-app-muted
  - Location: fa-solid fa-location-dot text-app-primary, text-sm text-app-muted, truncate
  - Dance style tags: text-[10px] font-semibold px-2 py-1 rounded bg-app-surface. Colors vary: text-app-primary (Salsa), text-app-accent (Bachata), text-purple-400 (Kizomba), text-blue-400 (Semba)

### Upcoming Events List ("Nadcházející akce")
- Title with sort button: "Datum" with fa-arrow-up-wide-short icon
- List items: bg-app-surface border border-app-border rounded-[16px] p-3, flex row
  - Thumbnail: w-24 h-24 rounded-xl object-cover
  - Heart button: absolute top-3 right-3
  - Title: font-bold text-base line-clamp-2
  - Location: text-xs text-app-muted with fa-location-dot
  - Date badge: text-xs font-medium bg-app-card px-2 py-1 rounded
  - Dance style label: text-[10px] font-bold uppercase tracking-wider, color varies per style

### Bottom Navigation
Standard 5-tab nav. "Hledat" tab is active (text-app-primary).

---

## 2. Event Detail Page
**File**: `.design/event-detail.html`
**Title**: Event Detail

### Purpose
Detailed view of a single dance event with full information, schedule, and action buttons.

### Header
Back button (left), "Detail akce" title (center), ellipsis menu button (right).

### Hero Image
- h-64 full-width image with gradient overlay
- Heart button (top-right, red filled = favorited)
- Price badge (top-left, bg-app-primary/90): "Od 350 Kč"

### Event Title & Dance Types
- Title: text-2xl font-bold
- Dance style chips: text-xs font-semibold px-3 py-1.5 rounded-full bg-app-surface border border-app-border. Colors: text-app-primary (Salsa), text-app-accent (Bachata), text-emerald-400 (Zouk), text-purple-400 (Kizomba)

### Key Info Card
bg-app-surface border border-app-border rounded-xl p-4. Three rows:
- Calendar icon + date range + time details
- Location icon + venue name + address
- User-tie icon + organizer name + "Organizátor" label

### Action Buttons
3-column grid:
- "Uložit" (fa-regular fa-heart): bg-app-primary text-white shadow-glow
- "Sdílet" (fa-share): bg-app-surface border
- "Mapa" (fa-map-location-dot): bg-app-surface border

### Description ("Popis akce")
text-sm text-app-muted leading-relaxed, multiple paragraphs

### Additional Info ("Dodatečné informace")
Card with key-value rows (Vstupné: price range, Dresscode: text), plus two full-width buttons:
- "Koupit vstupenky" (fa-ticket): bg-app-primary text-white
- "Původní zdroj" (fa-external-link): bg-app-surface border

### Program/Schedule ("Program akce")
Collapsible section (toggle with chevron). Contains day cards:
- Day header: bg-app-card border-b, font-bold
- Time slots: w-16 time column + event name + description + DJ/instructor in colored text

### Bottom Navigation
Standard. "Uložené" tab active (text-red-500, fa-solid fa-heart).

---

## 3. Filter — Dance Styles
**File**: `.design/filter-dance.html`
**Title**: Výběr tanečních stylů

### Purpose
Full-page filter for selecting dance styles to filter events.

### Header
Back button, "Taneční styly" title (text-xl font-bold), selected count ("0 vybraných"), "Vymazat" clear button (text-app-primary).

### Dance Styles List
Single card (bg-app-surface border rounded-2xl) containing checkbox rows separated by border-b:
Each row: label with flex layout:
- Colored circle icon (w-10 h-10 rounded-full bg-gradient-to-br), each style has unique gradient + FA icon
- Style name (font-semibold text-base) + subtitle (text-xs text-app-muted)
- Custom checkbox (24x24, rounded-6px, checked: bg-app-primary with checkmark)

**Styles listed**: Salsa (blue, fa-music), Bachata (purple-pink, fa-heart), Kizomba (violet-purple, fa-fire), Zouk (emerald-green, fa-leaf), Reggaeton (orange-red, fa-fire-flame-curved), Tango (yellow-amber, fa-bolt), Swing (cyan-blue, fa-crown), Ballroom (pink-rose, fa-star), Afro (indigo-purple, fa-drum), Forró (red-pink, fa-umbrella)

### Selected Styles Section
Hidden until selection. Shows tags: px-3 py-1.5 bg-app-primary/20 border border-app-primary/40 text-app-primary rounded-full with X remove button.

### Bottom Action
Fixed bottom: "Použít filtr" button, full-width bg-app-primary rounded-2xl py-4 shadow-glow. Shows count when items selected.

---

## 4. Filter — Location
**File**: `.design/filter-location.html`
**Title**: Lokalita

### Purpose
Location selection page for filtering events by city.

### Header
Back button + "Vybrat lokalitu" title. Search input below: fa-magnifying-glass icon, placeholder "Hledat město nebo oblast...", bg-app-surface border rounded-xl py-3 pl-11.

### Current Location Button
Full-width card: w-12 h-12 rounded-full bg-app-primary/20 icon, "Použít moji polohu" title, subtitle, chevron-right.

### Popular Cities ("Oblíbená města")
Cards with gradient circle icons, city name, event count, chevron. Praha has "Aktuální" badge (bg-app-primary/20 text-app-primary).
- Praha (blue-purple gradient, fa-building, 125 akcí)
- Brno (emerald-teal, fa-city, 47 akcí)
- Ostrava (orange-red, fa-industry, 23 akcí)
- Plzeň (yellow-amber, fa-beer-mug-empty, 18 akcí)

### All Cities ("Všechna města")
Simple list rows: city name + event count, hover:bg-app-surface rounded-lg. Cities: Bratislava SK (12), České Budějovice (8), Hradec Králové (6), Jihlava (4), Karlovy Vary (3), Liberec (9), Olomouc (14), Pardubice (5), Ústí nad Labem (7), Zlín (11).

### Bottom Navigation
Standard.

---

## 5. Profile Page
**File**: `.design/profile-page.html`
**Title**: Profil

### Purpose
User profile hub with settings, account management, and app info.

### Header
Back button, "Profil" title, edit button (fa-pen).

### User Profile Card
bg-app-surface border rounded-xl p-4. Avatar (w-16 h-16 rounded-full border-2 border-app-primary), name (text-lg font-bold), email (text-sm text-app-muted), dance style tags (rounded-full, colored).

### Account Section ("Účet")
Grouped card with rows:
- "Upravit profil" (fa-user, blue icon bg) → navigates to profile-edit
- "Změnit heslo" (fa-lock, orange icon bg) → navigates to change-password

### Settings Section ("Nastavení")
- "Jazyk" (fa-globe, green) → shows "Čeština"
- "Oznámení" (fa-bell, purple) → toggle switch (checked)

### Premium Section
Gradient background card (from-app-primary/20 via-app-accent/20 to-pink-500/20, border-app-primary/30):
- Crown icon, "Dancee Premium", "Odemkněte všechny funkce" → navigates to premium-page

### Support Section ("Podpora")
- "Napsat autorovi" (fa-message, blue) → navigates to author-contact
- "Ohodnotit aplikaci" (fa-star, yellow)

### App Info ("O aplikaci")
- Version: "1.2.5 (Build 125)" (non-clickable)
- "Podmínky použití" (fa-shield-halved, gray)
- "Ochrana soukromí" (fa-user-shield, gray)

### Danger Zone ("Nebezpečná zóna")
- "Odhlásit se" (fa-right-from-bracket, red text)
- "Smazat účet" (fa-trash, red text)
Both hover:bg-red-500/10.

### Bottom Navigation
"Profil" tab active.

---

## 6. Profile Edit Page
**File**: `.design/profile-edit.html`
**Title**: Upravit profil

### Purpose
Edit user profile information, preferences, and notification settings.

### Header
Back button, "Upravit profil" title, save checkmark button (bg-app-primary rounded-full).

### Profile Photo
Centered: w-24 h-24 rounded-full avatar with camera overlay button (absolute bottom-0 right-0, w-8 h-8 bg-app-primary). "Změnit fotku" link below.

### Personal Info ("Osobní údaje")
Input fields in bg-app-surface border rounded-xl p-4 cards:
- Jméno a příjmení (text input, value "Tereza Nováková")
- E-mail (email input)
- Telefon (tel input, "+420 123 456 789")
- Město (text input, "Praha")
Labels: text-xs font-medium text-app-muted mb-2. Inputs: bg-transparent, no border, font-medium.

### Bio ("O mně")
Textarea (rows=3) in card, placeholder "Napište něco o sobě..."

### Dance Preferences ("Oblíbené tance")
2-column grid of checkboxes: Salsa ✓, Bachata ✓, Zouk ✓, Kizomba, Tango, Swing. Custom checkbox: w-5 h-5 border-2 rounded, checked: bg-app-primary.

### Experience Level ("Úroveň")
Radio buttons: Začátečník, Mírně pokročilý (selected), Pokročilý, Expert. Custom radio: w-4 h-4 border-2 rounded-full.

### Social Links ("Sociální sítě")
- Instagram (fa-brands fa-instagram) placeholder "@vase_uzivatelske_jmeno"
- Facebook (fa-brands fa-facebook) placeholder "facebook.com/vase.jmeno"

### Notifications ("Oznámení")
Toggle switches for: Nové akce (on), Připomínky akcí (on), Marketingové zprávy (off). Toggle: w-11 h-6 rounded-full, checked: bg-app-primary.

### Save Button
Fixed above bottom nav: "Uložit změny", full-width bg-app-primary py-4 rounded-xl.

### Bottom Navigation
"Profil" tab active.

---

## 7. Change Password Page
**File**: `.design/change-password.html`
**Title**: Změnit heslo

### Purpose
Change account password with strength indicator and validation.

### Header
Back button, "Změnit heslo" title, empty right spacer.

### Security Info Banner
Gradient card (from-orange-500/10, border-orange-500/30): shield icon (orange), title "Zabezpečte svůj účet", password requirements description.

### Password Form
Three password fields, each with:
- Label (text-sm font-medium)
- Input: bg-app-surface border rounded-xl px-4 py-3.5, with eye toggle button
- Fields: Současné heslo, Nové heslo, Potvrdit nové heslo

### Password Strength Indicator
4 bars (h-1.5 flex-1 rounded-full), colors change: red → orange → yellow → green. Text label below.

### Match Validation
"Hesla se neshodují" error in text-red-500 text-xs.

### Buttons
- "Uložit nové heslo" (fa-check): bg-app-primary, shadow-lg, active:scale-[0.98]
- "Zrušit": bg-app-surface border

### Password Requirements
Checklist with fa-circle-check icons: min 8 chars, uppercase, lowercase, number, special char.

### Forgot Password Link
"Zapomněli jste heslo?" (fa-question-circle, text-app-primary)

---

## 8. Premium Page
**File**: `.design/premium-page.html`
**Title**: Dancee Premium

### Purpose
Premium subscription upsell page with plans, features, testimonials, and FAQ.

### Header
Back button, "Dancee Premium" title in gradient text (blue→purple→pink).

### Hero Section
Large crown icon (w-24 h-24 rounded-full gradient bg, shadow-glow-lg), "Odemkněte plný potenciál" in gradient text (text-3xl font-bold), subtitle.

### Subscription Plans
**Yearly** (premium-card with gradient bg + border):
- "POPULÁRNÍ" badge (absolute top-right, gradient bg)
- "Roční předplatné", "Nejlepší hodnota"
- Price: "499 Kč" gradient text (text-4xl font-bold), strikethrough "999 Kč"
- "Pouze 42 Kč/měsíc · Ušetříte 50%"
- CTA: gradient button, shadow-glow

**Monthly** (bg-app-surface border):
- "Měsíční předplatné", "Flexibilní možnost"
- Price: "99 Kč" (text-4xl font-bold)
- CTA: bg-app-card border button

### Features List ("Co získáte s Premium")
8 feature cards, each with gradient check icon (w-8 h-8 rounded-lg):
Neomezené oblíbené akce, Pokročilé filtry, Upozornění na nové akce, Offline režim, Prioritní podpora, Žádné reklamy, Exkluzivní odznaky, Kalendářová integrace.

### Testimonials ("Co říkají naši uživatelé")
Cards with avatar (w-10 h-10 rounded-full), name, 5 yellow stars, quote text.

### FAQ ("Časté otázky")
Expandable `<details>` elements: Zrušení, Platební metody, Zkušební období, Data po zrušení.

### Final CTA
Gradient card with sparkles icon, "Připraveni začít?", gradient CTA button, "7 dní zdarma · Zrušte kdykoliv".

### Bottom Navigation
Standard, no tab active.

---

## 9. Auth — Login Page
**File**: `.design/auth-login.html`
**Title**: Login

### Purpose
User login screen with email/password and social login options.

### Background
Animated floating blurred circles (blue, purple, green) with floating-animation keyframes.

### Header Section
- App icon: w-20 h-20 gradient rounded-2xl with fa-user-music, shadow-glow
- "Dancee" in gradient text (text-4xl font-bold)
- "Objevuj taneční svět" subtitle
- "Vítej zpět!" (text-2xl font-bold)

### Login Form
- Email input: h-14 pl-12 rounded-2xl, fa-envelope icon
- Password input: h-14 pl-12 pr-12 rounded-2xl, fa-lock icon, eye toggle
- "Zůstat přihlášen" checkbox + "Zapomenuté heslo?" link
- Submit: h-14 gradient button (from-app-primary to-app-accent), shadow-glow, font-bold rounded-2xl

### Social Login
Divider "nebo pokračuj s", then:
- Google button (fa-brands fa-google, red-500)
- Apple button (fa-brands fa-apple)
Both: h-14 bg-app-surface border rounded-2xl

### Footer
"Nemáš ještě účet? Zaregistruj se" link. Terms/Privacy links below divider.

### No Bottom Navigation (auth flow)

---

## 10. Auth — Registration Page
**File**: `.design/auth-registration.html`
**Title**: Registrace

### Purpose
New user registration with form validation and password strength.

### Background
Same floating circles animation as login.

### Header
Smaller app icon (w-16 h-16), "Dancee" gradient, "Vytvoř si účet" title.

### Registration Form
Fields (h-12 pl-11 rounded-xl):
- Jméno (fa-user icon)
- Příjmení (fa-user icon)
- E-mail (fa-envelope icon)
- Heslo (fa-lock + eye toggle) with 4-bar strength indicator
- Potvrzení hesla (fa-lock + eye toggle) with match validation

### Checkboxes
- Terms agreement (required): links to Podmínky používání + Zásady ochrany
- Newsletter opt-in: "Chci dostávat novinky o tanečních akcích"

### Submit
h-12 gradient button "Vytvořit účet"

### Social Registration
Same as login: Google + Apple buttons.

### Footer
"Už máš účet? Přihlaš se" link.

### No Bottom Navigation

---

## 11. Auth — Forgot Password Page
**File**: `.design/auth-password.html`
**Title**: Zapomenuté heslo

### Purpose
Password reset request via email.

### Background
Same floating circles.

### Header
Back button (w-11 h-11 rounded-xl bg-app-surface border).

### Content
- Key icon (w-20 h-20 gradient rounded-2xl, fa-key)
- "Dancee" gradient text
- "Zapomenuté heslo?" (text-2xl font-bold)
- Description text

### Form
- Email input (h-14 rounded-2xl)
- Submit: "Odeslat odkaz" gradient button

### Info Card
bg-app-surface border rounded-2xl: info icon + "Zkontroluj svou e-mailovou schránku" + 24h validity note.

### Links
"Vzpomněl sis na heslo? Přihlásit se"

### Help Section
Divider "Potřebuješ pomoc?", two buttons side by side:
- "Podpora" (fa-headset, primary)
- "FAQ" (fa-circle-question, accent)

### No Bottom Navigation

---

## 12. Auth — Onboarding Page
**File**: `.design/auth-onboarding.html`
**Title**: Onboarding

### Purpose
3-step post-registration onboarding wizard to personalize the experience.

### Background
Same floating circles.

### Header
App icon (w-16 h-16), "Přeskočit" button (top-right).

### Step Indicators
3 bars (h-1.5 flex-1 rounded-full). Active: gradient bg (blue→purple). Inactive: bg-app-border.

### Step 1 — Dance Preferences ("Jaké tance tě baví?")
2-column grid of selectable cards (h-24 rounded-2xl):
Salsa (fa-fire), Bachata (fa-heart), Zouk (fa-water), Kizomba (fa-moon), Tango (fa-rose), Swing (fa-music), Hip Hop (fa-bolt), Jiné (fa-star).
Selected: border-app-primary bg-app-primary/10.
"Pokračovat" gradient button.

### Step 2 — Experience Level ("Jaká je tvoje úroveň?")
Radio cards (rounded-2xl p-5):
- Začátečník (fa-seedling, green)
- Mírně pokročilý (fa-chart-line, primary)
- Pokročilý (fa-fire, accent)
- Expert (fa-crown, yellow)
"Zpět" + "Pokračovat" buttons.

### Step 3 — Location ("Kde se nacházíš?")
- City text input (fa-location-dot)
- Radius radio options: 10km, 25km (default), 50km, Celá republika
- "Použít aktuální polohu" button (fa-location-crosshairs)
"Zpět" + "Dokončit" buttons.

### No Bottom Navigation

---

## 13. Courses List Page
**File**: `.design/courses.html`
**Title**: Kurzy

### Purpose
Browse and discover dance courses/classes.

### Header
"Taneční kurzy" (text-2xl font-bold), "Najdi svůj kurz" subtitle, filter button (fa-sliders).

### Dance Styles Filter
Same horizontal scrollable pills as events list.

### Featured Courses Slider ("Doporučené kurzy")
Horizontal scrollable cards (w-[280px] rounded-[20px]):
- Image h-[140px] with gradient overlay
- Level badge (top-left): "Začátečníci" (bg-app-primary), "Pokročilí" (bg-app-accent)
- Title (font-bold text-lg line-clamp-2)
- Instructor (fa-user-tie icon)
- Date range (fa-calendar icon)
- Dance style tag + price (text-sm font-bold)

### All Courses List ("Všechny kurzy")
Cards (bg-app-surface border rounded-[16px] p-4):
- Title + instructor on left, small thumbnail (w-16 h-16 rounded-lg) on right
- Date range below
- Dance style tag + price at bottom

### Bottom Navigation
Different from events: center FAB has fa-graduation-cap, "Kurzy" tab (fa-book-open) is active. No heart/Uložené tab.

---

## 14. Course Detail Page
**File**: `.design/course-detail.html`
**Title**: Detail kurzu

### Purpose
Detailed view of a single dance course with instructor info and registration.

### Header
Back button, "Detail kurzu" title, ellipsis menu.

### Hero Image
h-64, price badge (top-right), level badge (top-left, bg-app-surface/90 border).

### Course Title & Style Tags
text-2xl font-bold, rounded-full style chips.

### Key Info Card
4 rows: Calendar (date range + schedule), Location (venue + address), Instructor (name + title), Price (amount + "Za celý kurz").

### Description ("Popis kurzu")
Multiple paragraphs, text-sm text-app-muted.

### Course Details ("Podrobnosti kurzu")
Key-value card: Délka kurzu (15 lekcí), Délka lekce (90 minut), Max počet (20 osob), Úroveň (Začátečníci), Věková skupina (18+).

### Instructor Section ("O lektorovi")
Card with avatar (w-16 h-16 rounded-full), name, bio, stats (10+ let zkušeností, 500+ studentů in text-app-primary).

### What You'll Learn ("Co se naučíte")
Checklist with fa-check text-app-success icons.

### Registration CTA
Highlighted card (bg-app-primary/10 border-app-primary/30):
- Price (text-2xl font-bold text-app-primary)
- Available spots (12/20, text-app-success)
- "Registrovat se na kurz" button (fa-user-plus, bg-app-primary shadow-glow)

### Additional Actions
2-column grid: "Sdílet kurz" + "Původní zdroj" buttons.

### Bottom Navigation
Same as courses list (graduation-cap FAB, Kurzy active).

---

## 15. Author Contact Page
**File**: `.design/author-contact.html`
**Title**: Napsat autorovi

### Purpose
Contact form to send feedback, bug reports, or feature requests to the app team.

### Header
Back button, "Napsat autorovi" title, empty right spacer.

### Author Info Card
Avatar circle (gradient bg, fa-user), "Tým Dancee", "hello@dancee.app", description text.

### Contact Form
- **Subject radio buttons** (4 options in cards):
  - Zpětná vazba (fa-comment, blue)
  - Nahlásit problém (fa-bug, red)
  - Návrh na vylepšení (fa-lightbulb, yellow)
  - Ostatní (fa-question, muted)
- **Message title** text input
- **Message** textarea (rows=6)
- **Device info** card (auto-attached): App version, Device, OS
- **Email** input (pre-filled)
- **Submit** button: bg-app-primary, fa-paper-plane, "Odeslat zprávu". Loading state → success state animation.

### Response Time Info
Blue info card (bg-blue-500/10 border-blue-500/20): "Obvykle odpovídáme do 24 hodin v pracovní dny."

### No Bottom Navigation

---

## Navigation Map

| From | To | Trigger |
|---|---|---|
| Events List | Event Detail | Tap event card |
| Events List | Filter Dance | Tap "Zobrazit vše" or dance style section |
| Events List | Filter Location | Tap location selector in header |
| Events List | Profile | Bottom nav "Profil" |
| Events List | Courses | Bottom nav "Kurzy" (on courses pages) |
| Profile | Profile Edit | "Upravit profil" or edit icon |
| Profile | Change Password | "Změnit heslo" |
| Profile | Premium | "Dancee Premium" card |
| Profile | Author Contact | "Napsat autorovi" |
| Login | Registration | "Zaregistruj se" link |
| Login | Forgot Password | "Zapomenuté heslo?" link |
| Registration | Login | "Přihlaš se" link |
| Registration | Onboarding | After successful registration |
| Forgot Password | Login | "Přihlásit se" link |
| Onboarding | Events List | After completing or skipping |
| Courses List | Course Detail | Tap course card |
