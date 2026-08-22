import 'package:meta/meta.dart';
import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';
import 'package:wompi_web_checkout/src/utils/validation_error_collector.dart';
import 'package:wompi_web_checkout/src/utils/validators.dart';

/// Shipping address, used to pre-fill the shipping form of the Web
/// Checkout.
@immutable
final class WompiShippingAddress {
  /// Creates a [WompiShippingAddress] instance.
  ///
  /// Throws a [WompiValidationException] if any field is invalid;
  /// optional fields, when provided, must not be empty.
  WompiShippingAddress({
    required this.addressLine1,
    required this.country,
    required this.region,
    required this.city,
    required this.phoneNumber,
    this.addressLine2,
    this.name,
    this.postalCode,
  }) {
    final errors = ValidationErrorCollector();

    if (addressLine1.trim().isEmpty) {
      errors.add(
        field: 'addressLine1',
        message: 'Address line 1 cannot be empty.',
      );
    }
    if (!WompiValidators.isValidCountryCode(country)) {
      errors.add(
        field: 'country',
        message: 'Country must be an ISO 3166-1 Alpha-2 code: 2 capital '
            'letters (e.g. "CO").',
      );
    }
    if (region.trim().isEmpty) {
      errors.add(field: 'region', message: 'Region cannot be empty.');
    }
    if (city.trim().isEmpty) {
      errors.add(field: 'city', message: 'City cannot be empty.');
    }
    if (!WompiValidators.isValidPhoneNumber(phoneNumber)) {
      errors.add(
        field: 'phoneNumber',
        message: 'Phone number must contain only digits (7 to 15) and must '
            'not include the country code.',
      );
    }
    if (addressLine2 != null && addressLine2!.trim().isEmpty) {
      errors.add(
        field: 'addressLine2',
        message: 'Address line 2 cannot be empty when provided.',
      );
    }
    if (name != null && name!.trim().isEmpty) {
      errors.add(field: 'name', message: 'Name cannot be empty when provided.');
    }
    if (postalCode != null && postalCode!.trim().isEmpty) {
      errors.add(
        field: 'postalCode',
        message: 'Postal code cannot be empty when provided.',
      );
    }

    errors.throwIfAny();
  }

  /// Primary address data.
  ///
  /// For example: `Carrera 123 # 4-5`.
  final String addressLine1;

  /// Secondary address data.
  ///
  /// For example: `Apartment 502, Tower I`.
  final String? addressLine2;

  /// Country of shipment in ISO 3166-1 Alpha-2 format (2 capital letters).
  ///
  /// For example: `CO`.
  final String country;

  /// Department, state or region (as applicable).
  ///
  /// For example: `Antioquia`.
  final String region;

  /// City or municipality.
  ///
  /// For example: `Medellín`.
  final String city;

  /// Name of the recipient.
  ///
  /// For example: `Miguel Vega`.
  final String? name;

  /// Recipient's phone number, without the country code (7 to 15 digits).
  ///
  /// For example: `3109999999`.
  final String phoneNumber;

  /// Postal code.
  ///
  /// For example: `050001`.
  final String? postalCode;

  /// Creates a copy with the given fields replaced.
  ///
  /// A `null` argument keeps the current value; use [clear] to remove an
  /// optional field.
  WompiShippingAddress copyWith({
    String? addressLine1,
    String? addressLine2,
    String? country,
    String? region,
    String? city,
    String? name,
    String? phoneNumber,
    String? postalCode,
  }) {
    return WompiShippingAddress(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      country: country ?? this.country,
      region: region ?? this.region,
      city: city ?? this.city,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  /// Creates a copy with the optional fields flagged `true` removed.
  WompiShippingAddress clear({
    bool addressLine2 = false,
    bool name = false,
    bool postalCode = false,
  }) {
    return WompiShippingAddress(
      addressLine1: addressLine1,
      addressLine2: addressLine2 ? null : this.addressLine2,
      country: country,
      region: region,
      city: city,
      name: name ? null : this.name,
      phoneNumber: phoneNumber,
      postalCode: postalCode ? null : this.postalCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WompiShippingAddress &&
          runtimeType == other.runtimeType &&
          addressLine1 == other.addressLine1 &&
          addressLine2 == other.addressLine2 &&
          country == other.country &&
          region == other.region &&
          city == other.city &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          postalCode == other.postalCode;

  @override
  int get hashCode => Object.hash(
        addressLine1,
        addressLine2,
        country,
        region,
        city,
        name,
        phoneNumber,
        postalCode,
      );

  @override
  String toString() {
    return 'WompiShippingAddress(addressLine1: $addressLine1, '
        'addressLine2: $addressLine2, country: $country, region: $region, '
        'city: $city, name: $name, phoneNumber: $phoneNumber, '
        'postalCode: $postalCode)';
  }
}
