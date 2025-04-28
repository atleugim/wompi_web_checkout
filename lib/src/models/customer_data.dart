import 'package:wompi_web_checkout/src/exceptions/wompi_exceptions.dart';
import 'package:wompi_web_checkout/src/models/enums.dart';
import 'package:wompi_web_checkout/src/validators/validators.dart';

/// Customer information for Wompi payments
class WompiWebCheckoutCustomerInfo {
  /// Creates a new [WompiWebCheckoutCustomerInfo] instance
  ///
  /// Optional parameters include:
  /// - `email`: Email to which the payment receipt is sent.
  /// - `fullName`: Full name of payer (first and last names)
  /// - `phoneNumber`: Payer's phone number
  /// - `legalId`: Payer's document number
  /// - `legalIdType`: Type of payer's document
  WompiWebCheckoutCustomerInfo({
    this.email,
    this.fullName,
    this.phoneNumber,
    this.legalId,
    this.legalIdType,
  }) {
    if (email != null && !WompiFieldValidator.isValidEmail(email)) {
      throw WompiInvalidArgumentException(
        'email',
        description: 'Invalid email format',
      );
    }

    if (fullName != null && fullName!.isEmpty) {
      throw WompiInvalidArgumentException(
        'fullName',
        description: 'Full name cannot be empty',
      );
    }

    if (phoneNumber != null &&
        !WompiFieldValidator.isValidPhoneNumber(phoneNumber)) {
      throw WompiInvalidArgumentException(
        'phoneNumber',
        description: 'Invalid phone number format',
      );
    }
  }

  /// Email to which the payment receipt is sent.
  ///
  /// For example:
  /// - example@wompi.co
  final String? email;

  /// Full name of payer (first and last names)
  ///
  /// For example:
  /// - Miguel Ángel Vega Jiménez
  final String? fullName;

  /// Payer's phone number
  ///
  /// For example:
  /// - 3307654321
  final String? phoneNumber;

  /// Payer's document number
  ///
  /// For example:
  /// - 1234567890
  final String? legalId;

  /// Type of payer's document
  ///
  /// For example:
  /// - [WompiLegalId.cc]
  ///
  /// Can use the [WompiLegalId.fromCode] method to convert a string to a
  /// [WompiLegalId]
  final WompiLegalId? legalIdType;

  /// Creates a copy of this [WompiWebCheckoutCustomerInfo] with the given
  /// fields replaced with the new values.
  WompiWebCheckoutCustomerInfo copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    String? legalId,
    WompiLegalId? legalIdType,
  }) {
    return WompiWebCheckoutCustomerInfo(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      legalId: legalId ?? this.legalId,
      legalIdType: legalIdType ?? this.legalIdType,
    );
  }

  @override
  String toString() {
    return '''WompiCustomerData(fullName: $fullName, phoneNumber: $phoneNumber, legalId: $legalId, legalIdType: $legalIdType)''';
  }
}
