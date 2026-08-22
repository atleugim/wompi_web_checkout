import 'package:meta/meta.dart';
import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';
import 'package:wompi_web_checkout/src/models/legal_id_type.dart';
import 'package:wompi_web_checkout/src/utils/validation_error_collector.dart';
import 'package:wompi_web_checkout/src/utils/validators.dart';

/// Payer information, used to pre-fill the contact form of the Web
/// Checkout.
///
/// All fields are optional, but Wompi requires two pairs to travel
/// together: [phoneNumber] with [phoneNumberPrefix], and [legalId] with
/// [legalIdType].
@immutable
final class WompiCustomerData {
  /// Creates a [WompiCustomerData] instance.
  ///
  /// Throws a [WompiValidationException] if any field is invalid.
  WompiCustomerData({
    this.email,
    this.fullName,
    this.phoneNumber,
    this.phoneNumberPrefix,
    this.legalId,
    this.legalIdType,
  }) {
    final errors = ValidationErrorCollector();

    if (email != null && !WompiValidators.isValidEmail(email!)) {
      errors.add(field: 'email', message: 'Invalid email format.');
    }
    if (fullName != null && fullName!.trim().isEmpty) {
      errors.add(field: 'fullName', message: 'Full name cannot be empty.');
    }
    if (phoneNumber != null &&
        !WompiValidators.isValidPhoneNumber(phoneNumber!)) {
      errors.add(
        field: 'phoneNumber',
        message: 'Phone number must contain only digits (7 to 15) and must '
            'not include the country code; use phoneNumberPrefix instead.',
      );
    }
    if (phoneNumberPrefix != null &&
        !WompiValidators.isValidPhoneNumberPrefix(phoneNumberPrefix!)) {
      errors.add(
        field: 'phoneNumberPrefix',
        message: 'Phone number prefix must be a "+" sign followed by 1 to '
            '4 digits (e.g. "+57").',
      );
    }
    if (phoneNumber != null && phoneNumberPrefix == null) {
      errors.add(
        field: 'phoneNumberPrefix',
        message: 'Required when phoneNumber is provided.',
      );
    }
    if (phoneNumberPrefix != null && phoneNumber == null) {
      errors.add(
        field: 'phoneNumber',
        message: 'Required when phoneNumberPrefix is provided.',
      );
    }
    if (legalId != null && legalId!.trim().isEmpty) {
      errors.add(field: 'legalId', message: 'Legal ID cannot be empty.');
    }
    if (legalId != null && legalIdType == null) {
      errors.add(
        field: 'legalIdType',
        message: 'Required when legalId is provided.',
      );
    }
    if (legalIdType != null && legalId == null) {
      errors.add(
        field: 'legalId',
        message: 'Required when legalIdType is provided.',
      );
    }

    errors.throwIfAny();
  }

  /// Email to which the payment receipt is sent.
  ///
  /// For example: `example@wompi.co`.
  final String? email;

  /// Full name of the payer (first and last names).
  ///
  /// For example: `Miguel Ángel Vega Jiménez`.
  final String? fullName;

  /// Payer's phone number, without the country code: 7 to 15 digits.
  ///
  /// For example: `3007654321`. Requires [phoneNumberPrefix].
  final String? phoneNumber;

  /// Country code of the payer's phone number (e.g. `+57`).
  ///
  /// Requires [phoneNumber].
  final String? phoneNumberPrefix;

  /// Payer's identity document number.
  ///
  /// Requires [legalIdType].
  final String? legalId;

  /// Type of the payer's identity document.
  ///
  /// Requires [legalId]. The accepted types depend on the merchant's
  /// country (`WompiCountry.legalIdTypes`), checked when the URL is
  /// generated.
  final WompiLegalIdType? legalIdType;

  /// Creates a copy with the given fields replaced.
  ///
  /// A `null` argument keeps the current value; use [clear] to remove a
  /// field.
  WompiCustomerData copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    String? phoneNumberPrefix,
    String? legalId,
    WompiLegalIdType? legalIdType,
  }) {
    return WompiCustomerData(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneNumberPrefix: phoneNumberPrefix ?? this.phoneNumberPrefix,
      legalId: legalId ?? this.legalId,
      legalIdType: legalIdType ?? this.legalIdType,
    );
  }

  /// Creates a copy with the fields flagged `true` removed.
  ///
  /// Clear both sides of a required pair at once — dropping only
  /// [phoneNumber] or only [legalId] throws a
  /// [WompiValidationException].
  WompiCustomerData clear({
    bool email = false,
    bool fullName = false,
    bool phoneNumber = false,
    bool phoneNumberPrefix = false,
    bool legalId = false,
    bool legalIdType = false,
  }) {
    return WompiCustomerData(
      email: email ? null : this.email,
      fullName: fullName ? null : this.fullName,
      phoneNumber: phoneNumber ? null : this.phoneNumber,
      phoneNumberPrefix: phoneNumberPrefix ? null : this.phoneNumberPrefix,
      legalId: legalId ? null : this.legalId,
      legalIdType: legalIdType ? null : this.legalIdType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WompiCustomerData &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          fullName == other.fullName &&
          phoneNumber == other.phoneNumber &&
          phoneNumberPrefix == other.phoneNumberPrefix &&
          legalId == other.legalId &&
          legalIdType == other.legalIdType;

  @override
  int get hashCode => Object.hash(
        email,
        fullName,
        phoneNumber,
        phoneNumberPrefix,
        legalId,
        legalIdType,
      );

  @override
  String toString() {
    return 'WompiCustomerData(email: $email, fullName: $fullName, '
        'phoneNumber: $phoneNumber, phoneNumberPrefix: $phoneNumberPrefix, '
        'legalId: $legalId, legalIdType: $legalIdType)';
  }
}
