/// Pure Dart validators for authentication credentials.
///
/// Fully UI-independent and directly testable without Flutter dependencies.
abstract final class AuthValidators {
  static const int minPasswordLength = 8;

  // Standard RFC 5322 compliant email regex pattern
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Checks if [email] is formatted properly.
  static bool isValidEmail(String? email) {
    if (email == null) return false;
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    return _emailRegExp.hasMatch(trimmed);
  }

  /// Checks if [password] meets minimum length requirements (>= 8 characters).
  static bool isValidPassword(String? password) {
    if (password == null) return false;
    return password.length >= minPasswordLength;
  }

  /// Checks if [name] is non-empty after trimming.
  static bool isValidName(String? name) {
    if (name == null) return false;
    return name.trim().isNotEmpty;
  }

  /// Validates an email input and returns a localization key on failure, or `null` if valid.
  static String? validateEmail(
    String? value, {
    String emptyErrorKey = 'auth.validation.email_required',
    String invalidErrorKey = 'auth.validation.email_invalid',
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyErrorKey;
    }
    if (!isValidEmail(value)) {
      return invalidErrorKey;
    }
    return null;
  }

  /// Validates a password input and returns a localization key on failure, or `null` if valid.
  static String? validatePassword(
    String? value, {
    String emptyErrorKey = 'auth.validation.password_required',
    String tooShortErrorKey = 'auth.validation.password_too_short',
  }) {
    if (value == null || value.isEmpty) {
      return emptyErrorKey;
    }
    if (!isValidPassword(value)) {
      return tooShortErrorKey;
    }
    return null;
  }

  /// Validates a customer name input and returns a localization key on failure, or `null` if valid.
  static String? validateName(
    String? value, {
    String emptyErrorKey = 'auth.validation.name_required',
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyErrorKey;
    }
    return null;
  }

  // Egyptian mobile regex pattern (010, 011, 012, 015 followed by 8 digits)
  static final RegExp _egyptianPhoneRegExp = RegExp(r'^01[0125][0-9]{8}$');

  /// Checks if [phone] is a valid 11-digit Egyptian mobile number.
  static bool isValidPhone(String? phone) {
    if (phone == null) return false;
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return false;
    return _egyptianPhoneRegExp.hasMatch(trimmed);
  }

  /// Validates a phone input.
  /// If [isRequired] is false and input is empty/null, it returns `null` (valid).
  /// Otherwise checks format and returns the error localization key.
  static String? validatePhone(
    String? value, {
    bool isRequired = true,
    String emptyErrorKey = 'auth.validation.phone_required',
    String invalidErrorKey = 'auth.validation.phone_invalid',
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? emptyErrorKey : null;
    }
    if (!isValidPhone(value)) {
      return invalidErrorKey;
    }
    return null;
  }

  /// Validates a delivery address.
  static String? validateAddress(
    String? value, {
    bool isRequired = true,
    String emptyErrorKey = 'auth.validation.address_required',
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? emptyErrorKey : null;
    }
    return null;
  }
}
