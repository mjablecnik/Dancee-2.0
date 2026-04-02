/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 414 (138 per locale)
///
/// Built on 2026-04-02 at 06:25 UTC

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
	cs(languageCode: 'cs', build: _StringsCs.build),
	es(languageCode: 'es', build: _StringsEs.build);

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
/// String b = t['someKey.anotherKey']; // Only for edge cases!
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
/// String b = t['someKey.anotherKey']; // Only for edge cases!
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
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

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
	String get eventsCount => '{count} events';
	String get detail => 'Detail';
	String get hours => '{count} hours';
	String get errorLoadingEvents => 'Error Loading Events';
	String get retry => 'Retry';
	String get favoriteEvents => 'Favorite Events';
	String get savedEvents => '{count} saved events';
	String get all => 'All';
	String get upcomingEvents => 'Upcoming Events';
	String get pastEvents => 'Past Events';
	String get noFavoriteEvents => 'No Favorite Events';
	String get noFavoriteEventsDescription => 'You haven\'t saved any favorite events yet. Start exploring dance events and save the ones that interest you.';
	String get browseEvents => 'Browse Events';
	String get errorLoadingFavorites => 'Error Loading Favorites';
	String get dancee => 'Dancee';
	String get tuesdayDate => '(Tuesday {date})';
	String get wednesdayDate => '(Wednesday {date})';
	String get apiErrorNetwork => 'Connection error. Please check your internet connection.';
	String get apiErrorTimeout => 'Request timeout. Please try again.';
	String get apiErrorServer => 'Server error occurred. Please try again later.';
	String get apiErrorParsing => 'Failed to process server response.';
	String get apiErrorGeneric => 'An unexpected error occurred. Please try again.';
	late final _StringsEventDetailEn eventDetail = _StringsEventDetailEn._(_root);
	late final _StringsEventFiltersEn eventFilters = _StringsEventFiltersEn._(_root);
	late final _StringsAuthEn auth = _StringsAuthEn._(_root);
	late final _StringsSettingsPageEn settingsPage = _StringsSettingsPageEn._(_root);
	String get goHome => 'Go to Home';
	late final _StringsErrorsEn errors = _StringsErrorsEn._(_root);
}

// Path: eventDetail
class _StringsEventDetailEn {
	_StringsEventDetailEn._(this._root);

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
class _StringsEventFiltersEn {
	_StringsEventFiltersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Filter & Sort';
	String get subtitle => 'Customize your event view';
	String get activeFilters => 'Active filters';
	String get eventsShown => '{count} events shown based on your criteria';
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
	String get noEventsMatch => 'No events match your filters';
	String get showEvents => 'Show {count} events';
	String get activeFilterCount => '{count} active';
	String get noResults => 'No results';
	String get showMoreDances => 'Show more dances';
	String get showLessDances => 'Show less';
	String get applyFilters => 'Apply filters';
}

// Path: auth
class _StringsAuthEn {
	_StringsAuthEn._(this._root);

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
class _StringsSettingsPageEn {
	_StringsSettingsPageEn._(this._root);

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
class _StringsErrorsEn {
	_StringsErrorsEn._(this._root);

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
class _StringsCs implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsCs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.cs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <cs>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsCs _root = this; // ignore: unused_field

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
	@override String get eventsCount => '{count} událostí';
	@override String get detail => 'Detail';
	@override String get hours => '{count} hodin';
	@override String get errorLoadingEvents => 'Chyba při načítání událostí';
	@override String get retry => 'Zkusit znovu';
	@override String get favoriteEvents => 'Oblíbené události';
	@override String get savedEvents => '{count} uložených událostí';
	@override String get all => 'Vše';
	@override String get upcomingEvents => 'Nadcházející události';
	@override String get pastEvents => 'Minulé události';
	@override String get noFavoriteEvents => 'Žádné oblíbené události';
	@override String get noFavoriteEventsDescription => 'Zatím jste neuložili žádné oblíbené události. Začněte prozkoumávat taneční události a uložte si ty, které vás zajímají.';
	@override String get browseEvents => 'Procházet události';
	@override String get errorLoadingFavorites => 'Chyba při načítání oblíbených';
	@override String get dancee => 'Dancee';
	@override String get tuesdayDate => '(Úterý {date})';
	@override String get wednesdayDate => '(Středa {date})';
	@override String get apiErrorNetwork => 'Chyba připojení. Zkontrolujte prosím své internetové připojení.';
	@override String get apiErrorTimeout => 'Vypršel časový limit požadavku. Zkuste to prosím znovu.';
	@override String get apiErrorServer => 'Došlo k chybě serveru. Zkuste to prosím později.';
	@override String get apiErrorParsing => 'Nepodařilo se zpracovat odpověď serveru.';
	@override String get apiErrorGeneric => 'Došlo k neočekávané chybě. Zkuste to prosím znovu.';
	@override late final _StringsEventDetailCs eventDetail = _StringsEventDetailCs._(_root);
	@override late final _StringsEventFiltersCs eventFilters = _StringsEventFiltersCs._(_root);
	@override late final _StringsAuthCs auth = _StringsAuthCs._(_root);
	@override late final _StringsSettingsPageCs settingsPage = _StringsSettingsPageCs._(_root);
	@override String get goHome => 'Přejít na hlavní stránku';
	@override late final _StringsErrorsCs errors = _StringsErrorsCs._(_root);
}

// Path: eventDetail
class _StringsEventDetailCs implements _StringsEventDetailEn {
	_StringsEventDetailCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

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
class _StringsEventFiltersCs implements _StringsEventFiltersEn {
	_StringsEventFiltersCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filtrování & Řazení';
	@override String get subtitle => 'Přizpůsobte si zobrazení akcí';
	@override String get activeFilters => 'Aktivní filtry';
	@override String get eventsShown => '{count} akcí podle vašich kritérií';
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
	@override String get noEventsMatch => 'Žádné akce neodpovídají vašim filtrům';
	@override String get showEvents => 'Zobrazit {count} akcí';
	@override String get activeFilterCount => '{count} aktivní';
	@override String get noResults => 'Žádné výsledky';
	@override String get showMoreDances => 'Zobrazit další tance';
	@override String get showLessDances => 'Zobrazit méně';
	@override String get applyFilters => 'Použít filtry';
}

// Path: auth
class _StringsAuthCs implements _StringsAuthEn {
	_StringsAuthCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

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
class _StringsSettingsPageCs implements _StringsSettingsPageEn {
	_StringsSettingsPageCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

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
class _StringsErrorsCs implements _StringsErrorsEn {
	_StringsErrorsCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

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
class _StringsEs implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsEs _root = this; // ignore: unused_field

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
	@override String get eventsCount => '{count} eventos';
	@override String get detail => 'Detalle';
	@override String get hours => '{count} horas';
	@override String get errorLoadingEvents => 'Error al cargar eventos';
	@override String get retry => 'Reintentar';
	@override String get favoriteEvents => 'Eventos favoritos';
	@override String get savedEvents => '{count} eventos guardados';
	@override String get all => 'Todos';
	@override String get upcomingEvents => 'Próximos eventos';
	@override String get pastEvents => 'Eventos pasados';
	@override String get noFavoriteEvents => 'Sin eventos favoritos';
	@override String get noFavoriteEventsDescription => 'Aún no has guardado ningún evento favorito. Comienza a explorar eventos de baile y guarda los que te interesen.';
	@override String get browseEvents => 'Explorar eventos';
	@override String get errorLoadingFavorites => 'Error al cargar favoritos';
	@override String get dancee => 'Dancee';
	@override String get tuesdayDate => '(Martes {date})';
	@override String get wednesdayDate => '(Miércoles {date})';
	@override String get apiErrorNetwork => 'Error de conexión. Por favor, verifica tu conexión a internet.';
	@override String get apiErrorTimeout => 'Tiempo de espera agotado. Por favor, inténtalo de nuevo.';
	@override String get apiErrorServer => 'Error del servidor. Por favor, inténtalo más tarde.';
	@override String get apiErrorParsing => 'Error al procesar la respuesta del servidor.';
	@override String get apiErrorGeneric => 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
	@override late final _StringsEventDetailEs eventDetail = _StringsEventDetailEs._(_root);
	@override late final _StringsEventFiltersEs eventFilters = _StringsEventFiltersEs._(_root);
	@override late final _StringsAuthEs auth = _StringsAuthEs._(_root);
	@override late final _StringsSettingsPageEs settingsPage = _StringsSettingsPageEs._(_root);
	@override String get goHome => 'Ir al inicio';
	@override late final _StringsErrorsEs errors = _StringsErrorsEs._(_root);
}

// Path: eventDetail
class _StringsEventDetailEs implements _StringsEventDetailEn {
	_StringsEventDetailEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsEventFiltersEs implements _StringsEventFiltersEn {
	_StringsEventFiltersEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filtrar y Ordenar';
	@override String get subtitle => 'Personaliza tu vista de eventos';
	@override String get activeFilters => 'Filtros activos';
	@override String get eventsShown => '{count} eventos según tus criterios';
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
	@override String get noEventsMatch => 'Ningún evento coincide con tus filtros';
	@override String get showEvents => 'Mostrar {count} eventos';
	@override String get activeFilterCount => '{count} activo';
	@override String get noResults => 'Sin resultados';
	@override String get showMoreDances => 'Mostrar más bailes';
	@override String get showLessDances => 'Mostrar menos';
	@override String get applyFilters => 'Aplicar filtros';
}

// Path: auth
class _StringsAuthEs implements _StringsAuthEn {
	_StringsAuthEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsSettingsPageEs implements _StringsSettingsPageEn {
	_StringsSettingsPageEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

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
class _StringsErrorsEs implements _StringsErrorsEn {
	_StringsErrorsEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

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

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'appTitle': return 'Dancee App';
			case 'events': return 'Events';
			case 'favorites': return 'Favorites';
			case 'settings': return 'Settings';
			case 'searchEvents': return 'Search events...';
			case 'filters': return 'Filters';
			case 'today': return 'Today';
			case 'tomorrow': return 'Tomorrow';
			case 'thisWeek': return 'This week';
			case 'thisMonth': return 'This month';
			case 'prague': return 'Prague';
			case 'eventsCount': return '{count} events';
			case 'detail': return 'Detail';
			case 'hours': return '{count} hours';
			case 'errorLoadingEvents': return 'Error Loading Events';
			case 'retry': return 'Retry';
			case 'favoriteEvents': return 'Favorite Events';
			case 'savedEvents': return '{count} saved events';
			case 'all': return 'All';
			case 'upcomingEvents': return 'Upcoming Events';
			case 'pastEvents': return 'Past Events';
			case 'noFavoriteEvents': return 'No Favorite Events';
			case 'noFavoriteEventsDescription': return 'You haven\'t saved any favorite events yet. Start exploring dance events and save the ones that interest you.';
			case 'browseEvents': return 'Browse Events';
			case 'errorLoadingFavorites': return 'Error Loading Favorites';
			case 'dancee': return 'Dancee';
			case 'tuesdayDate': return '(Tuesday {date})';
			case 'wednesdayDate': return '(Wednesday {date})';
			case 'apiErrorNetwork': return 'Connection error. Please check your internet connection.';
			case 'apiErrorTimeout': return 'Request timeout. Please try again.';
			case 'apiErrorServer': return 'Server error occurred. Please try again later.';
			case 'apiErrorParsing': return 'Failed to process server response.';
			case 'apiErrorGeneric': return 'An unexpected error occurred. Please try again.';
			case 'eventDetail.title': return 'Event Detail';
			case 'eventDetail.favorite': return 'Favorite';
			case 'eventDetail.map': return 'Map';
			case 'eventDetail.dancesAtEvent': return 'Dances at Event';
			case 'eventDetail.venue': return 'Venue';
			case 'eventDetail.address': return 'Address';
			case 'eventDetail.navigateToVenue': return 'Navigate to Venue';
			case 'eventDetail.organizer': return 'Organizer';
			case 'eventDetail.description': return 'Description';
			case 'eventDetail.additionalInfo': return 'Additional Info';
			case 'eventDetail.eventParts': return 'Event Parts';
			case 'eventDetail.workshop': return 'Workshop';
			case 'eventDetail.party': return 'Party';
			case 'eventDetail.openLesson': return 'Open Lesson';
			case 'eventDetail.eventNotFound': return 'Event not found';
			case 'eventDetail.eventNotFoundDescription': return 'The event you are looking for could not be found.';
			case 'eventDetail.backToEvents': return 'Back to Events';
			case 'eventDetail.addedToFavorites': return 'Added to favorites';
			case 'eventDetail.removedFromFavorites': return 'Removed from favorites';
			case 'eventDetail.favoriteError': return 'Failed to update favorite';
			case 'eventDetail.remove': return 'Remove';
			case 'eventDetail.originalSource': return 'Original Source';
			case 'eventDetail.viewOriginal': return 'View original event';
			case 'eventFilters.title': return 'Filter & Sort';
			case 'eventFilters.subtitle': return 'Customize your event view';
			case 'eventFilters.activeFilters': return 'Active filters';
			case 'eventFilters.eventsShown': return '{count} events shown based on your criteria';
			case 'eventFilters.danceType': return 'Dance type';
			case 'eventFilters.clear': return 'Clear';
			case 'eventFilters.location': return 'Location';
			case 'eventFilters.date': return 'Date';
			case 'eventFilters.dateFrom': return 'From:';
			case 'eventFilters.dateTo': return 'To:';
			case 'eventFilters.dateToday': return 'Today';
			case 'eventFilters.dateTomorrow': return 'Tomorrow';
			case 'eventFilters.dateThisWeek': return 'This week';
			case 'eventFilters.dateWeekend': return 'Weekend';
			case 'eventFilters.saveFilter': return 'Save this filter';
			case 'eventFilters.saveFilterDescription': return 'For quick access next time';
			case 'eventFilters.saveFilterButton': return 'Save filter';
			case 'eventFilters.datePlaceholder': return 'dd.mm.yyyy';
			case 'eventFilters.clearAll': return 'Clear all';
			case 'eventFilters.noEventsMatch': return 'No events match your filters';
			case 'eventFilters.showEvents': return 'Show {count} events';
			case 'eventFilters.activeFilterCount': return '{count} active';
			case 'eventFilters.noResults': return 'No results';
			case 'eventFilters.showMoreDances': return 'Show more dances';
			case 'eventFilters.showLessDances': return 'Show less';
			case 'eventFilters.applyFilters': return 'Apply filters';
			case 'auth.login': return 'Login';
			case 'auth.loginTitle': return 'Sign In';
			case 'auth.loginSubtitle': return 'Welcome back to Dancee';
			case 'auth.email': return 'Email';
			case 'auth.emailPlaceholder': return 'your@email.com';
			case 'auth.password': return 'Password';
			case 'auth.passwordPlaceholder': return '••••••••';
			case 'auth.forgotPassword': return 'Forgot your password?';
			case 'auth.loginButton': return 'Sign In';
			case 'auth.orDivider': return 'OR';
			case 'auth.continueWithGoogle': return 'Continue with Google';
			case 'auth.continueWithApple': return 'Continue with Apple';
			case 'auth.noAccount': return 'Don\'t have an account?';
			case 'auth.register': return 'Register';
			case 'auth.registerTitle': return 'Create Account';
			case 'auth.registerSubtitle': return 'Join the Dancee community';
			case 'auth.name': return 'Name';
			case 'auth.namePlaceholder': return 'Your name';
			case 'auth.registerButton': return 'Register';
			case 'auth.alreadyHaveAccount': return 'Already have an account?';
			case 'auth.loginLink': return 'Sign In';
			case 'settingsPage.title': return 'Settings';
			case 'settingsPage.subtitle': return 'Manage your account';
			case 'settingsPage.profile': return 'Profile';
			case 'settingsPage.profileName': return 'Jan Novák';
			case 'settingsPage.profileEmail': return 'jan.novak@email.cz';
			case 'settingsPage.editProfile': return 'Edit Profile';
			case 'settingsPage.preferences': return 'Preferences';
			case 'settingsPage.language': return 'Language';
			case 'settingsPage.languageValue': return 'English';
			case 'settingsPage.theme': return 'Theme';
			case 'settingsPage.themeValue': return 'System';
			case 'settingsPage.notifications': return 'Notifications';
			case 'settingsPage.notificationsEnabled': return 'Enabled';
			case 'settingsPage.account': return 'Account';
			case 'settingsPage.changePassword': return 'Change Password';
			case 'settingsPage.privacySettings': return 'Privacy Settings';
			case 'settingsPage.deleteAccount': return 'Delete Account';
			case 'settingsPage.deleteAccountWarning': return 'This action is irreversible';
			case 'settingsPage.appInfo': return 'App Info';
			case 'settingsPage.version': return 'Version';
			case 'settingsPage.about': return 'About Dancee';
			case 'settingsPage.termsOfService': return 'Terms of Service';
			case 'settingsPage.privacyPolicy': return 'Privacy Policy';
			case 'settingsPage.contactSupport': return 'Contact Support';
			case 'goHome': return 'Go to Home';
			case 'errors.pageNotFound': return 'Page not found';
			case 'errors.pageNotFoundDescription': return 'The page you are looking for does not exist.';
			case 'errors.somethingWentWrong': return 'Something went wrong';
			case 'errors.networkError': return 'Connection error. Please check your internet connection.';
			case 'errors.timeoutError': return 'Request timeout. Please try again.';
			case 'errors.serverError': return 'Server error occurred. Please try again later.';
			case 'errors.parsingError': return 'Failed to process server response.';
			case 'errors.genericError': return 'An unexpected error occurred.';
			case 'errors.loadEventsError': return 'Failed to load events.';
			case 'errors.loadFavoritesError': return 'Failed to load favorites.';
			case 'errors.toggleFavoriteError': return 'Failed to update favorite.';
			default: return null;
		}
	}
}

extension on _StringsCs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'appTitle': return 'Dancee Aplikace';
			case 'events': return 'Události';
			case 'favorites': return 'Oblíbené';
			case 'settings': return 'Nastavení';
			case 'searchEvents': return 'Hledat události...';
			case 'filters': return 'Filtry';
			case 'today': return 'Dnes';
			case 'tomorrow': return 'Zítra';
			case 'thisWeek': return 'Tento týden';
			case 'thisMonth': return 'Tento měsíc';
			case 'prague': return 'Praha';
			case 'eventsCount': return '{count} událostí';
			case 'detail': return 'Detail';
			case 'hours': return '{count} hodin';
			case 'errorLoadingEvents': return 'Chyba při načítání událostí';
			case 'retry': return 'Zkusit znovu';
			case 'favoriteEvents': return 'Oblíbené události';
			case 'savedEvents': return '{count} uložených událostí';
			case 'all': return 'Vše';
			case 'upcomingEvents': return 'Nadcházející události';
			case 'pastEvents': return 'Minulé události';
			case 'noFavoriteEvents': return 'Žádné oblíbené události';
			case 'noFavoriteEventsDescription': return 'Zatím jste neuložili žádné oblíbené události. Začněte prozkoumávat taneční události a uložte si ty, které vás zajímají.';
			case 'browseEvents': return 'Procházet události';
			case 'errorLoadingFavorites': return 'Chyba při načítání oblíbených';
			case 'dancee': return 'Dancee';
			case 'tuesdayDate': return '(Úterý {date})';
			case 'wednesdayDate': return '(Středa {date})';
			case 'apiErrorNetwork': return 'Chyba připojení. Zkontrolujte prosím své internetové připojení.';
			case 'apiErrorTimeout': return 'Vypršel časový limit požadavku. Zkuste to prosím znovu.';
			case 'apiErrorServer': return 'Došlo k chybě serveru. Zkuste to prosím později.';
			case 'apiErrorParsing': return 'Nepodařilo se zpracovat odpověď serveru.';
			case 'apiErrorGeneric': return 'Došlo k neočekávané chybě. Zkuste to prosím znovu.';
			case 'eventDetail.title': return 'Detail akce';
			case 'eventDetail.favorite': return 'Oblíbené';
			case 'eventDetail.map': return 'Mapa';
			case 'eventDetail.dancesAtEvent': return 'Tance na akci';
			case 'eventDetail.venue': return 'Místo konání';
			case 'eventDetail.address': return 'Adresa';
			case 'eventDetail.navigateToVenue': return 'Navigovat k místu';
			case 'eventDetail.organizer': return 'Pořadatel';
			case 'eventDetail.description': return 'Popis akce';
			case 'eventDetail.additionalInfo': return 'Dodatečné informace';
			case 'eventDetail.eventParts': return 'Program akce';
			case 'eventDetail.workshop': return 'Workshop';
			case 'eventDetail.party': return 'Párty';
			case 'eventDetail.openLesson': return 'Otevřená lekce';
			case 'eventDetail.eventNotFound': return 'Akce nenalezena';
			case 'eventDetail.eventNotFoundDescription': return 'Akce, kterou hledáte, nebyla nalezena.';
			case 'eventDetail.backToEvents': return 'Zpět na události';
			case 'eventDetail.addedToFavorites': return 'Přidáno do oblíbených';
			case 'eventDetail.removedFromFavorites': return 'Odebráno z oblíbených';
			case 'eventDetail.favoriteError': return 'Nepodařilo se aktualizovat oblíbené';
			case 'eventDetail.remove': return 'Odebrat';
			case 'eventDetail.originalSource': return 'Původní zdroj';
			case 'eventDetail.viewOriginal': return 'Zobrazit původní událost';
			case 'eventFilters.title': return 'Filtrování & Řazení';
			case 'eventFilters.subtitle': return 'Přizpůsobte si zobrazení akcí';
			case 'eventFilters.activeFilters': return 'Aktivní filtry';
			case 'eventFilters.eventsShown': return '{count} akcí podle vašich kritérií';
			case 'eventFilters.danceType': return 'Typ tance';
			case 'eventFilters.clear': return 'Zrušit';
			case 'eventFilters.location': return 'Místo konání';
			case 'eventFilters.date': return 'Datum';
			case 'eventFilters.dateFrom': return 'Od:';
			case 'eventFilters.dateTo': return 'Do:';
			case 'eventFilters.dateToday': return 'Dnes';
			case 'eventFilters.dateTomorrow': return 'Zítra';
			case 'eventFilters.dateThisWeek': return 'Tento týden';
			case 'eventFilters.dateWeekend': return 'Víkend';
			case 'eventFilters.saveFilter': return 'Uložit toto filtrování';
			case 'eventFilters.saveFilterDescription': return 'Pro rychlý přístup příště';
			case 'eventFilters.saveFilterButton': return 'Uložit filtr';
			case 'eventFilters.datePlaceholder': return 'dd.mm.yyyy';
			case 'eventFilters.clearAll': return 'Vymazat vše';
			case 'eventFilters.noEventsMatch': return 'Žádné akce neodpovídají vašim filtrům';
			case 'eventFilters.showEvents': return 'Zobrazit {count} akcí';
			case 'eventFilters.activeFilterCount': return '{count} aktivní';
			case 'eventFilters.noResults': return 'Žádné výsledky';
			case 'eventFilters.showMoreDances': return 'Zobrazit další tance';
			case 'eventFilters.showLessDances': return 'Zobrazit méně';
			case 'eventFilters.applyFilters': return 'Použít filtry';
			case 'auth.login': return 'Přihlášení';
			case 'auth.loginTitle': return 'Přihlášení';
			case 'auth.loginSubtitle': return 'Vítejte zpět v Dancee';
			case 'auth.email': return 'E-mail';
			case 'auth.emailPlaceholder': return 'vas@email.cz';
			case 'auth.password': return 'Heslo';
			case 'auth.passwordPlaceholder': return '••••••••';
			case 'auth.forgotPassword': return 'Zapomněli jste heslo?';
			case 'auth.loginButton': return 'Přihlásit se';
			case 'auth.orDivider': return 'NEBO';
			case 'auth.continueWithGoogle': return 'Pokračovat s Google';
			case 'auth.continueWithApple': return 'Pokračovat s Apple';
			case 'auth.noAccount': return 'Nemáte účet?';
			case 'auth.register': return 'Zaregistrujte se';
			case 'auth.registerTitle': return 'Vytvořit účet';
			case 'auth.registerSubtitle': return 'Připojte se ke komunitě Dancee';
			case 'auth.name': return 'Jméno';
			case 'auth.namePlaceholder': return 'Vaše jméno';
			case 'auth.registerButton': return 'Zaregistrovat se';
			case 'auth.alreadyHaveAccount': return 'Již máte účet?';
			case 'auth.loginLink': return 'Přihlásit se';
			case 'settingsPage.title': return 'Nastavení';
			case 'settingsPage.subtitle': return 'Správa vašeho účtu';
			case 'settingsPage.profile': return 'Profil';
			case 'settingsPage.profileName': return 'Jan Novák';
			case 'settingsPage.profileEmail': return 'jan.novak@email.cz';
			case 'settingsPage.editProfile': return 'Upravit profil';
			case 'settingsPage.preferences': return 'Předvolby';
			case 'settingsPage.language': return 'Jazyk';
			case 'settingsPage.languageValue': return 'Čeština';
			case 'settingsPage.theme': return 'Motiv';
			case 'settingsPage.themeValue': return 'Systémový';
			case 'settingsPage.notifications': return 'Oznámení';
			case 'settingsPage.notificationsEnabled': return 'Zapnuto';
			case 'settingsPage.account': return 'Účet';
			case 'settingsPage.changePassword': return 'Změnit heslo';
			case 'settingsPage.privacySettings': return 'Nastavení soukromí';
			case 'settingsPage.deleteAccount': return 'Smazat účet';
			case 'settingsPage.deleteAccountWarning': return 'Tato akce je nevratná';
			case 'settingsPage.appInfo': return 'O aplikaci';
			case 'settingsPage.version': return 'Verze';
			case 'settingsPage.about': return 'O Dancee';
			case 'settingsPage.termsOfService': return 'Podmínky služby';
			case 'settingsPage.privacyPolicy': return 'Zásady ochrany osobních údajů';
			case 'settingsPage.contactSupport': return 'Kontaktovat podporu';
			case 'goHome': return 'Přejít na hlavní stránku';
			case 'errors.pageNotFound': return 'Stránka nenalezena';
			case 'errors.pageNotFoundDescription': return 'Stránka, kterou hledáte, neexistuje.';
			case 'errors.somethingWentWrong': return 'Něco se pokazilo';
			case 'errors.networkError': return 'Chyba připojení. Zkontrolujte prosím své internetové připojení.';
			case 'errors.timeoutError': return 'Vypršel časový limit požadavku. Zkuste to prosím znovu.';
			case 'errors.serverError': return 'Došlo k chybě serveru. Zkuste to prosím později.';
			case 'errors.parsingError': return 'Nepodařilo se zpracovat odpověď serveru.';
			case 'errors.genericError': return 'Došlo k neočekávané chybě.';
			case 'errors.loadEventsError': return 'Nepodařilo se načíst události.';
			case 'errors.loadFavoritesError': return 'Nepodařilo se načíst oblíbené.';
			case 'errors.toggleFavoriteError': return 'Nepodařilo se aktualizovat oblíbené.';
			default: return null;
		}
	}
}

extension on _StringsEs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'appTitle': return 'Aplicación Dancee';
			case 'events': return 'Eventos';
			case 'favorites': return 'Favoritos';
			case 'settings': return 'Configuración';
			case 'searchEvents': return 'Buscar eventos...';
			case 'filters': return 'Filtros';
			case 'today': return 'Hoy';
			case 'tomorrow': return 'Mañana';
			case 'thisWeek': return 'Esta semana';
			case 'thisMonth': return 'Este mes';
			case 'prague': return 'Praga';
			case 'eventsCount': return '{count} eventos';
			case 'detail': return 'Detalle';
			case 'hours': return '{count} horas';
			case 'errorLoadingEvents': return 'Error al cargar eventos';
			case 'retry': return 'Reintentar';
			case 'favoriteEvents': return 'Eventos favoritos';
			case 'savedEvents': return '{count} eventos guardados';
			case 'all': return 'Todos';
			case 'upcomingEvents': return 'Próximos eventos';
			case 'pastEvents': return 'Eventos pasados';
			case 'noFavoriteEvents': return 'Sin eventos favoritos';
			case 'noFavoriteEventsDescription': return 'Aún no has guardado ningún evento favorito. Comienza a explorar eventos de baile y guarda los que te interesen.';
			case 'browseEvents': return 'Explorar eventos';
			case 'errorLoadingFavorites': return 'Error al cargar favoritos';
			case 'dancee': return 'Dancee';
			case 'tuesdayDate': return '(Martes {date})';
			case 'wednesdayDate': return '(Miércoles {date})';
			case 'apiErrorNetwork': return 'Error de conexión. Por favor, verifica tu conexión a internet.';
			case 'apiErrorTimeout': return 'Tiempo de espera agotado. Por favor, inténtalo de nuevo.';
			case 'apiErrorServer': return 'Error del servidor. Por favor, inténtalo más tarde.';
			case 'apiErrorParsing': return 'Error al procesar la respuesta del servidor.';
			case 'apiErrorGeneric': return 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
			case 'eventDetail.title': return 'Detalle del Evento';
			case 'eventDetail.favorite': return 'Favorito';
			case 'eventDetail.map': return 'Mapa';
			case 'eventDetail.dancesAtEvent': return 'Bailes en el Evento';
			case 'eventDetail.venue': return 'Lugar';
			case 'eventDetail.address': return 'Dirección';
			case 'eventDetail.navigateToVenue': return 'Navegar al Lugar';
			case 'eventDetail.organizer': return 'Organizador';
			case 'eventDetail.description': return 'Descripción';
			case 'eventDetail.additionalInfo': return 'Información Adicional';
			case 'eventDetail.eventParts': return 'Programa del Evento';
			case 'eventDetail.workshop': return 'Taller';
			case 'eventDetail.party': return 'Fiesta';
			case 'eventDetail.openLesson': return 'Clase Abierta';
			case 'eventDetail.eventNotFound': return 'Evento no encontrado';
			case 'eventDetail.eventNotFoundDescription': return 'El evento que buscas no se pudo encontrar.';
			case 'eventDetail.backToEvents': return 'Volver a Eventos';
			case 'eventDetail.addedToFavorites': return 'Añadido a favoritos';
			case 'eventDetail.removedFromFavorites': return 'Eliminado de favoritos';
			case 'eventDetail.favoriteError': return 'Error al actualizar favorito';
			case 'eventDetail.remove': return 'Eliminar';
			case 'eventDetail.originalSource': return 'Fuente Original';
			case 'eventDetail.viewOriginal': return 'Ver evento original';
			case 'eventFilters.title': return 'Filtrar y Ordenar';
			case 'eventFilters.subtitle': return 'Personaliza tu vista de eventos';
			case 'eventFilters.activeFilters': return 'Filtros activos';
			case 'eventFilters.eventsShown': return '{count} eventos según tus criterios';
			case 'eventFilters.danceType': return 'Tipo de baile';
			case 'eventFilters.clear': return 'Limpiar';
			case 'eventFilters.location': return 'Ubicación';
			case 'eventFilters.date': return 'Fecha';
			case 'eventFilters.dateFrom': return 'Desde:';
			case 'eventFilters.dateTo': return 'Hasta:';
			case 'eventFilters.dateToday': return 'Hoy';
			case 'eventFilters.dateTomorrow': return 'Mañana';
			case 'eventFilters.dateThisWeek': return 'Esta semana';
			case 'eventFilters.dateWeekend': return 'Fin de semana';
			case 'eventFilters.saveFilter': return 'Guardar este filtro';
			case 'eventFilters.saveFilterDescription': return 'Para acceso rápido la próxima vez';
			case 'eventFilters.saveFilterButton': return 'Guardar filtro';
			case 'eventFilters.datePlaceholder': return 'dd.mm.yyyy';
			case 'eventFilters.clearAll': return 'Limpiar todo';
			case 'eventFilters.noEventsMatch': return 'Ningún evento coincide con tus filtros';
			case 'eventFilters.showEvents': return 'Mostrar {count} eventos';
			case 'eventFilters.activeFilterCount': return '{count} activo';
			case 'eventFilters.noResults': return 'Sin resultados';
			case 'eventFilters.showMoreDances': return 'Mostrar más bailes';
			case 'eventFilters.showLessDances': return 'Mostrar menos';
			case 'eventFilters.applyFilters': return 'Aplicar filtros';
			case 'auth.login': return 'Iniciar sesión';
			case 'auth.loginTitle': return 'Iniciar sesión';
			case 'auth.loginSubtitle': return 'Bienvenido de vuelta a Dancee';
			case 'auth.email': return 'Correo electrónico';
			case 'auth.emailPlaceholder': return 'tu@email.com';
			case 'auth.password': return 'Contraseña';
			case 'auth.passwordPlaceholder': return '••••••••';
			case 'auth.forgotPassword': return '¿Olvidaste tu contraseña?';
			case 'auth.loginButton': return 'Iniciar sesión';
			case 'auth.orDivider': return 'O';
			case 'auth.continueWithGoogle': return 'Continuar con Google';
			case 'auth.continueWithApple': return 'Continuar con Apple';
			case 'auth.noAccount': return '¿No tienes cuenta?';
			case 'auth.register': return 'Regístrate';
			case 'auth.registerTitle': return 'Crear cuenta';
			case 'auth.registerSubtitle': return 'Únete a la comunidad Dancee';
			case 'auth.name': return 'Nombre';
			case 'auth.namePlaceholder': return 'Tu nombre';
			case 'auth.registerButton': return 'Registrarse';
			case 'auth.alreadyHaveAccount': return '¿Ya tienes cuenta?';
			case 'auth.loginLink': return 'Iniciar sesión';
			case 'settingsPage.title': return 'Configuración';
			case 'settingsPage.subtitle': return 'Administra tu cuenta';
			case 'settingsPage.profile': return 'Perfil';
			case 'settingsPage.profileName': return 'Jan Novák';
			case 'settingsPage.profileEmail': return 'jan.novak@email.cz';
			case 'settingsPage.editProfile': return 'Editar perfil';
			case 'settingsPage.preferences': return 'Preferencias';
			case 'settingsPage.language': return 'Idioma';
			case 'settingsPage.languageValue': return 'Español';
			case 'settingsPage.theme': return 'Tema';
			case 'settingsPage.themeValue': return 'Sistema';
			case 'settingsPage.notifications': return 'Notificaciones';
			case 'settingsPage.notificationsEnabled': return 'Activadas';
			case 'settingsPage.account': return 'Cuenta';
			case 'settingsPage.changePassword': return 'Cambiar contraseña';
			case 'settingsPage.privacySettings': return 'Configuración de privacidad';
			case 'settingsPage.deleteAccount': return 'Eliminar cuenta';
			case 'settingsPage.deleteAccountWarning': return 'Esta acción es irreversible';
			case 'settingsPage.appInfo': return 'Información de la app';
			case 'settingsPage.version': return 'Versión';
			case 'settingsPage.about': return 'Acerca de Dancee';
			case 'settingsPage.termsOfService': return 'Términos de servicio';
			case 'settingsPage.privacyPolicy': return 'Política de privacidad';
			case 'settingsPage.contactSupport': return 'Contactar soporte';
			case 'goHome': return 'Ir al inicio';
			case 'errors.pageNotFound': return 'Página no encontrada';
			case 'errors.pageNotFoundDescription': return 'La página que buscas no existe.';
			case 'errors.somethingWentWrong': return 'Algo salió mal';
			case 'errors.networkError': return 'Error de conexión. Por favor, verifica tu conexión a internet.';
			case 'errors.timeoutError': return 'Tiempo de espera agotado. Por favor, inténtalo de nuevo.';
			case 'errors.serverError': return 'Error del servidor. Por favor, inténtalo más tarde.';
			case 'errors.parsingError': return 'Error al procesar la respuesta del servidor.';
			case 'errors.genericError': return 'Ocurrió un error inesperado.';
			case 'errors.loadEventsError': return 'Error al cargar eventos.';
			case 'errors.loadFavoritesError': return 'Error al cargar favoritos.';
			case 'errors.toggleFavoriteError': return 'Error al actualizar favorito.';
			default: return null;
		}
	}
}
