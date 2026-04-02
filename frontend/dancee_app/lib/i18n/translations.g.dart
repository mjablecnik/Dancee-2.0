/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 417 (139 per locale)
///
/// Built on 2026-04-02 at 06:44 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	cs(languageCode: 'cs', build: _TranslationsCs.build),
	es(languageCode: 'es', build: _TranslationsEs.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	// Translations
	String get appTitle => 'Dancee App';
	String get events => 'Events';
	String get favorites => 'Favorites';
	String get settings => 'Settings';
	String get searchEvents => 'Search events...';
	String get filters => 'Filters';
	String get today => 'Today';
	String get tomorrow => 'Tomorrow';
	String get thisWeek => 'This week';
	String get thisMonth => 'This month';
	String get prague => 'Prague';
	String eventsCount({required Object count}) => '${count} events';
	String get detail => 'Detail';
	String hours({required Object count}) => '${count} hours';
	String get errorLoadingEvents => 'Error Loading Events';
	String get retry => 'Retry';
	String get favoriteEvents => 'Favorite Events';
	String savedEvents({required Object count}) => '${count} saved events';
	String get all => 'All';
	String get upcomingEvents => 'Upcoming Events';
	String get pastEvents => 'Past Events';
	String get noFavoriteEvents => 'No Favorite Events';
	String get noFavoriteEventsDescription => 'You haven\'t saved any favorite events yet. Start exploring dance events and save the ones that interest you.';
	String get browseEvents => 'Browse Events';
	String get errorLoadingFavorites => 'Error Loading Favorites';
	String get dancee => 'Dancee';
	String tuesdayDate({required Object date}) => '(Tuesday ${date})';
	String wednesdayDate({required Object date}) => '(Wednesday ${date})';
	String get apiErrorNetwork => 'Connection error. Please check your internet connection.';
	String get apiErrorTimeout => 'Request timeout. Please try again.';
	String get apiErrorServer => 'Server error occurred. Please try again later.';
	String get apiErrorParsing => 'Failed to process server response.';
	String get apiErrorGeneric => 'An unexpected error occurred. Please try again.';
	late final _TranslationsEventDetailEn eventDetail = _TranslationsEventDetailEn._(_root);
	late final _TranslationsEventFiltersEn eventFilters = _TranslationsEventFiltersEn._(_root);
	late final _TranslationsAuthEn auth = _TranslationsAuthEn._(_root);
	late final _TranslationsSettingsPageEn settingsPage = _TranslationsSettingsPageEn._(_root);
	String get goHome => 'Go to Home';
	late final _TranslationsErrorsEn errors = _TranslationsErrorsEn._(_root);
}

// Path: eventDetail
class _TranslationsEventDetailEn {
	_TranslationsEventDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Event Detail';
	String get favorite => 'Favorite';
	String get map => 'Map';
	String get dancesAtEvent => 'Dances at Event';
	String get venue => 'Venue';
	String get address => 'Address';
	String get navigateToVenue => 'Navigate to Venue';
	String get organizer => 'Organizer';
	String get description => 'Description';
	String get additionalInfo => 'Additional Info';
	String get eventParts => 'Event Parts';
	String get workshop => 'Workshop';
	String get party => 'Party';
	String get openLesson => 'Open Lesson';
	String get eventNotFound => 'Event not found';
	String get eventNotFoundDescription => 'The event you are looking for could not be found.';
	String get backToEvents => 'Back to Events';
	String get addedToFavorites => 'Added to favorites';
	String get removedFromFavorites => 'Removed from favorites';
	String get favoriteError => 'Failed to update favorite';
	String get remove => 'Remove';
	String get originalSource => 'Original Source';
	String get viewOriginal => 'View original event';
}

// Path: eventFilters
class _TranslationsEventFiltersEn {
	_TranslationsEventFiltersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Filter & Sort';
	String get subtitle => 'Customize your event view';
	String get activeFilters => 'Active filters';
	String eventsShown({required Object count}) => '${count} events shown based on your criteria';
	String get danceType => 'Dance type';
	String get clear => 'Clear';
	String get location => 'Location';
	String get date => 'Date';
	String get dateFrom => 'From:';
	String get dateTo => 'To:';
	String get dateToday => 'Today';
	String get dateTomorrow => 'Tomorrow';
	String get dateThisWeek => 'This week';
	String get dateWeekend => 'Weekend';
	String get saveFilter => 'Save this filter';
	String get saveFilterDescription => 'For quick access next time';
	String get saveFilterButton => 'Save filter';
	String get datePlaceholder => 'dd.mm.yyyy';
	String get clearAll => 'Clear all';
	String get noEvents => 'No events found';
	String get noEventsMatch => 'No events match your filters';
	String showEvents({required Object count}) => 'Show ${count} events';
	String activeFilterCount({required Object count}) => '${count} active';
	String get noResults => 'No results';
	String get showMoreDances => 'Show more dances';
	String get showLessDances => 'Show less';
	String get applyFilters => 'Apply filters';
}

// Path: auth
class _TranslationsAuthEn {
	_TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get login => 'Login';
	String get loginTitle => 'Sign In';
	String get loginSubtitle => 'Welcome back to Dancee';
	String get email => 'Email';
	String get emailPlaceholder => 'your@email.com';
	String get password => 'Password';
	String get passwordPlaceholder => '••••••••';
	String get forgotPassword => 'Forgot your password?';
	String get loginButton => 'Sign In';
	String get orDivider => 'OR';
	String get continueWithGoogle => 'Continue with Google';
	String get continueWithApple => 'Continue with Apple';
	String get noAccount => 'Don\'t have an account?';
	String get register => 'Register';
	String get registerTitle => 'Create Account';
	String get registerSubtitle => 'Join the Dancee community';
	String get name => 'Name';
	String get namePlaceholder => 'Your name';
	String get registerButton => 'Register';
	String get alreadyHaveAccount => 'Already have an account?';
	String get loginLink => 'Sign In';
}

// Path: settingsPage
class _TranslationsSettingsPageEn {
	_TranslationsSettingsPageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Settings';
	String get subtitle => 'Manage your account';
	String get profile => 'Profile';
	String get profileName => 'Jan Novák';
	String get profileEmail => 'jan.novak@email.cz';
	String get editProfile => 'Edit Profile';
	String get preferences => 'Preferences';
	String get language => 'Language';
	String get languageValue => 'English';
	String get theme => 'Theme';
	String get themeValue => 'System';
	String get notifications => 'Notifications';
	String get notificationsEnabled => 'Enabled';
	String get account => 'Account';
	String get changePassword => 'Change Password';
	String get privacySettings => 'Privacy Settings';
	String get deleteAccount => 'Delete Account';
	String get deleteAccountWarning => 'This action is irreversible';
	String get appInfo => 'App Info';
	String get version => 'Version';
	String get about => 'About Dancee';
	String get termsOfService => 'Terms of Service';
	String get privacyPolicy => 'Privacy Policy';
	String get contactSupport => 'Contact Support';
}

// Path: errors
class _TranslationsErrorsEn {
	_TranslationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pageNotFound => 'Page not found';
	String get pageNotFoundDescription => 'The page you are looking for does not exist.';
	String get somethingWentWrong => 'Something went wrong';
	String get networkError => 'Connection error. Please check your internet connection.';
	String get timeoutError => 'Request timeout. Please try again.';
	String get serverError => 'Server error occurred. Please try again later.';
	String get parsingError => 'Failed to process server response.';
	String get genericError => 'An unexpected error occurred.';
	String get loadEventsError => 'Failed to load events.';
	String get loadFavoritesError => 'Failed to load favorites.';
	String get toggleFavoriteError => 'Failed to update favorite.';
}

// Path: <root>
class _TranslationsCs extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsCs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.cs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <cs>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	@override late final _TranslationsCs _root = this; // ignore: unused_field

	// Translations
	@override String get appTitle => 'Dancee Aplikace';
	@override String get events => 'Události';
	@override String get favorites => 'Oblíbené';
	@override String get settings => 'Nastavení';
	@override String get searchEvents => 'Hledat události...';
	@override String get filters => 'Filtry';
	@override String get today => 'Dnes';
	@override String get tomorrow => 'Zítra';
	@override String get thisWeek => 'Tento týden';
	@override String get thisMonth => 'Tento měsíc';
	@override String get prague => 'Praha';
	@override String eventsCount({required Object count}) => '${count} událostí';
	@override String get detail => 'Detail';
	@override String hours({required Object count}) => '${count} hodin';
	@override String get errorLoadingEvents => 'Chyba při načítání událostí';
	@override String get retry => 'Zkusit znovu';
	@override String get favoriteEvents => 'Oblíbené události';
	@override String savedEvents({required Object count}) => '${count} uložených událostí';
	@override String get all => 'Vše';
	@override String get upcomingEvents => 'Nadcházející události';
	@override String get pastEvents => 'Minulé události';
	@override String get noFavoriteEvents => 'Žádné oblíbené události';
	@override String get noFavoriteEventsDescription => 'Zatím jste neuložili žádné oblíbené události. Začněte prozkoumávat taneční události a uložte si ty, které vás zajímají.';
	@override String get browseEvents => 'Procházet události';
	@override String get errorLoadingFavorites => 'Chyba při načítání oblíbených';
	@override String get dancee => 'Dancee';
	@override String tuesdayDate({required Object date}) => '(Úterý ${date})';
	@override String wednesdayDate({required Object date}) => '(Středa ${date})';
	@override String get apiErrorNetwork => 'Chyba připojení. Zkontrolujte prosím své internetové připojení.';
	@override String get apiErrorTimeout => 'Vypršel časový limit požadavku. Zkuste to prosím znovu.';
	@override String get apiErrorServer => 'Došlo k chybě serveru. Zkuste to prosím později.';
	@override String get apiErrorParsing => 'Nepodařilo se zpracovat odpověď serveru.';
	@override String get apiErrorGeneric => 'Došlo k neočekávané chybě. Zkuste to prosím znovu.';
	@override late final _TranslationsEventDetailCs eventDetail = _TranslationsEventDetailCs._(_root);
	@override late final _TranslationsEventFiltersCs eventFilters = _TranslationsEventFiltersCs._(_root);
	@override late final _TranslationsAuthCs auth = _TranslationsAuthCs._(_root);
	@override late final _TranslationsSettingsPageCs settingsPage = _TranslationsSettingsPageCs._(_root);
	@override String get goHome => 'Přejít na hlavní stránku';
	@override late final _TranslationsErrorsCs errors = _TranslationsErrorsCs._(_root);
}

// Path: eventDetail
class _TranslationsEventDetailCs extends _TranslationsEventDetailEn {
	_TranslationsEventDetailCs._(_TranslationsCs root) : this._root = root, super._(root);

	@override final _TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Detail akce';
	@override String get favorite => 'Oblíbené';
	@override String get map => 'Mapa';
	@override String get dancesAtEvent => 'Tance na akci';
	@override String get venue => 'Místo konání';
	@override String get address => 'Adresa';
	@override String get navigateToVenue => 'Navigovat k místu';
	@override String get organizer => 'Pořadatel';
	@override String get description => 'Popis akce';
	@override String get additionalInfo => 'Dodatečné informace';
	@override String get eventParts => 'Program akce';
	@override String get workshop => 'Workshop';
	@override String get party => 'Párty';
	@override String get openLesson => 'Otevřená lekce';
	@override String get eventNotFound => 'Akce nenalezena';
	@override String get eventNotFoundDescription => 'Akce, kterou hledáte, nebyla nalezena.';
	@override String get backToEvents => 'Zpět na události';
	@override String get addedToFavorites => 'Přidáno do oblíbených';
	@override String get removedFromFavorites => 'Odebráno z oblíbených';
	@override String get favoriteError => 'Nepodařilo se aktualizovat oblíbené';
	@override String get remove => 'Odebrat';
	@override String get originalSource => 'Původní zdroj';
	@override String get viewOriginal => 'Zobrazit původní událost';
}

// Path: eventFilters
class _TranslationsEventFiltersCs extends _TranslationsEventFiltersEn {
	_TranslationsEventFiltersCs._(_TranslationsCs root) : this._root = root, super._(root);

	@override final _TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filtrování & Řazení';
	@override String get subtitle => 'Přizpůsobte si zobrazení akcí';
	@override String get activeFilters => 'Aktivní filtry';
	@override String eventsShown({required Object count}) => '${count} akcí podle vašich kritérií';
	@override String get danceType => 'Typ tance';
	@override String get clear => 'Zrušit';
	@override String get location => 'Místo konání';
	@override String get date => 'Datum';
	@override String get dateFrom => 'Od:';
	@override String get dateTo => 'Do:';
	@override String get dateToday => 'Dnes';
	@override String get dateTomorrow => 'Zítra';
	@override String get dateThisWeek => 'Tento týden';
	@override String get dateWeekend => 'Víkend';
	@override String get saveFilter => 'Uložit toto filtrování';
	@override String get saveFilterDescription => 'Pro rychlý přístup příště';
	@override String get saveFilterButton => 'Uložit filtr';
	@override String get datePlaceholder => 'dd.mm.yyyy';
	@override String get clearAll => 'Vymazat vše';
	@override String get noEvents => 'Žádné akce nebyly nalezeny';
	@override String get noEventsMatch => 'Žádné akce neodpovídají vašim filtrům';
	@override String showEvents({required Object count}) => 'Zobrazit ${count} akcí';
	@override String activeFilterCount({required Object count}) => '${count} aktivní';
	@override String get noResults => 'Žádné výsledky';
	@override String get showMoreDances => 'Zobrazit další tance';
	@override String get showLessDances => 'Zobrazit méně';
	@override String get applyFilters => 'Použít filtry';
}

// Path: auth
class _TranslationsAuthCs extends _TranslationsAuthEn {
	_TranslationsAuthCs._(_TranslationsCs root) : this._root = root, super._(root);

	@override final _TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get login => 'Přihlášení';
	@override String get loginTitle => 'Přihlášení';
	@override String get loginSubtitle => 'Vítejte zpět v Dancee';
	@override String get email => 'E-mail';
	@override String get emailPlaceholder => 'vas@email.cz';
	@override String get password => 'Heslo';
	@override String get passwordPlaceholder => '••••••••';
	@override String get forgotPassword => 'Zapomněli jste heslo?';
	@override String get loginButton => 'Přihlásit se';
	@override String get orDivider => 'NEBO';
	@override String get continueWithGoogle => 'Pokračovat s Google';
	@override String get continueWithApple => 'Pokračovat s Apple';
	@override String get noAccount => 'Nemáte účet?';
	@override String get register => 'Zaregistrujte se';
	@override String get registerTitle => 'Vytvořit účet';
	@override String get registerSubtitle => 'Připojte se ke komunitě Dancee';
	@override String get name => 'Jméno';
	@override String get namePlaceholder => 'Vaše jméno';
	@override String get registerButton => 'Zaregistrovat se';
	@override String get alreadyHaveAccount => 'Již máte účet?';
	@override String get loginLink => 'Přihlásit se';
}

// Path: settingsPage
class _TranslationsSettingsPageCs extends _TranslationsSettingsPageEn {
	_TranslationsSettingsPageCs._(_TranslationsCs root) : this._root = root, super._(root);

	@override final _TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nastavení';
	@override String get subtitle => 'Správa vašeho účtu';
	@override String get profile => 'Profil';
	@override String get profileName => 'Jan Novák';
	@override String get profileEmail => 'jan.novak@email.cz';
	@override String get editProfile => 'Upravit profil';
	@override String get preferences => 'Předvolby';
	@override String get language => 'Jazyk';
	@override String get languageValue => 'Čeština';
	@override String get theme => 'Motiv';
	@override String get themeValue => 'Systémový';
	@override String get notifications => 'Oznámení';
	@override String get notificationsEnabled => 'Zapnuto';
	@override String get account => 'Účet';
	@override String get changePassword => 'Změnit heslo';
	@override String get privacySettings => 'Nastavení soukromí';
	@override String get deleteAccount => 'Smazat účet';
	@override String get deleteAccountWarning => 'Tato akce je nevratná';
	@override String get appInfo => 'O aplikaci';
	@override String get version => 'Verze';
	@override String get about => 'O Dancee';
	@override String get termsOfService => 'Podmínky služby';
	@override String get privacyPolicy => 'Zásady ochrany osobních údajů';
	@override String get contactSupport => 'Kontaktovat podporu';
}

// Path: errors
class _TranslationsErrorsCs extends _TranslationsErrorsEn {
	_TranslationsErrorsCs._(_TranslationsCs root) : this._root = root, super._(root);

	@override final _TranslationsCs _root; // ignore: unused_field

	// Translations
	@override String get pageNotFound => 'Stránka nenalezena';
	@override String get pageNotFoundDescription => 'Stránka, kterou hledáte, neexistuje.';
	@override String get somethingWentWrong => 'Něco se pokazilo';
	@override String get networkError => 'Chyba připojení. Zkontrolujte prosím své internetové připojení.';
	@override String get timeoutError => 'Vypršel časový limit požadavku. Zkuste to prosím znovu.';
	@override String get serverError => 'Došlo k chybě serveru. Zkuste to prosím později.';
	@override String get parsingError => 'Nepodařilo se zpracovat odpověď serveru.';
	@override String get genericError => 'Došlo k neočekávané chybě.';
	@override String get loadEventsError => 'Nepodařilo se načíst události.';
	@override String get loadFavoritesError => 'Nepodařilo se načíst oblíbené.';
	@override String get toggleFavoriteError => 'Nepodařilo se aktualizovat oblíbené.';
}

// Path: <root>
class _TranslationsEs extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsEs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	@override late final _TranslationsEs _root = this; // ignore: unused_field

	// Translations
	@override String get appTitle => 'Aplicación Dancee';
	@override String get events => 'Eventos';
	@override String get favorites => 'Favoritos';
	@override String get settings => 'Configuración';
	@override String get searchEvents => 'Buscar eventos...';
	@override String get filters => 'Filtros';
	@override String get today => 'Hoy';
	@override String get tomorrow => 'Mañana';
	@override String get thisWeek => 'Esta semana';
	@override String get thisMonth => 'Este mes';
	@override String get prague => 'Praga';
	@override String eventsCount({required Object count}) => '${count} eventos';
	@override String get detail => 'Detalle';
	@override String hours({required Object count}) => '${count} horas';
	@override String get errorLoadingEvents => 'Error al cargar eventos';
	@override String get retry => 'Reintentar';
	@override String get favoriteEvents => 'Eventos favoritos';
	@override String savedEvents({required Object count}) => '${count} eventos guardados';
	@override String get all => 'Todos';
	@override String get upcomingEvents => 'Próximos eventos';
	@override String get pastEvents => 'Eventos pasados';
	@override String get noFavoriteEvents => 'Sin eventos favoritos';
	@override String get noFavoriteEventsDescription => 'Aún no has guardado ningún evento favorito. Comienza a explorar eventos de baile y guarda los que te interesen.';
	@override String get browseEvents => 'Explorar eventos';
	@override String get errorLoadingFavorites => 'Error al cargar favoritos';
	@override String get dancee => 'Dancee';
	@override String tuesdayDate({required Object date}) => '(Martes ${date})';
	@override String wednesdayDate({required Object date}) => '(Miércoles ${date})';
	@override String get apiErrorNetwork => 'Error de conexión. Por favor, verifica tu conexión a internet.';
	@override String get apiErrorTimeout => 'Tiempo de espera agotado. Por favor, inténtalo de nuevo.';
	@override String get apiErrorServer => 'Error del servidor. Por favor, inténtalo más tarde.';
	@override String get apiErrorParsing => 'Error al procesar la respuesta del servidor.';
	@override String get apiErrorGeneric => 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
	@override late final _TranslationsEventDetailEs eventDetail = _TranslationsEventDetailEs._(_root);
	@override late final _TranslationsEventFiltersEs eventFilters = _TranslationsEventFiltersEs._(_root);
	@override late final _TranslationsAuthEs auth = _TranslationsAuthEs._(_root);
	@override late final _TranslationsSettingsPageEs settingsPage = _TranslationsSettingsPageEs._(_root);
	@override String get goHome => 'Ir al inicio';
	@override late final _TranslationsErrorsEs errors = _TranslationsErrorsEs._(_root);
}

// Path: eventDetail
class _TranslationsEventDetailEs extends _TranslationsEventDetailEn {
	_TranslationsEventDetailEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Detalle del Evento';
	@override String get favorite => 'Favorito';
	@override String get map => 'Mapa';
	@override String get dancesAtEvent => 'Bailes en el Evento';
	@override String get venue => 'Lugar';
	@override String get address => 'Dirección';
	@override String get navigateToVenue => 'Navegar al Lugar';
	@override String get organizer => 'Organizador';
	@override String get description => 'Descripción';
	@override String get additionalInfo => 'Información Adicional';
	@override String get eventParts => 'Programa del Evento';
	@override String get workshop => 'Taller';
	@override String get party => 'Fiesta';
	@override String get openLesson => 'Clase Abierta';
	@override String get eventNotFound => 'Evento no encontrado';
	@override String get eventNotFoundDescription => 'El evento que buscas no se pudo encontrar.';
	@override String get backToEvents => 'Volver a Eventos';
	@override String get addedToFavorites => 'Añadido a favoritos';
	@override String get removedFromFavorites => 'Eliminado de favoritos';
	@override String get favoriteError => 'Error al actualizar favorito';
	@override String get remove => 'Eliminar';
	@override String get originalSource => 'Fuente Original';
	@override String get viewOriginal => 'Ver evento original';
}

// Path: eventFilters
class _TranslationsEventFiltersEs extends _TranslationsEventFiltersEn {
	_TranslationsEventFiltersEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filtrar y Ordenar';
	@override String get subtitle => 'Personaliza tu vista de eventos';
	@override String get activeFilters => 'Filtros activos';
	@override String eventsShown({required Object count}) => '${count} eventos según tus criterios';
	@override String get danceType => 'Tipo de baile';
	@override String get clear => 'Limpiar';
	@override String get location => 'Ubicación';
	@override String get date => 'Fecha';
	@override String get dateFrom => 'Desde:';
	@override String get dateTo => 'Hasta:';
	@override String get dateToday => 'Hoy';
	@override String get dateTomorrow => 'Mañana';
	@override String get dateThisWeek => 'Esta semana';
	@override String get dateWeekend => 'Fin de semana';
	@override String get saveFilter => 'Guardar este filtro';
	@override String get saveFilterDescription => 'Para acceso rápido la próxima vez';
	@override String get saveFilterButton => 'Guardar filtro';
	@override String get datePlaceholder => 'dd.mm.yyyy';
	@override String get clearAll => 'Limpiar todo';
	@override String get noEvents => 'No se encontraron eventos';
	@override String get noEventsMatch => 'Ningún evento coincide con tus filtros';
	@override String showEvents({required Object count}) => 'Mostrar ${count} eventos';
	@override String activeFilterCount({required Object count}) => '${count} activo';
	@override String get noResults => 'Sin resultados';
	@override String get showMoreDances => 'Mostrar más bailes';
	@override String get showLessDances => 'Mostrar menos';
	@override String get applyFilters => 'Aplicar filtros';
}

// Path: auth
class _TranslationsAuthEs extends _TranslationsAuthEn {
	_TranslationsAuthEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get login => 'Iniciar sesión';
	@override String get loginTitle => 'Iniciar sesión';
	@override String get loginSubtitle => 'Bienvenido de vuelta a Dancee';
	@override String get email => 'Correo electrónico';
	@override String get emailPlaceholder => 'tu@email.com';
	@override String get password => 'Contraseña';
	@override String get passwordPlaceholder => '••••••••';
	@override String get forgotPassword => '¿Olvidaste tu contraseña?';
	@override String get loginButton => 'Iniciar sesión';
	@override String get orDivider => 'O';
	@override String get continueWithGoogle => 'Continuar con Google';
	@override String get continueWithApple => 'Continuar con Apple';
	@override String get noAccount => '¿No tienes cuenta?';
	@override String get register => 'Regístrate';
	@override String get registerTitle => 'Crear cuenta';
	@override String get registerSubtitle => 'Únete a la comunidad Dancee';
	@override String get name => 'Nombre';
	@override String get namePlaceholder => 'Tu nombre';
	@override String get registerButton => 'Registrarse';
	@override String get alreadyHaveAccount => '¿Ya tienes cuenta?';
	@override String get loginLink => 'Iniciar sesión';
}

// Path: settingsPage
class _TranslationsSettingsPageEs extends _TranslationsSettingsPageEn {
	_TranslationsSettingsPageEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configuración';
	@override String get subtitle => 'Administra tu cuenta';
	@override String get profile => 'Perfil';
	@override String get profileName => 'Jan Novák';
	@override String get profileEmail => 'jan.novak@email.cz';
	@override String get editProfile => 'Editar perfil';
	@override String get preferences => 'Preferencias';
	@override String get language => 'Idioma';
	@override String get languageValue => 'Español';
	@override String get theme => 'Tema';
	@override String get themeValue => 'Sistema';
	@override String get notifications => 'Notificaciones';
	@override String get notificationsEnabled => 'Activadas';
	@override String get account => 'Cuenta';
	@override String get changePassword => 'Cambiar contraseña';
	@override String get privacySettings => 'Configuración de privacidad';
	@override String get deleteAccount => 'Eliminar cuenta';
	@override String get deleteAccountWarning => 'Esta acción es irreversible';
	@override String get appInfo => 'Información de la app';
	@override String get version => 'Versión';
	@override String get about => 'Acerca de Dancee';
	@override String get termsOfService => 'Términos de servicio';
	@override String get privacyPolicy => 'Política de privacidad';
	@override String get contactSupport => 'Contactar soporte';
}

// Path: errors
class _TranslationsErrorsEs extends _TranslationsErrorsEn {
	_TranslationsErrorsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pageNotFound => 'Página no encontrada';
	@override String get pageNotFoundDescription => 'La página que buscas no existe.';
	@override String get somethingWentWrong => 'Algo salió mal';
	@override String get networkError => 'Error de conexión. Por favor, verifica tu conexión a internet.';
	@override String get timeoutError => 'Tiempo de espera agotado. Por favor, inténtalo de nuevo.';
	@override String get serverError => 'Error del servidor. Por favor, inténtalo más tarde.';
	@override String get parsingError => 'Error al procesar la respuesta del servidor.';
	@override String get genericError => 'Ocurrió un error inesperado.';
	@override String get loadEventsError => 'Error al cargar eventos.';
	@override String get loadFavoritesError => 'Error al cargar favoritos.';
	@override String get toggleFavoriteError => 'Error al actualizar favorito.';
}
