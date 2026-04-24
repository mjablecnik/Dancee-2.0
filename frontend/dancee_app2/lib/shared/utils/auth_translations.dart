import '../../i18n/strings.g.dart';

/// Resolves an auth error translation key emitted by [AuthRepository.mapFirebaseError]
/// (and stored in [AuthState.error.message]) into a user-visible translated string.
///
/// Falls back to the generic error message for unknown or unrecognised keys,
/// including any raw exception messages that are not translation keys.
String resolveAuthErrorKey(String key) {
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
      return t.auth.errors.generic;
  }
}

/// Resolves a validation translation key returned by [FormValidators] into a
/// user-visible translated string. Returns [null] when [key] is [null] (valid
/// field). Falls back to the raw [key] string for unrecognised keys.
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
