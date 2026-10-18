import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/auth/domain/validators/auth_validators.dart';

void main() {
  group('AuthValidators - Email', () {
    test('isValidEmail returns false for null, empty, and whitespace', () {
      expect(AuthValidators.isValidEmail(null), isFalse);
      expect(AuthValidators.isValidEmail(''), isFalse);
      expect(AuthValidators.isValidEmail('   '), isFalse);
    });

    test('isValidEmail returns false for malformed emails', () {
      expect(AuthValidators.isValidEmail('plainaddress'), isFalse);
      expect(AuthValidators.isValidEmail('@missingusername.com'), isFalse);
      expect(AuthValidators.isValidEmail('user@'), isFalse);
      expect(AuthValidators.isValidEmail('user@domain'), isFalse);
      expect(AuthValidators.isValidEmail('user@.com'), isFalse);
    });

    test('isValidEmail returns true for valid email formats', () {
      expect(AuthValidators.isValidEmail('user@example.com'), isTrue);
      expect(AuthValidators.isValidEmail('dr.tarek@alexhealth.eg'), isTrue);
      expect(AuthValidators.isValidEmail('ahmed+store@indexpharma.com'), isTrue);
      expect(AuthValidators.isValidEmail('  customer@domain.com  '), isTrue);
    });

    test('validateEmail returns required key for null, empty, or whitespace', () {
      expect(
        AuthValidators.validateEmail(null),
        equals('auth.validation.email_required'),
      );
      expect(
        AuthValidators.validateEmail(''),
        equals('auth.validation.email_required'),
      );
      expect(
        AuthValidators.validateEmail('   '),
        equals('auth.validation.email_required'),
      );
    });

    test('validateEmail returns invalid key for invalid emails', () {
      expect(
        AuthValidators.validateEmail('invalid-email'),
        equals('auth.validation.email_invalid'),
      );
      expect(
        AuthValidators.validateEmail('user@com'),
        equals('auth.validation.email_invalid'),
      );
    });

    test('validateEmail returns null for valid emails', () {
      expect(AuthValidators.validateEmail('user@example.com'), isNull);
    });

    test('validateEmail supports custom error keys', () {
      expect(
        AuthValidators.validateEmail('', emptyErrorKey: 'custom_empty'),
        equals('custom_empty'),
      );
      expect(
        AuthValidators.validateEmail('bad', invalidErrorKey: 'custom_invalid'),
        equals('custom_invalid'),
      );
    });
  });

  group('AuthValidators - Password', () {
    test('isValidPassword returns false for null, empty, and strings < 8 chars', () {
      expect(AuthValidators.isValidPassword(null), isFalse);
      expect(AuthValidators.isValidPassword(''), isFalse);
      expect(AuthValidators.isValidPassword('1234567'), isFalse);
      expect(AuthValidators.isValidPassword('short'), isFalse);
    });

    test('isValidPassword returns true for strings with 8 or more characters', () {
      expect(AuthValidators.isValidPassword('12345678'), isTrue);
      expect(AuthValidators.isValidPassword('SecurePass123!'), isTrue);
      expect(AuthValidators.isValidPassword('extremely_long_secure_password'), isTrue);
    });

    test('validatePassword returns required key for null or empty', () {
      expect(
        AuthValidators.validatePassword(null),
        equals('auth.validation.password_required'),
      );
      expect(
        AuthValidators.validatePassword(''),
        equals('auth.validation.password_required'),
      );
    });

    test('validatePassword returns too short key for passwords < 8 chars', () {
      expect(
        AuthValidators.validatePassword('1234567'),
        equals('auth.validation.password_too_short'),
      );
    });

    test('validatePassword returns null for valid passwords >= 8 chars', () {
      expect(AuthValidators.validatePassword('12345678'), isNull);
      expect(AuthValidators.validatePassword('password123'), isNull);
    });

    test('validatePassword supports custom error keys', () {
      expect(
        AuthValidators.validatePassword('', emptyErrorKey: 'custom_empty'),
        equals('custom_empty'),
      );
      expect(
        AuthValidators.validatePassword('123', tooShortErrorKey: 'custom_short'),
        equals('custom_short'),
      );
    });
  });

  group('AuthValidators - Name', () {
    test('isValidName returns false for null, empty, and whitespace', () {
      expect(AuthValidators.isValidName(null), isFalse);
      expect(AuthValidators.isValidName(''), isFalse);
      expect(AuthValidators.isValidName('   '), isFalse);
    });

    test('isValidName returns true for non-empty names', () {
      expect(AuthValidators.isValidName('أحمد'), isTrue);
      expect(AuthValidators.isValidName('Ahmed Ibrahim'), isTrue);
      expect(AuthValidators.isValidName('  د. طارق محمود  '), isTrue);
    });

    test('validateName returns required key for null, empty, or whitespace', () {
      expect(
        AuthValidators.validateName(null),
        equals('auth.validation.name_required'),
      );
      expect(
        AuthValidators.validateName(''),
        equals('auth.validation.name_required'),
      );
      expect(
        AuthValidators.validateName('   '),
        equals('auth.validation.name_required'),
      );
    });

    test('validateName returns null for valid names', () {
      expect(AuthValidators.validateName('Ahmed'), isNull);
      expect(AuthValidators.validateName('أحمد محمود'), isNull);
    });

    test('validateName supports custom error keys', () {
      expect(
        AuthValidators.validateName('', emptyErrorKey: 'custom_name_empty'),
        equals('custom_name_empty'),
      );
    });
  });
}
