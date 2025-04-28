import 'package:email_validator/email_validator.dart';

/// A utility class that provides validation methods for various Wompi fields.
class WompiFieldValidator {
  /// Validates if the given email address is in a valid format.
  static bool isValidEmail(String? email) {
    if (email == null) {
      return false;
    }

    return EmailValidator.validate(email);
  }

  static bool _onlyNumbers(String? value) {
    if (value == null) {
      return false;
    }

    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  /// Validates if the given phone number is in a valid format for Wompi.
  ///
  /// The phone number must:
  /// - Not start with a country code (+)
  /// - Contain only numbers
  /// - Be exactly 10 digits long
  static bool isValidPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null) {
      return false;
    }

    // if phone number contains the country code then is not valid
    if (phoneNumber.startsWith('+')) {
      return false;
    }

    if (!_onlyNumbers(phoneNumber) || phoneNumber.length != 10) {
      return false;
    }

    return true;
  }
}
