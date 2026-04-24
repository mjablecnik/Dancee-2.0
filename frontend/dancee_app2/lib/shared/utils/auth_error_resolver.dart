import '../../i18n/strings.g.dart';

/// Resolves an auth error translation key (e.g. 'auth.errors.invalidCredential')
/// to its translated string. Returns the raw key if no mapping is found.
String resolveAuthError(String key) {
  switch (key) {
    case 'auth.errors.invalidCredential':
      return t.auth.errors.invalidCredential;
    case 'auth.errors.userDisabled':
      return t.auth.errors.userDisabled;
    case 'auth.errors.emailAlreadyInUse':
      return t.auth.errors.emailAlreadyInUse;
    case 'auth.errors.weakPassword':
      return t.auth.errors.weakPassword;
    case 'auth.errors.tooManyRequests':
      return t.auth.errors.tooManyRequests;
    case 'auth.errors.networkError':
      return t.auth.errors.networkError;
    case 'auth.errors.generic':
      return t.auth.errors.generic;
    default:
      return key;
  }
}

/// Resolves a form validation translation key (e.g. 'validation.invalidEmail')
/// to its translated string. Returns null if [key] is null.
String? resolveValidationKey(String? key) {
  if (key == null) return null;
  switch (key) {
    case 'validation.emailRequired':
      return t.validation.emailRequired;
    case 'validation.invalidEmail':
      return t.validation.invalidEmail;
    case 'validation.fieldRequired':
      return t.validation.fieldRequired;
    case 'validation.passwordTooShort':
      return t.validation.passwordTooShort;
    case 'validation.passwordsDoNotMatch':
      return t.validation.passwordsDoNotMatch;
    default:
      return key;
  }
}
