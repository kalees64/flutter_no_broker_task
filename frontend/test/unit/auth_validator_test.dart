import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Validation Rules', () {
    test('Email validator correctly validates addresses', () {
      bool isValidEmail(String email) {
        final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return regex.hasMatch(email.trim());
      }

      expect(isValidEmail('admin@nobroker.in'), isTrue);
      expect(isValidEmail('rajesh.sharma@domain.co'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
      expect(isValidEmail('missing@domain'), isFalse);
      expect(isValidEmail(''), isFalse);
    });

    test('Password validator enforces 8 characters minimum', () {
      bool isValidPassword(String pass) => pass.length >= 8;

      expect(isValidPassword('Pass123!'), isTrue);
      expect(isValidPassword('AdminPass123!'), isTrue);
      expect(isValidPassword('short'), isFalse);
      expect(isValidPassword('1234567'), isFalse);
    });

    test('Phone validator accepts valid international formats', () {
      bool isValidPhone(String phone) {
        final regex = RegExp(r'^[0-9+ -]{7,20}$');
        return regex.hasMatch(phone.trim());
      }

      expect(isValidPhone('+91 9876543210'), isTrue);
      expect(isValidPhone('9876543210'), isTrue);
      expect(isValidPhone('abc'), isFalse);
    });
  });
}
