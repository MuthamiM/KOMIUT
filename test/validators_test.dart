import 'package:flutter_test/flutter_test.dart';
import 'package:komiut_app/core/utils/validators.dart';

void main() {
  group('Validators Test', () {
    test('Email validation - valid emails', () {
      expect(Validators.validateEmail('test@gmail.com'), null);
      expect(Validators.validateEmail('user.name@domain.co.ke'), null);
    });

    test('Email validation - invalid emails', () {
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('invalid-email'), 'Enter a valid email address');
      expect(Validators.validateEmail('test@domain'), 'Enter a valid email address');
    });

    test('Password validation', () {
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(Validators.validatePassword('password123'), null);
    });

    test('Name validation', () {
      expect(Validators.validateName(''), 'Name is required');
      expect(Validators.validateName('Eric'), 'Enter your full name');
      expect(Validators.validateName('Eric Muthemba'), null);
    });

    test('OTP validation', () {
      expect(Validators.validateOTP(''), 'OTP is required');
      expect(Validators.validateOTP('123'), 'Enter a 6-digit code');
      expect(Validators.validateOTP('abc123'), 'Enter a valid numeric code');
      expect(Validators.validateOTP('123456'), null);
    });
  });
}
