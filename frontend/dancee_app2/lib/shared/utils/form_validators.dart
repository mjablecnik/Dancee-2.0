import '../../i18n/strings.g.dart';

class FormValidators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validation.emailRequired;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return t.validation.invalidEmail;
    }
    return null;
  }

  static String? notEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validation.fieldRequired;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) {
      return t.validation.passwordTooShort;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return t.validation.passwordsDoNotMatch;
    }
    return null;
  }

  static int passwordStrength(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[a-z]'))) {
      score++;
    }
    if (value.contains(RegExp(r'[0-9]'))) score++;
    if (value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }
}
