import 'package:wompi_web_checkout/src/models/enums.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart' show WompiLegalId;

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
  const WompiWebCheckoutCustomerInfo({
    this.email,
    this.fullName,
    this.phoneNumber,
    this.legalId,
    this.legalIdType,
  });

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

  @override
  String toString() {
    return '''WompiCustomerData(fullName: $fullName, phoneNumber: $phoneNumber, legalId: $legalId, legalIdType: $legalIdType)''';
  }
}
