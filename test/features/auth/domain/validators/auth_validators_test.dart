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

  group('AuthValidators - Egyptian Phone', () {
    test('isValidPhone returns false for null, empty, and whitespace', () {
      expect(AuthValidators.isValidPhone(null), isFalse);
      expect(AuthValidators.isValidPhone(''), isFalse);
      expect(AuthValidators.isValidPhone('   '), isFalse);
    });

    test('isValidPhone returns false for non-11 digits or non-Egyptian prefixes', () {
      expect(AuthValidators.isValidPhone('0101234567'), isFalse); // 10 digits
      expect(AuthValidators.isValidPhone('010123456789'), isFalse); // 12 digits
      expect(AuthValidators.isValidPhone('01912345678'), isFalse); // invalid prefix 019
      expect(AuthValidators.isValidPhone('02212345678'), isFalse); // landline prefix
      expect(AuthValidators.isValidPhone('abcdefghijk'), isFalse);
      expect(AuthValidators.isValidPhone('0101234abcd'), isFalse);
    });

    test('isValidPhone returns true for valid Egyptian mobile prefixes', () {
      expect(AuthValidators.isValidPhone('01012345678'), isTrue); // Vodafone
      expect(AuthValidators.isValidPhone('01112345678'), isTrue); // Etisalat
      expect(AuthValidators.isValidPhone('01212345678'), isTrue); // Orange
      expect(AuthValidators.isValidPhone('01512345678'), isTrue); // WE
      expect(AuthValidators.isValidPhone('  01098765432  '), isTrue); // trimmed
    });

    test('validatePhone when required returns empty key on null or empty', () {
      expect(
        AuthValidators.validatePhone(null, isRequired: true),
        equals('auth.validation.phone_required'),
      );
      expect(
        AuthValidators.validatePhone('', isRequired: true),
        equals('auth.validation.phone_required'),
      );
      expect(
        AuthValidators.validatePhone('   ', isRequired: true),
        equals('auth.validation.phone_required'),
      );
    });

    test('validatePhone when optional returns null on null or empty', () {
      expect(AuthValidators.validatePhone(null, isRequired: false), isNull);
      expect(AuthValidators.validatePhone('', isRequired: false), isNull);
      expect(AuthValidators.validatePhone('   ', isRequired: false), isNull);
    });

    test('validatePhone returns invalid key on malformed Egyptian numbers', () {
      expect(
        AuthValidators.validatePhone('012345', isRequired: true),
        equals('auth.validation.phone_invalid'),
      );
      expect(
        AuthValidators.validatePhone('012345', isRequired: false),
        equals('auth.validation.phone_invalid'),
      );
    });

    test('validatePhone returns null on valid Egyptian numbers', () {
      expect(
        AuthValidators.validatePhone('01012345678', isRequired: true),
        isNull,
      );
      expect(
        AuthValidators.validatePhone('01198765432', isRequired: false),
        isNull,
      );
    });
  });

  group('AuthValidators - Address', () {
    test('validateAddress returns required key on null or empty when required', () {
      expect(
        AuthValidators.validateAddress(null, isRequired: true),
        equals('auth.validation.address_required'),
      );
      expect(
        AuthValidators.validateAddress('', isRequired: true),
        equals('auth.validation.address_required'),
      );
      expect(
        AuthValidators.validateAddress('   ', isRequired: true),
        equals('auth.validation.address_required'),
      );
    });

    test('validateAddress returns null on null or empty when optional', () {
      expect(AuthValidators.validateAddress(null, isRequired: false), isNull);
      expect(AuthValidators.validateAddress('', isRequired: false), isNull);
    });

    test('validateAddress returns null for valid address strings', () {
      expect(
        AuthValidators.validateAddress('شارع عباس العقاد، مدينة نصر'),
        isNull,
      );
    });
  });
}
