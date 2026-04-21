/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 2
/// Strings: 446 (223 per locale)
///
/// Built on 2026-04-21 at 22:38 UTC

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
	cs(languageCode: 'cs', build: _StringsCs.build);

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
	late final _StringsCommonEn common = _StringsCommonEn._(_root);
	late final _StringsNavEn nav = _StringsNavEn._(_root);
	late final _StringsAuthEn auth = _StringsAuthEn._(_root);
	late final _StringsOnboardingEn onboarding = _StringsOnboardingEn._(_root);
	late final _StringsEventsEn events = _StringsEventsEn._(_root);
	late final _StringsCoursesEn courses = _StringsCoursesEn._(_root);
	late final _StringsProfileEn profile = _StringsProfileEn._(_root);
	late final _StringsPremiumEn premium = _StringsPremiumEn._(_root);
	late final _StringsSavedEn saved = _StringsSavedEn._(_root);
	late final _StringsContactEn contact = _StringsContactEn._(_root);
}

// Path: common
class _StringsCommonEn {
	_StringsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get appName => 'Dancee';
	String get showAll => 'Show all';
	String get date => 'Date';
	String get save => 'Save';
	String get share => 'Share';
	String get map => 'Map';
	String get skip => 'Skip';
	String get continue_ => 'Continue';
	String get back => 'Back';
	String get finish => 'Finish';
	String get cancel => 'Cancel';
	String get support => 'Support';
	String get faq => 'FAQ';
	String get clear => 'Clear';
	String get current => 'Current';
	String get saveChanges => 'Save changes';
	late final _StringsCommonFormEn form = _StringsCommonFormEn._(_root);
}

// Path: nav
class _StringsNavEn {
	_StringsNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get events => 'Events';
	String get courses => 'Courses';
	String get saved => 'Saved';
	String get profile => 'Profile';
}

// Path: auth
class _StringsAuthEn {
	_StringsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get tagline => 'Discover the dancing world';
	String get orContinueWith => 'or continue with';
	String get continueWithGoogle => 'Continue with Google';
	String get continueWithApple => 'Continue with Apple';
	String get termsPrefix => 'By continuing you agree to our ';
	String get termsOfUse => 'Terms of use';
	String get and => ' and ';
	String get privacyPolicy => 'Privacy policy';
	String get agreeWith => 'I agree with ';
	String get orRegisterWith => 'or register with';
	late final _StringsAuthLoginEn login = _StringsAuthLoginEn._(_root);
	late final _StringsAuthRegisterEn register = _StringsAuthRegisterEn._(_root);
	late final _StringsAuthForgotPasswordEn forgotPassword = _StringsAuthForgotPasswordEn._(_root);
	late final _StringsAuthPasswordStrengthEn passwordStrength = _StringsAuthPasswordStrengthEn._(_root);
}

// Path: onboarding
class _StringsOnboardingEn {
	_StringsOnboardingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsOnboardingStep1En step1 = _StringsOnboardingStep1En._(_root);
	late final _StringsOnboardingStep2En step2 = _StringsOnboardingStep2En._(_root);
	late final _StringsOnboardingStep3En step3 = _StringsOnboardingStep3En._(_root);
}

// Path: events
class _StringsEventsEn {
	_StringsEventsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get featuredEvents => 'Featured events';
	String get upcomingEvents => 'Upcoming events';
	String get danceStyles => 'Dance styles';
	String get danceStylesLabel => 'DANCE STYLES';
	String get location => 'Location';
	late final _StringsEventsDetailEn detail = _StringsEventsDetailEn._(_root);
	late final _StringsEventsFilterEn filter = _StringsEventsFilterEn._(_root);
	late final _StringsEventsFiltersEn filters = _StringsEventsFiltersEn._(_root);
}

// Path: courses
class _StringsCoursesEn {
	_StringsCoursesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Dance courses';
	String get subtitle => 'Find your course';
	String get featuredCourses => 'Featured courses';
	String get allCourses => 'All courses';
	late final _StringsCoursesDetailEn detail = _StringsCoursesDetailEn._(_root);
}

// Path: profile
class _StringsProfileEn {
	_StringsProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Profile';
	late final _StringsProfileSectionsEn sections = _StringsProfileSectionsEn._(_root);
	late final _StringsProfileAccountEn account = _StringsProfileAccountEn._(_root);
	late final _StringsProfileSettingsEn settings = _StringsProfileSettingsEn._(_root);
	late final _StringsProfileSupportEn support = _StringsProfileSupportEn._(_root);
	late final _StringsProfileAppInfoEn appInfo = _StringsProfileAppInfoEn._(_root);
	late final _StringsProfileDangerEn danger = _StringsProfileDangerEn._(_root);
	late final _StringsProfileChangePasswordEn changePassword = _StringsProfileChangePasswordEn._(_root);
	late final _StringsProfileEditProfileEn editProfile = _StringsProfileEditProfileEn._(_root);
}

// Path: premium
class _StringsPremiumEn {
	_StringsPremiumEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Dancee Premium';
	String get bannerSubtitle => 'Unlock all features';
	String get heroTitle => 'Unlock full potential';
	String get heroSubtitle => 'Get access to all premium features and improve your dance experiences';
	String get featuresTitle => 'What you get with Premium';
	String get testimonialsTitle => 'What our users say';
	String get faqTitle => 'Frequently asked questions';
	String get ctaTitle => 'Ready to start?';
	String get ctaSubtitle => 'Join thousands of satisfied dancers';
	String get ctaButton => 'Get Premium now';
	String get ctaNote => '7 days free · Cancel anytime';
}

// Path: saved
class _StringsSavedEn {
	_StringsSavedEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Saved events';
	String get subtitle => 'Your favorite events';
	String get emptyTitle => 'No saved events';
	String get emptySubtitle => 'Events you save will appear here';
}

// Path: contact
class _StringsContactEn {
	_StringsContactEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get teamName => 'Dancee Team';
	String get email => 'hello@dancee.app';
	String get description => 'We\'d love to read your feedback...';
	String get responseTime => 'Response time';
	String get responseTimeDetail => 'We usually respond within 24 hours on working days. Thank you for your patience!';
	String get deviceInfo => 'Device information';
	String get autoAttached => 'Automatically attached';
	late final _StringsContactFormEn form = _StringsContactFormEn._(_root);
	late final _StringsContactDeviceInfoLabelsEn deviceInfoLabels = _StringsContactDeviceInfoLabelsEn._(_root);
}

// Path: common.form
class _StringsCommonFormEn {
	_StringsCommonFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get email => 'E-mail';
	String get emailHint => 'your@email.com';
	String get password => 'Password';
	String get passwordPlaceholder => '••••••••';
	String get confirmPassword => 'Confirm password';
	String get firstName => 'First name';
	String get firstNameHint => 'Your first name';
	String get lastName => 'Last name';
	String get lastNameHint => 'Your last name';
	String get city => 'City';
	String get phone => 'Phone';
	String get fullName => 'Full name';
}

// Path: auth.login
class _StringsAuthLoginEn {
	_StringsAuthLoginEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Welcome back!';
	String get subtitle => 'Sign in and continue exploring dance events';
	String get stayLoggedIn => 'Stay logged in';
	String get forgotPassword => 'Forgot password?';
	String get submit => 'Sign in';
	String get noAccount => 'Don\'t have an account?';
	String get register => 'Register';
}

// Path: auth.register
class _StringsAuthRegisterEn {
	_StringsAuthRegisterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Create an account';
	String get subtitle => 'Register and start exploring dance events';
	String get passwordsMatch => 'Passwords match';
	String get passwordsMismatch => 'Passwords don\'t match';
	String get newsletter => 'I want to receive news about dance events';
	String get submit => 'Create account';
	String get hasAccount => 'Already have an account?';
	String get login => 'Sign in';
}

// Path: auth.forgotPassword
class _StringsAuthForgotPasswordEn {
	_StringsAuthForgotPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Forgot password?';
	String get subtitle => 'Enter your email and we\'ll send you a link to reset your password';
	String get submit => 'Send link';
	String get checkInbox => 'Check your inbox';
	String get checkInboxDetail => 'After sending you\'ll receive an email with a link to reset your password. The link is valid for 24 hours.';
	String get rememberPassword => 'Remembered your password?';
	String get login => 'Sign in';
	String get needHelp => 'Need help?';
}

// Path: auth.passwordStrength
class _StringsAuthPasswordStrengthEn {
	_StringsAuthPasswordStrengthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get weak => 'Weak password';
	String get medium => 'Medium';
	String get strong => 'Strong password';
	String get veryStrong => 'Very strong';
	String get hint => 'At least 8 characters';
}

// Path: onboarding.step1
class _StringsOnboardingStep1En {
	_StringsOnboardingStep1En._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'What dances do you like?';
	String get subtitle => 'Choose your favorite dance styles so we can offer you relevant events';
}

// Path: onboarding.step2
class _StringsOnboardingStep2En {
	_StringsOnboardingStep2En._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'What is your level?';
	String get subtitle => 'It will help us recommend suitable events and courses';
}

// Path: onboarding.step3
class _StringsOnboardingStep3En {
	_StringsOnboardingStep3En._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Where are you located?';
	String get subtitle => 'We\'ll find the nearest dance events in your area';
	String get radius10km => '10 km';
	String get radius25km => '25 km';
	String get radius50km => '50 km';
	String get radiusAll => 'Whole country';
	String get cityHint => 'E.g. Prague, Brno...';
	String get searchRadius => 'Search events within radius';
	String get useCurrentLocation => 'Use current location';
}

// Path: events.detail
class _StringsEventsDetailEn {
	_StringsEventsDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get header => 'Event detail';
	String get description => 'Event description';
	String get additionalInfo => 'Additional information';
	String get admission => 'Admission';
	String get dresscode => 'Dresscode';
	String get buyTickets => 'Buy tickets';
	String get originalSource => 'Original source';
	String get program => 'Event program';
}

// Path: events.filter
class _StringsEventsFilterEn {
	_StringsEventsFilterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String selectedCount({required Object count}) => '${count} selected';
	String get selectedStyles => 'SELECTED STYLES';
	String get apply => 'Apply filter';
	String applyCount({required Object count}) => 'Apply filter (${count})';
	String get selectLocation => 'Select location';
	String get searchCityHint => 'Search city or area...';
	String get useMyLocation => 'Use my location';
	String get useMyLocationSubtitle => 'Automatically finds events near you';
	String get popularCities => 'Popular cities';
	String get allCities => 'All cities';
}

// Path: events.filters
class _StringsEventsFiltersEn {
	_StringsEventsFiltersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get today => 'Today';
	String get thisWeek => 'This week';
	String get thisMonth => 'This month';
	String get thisWeekend => 'This weekend';
}

// Path: courses.detail
class _StringsCoursesDetailEn {
	_StringsCoursesDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get header => 'Course detail';
	String get description => 'Course description';
	String get details => 'Course details';
	String get whatYouLearn => 'What you\'ll learn';
	String get aboutInstructor => 'About instructor';
	String get shareCourse => 'Share course';
	String get coursePrice => 'Course price';
	String get availableSpots => 'Available spots';
	String get register => 'Register for course';
}

// Path: profile.sections
class _StringsProfileSectionsEn {
	_StringsProfileSectionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get account => 'Account';
	String get settings => 'Settings';
	String get support => 'Support';
	String get appInfo => 'About app';
	String get dangerZone => 'Danger zone';
}

// Path: profile.account
class _StringsProfileAccountEn {
	_StringsProfileAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get editProfile => 'Edit profile';
	String get changePassword => 'Change password';
}

// Path: profile.settings
class _StringsProfileSettingsEn {
	_StringsProfileSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get language => 'Language';
	String get czech => 'Czech';
	String get notifications => 'Notifications';
	String get english => 'English';
}

// Path: profile.support
class _StringsProfileSupportEn {
	_StringsProfileSupportEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get contactAuthor => 'Contact author';
	String get rateApp => 'Rate app';
}

// Path: profile.appInfo
class _StringsProfileAppInfoEn {
	_StringsProfileAppInfoEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get version => 'App version';
	String get termsOfUse => 'Terms of use';
	String get privacy => 'Privacy';
}

// Path: profile.danger
class _StringsProfileDangerEn {
	_StringsProfileDangerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get logout => 'Log out';
	String get deleteAccount => 'Delete account';
}

// Path: profile.changePassword
class _StringsProfileChangePasswordEn {
	_StringsProfileChangePasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Change password';
	String get secureAccount => 'Secure your account';
	String get secureAccountDetail => 'A strong password must contain at least 8 characters, uppercase and lowercase letters, numbers and special characters.';
	String get currentPassword => 'Current password';
	String get currentPasswordHint => 'Enter current password';
	String get newPassword => 'New password';
	String get newPasswordHint => 'Enter new password';
	String get confirmPassword => 'Confirm new password';
	String get confirmPasswordHint => 'Enter new password again';
	String get save => 'Save new password';
	String get requirements => 'PASSWORD REQUIREMENTS';
	String get req8chars => 'Minimum 8 characters';
	String get reqUppercase => 'At least one uppercase letter (A-Z)';
	String get reqLowercase => 'At least one lowercase letter (a-z)';
	String get reqNumber => 'At least one number (0-9)';
	String get reqSpecial => 'At least one special character (!@#\$%^&*)';
	String get forgotPassword => 'Forgot your password?';
	String get strengthVeryWeak => 'Password strength: Very weak';
	String get strengthWeak => 'Password strength: Weak';
	String get strengthMedium => 'Password strength: Medium';
	String get strengthStrong => 'Password strength: Strong';
}

// Path: profile.editProfile
class _StringsProfileEditProfileEn {
	_StringsProfileEditProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Edit profile';
	late final _StringsProfileEditProfileSectionsEn sections = _StringsProfileEditProfileSectionsEn._(_root);
	String get changePhoto => 'Change photo';
	String get bio => 'Description';
	String get bioHint => 'Write something about yourself...';
	String get selectDanceStyles => 'Select your favorite dance styles';
	String get yourLevel => 'Your dance level';
	String get instagram => 'Instagram';
	String get instagramHint => '@your_username';
	String get facebook => 'Facebook';
	String get facebookHint => 'facebook.com/your.name';
	late final _StringsProfileEditProfileNotificationsEn notifications = _StringsProfileEditProfileNotificationsEn._(_root);
	late final _StringsProfileEditProfileNotificationSubtitlesEn notificationSubtitles = _StringsProfileEditProfileNotificationSubtitlesEn._(_root);
}

// Path: contact.form
class _StringsContactFormEn {
	_StringsContactFormEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get subject => 'Message subject';
	String get feedback => 'Feedback';
	String get reportBug => 'Report bug';
	String get featureRequest => 'Feature request';
	String get other => 'Other';
	String get title => 'Message title';
	String get titleHint => 'Briefly describe your issue or suggestion';
	String get message => 'Message';
	String get messageHint => 'Describe your issue in detail...';
	String get replyEmail => 'Your reply email';
	String get sending => 'Sending...';
	String get sent => 'Sent!';
	String get submit => 'Send message';
}

// Path: contact.deviceInfoLabels
class _StringsContactDeviceInfoLabelsEn {
	_StringsContactDeviceInfoLabelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get app => 'App:';
	String get device => 'Device:';
	String get os => 'System:';
}

// Path: profile.editProfile.sections
class _StringsProfileEditProfileSectionsEn {
	_StringsProfileEditProfileSectionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get personalInfo => 'Personal information';
	String get aboutMe => 'About me';
	String get favoriteDances => 'Favorite dances';
	String get level => 'Level';
	String get socialNetworks => 'Social networks';
	String get notifications => 'Notifications';
}

// Path: profile.editProfile.notifications
class _StringsProfileEditProfileNotificationsEn {
	_StringsProfileEditProfileNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get newEvents => 'New events';
	String get eventReminders => 'Event reminders';
	String get marketing => 'Marketing messages';
}

// Path: profile.editProfile.notificationSubtitles
class _StringsProfileEditProfileNotificationSubtitlesEn {
	_StringsProfileEditProfileNotificationSubtitlesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get newEvents => 'Get notified about new events in your area';
	String get eventReminders => 'Reminders before your saved events';
	String get marketing => 'Promotional messages and offers';
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
	@override late final _StringsCommonCs common = _StringsCommonCs._(_root);
	@override late final _StringsNavCs nav = _StringsNavCs._(_root);
	@override late final _StringsAuthCs auth = _StringsAuthCs._(_root);
	@override late final _StringsOnboardingCs onboarding = _StringsOnboardingCs._(_root);
	@override late final _StringsEventsCs events = _StringsEventsCs._(_root);
	@override late final _StringsCoursesCs courses = _StringsCoursesCs._(_root);
	@override late final _StringsProfileCs profile = _StringsProfileCs._(_root);
	@override late final _StringsPremiumCs premium = _StringsPremiumCs._(_root);
	@override late final _StringsSavedCs saved = _StringsSavedCs._(_root);
	@override late final _StringsContactCs contact = _StringsContactCs._(_root);
}

// Path: common
class _StringsCommonCs implements _StringsCommonEn {
	_StringsCommonCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Dancee';
	@override String get showAll => 'Zobrazit vše';
	@override String get date => 'Datum';
	@override String get save => 'Uložit';
	@override String get share => 'Sdílet';
	@override String get map => 'Mapa';
	@override String get skip => 'Přeskočit';
	@override String get continue_ => 'Pokračovat';
	@override String get back => 'Zpět';
	@override String get finish => 'Dokončit';
	@override String get cancel => 'Zrušit';
	@override String get support => 'Podpora';
	@override String get faq => 'FAQ';
	@override String get clear => 'Vymazat';
	@override String get current => 'Aktuální';
	@override String get saveChanges => 'Uložit změny';
	@override late final _StringsCommonFormCs form = _StringsCommonFormCs._(_root);
}

// Path: nav
class _StringsNavCs implements _StringsNavEn {
	_StringsNavCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get events => 'Události';
	@override String get courses => 'Kurzy';
	@override String get saved => 'Uložené';
	@override String get profile => 'Profil';
}

// Path: auth
class _StringsAuthCs implements _StringsAuthEn {
	_StringsAuthCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Objevuj taneční svět';
	@override String get orContinueWith => 'nebo pokračuj s';
	@override String get continueWithGoogle => 'Pokračovat s Google';
	@override String get continueWithApple => 'Pokračovat s Apple';
	@override String get termsPrefix => 'Pokračováním souhlasíš s našimi ';
	@override String get termsOfUse => 'Podmínkami používání';
	@override String get and => ' a ';
	@override String get privacyPolicy => 'Zásadami ochrany osobních údajů';
	@override String get agreeWith => 'Souhlasím s ';
	@override String get orRegisterWith => 'nebo se zaregistruj s';
	@override late final _StringsAuthLoginCs login = _StringsAuthLoginCs._(_root);
	@override late final _StringsAuthRegisterCs register = _StringsAuthRegisterCs._(_root);
	@override late final _StringsAuthForgotPasswordCs forgotPassword = _StringsAuthForgotPasswordCs._(_root);
	@override late final _StringsAuthPasswordStrengthCs passwordStrength = _StringsAuthPasswordStrengthCs._(_root);
}

// Path: onboarding
class _StringsOnboardingCs implements _StringsOnboardingEn {
	_StringsOnboardingCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override late final _StringsOnboardingStep1Cs step1 = _StringsOnboardingStep1Cs._(_root);
	@override late final _StringsOnboardingStep2Cs step2 = _StringsOnboardingStep2Cs._(_root);
	@override late final _StringsOnboardingStep3Cs step3 = _StringsOnboardingStep3Cs._(_root);
}

// Path: events
class _StringsEventsCs implements _StringsEventsEn {
	_StringsEventsCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get featuredEvents => 'Doporučené akce';
	@override String get upcomingEvents => 'Nadcházející akce';
	@override String get danceStyles => 'Taneční styly';
	@override String get danceStylesLabel => 'TANEČNÍ STYLY';
	@override String get location => 'Lokalita';
	@override late final _StringsEventsDetailCs detail = _StringsEventsDetailCs._(_root);
	@override late final _StringsEventsFilterCs filter = _StringsEventsFilterCs._(_root);
	@override late final _StringsEventsFiltersCs filters = _StringsEventsFiltersCs._(_root);
}

// Path: courses
class _StringsCoursesCs implements _StringsCoursesEn {
	_StringsCoursesCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Taneční kurzy';
	@override String get subtitle => 'Najdi svůj kurz';
	@override String get featuredCourses => 'Doporučené kurzy';
	@override String get allCourses => 'Všechny kurzy';
	@override late final _StringsCoursesDetailCs detail = _StringsCoursesDetailCs._(_root);
}

// Path: profile
class _StringsProfileCs implements _StringsProfileEn {
	_StringsProfileCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profil';
	@override late final _StringsProfileSectionsCs sections = _StringsProfileSectionsCs._(_root);
	@override late final _StringsProfileAccountCs account = _StringsProfileAccountCs._(_root);
	@override late final _StringsProfileSettingsCs settings = _StringsProfileSettingsCs._(_root);
	@override late final _StringsProfileSupportCs support = _StringsProfileSupportCs._(_root);
	@override late final _StringsProfileAppInfoCs appInfo = _StringsProfileAppInfoCs._(_root);
	@override late final _StringsProfileDangerCs danger = _StringsProfileDangerCs._(_root);
	@override late final _StringsProfileChangePasswordCs changePassword = _StringsProfileChangePasswordCs._(_root);
	@override late final _StringsProfileEditProfileCs editProfile = _StringsProfileEditProfileCs._(_root);
}

// Path: premium
class _StringsPremiumCs implements _StringsPremiumEn {
	_StringsPremiumCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dancee Premium';
	@override String get bannerSubtitle => 'Odemkněte všechny funkce';
	@override String get heroTitle => 'Odemkněte plný potenciál';
	@override String get heroSubtitle => 'Získejte přístup ke všem prémiové funkcím a zlepšete své taneční zážitky';
	@override String get featuresTitle => 'Co získáte s Premium';
	@override String get testimonialsTitle => 'Co říkají naši uživatelé';
	@override String get faqTitle => 'Časté otázky';
	@override String get ctaTitle => 'Připraveni začít?';
	@override String get ctaSubtitle => 'Připojte se k tisícům spokojených tanečníků';
	@override String get ctaButton => 'Získat Premium nyní';
	@override String get ctaNote => '7 dní zdarma · Zrušte kdykoliv';
}

// Path: saved
class _StringsSavedCs implements _StringsSavedEn {
	_StringsSavedCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Uložené akce';
	@override String get subtitle => 'Tvoje oblíbené akce';
	@override String get emptyTitle => 'Žádné uložené akce';
	@override String get emptySubtitle => 'Akce, které si uložíš, se zobrazí zde';
}

// Path: contact
class _StringsContactCs implements _StringsContactEn {
	_StringsContactCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get teamName => 'Tým Dancee';
	@override String get email => 'hello@dancee.app';
	@override String get description => 'Rádi si přečteme vaše zpětné vazby...';
	@override String get responseTime => 'Doba odezvy';
	@override String get responseTimeDetail => 'Obvykle odpovídáme do 24 hodin v pracovní dny. Děkujeme za trpělivost!';
	@override String get deviceInfo => 'Informace o zařízení';
	@override String get autoAttached => 'Automaticky přiloženo';
	@override late final _StringsContactFormCs form = _StringsContactFormCs._(_root);
	@override late final _StringsContactDeviceInfoLabelsCs deviceInfoLabels = _StringsContactDeviceInfoLabelsCs._(_root);
}

// Path: common.form
class _StringsCommonFormCs implements _StringsCommonFormEn {
	_StringsCommonFormCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get email => 'E-mail';
	@override String get emailHint => 'tvuj@email.cz';
	@override String get password => 'Heslo';
	@override String get passwordPlaceholder => '••••••••';
	@override String get confirmPassword => 'Potvrzení hesla';
	@override String get firstName => 'Jméno';
	@override String get firstNameHint => 'Tvoje jméno';
	@override String get lastName => 'Příjmení';
	@override String get lastNameHint => 'Tvoje příjmení';
	@override String get city => 'Město';
	@override String get phone => 'Telefon';
	@override String get fullName => 'Jméno a příjmení';
}

// Path: auth.login
class _StringsAuthLoginCs implements _StringsAuthLoginEn {
	_StringsAuthLoginCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vítej zpět!';
	@override String get subtitle => 'Přihlaš se a pokračuj v objevování tanečních akcí';
	@override String get stayLoggedIn => 'Zůstat přihlášen';
	@override String get forgotPassword => 'Zapomenuté heslo?';
	@override String get submit => 'Přihlásit se';
	@override String get noAccount => 'Nemáš ještě účet?';
	@override String get register => 'Zaregistruj se';
}

// Path: auth.register
class _StringsAuthRegisterCs implements _StringsAuthRegisterEn {
	_StringsAuthRegisterCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vytvoř si účet';
	@override String get subtitle => 'Zaregistruj se a začni objevovat taneční akce';
	@override String get passwordsMatch => 'Hesla se shodují';
	@override String get passwordsMismatch => 'Hesla se neshodují';
	@override String get newsletter => 'Chci dostávat novinky o tanečních akcích';
	@override String get submit => 'Vytvořit účet';
	@override String get hasAccount => 'Už máš účet?';
	@override String get login => 'Přihlaš se';
}

// Path: auth.forgotPassword
class _StringsAuthForgotPasswordCs implements _StringsAuthForgotPasswordEn {
	_StringsAuthForgotPasswordCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zapomenuté heslo?';
	@override String get subtitle => 'Zadej svůj e-mail a pošleme ti odkaz pro obnovení hesla';
	@override String get submit => 'Odeslat odkaz';
	@override String get checkInbox => 'Zkontroluj svou e-mailovou schránku';
	@override String get checkInboxDetail => 'Po odeslání obdržíš e-mail s odkazem pro obnovení hesla. Odkaz je platný 24 hodin.';
	@override String get rememberPassword => 'Vzpomněl sis na heslo?';
	@override String get login => 'Přihlásit se';
	@override String get needHelp => 'Potřebuješ pomoc?';
}

// Path: auth.passwordStrength
class _StringsAuthPasswordStrengthCs implements _StringsAuthPasswordStrengthEn {
	_StringsAuthPasswordStrengthCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get weak => 'Slabé heslo';
	@override String get medium => 'Středně silné';
	@override String get strong => 'Silné heslo';
	@override String get veryStrong => 'Velmi silné';
	@override String get hint => 'Alespoň 8 znaků';
}

// Path: onboarding.step1
class _StringsOnboardingStep1Cs implements _StringsOnboardingStep1En {
	_StringsOnboardingStep1Cs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jaké tance tě baví?';
	@override String get subtitle => 'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce';
}

// Path: onboarding.step2
class _StringsOnboardingStep2Cs implements _StringsOnboardingStep2En {
	_StringsOnboardingStep2Cs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jaká je tvoje úroveň?';
	@override String get subtitle => 'Pomůže nám to doporučit ti vhodné akce a kurzy';
}

// Path: onboarding.step3
class _StringsOnboardingStep3Cs implements _StringsOnboardingStep3En {
	_StringsOnboardingStep3Cs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kde se nacházíš?';
	@override String get subtitle => 'Najdeme pro tebe nejbližší taneční akce ve tvém okolí';
	@override String get radius10km => '10 km';
	@override String get radius25km => '25 km';
	@override String get radius50km => '50 km';
	@override String get radiusAll => 'Celá republika';
	@override String get cityHint => 'Např. Praha, Brno...';
	@override String get searchRadius => 'Vyhledat akce v okruhu';
	@override String get useCurrentLocation => 'Použít aktuální polohu';
}

// Path: events.detail
class _StringsEventsDetailCs implements _StringsEventsDetailEn {
	_StringsEventsDetailCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Detail akce';
	@override String get description => 'Popis akce';
	@override String get additionalInfo => 'Dodatečné informace';
	@override String get admission => 'Vstupné';
	@override String get dresscode => 'Dresscode';
	@override String get buyTickets => 'Koupit vstupenky';
	@override String get originalSource => 'Původní zdroj';
	@override String get program => 'Program akce';
}

// Path: events.filter
class _StringsEventsFilterCs implements _StringsEventsFilterEn {
	_StringsEventsFilterCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String selectedCount({required Object count}) => '${count} vybraných';
	@override String get selectedStyles => 'VYBRANÉ STYLY';
	@override String get apply => 'Použít filtr';
	@override String applyCount({required Object count}) => 'Použít filtr (${count})';
	@override String get selectLocation => 'Vybrat lokalitu';
	@override String get searchCityHint => 'Hledat město nebo oblast...';
	@override String get useMyLocation => 'Použít moji polohu';
	@override String get useMyLocationSubtitle => 'Automaticky najde akce ve vašem okolí';
	@override String get popularCities => 'Oblíbená města';
	@override String get allCities => 'Všechna města';
}

// Path: events.filters
class _StringsEventsFiltersCs implements _StringsEventsFiltersEn {
	_StringsEventsFiltersCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get today => 'Dnes';
	@override String get thisWeek => 'Tento týden';
	@override String get thisMonth => 'Tento měsíc';
	@override String get thisWeekend => 'Tento víkend';
}

// Path: courses.detail
class _StringsCoursesDetailCs implements _StringsCoursesDetailEn {
	_StringsCoursesDetailCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get header => 'Detail kurzu';
	@override String get description => 'Popis kurzu';
	@override String get details => 'Podrobnosti kurzu';
	@override String get whatYouLearn => 'Co se naučíte';
	@override String get aboutInstructor => 'O lektorovi';
	@override String get shareCourse => 'Sdílet kurz';
	@override String get coursePrice => 'Cena kurzu';
	@override String get availableSpots => 'Volná místa';
	@override String get register => 'Registrovat se na kurz';
}

// Path: profile.sections
class _StringsProfileSectionsCs implements _StringsProfileSectionsEn {
	_StringsProfileSectionsCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get account => 'Účet';
	@override String get settings => 'Nastavení';
	@override String get support => 'Podpora';
	@override String get appInfo => 'O aplikaci';
	@override String get dangerZone => 'Nebezpečná zóna';
}

// Path: profile.account
class _StringsProfileAccountCs implements _StringsProfileAccountEn {
	_StringsProfileAccountCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Upravit profil';
	@override String get changePassword => 'Změnit heslo';
}

// Path: profile.settings
class _StringsProfileSettingsCs implements _StringsProfileSettingsEn {
	_StringsProfileSettingsCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get language => 'Jazyk';
	@override String get czech => 'Čeština';
	@override String get notifications => 'Oznámení';
	@override String get english => 'Angličtina';
}

// Path: profile.support
class _StringsProfileSupportCs implements _StringsProfileSupportEn {
	_StringsProfileSupportCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get contactAuthor => 'Napsat autorovi';
	@override String get rateApp => 'Ohodnotit aplikaci';
}

// Path: profile.appInfo
class _StringsProfileAppInfoCs implements _StringsProfileAppInfoEn {
	_StringsProfileAppInfoCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get version => 'Verze aplikace';
	@override String get termsOfUse => 'Podmínky použití';
	@override String get privacy => 'Ochrana soukromí';
}

// Path: profile.danger
class _StringsProfileDangerCs implements _StringsProfileDangerEn {
	_StringsProfileDangerCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get logout => 'Odhlásit se';
	@override String get deleteAccount => 'Smazat účet';
}

// Path: profile.changePassword
class _StringsProfileChangePasswordCs implements _StringsProfileChangePasswordEn {
	_StringsProfileChangePasswordCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Změnit heslo';
	@override String get secureAccount => 'Zabezpečte svůj účet';
	@override String get secureAccountDetail => 'Silné heslo musí obsahovat alespoň 8 znaků, velká a malá písmena, čísla a speciální znaky.';
	@override String get currentPassword => 'Současné heslo';
	@override String get currentPasswordHint => 'Zadejte současné heslo';
	@override String get newPassword => 'Nové heslo';
	@override String get newPasswordHint => 'Zadejte nové heslo';
	@override String get confirmPassword => 'Potvrdit nové heslo';
	@override String get confirmPasswordHint => 'Zadejte nové heslo znovu';
	@override String get save => 'Uložit nové heslo';
	@override String get requirements => 'POŽADAVKY NA HESLO';
	@override String get req8chars => 'Minimálně 8 znaků';
	@override String get reqUppercase => 'Alespoň jedno velké písmeno (A-Z)';
	@override String get reqLowercase => 'Alespoň jedno malé písmeno (a-z)';
	@override String get reqNumber => 'Alespoň jedno číslo (0-9)';
	@override String get reqSpecial => 'Alespoň jeden speciální znak (!@#\$%^&*)';
	@override String get forgotPassword => 'Zapomněli jste heslo?';
	@override String get strengthVeryWeak => 'Síla hesla: Velmi slabé';
	@override String get strengthWeak => 'Síla hesla: Slabé';
	@override String get strengthMedium => 'Síla hesla: Střední';
	@override String get strengthStrong => 'Síla hesla: Silné';
}

// Path: profile.editProfile
class _StringsProfileEditProfileCs implements _StringsProfileEditProfileEn {
	_StringsProfileEditProfileCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Upravit profil';
	@override late final _StringsProfileEditProfileSectionsCs sections = _StringsProfileEditProfileSectionsCs._(_root);
	@override String get changePhoto => 'Změnit fotku';
	@override String get bio => 'Popis';
	@override String get bioHint => 'Napište něco o sobě...';
	@override String get selectDanceStyles => 'Vyberte své oblíbené tanční styly';
	@override String get yourLevel => 'Vaše taneční úroveň';
	@override String get instagram => 'Instagram';
	@override String get instagramHint => '@vase_uzivatelske_jmeno';
	@override String get facebook => 'Facebook';
	@override String get facebookHint => 'facebook.com/vase.jmeno';
	@override late final _StringsProfileEditProfileNotificationsCs notifications = _StringsProfileEditProfileNotificationsCs._(_root);
	@override late final _StringsProfileEditProfileNotificationSubtitlesCs notificationSubtitles = _StringsProfileEditProfileNotificationSubtitlesCs._(_root);
}

// Path: contact.form
class _StringsContactFormCs implements _StringsContactFormEn {
	_StringsContactFormCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get subject => 'Předmět zprávy';
	@override String get feedback => 'Zpětná vazba';
	@override String get reportBug => 'Nahlásit problém';
	@override String get featureRequest => 'Návrh na vylepšení';
	@override String get other => 'Ostatní';
	@override String get title => 'Název zprávy';
	@override String get titleHint => 'Stručně popište váš problém nebo návrh';
	@override String get message => 'Zpráva';
	@override String get messageHint => 'Podrobně popište váš problém...';
	@override String get replyEmail => 'Váš e-mail pro odpověď';
	@override String get sending => 'Odesílání...';
	@override String get sent => 'Odesláno!';
	@override String get submit => 'Odeslat zprávu';
}

// Path: contact.deviceInfoLabels
class _StringsContactDeviceInfoLabelsCs implements _StringsContactDeviceInfoLabelsEn {
	_StringsContactDeviceInfoLabelsCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get app => 'Aplikace:';
	@override String get device => 'Zařízení:';
	@override String get os => 'Systém:';
}

// Path: profile.editProfile.sections
class _StringsProfileEditProfileSectionsCs implements _StringsProfileEditProfileSectionsEn {
	_StringsProfileEditProfileSectionsCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get personalInfo => 'Osobní údaje';
	@override String get aboutMe => 'O mně';
	@override String get favoriteDances => 'Oblíbené tance';
	@override String get level => 'Úroveň';
	@override String get socialNetworks => 'Sociální sítě';
	@override String get notifications => 'Oznámení';
}

// Path: profile.editProfile.notifications
class _StringsProfileEditProfileNotificationsCs implements _StringsProfileEditProfileNotificationsEn {
	_StringsProfileEditProfileNotificationsCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Nové akce';
	@override String get eventReminders => 'Připomínky akcí';
	@override String get marketing => 'Marketingové zprávy';
}

// Path: profile.editProfile.notificationSubtitles
class _StringsProfileEditProfileNotificationSubtitlesCs implements _StringsProfileEditProfileNotificationSubtitlesEn {
	_StringsProfileEditProfileNotificationSubtitlesCs._(this._root);

	@override final _StringsCs _root; // ignore: unused_field

	// Translations
	@override String get newEvents => 'Dostávejte upozornění o nových akcích ve vašem okolí';
	@override String get eventReminders => 'Připomínky před vašimi uloženými akcemi';
	@override String get marketing => 'Propagační zprávy a nabídky';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Dancee';
			case 'common.showAll': return 'Show all';
			case 'common.date': return 'Date';
			case 'common.save': return 'Save';
			case 'common.share': return 'Share';
			case 'common.map': return 'Map';
			case 'common.skip': return 'Skip';
			case 'common.continue_': return 'Continue';
			case 'common.back': return 'Back';
			case 'common.finish': return 'Finish';
			case 'common.cancel': return 'Cancel';
			case 'common.support': return 'Support';
			case 'common.faq': return 'FAQ';
			case 'common.clear': return 'Clear';
			case 'common.current': return 'Current';
			case 'common.saveChanges': return 'Save changes';
			case 'common.form.email': return 'E-mail';
			case 'common.form.emailHint': return 'your@email.com';
			case 'common.form.password': return 'Password';
			case 'common.form.passwordPlaceholder': return '••••••••';
			case 'common.form.confirmPassword': return 'Confirm password';
			case 'common.form.firstName': return 'First name';
			case 'common.form.firstNameHint': return 'Your first name';
			case 'common.form.lastName': return 'Last name';
			case 'common.form.lastNameHint': return 'Your last name';
			case 'common.form.city': return 'City';
			case 'common.form.phone': return 'Phone';
			case 'common.form.fullName': return 'Full name';
			case 'nav.events': return 'Events';
			case 'nav.courses': return 'Courses';
			case 'nav.saved': return 'Saved';
			case 'nav.profile': return 'Profile';
			case 'auth.tagline': return 'Discover the dancing world';
			case 'auth.orContinueWith': return 'or continue with';
			case 'auth.continueWithGoogle': return 'Continue with Google';
			case 'auth.continueWithApple': return 'Continue with Apple';
			case 'auth.termsPrefix': return 'By continuing you agree to our ';
			case 'auth.termsOfUse': return 'Terms of use';
			case 'auth.and': return ' and ';
			case 'auth.privacyPolicy': return 'Privacy policy';
			case 'auth.agreeWith': return 'I agree with ';
			case 'auth.orRegisterWith': return 'or register with';
			case 'auth.login.title': return 'Welcome back!';
			case 'auth.login.subtitle': return 'Sign in and continue exploring dance events';
			case 'auth.login.stayLoggedIn': return 'Stay logged in';
			case 'auth.login.forgotPassword': return 'Forgot password?';
			case 'auth.login.submit': return 'Sign in';
			case 'auth.login.noAccount': return 'Don\'t have an account?';
			case 'auth.login.register': return 'Register';
			case 'auth.register.title': return 'Create an account';
			case 'auth.register.subtitle': return 'Register and start exploring dance events';
			case 'auth.register.passwordsMatch': return 'Passwords match';
			case 'auth.register.passwordsMismatch': return 'Passwords don\'t match';
			case 'auth.register.newsletter': return 'I want to receive news about dance events';
			case 'auth.register.submit': return 'Create account';
			case 'auth.register.hasAccount': return 'Already have an account?';
			case 'auth.register.login': return 'Sign in';
			case 'auth.forgotPassword.title': return 'Forgot password?';
			case 'auth.forgotPassword.subtitle': return 'Enter your email and we\'ll send you a link to reset your password';
			case 'auth.forgotPassword.submit': return 'Send link';
			case 'auth.forgotPassword.checkInbox': return 'Check your inbox';
			case 'auth.forgotPassword.checkInboxDetail': return 'After sending you\'ll receive an email with a link to reset your password. The link is valid for 24 hours.';
			case 'auth.forgotPassword.rememberPassword': return 'Remembered your password?';
			case 'auth.forgotPassword.login': return 'Sign in';
			case 'auth.forgotPassword.needHelp': return 'Need help?';
			case 'auth.passwordStrength.weak': return 'Weak password';
			case 'auth.passwordStrength.medium': return 'Medium';
			case 'auth.passwordStrength.strong': return 'Strong password';
			case 'auth.passwordStrength.veryStrong': return 'Very strong';
			case 'auth.passwordStrength.hint': return 'At least 8 characters';
			case 'onboarding.step1.title': return 'What dances do you like?';
			case 'onboarding.step1.subtitle': return 'Choose your favorite dance styles so we can offer you relevant events';
			case 'onboarding.step2.title': return 'What is your level?';
			case 'onboarding.step2.subtitle': return 'It will help us recommend suitable events and courses';
			case 'onboarding.step3.title': return 'Where are you located?';
			case 'onboarding.step3.subtitle': return 'We\'ll find the nearest dance events in your area';
			case 'onboarding.step3.radius10km': return '10 km';
			case 'onboarding.step3.radius25km': return '25 km';
			case 'onboarding.step3.radius50km': return '50 km';
			case 'onboarding.step3.radiusAll': return 'Whole country';
			case 'onboarding.step3.cityHint': return 'E.g. Prague, Brno...';
			case 'onboarding.step3.searchRadius': return 'Search events within radius';
			case 'onboarding.step3.useCurrentLocation': return 'Use current location';
			case 'events.featuredEvents': return 'Featured events';
			case 'events.upcomingEvents': return 'Upcoming events';
			case 'events.danceStyles': return 'Dance styles';
			case 'events.danceStylesLabel': return 'DANCE STYLES';
			case 'events.location': return 'Location';
			case 'events.detail.header': return 'Event detail';
			case 'events.detail.description': return 'Event description';
			case 'events.detail.additionalInfo': return 'Additional information';
			case 'events.detail.admission': return 'Admission';
			case 'events.detail.dresscode': return 'Dresscode';
			case 'events.detail.buyTickets': return 'Buy tickets';
			case 'events.detail.originalSource': return 'Original source';
			case 'events.detail.program': return 'Event program';
			case 'events.filter.selectedCount': return ({required Object count}) => '${count} selected';
			case 'events.filter.selectedStyles': return 'SELECTED STYLES';
			case 'events.filter.apply': return 'Apply filter';
			case 'events.filter.applyCount': return ({required Object count}) => 'Apply filter (${count})';
			case 'events.filter.selectLocation': return 'Select location';
			case 'events.filter.searchCityHint': return 'Search city or area...';
			case 'events.filter.useMyLocation': return 'Use my location';
			case 'events.filter.useMyLocationSubtitle': return 'Automatically finds events near you';
			case 'events.filter.popularCities': return 'Popular cities';
			case 'events.filter.allCities': return 'All cities';
			case 'events.filters.today': return 'Today';
			case 'events.filters.thisWeek': return 'This week';
			case 'events.filters.thisMonth': return 'This month';
			case 'events.filters.thisWeekend': return 'This weekend';
			case 'courses.title': return 'Dance courses';
			case 'courses.subtitle': return 'Find your course';
			case 'courses.featuredCourses': return 'Featured courses';
			case 'courses.allCourses': return 'All courses';
			case 'courses.detail.header': return 'Course detail';
			case 'courses.detail.description': return 'Course description';
			case 'courses.detail.details': return 'Course details';
			case 'courses.detail.whatYouLearn': return 'What you\'ll learn';
			case 'courses.detail.aboutInstructor': return 'About instructor';
			case 'courses.detail.shareCourse': return 'Share course';
			case 'courses.detail.coursePrice': return 'Course price';
			case 'courses.detail.availableSpots': return 'Available spots';
			case 'courses.detail.register': return 'Register for course';
			case 'profile.title': return 'Profile';
			case 'profile.sections.account': return 'Account';
			case 'profile.sections.settings': return 'Settings';
			case 'profile.sections.support': return 'Support';
			case 'profile.sections.appInfo': return 'About app';
			case 'profile.sections.dangerZone': return 'Danger zone';
			case 'profile.account.editProfile': return 'Edit profile';
			case 'profile.account.changePassword': return 'Change password';
			case 'profile.settings.language': return 'Language';
			case 'profile.settings.czech': return 'Czech';
			case 'profile.settings.notifications': return 'Notifications';
			case 'profile.settings.english': return 'English';
			case 'profile.support.contactAuthor': return 'Contact author';
			case 'profile.support.rateApp': return 'Rate app';
			case 'profile.appInfo.version': return 'App version';
			case 'profile.appInfo.termsOfUse': return 'Terms of use';
			case 'profile.appInfo.privacy': return 'Privacy';
			case 'profile.danger.logout': return 'Log out';
			case 'profile.danger.deleteAccount': return 'Delete account';
			case 'profile.changePassword.title': return 'Change password';
			case 'profile.changePassword.secureAccount': return 'Secure your account';
			case 'profile.changePassword.secureAccountDetail': return 'A strong password must contain at least 8 characters, uppercase and lowercase letters, numbers and special characters.';
			case 'profile.changePassword.currentPassword': return 'Current password';
			case 'profile.changePassword.currentPasswordHint': return 'Enter current password';
			case 'profile.changePassword.newPassword': return 'New password';
			case 'profile.changePassword.newPasswordHint': return 'Enter new password';
			case 'profile.changePassword.confirmPassword': return 'Confirm new password';
			case 'profile.changePassword.confirmPasswordHint': return 'Enter new password again';
			case 'profile.changePassword.save': return 'Save new password';
			case 'profile.changePassword.requirements': return 'PASSWORD REQUIREMENTS';
			case 'profile.changePassword.req8chars': return 'Minimum 8 characters';
			case 'profile.changePassword.reqUppercase': return 'At least one uppercase letter (A-Z)';
			case 'profile.changePassword.reqLowercase': return 'At least one lowercase letter (a-z)';
			case 'profile.changePassword.reqNumber': return 'At least one number (0-9)';
			case 'profile.changePassword.reqSpecial': return 'At least one special character (!@#\$%^&*)';
			case 'profile.changePassword.forgotPassword': return 'Forgot your password?';
			case 'profile.changePassword.strengthVeryWeak': return 'Password strength: Very weak';
			case 'profile.changePassword.strengthWeak': return 'Password strength: Weak';
			case 'profile.changePassword.strengthMedium': return 'Password strength: Medium';
			case 'profile.changePassword.strengthStrong': return 'Password strength: Strong';
			case 'profile.editProfile.title': return 'Edit profile';
			case 'profile.editProfile.sections.personalInfo': return 'Personal information';
			case 'profile.editProfile.sections.aboutMe': return 'About me';
			case 'profile.editProfile.sections.favoriteDances': return 'Favorite dances';
			case 'profile.editProfile.sections.level': return 'Level';
			case 'profile.editProfile.sections.socialNetworks': return 'Social networks';
			case 'profile.editProfile.sections.notifications': return 'Notifications';
			case 'profile.editProfile.changePhoto': return 'Change photo';
			case 'profile.editProfile.bio': return 'Description';
			case 'profile.editProfile.bioHint': return 'Write something about yourself...';
			case 'profile.editProfile.selectDanceStyles': return 'Select your favorite dance styles';
			case 'profile.editProfile.yourLevel': return 'Your dance level';
			case 'profile.editProfile.instagram': return 'Instagram';
			case 'profile.editProfile.instagramHint': return '@your_username';
			case 'profile.editProfile.facebook': return 'Facebook';
			case 'profile.editProfile.facebookHint': return 'facebook.com/your.name';
			case 'profile.editProfile.notifications.newEvents': return 'New events';
			case 'profile.editProfile.notifications.eventReminders': return 'Event reminders';
			case 'profile.editProfile.notifications.marketing': return 'Marketing messages';
			case 'profile.editProfile.notificationSubtitles.newEvents': return 'Get notified about new events in your area';
			case 'profile.editProfile.notificationSubtitles.eventReminders': return 'Reminders before your saved events';
			case 'profile.editProfile.notificationSubtitles.marketing': return 'Promotional messages and offers';
			case 'premium.title': return 'Dancee Premium';
			case 'premium.bannerSubtitle': return 'Unlock all features';
			case 'premium.heroTitle': return 'Unlock full potential';
			case 'premium.heroSubtitle': return 'Get access to all premium features and improve your dance experiences';
			case 'premium.featuresTitle': return 'What you get with Premium';
			case 'premium.testimonialsTitle': return 'What our users say';
			case 'premium.faqTitle': return 'Frequently asked questions';
			case 'premium.ctaTitle': return 'Ready to start?';
			case 'premium.ctaSubtitle': return 'Join thousands of satisfied dancers';
			case 'premium.ctaButton': return 'Get Premium now';
			case 'premium.ctaNote': return '7 days free · Cancel anytime';
			case 'saved.title': return 'Saved events';
			case 'saved.subtitle': return 'Your favorite events';
			case 'saved.emptyTitle': return 'No saved events';
			case 'saved.emptySubtitle': return 'Events you save will appear here';
			case 'contact.teamName': return 'Dancee Team';
			case 'contact.email': return 'hello@dancee.app';
			case 'contact.description': return 'We\'d love to read your feedback...';
			case 'contact.responseTime': return 'Response time';
			case 'contact.responseTimeDetail': return 'We usually respond within 24 hours on working days. Thank you for your patience!';
			case 'contact.deviceInfo': return 'Device information';
			case 'contact.autoAttached': return 'Automatically attached';
			case 'contact.form.subject': return 'Message subject';
			case 'contact.form.feedback': return 'Feedback';
			case 'contact.form.reportBug': return 'Report bug';
			case 'contact.form.featureRequest': return 'Feature request';
			case 'contact.form.other': return 'Other';
			case 'contact.form.title': return 'Message title';
			case 'contact.form.titleHint': return 'Briefly describe your issue or suggestion';
			case 'contact.form.message': return 'Message';
			case 'contact.form.messageHint': return 'Describe your issue in detail...';
			case 'contact.form.replyEmail': return 'Your reply email';
			case 'contact.form.sending': return 'Sending...';
			case 'contact.form.sent': return 'Sent!';
			case 'contact.form.submit': return 'Send message';
			case 'contact.deviceInfoLabels.app': return 'App:';
			case 'contact.deviceInfoLabels.device': return 'Device:';
			case 'contact.deviceInfoLabels.os': return 'System:';
			default: return null;
		}
	}
}

extension on _StringsCs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Dancee';
			case 'common.showAll': return 'Zobrazit vše';
			case 'common.date': return 'Datum';
			case 'common.save': return 'Uložit';
			case 'common.share': return 'Sdílet';
			case 'common.map': return 'Mapa';
			case 'common.skip': return 'Přeskočit';
			case 'common.continue_': return 'Pokračovat';
			case 'common.back': return 'Zpět';
			case 'common.finish': return 'Dokončit';
			case 'common.cancel': return 'Zrušit';
			case 'common.support': return 'Podpora';
			case 'common.faq': return 'FAQ';
			case 'common.clear': return 'Vymazat';
			case 'common.current': return 'Aktuální';
			case 'common.saveChanges': return 'Uložit změny';
			case 'common.form.email': return 'E-mail';
			case 'common.form.emailHint': return 'tvuj@email.cz';
			case 'common.form.password': return 'Heslo';
			case 'common.form.passwordPlaceholder': return '••••••••';
			case 'common.form.confirmPassword': return 'Potvrzení hesla';
			case 'common.form.firstName': return 'Jméno';
			case 'common.form.firstNameHint': return 'Tvoje jméno';
			case 'common.form.lastName': return 'Příjmení';
			case 'common.form.lastNameHint': return 'Tvoje příjmení';
			case 'common.form.city': return 'Město';
			case 'common.form.phone': return 'Telefon';
			case 'common.form.fullName': return 'Jméno a příjmení';
			case 'nav.events': return 'Události';
			case 'nav.courses': return 'Kurzy';
			case 'nav.saved': return 'Uložené';
			case 'nav.profile': return 'Profil';
			case 'auth.tagline': return 'Objevuj taneční svět';
			case 'auth.orContinueWith': return 'nebo pokračuj s';
			case 'auth.continueWithGoogle': return 'Pokračovat s Google';
			case 'auth.continueWithApple': return 'Pokračovat s Apple';
			case 'auth.termsPrefix': return 'Pokračováním souhlasíš s našimi ';
			case 'auth.termsOfUse': return 'Podmínkami používání';
			case 'auth.and': return ' a ';
			case 'auth.privacyPolicy': return 'Zásadami ochrany osobních údajů';
			case 'auth.agreeWith': return 'Souhlasím s ';
			case 'auth.orRegisterWith': return 'nebo se zaregistruj s';
			case 'auth.login.title': return 'Vítej zpět!';
			case 'auth.login.subtitle': return 'Přihlaš se a pokračuj v objevování tanečních akcí';
			case 'auth.login.stayLoggedIn': return 'Zůstat přihlášen';
			case 'auth.login.forgotPassword': return 'Zapomenuté heslo?';
			case 'auth.login.submit': return 'Přihlásit se';
			case 'auth.login.noAccount': return 'Nemáš ještě účet?';
			case 'auth.login.register': return 'Zaregistruj se';
			case 'auth.register.title': return 'Vytvoř si účet';
			case 'auth.register.subtitle': return 'Zaregistruj se a začni objevovat taneční akce';
			case 'auth.register.passwordsMatch': return 'Hesla se shodují';
			case 'auth.register.passwordsMismatch': return 'Hesla se neshodují';
			case 'auth.register.newsletter': return 'Chci dostávat novinky o tanečních akcích';
			case 'auth.register.submit': return 'Vytvořit účet';
			case 'auth.register.hasAccount': return 'Už máš účet?';
			case 'auth.register.login': return 'Přihlaš se';
			case 'auth.forgotPassword.title': return 'Zapomenuté heslo?';
			case 'auth.forgotPassword.subtitle': return 'Zadej svůj e-mail a pošleme ti odkaz pro obnovení hesla';
			case 'auth.forgotPassword.submit': return 'Odeslat odkaz';
			case 'auth.forgotPassword.checkInbox': return 'Zkontroluj svou e-mailovou schránku';
			case 'auth.forgotPassword.checkInboxDetail': return 'Po odeslání obdržíš e-mail s odkazem pro obnovení hesla. Odkaz je platný 24 hodin.';
			case 'auth.forgotPassword.rememberPassword': return 'Vzpomněl sis na heslo?';
			case 'auth.forgotPassword.login': return 'Přihlásit se';
			case 'auth.forgotPassword.needHelp': return 'Potřebuješ pomoc?';
			case 'auth.passwordStrength.weak': return 'Slabé heslo';
			case 'auth.passwordStrength.medium': return 'Středně silné';
			case 'auth.passwordStrength.strong': return 'Silné heslo';
			case 'auth.passwordStrength.veryStrong': return 'Velmi silné';
			case 'auth.passwordStrength.hint': return 'Alespoň 8 znaků';
			case 'onboarding.step1.title': return 'Jaké tance tě baví?';
			case 'onboarding.step1.subtitle': return 'Vyber své oblíbené taneční styly, abychom ti mohli nabídnout relevantní akce';
			case 'onboarding.step2.title': return 'Jaká je tvoje úroveň?';
			case 'onboarding.step2.subtitle': return 'Pomůže nám to doporučit ti vhodné akce a kurzy';
			case 'onboarding.step3.title': return 'Kde se nacházíš?';
			case 'onboarding.step3.subtitle': return 'Najdeme pro tebe nejbližší taneční akce ve tvém okolí';
			case 'onboarding.step3.radius10km': return '10 km';
			case 'onboarding.step3.radius25km': return '25 km';
			case 'onboarding.step3.radius50km': return '50 km';
			case 'onboarding.step3.radiusAll': return 'Celá republika';
			case 'onboarding.step3.cityHint': return 'Např. Praha, Brno...';
			case 'onboarding.step3.searchRadius': return 'Vyhledat akce v okruhu';
			case 'onboarding.step3.useCurrentLocation': return 'Použít aktuální polohu';
			case 'events.featuredEvents': return 'Doporučené akce';
			case 'events.upcomingEvents': return 'Nadcházející akce';
			case 'events.danceStyles': return 'Taneční styly';
			case 'events.danceStylesLabel': return 'TANEČNÍ STYLY';
			case 'events.location': return 'Lokalita';
			case 'events.detail.header': return 'Detail akce';
			case 'events.detail.description': return 'Popis akce';
			case 'events.detail.additionalInfo': return 'Dodatečné informace';
			case 'events.detail.admission': return 'Vstupné';
			case 'events.detail.dresscode': return 'Dresscode';
			case 'events.detail.buyTickets': return 'Koupit vstupenky';
			case 'events.detail.originalSource': return 'Původní zdroj';
			case 'events.detail.program': return 'Program akce';
			case 'events.filter.selectedCount': return ({required Object count}) => '${count} vybraných';
			case 'events.filter.selectedStyles': return 'VYBRANÉ STYLY';
			case 'events.filter.apply': return 'Použít filtr';
			case 'events.filter.applyCount': return ({required Object count}) => 'Použít filtr (${count})';
			case 'events.filter.selectLocation': return 'Vybrat lokalitu';
			case 'events.filter.searchCityHint': return 'Hledat město nebo oblast...';
			case 'events.filter.useMyLocation': return 'Použít moji polohu';
			case 'events.filter.useMyLocationSubtitle': return 'Automaticky najde akce ve vašem okolí';
			case 'events.filter.popularCities': return 'Oblíbená města';
			case 'events.filter.allCities': return 'Všechna města';
			case 'events.filters.today': return 'Dnes';
			case 'events.filters.thisWeek': return 'Tento týden';
			case 'events.filters.thisMonth': return 'Tento měsíc';
			case 'events.filters.thisWeekend': return 'Tento víkend';
			case 'courses.title': return 'Taneční kurzy';
			case 'courses.subtitle': return 'Najdi svůj kurz';
			case 'courses.featuredCourses': return 'Doporučené kurzy';
			case 'courses.allCourses': return 'Všechny kurzy';
			case 'courses.detail.header': return 'Detail kurzu';
			case 'courses.detail.description': return 'Popis kurzu';
			case 'courses.detail.details': return 'Podrobnosti kurzu';
			case 'courses.detail.whatYouLearn': return 'Co se naučíte';
			case 'courses.detail.aboutInstructor': return 'O lektorovi';
			case 'courses.detail.shareCourse': return 'Sdílet kurz';
			case 'courses.detail.coursePrice': return 'Cena kurzu';
			case 'courses.detail.availableSpots': return 'Volná místa';
			case 'courses.detail.register': return 'Registrovat se na kurz';
			case 'profile.title': return 'Profil';
			case 'profile.sections.account': return 'Účet';
			case 'profile.sections.settings': return 'Nastavení';
			case 'profile.sections.support': return 'Podpora';
			case 'profile.sections.appInfo': return 'O aplikaci';
			case 'profile.sections.dangerZone': return 'Nebezpečná zóna';
			case 'profile.account.editProfile': return 'Upravit profil';
			case 'profile.account.changePassword': return 'Změnit heslo';
			case 'profile.settings.language': return 'Jazyk';
			case 'profile.settings.czech': return 'Čeština';
			case 'profile.settings.notifications': return 'Oznámení';
			case 'profile.settings.english': return 'Angličtina';
			case 'profile.support.contactAuthor': return 'Napsat autorovi';
			case 'profile.support.rateApp': return 'Ohodnotit aplikaci';
			case 'profile.appInfo.version': return 'Verze aplikace';
			case 'profile.appInfo.termsOfUse': return 'Podmínky použití';
			case 'profile.appInfo.privacy': return 'Ochrana soukromí';
			case 'profile.danger.logout': return 'Odhlásit se';
			case 'profile.danger.deleteAccount': return 'Smazat účet';
			case 'profile.changePassword.title': return 'Změnit heslo';
			case 'profile.changePassword.secureAccount': return 'Zabezpečte svůj účet';
			case 'profile.changePassword.secureAccountDetail': return 'Silné heslo musí obsahovat alespoň 8 znaků, velká a malá písmena, čísla a speciální znaky.';
			case 'profile.changePassword.currentPassword': return 'Současné heslo';
			case 'profile.changePassword.currentPasswordHint': return 'Zadejte současné heslo';
			case 'profile.changePassword.newPassword': return 'Nové heslo';
			case 'profile.changePassword.newPasswordHint': return 'Zadejte nové heslo';
			case 'profile.changePassword.confirmPassword': return 'Potvrdit nové heslo';
			case 'profile.changePassword.confirmPasswordHint': return 'Zadejte nové heslo znovu';
			case 'profile.changePassword.save': return 'Uložit nové heslo';
			case 'profile.changePassword.requirements': return 'POŽADAVKY NA HESLO';
			case 'profile.changePassword.req8chars': return 'Minimálně 8 znaků';
			case 'profile.changePassword.reqUppercase': return 'Alespoň jedno velké písmeno (A-Z)';
			case 'profile.changePassword.reqLowercase': return 'Alespoň jedno malé písmeno (a-z)';
			case 'profile.changePassword.reqNumber': return 'Alespoň jedno číslo (0-9)';
			case 'profile.changePassword.reqSpecial': return 'Alespoň jeden speciální znak (!@#\$%^&*)';
			case 'profile.changePassword.forgotPassword': return 'Zapomněli jste heslo?';
			case 'profile.changePassword.strengthVeryWeak': return 'Síla hesla: Velmi slabé';
			case 'profile.changePassword.strengthWeak': return 'Síla hesla: Slabé';
			case 'profile.changePassword.strengthMedium': return 'Síla hesla: Střední';
			case 'profile.changePassword.strengthStrong': return 'Síla hesla: Silné';
			case 'profile.editProfile.title': return 'Upravit profil';
			case 'profile.editProfile.sections.personalInfo': return 'Osobní údaje';
			case 'profile.editProfile.sections.aboutMe': return 'O mně';
			case 'profile.editProfile.sections.favoriteDances': return 'Oblíbené tance';
			case 'profile.editProfile.sections.level': return 'Úroveň';
			case 'profile.editProfile.sections.socialNetworks': return 'Sociální sítě';
			case 'profile.editProfile.sections.notifications': return 'Oznámení';
			case 'profile.editProfile.changePhoto': return 'Změnit fotku';
			case 'profile.editProfile.bio': return 'Popis';
			case 'profile.editProfile.bioHint': return 'Napište něco o sobě...';
			case 'profile.editProfile.selectDanceStyles': return 'Vyberte své oblíbené tanční styly';
			case 'profile.editProfile.yourLevel': return 'Vaše taneční úroveň';
			case 'profile.editProfile.instagram': return 'Instagram';
			case 'profile.editProfile.instagramHint': return '@vase_uzivatelske_jmeno';
			case 'profile.editProfile.facebook': return 'Facebook';
			case 'profile.editProfile.facebookHint': return 'facebook.com/vase.jmeno';
			case 'profile.editProfile.notifications.newEvents': return 'Nové akce';
			case 'profile.editProfile.notifications.eventReminders': return 'Připomínky akcí';
			case 'profile.editProfile.notifications.marketing': return 'Marketingové zprávy';
			case 'profile.editProfile.notificationSubtitles.newEvents': return 'Dostávejte upozornění o nových akcích ve vašem okolí';
			case 'profile.editProfile.notificationSubtitles.eventReminders': return 'Připomínky před vašimi uloženými akcemi';
			case 'profile.editProfile.notificationSubtitles.marketing': return 'Propagační zprávy a nabídky';
			case 'premium.title': return 'Dancee Premium';
			case 'premium.bannerSubtitle': return 'Odemkněte všechny funkce';
			case 'premium.heroTitle': return 'Odemkněte plný potenciál';
			case 'premium.heroSubtitle': return 'Získejte přístup ke všem prémiové funkcím a zlepšete své taneční zážitky';
			case 'premium.featuresTitle': return 'Co získáte s Premium';
			case 'premium.testimonialsTitle': return 'Co říkají naši uživatelé';
			case 'premium.faqTitle': return 'Časté otázky';
			case 'premium.ctaTitle': return 'Připraveni začít?';
			case 'premium.ctaSubtitle': return 'Připojte se k tisícům spokojených tanečníků';
			case 'premium.ctaButton': return 'Získat Premium nyní';
			case 'premium.ctaNote': return '7 dní zdarma · Zrušte kdykoliv';
			case 'saved.title': return 'Uložené akce';
			case 'saved.subtitle': return 'Tvoje oblíbené akce';
			case 'saved.emptyTitle': return 'Žádné uložené akce';
			case 'saved.emptySubtitle': return 'Akce, které si uložíš, se zobrazí zde';
			case 'contact.teamName': return 'Tým Dancee';
			case 'contact.email': return 'hello@dancee.app';
			case 'contact.description': return 'Rádi si přečteme vaše zpětné vazby...';
			case 'contact.responseTime': return 'Doba odezvy';
			case 'contact.responseTimeDetail': return 'Obvykle odpovídáme do 24 hodin v pracovní dny. Děkujeme za trpělivost!';
			case 'contact.deviceInfo': return 'Informace o zařízení';
			case 'contact.autoAttached': return 'Automaticky přiloženo';
			case 'contact.form.subject': return 'Předmět zprávy';
			case 'contact.form.feedback': return 'Zpětná vazba';
			case 'contact.form.reportBug': return 'Nahlásit problém';
			case 'contact.form.featureRequest': return 'Návrh na vylepšení';
			case 'contact.form.other': return 'Ostatní';
			case 'contact.form.title': return 'Název zprávy';
			case 'contact.form.titleHint': return 'Stručně popište váš problém nebo návrh';
			case 'contact.form.message': return 'Zpráva';
			case 'contact.form.messageHint': return 'Podrobně popište váš problém...';
			case 'contact.form.replyEmail': return 'Váš e-mail pro odpověď';
			case 'contact.form.sending': return 'Odesílání...';
			case 'contact.form.sent': return 'Odesláno!';
			case 'contact.form.submit': return 'Odeslat zprávu';
			case 'contact.deviceInfoLabels.app': return 'Aplikace:';
			case 'contact.deviceInfoLabels.device': return 'Zařízení:';
			case 'contact.deviceInfoLabels.os': return 'Systém:';
			default: return null;
		}
	}
}
