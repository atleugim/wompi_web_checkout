// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:wompi_web_checkout/src/exceptions/wompi_exceptions.dart';
import 'package:wompi_web_checkout/src/validators/validators.dart';

/// Shipping address information for Wompi payments
class WompiWebCheckoutShippingAddressInfo {
  /// Creates a new [WompiWebCheckoutShippingAddressInfo] instance with the
  /// required shipping address information.
  ///
  /// Required parameters:
  /// - `addressLine1`: Primary address data
  /// - `country`: Country of shipment in ISO 3166-1 Alpha-2 format
  /// - `city`: City or municipality
  /// - `region`: Department/State/Region
  /// - `phoneNumber`: Receiver's phone number
  ///
  /// Optional parameters:
  /// - `addressLine2`: Secondary address data
  /// - `name`: Name of recipient
  /// - `postalCode`: Postal code
  WompiWebCheckoutShippingAddressInfo({
    required this.addressLine1,
    required this.country,
    required this.region,
    required this.city,
    required this.phoneNumber,
    this.addressLine2,
    this.name,
    this.postalCode,
  }) {
    if (addressLine1.isEmpty) {
      throw WompiInvalidArgumentException(
        'addressLine1',
        description: 'Address line 1 cannot be empty',
      );
    }

    if (country.isEmpty) {
      throw WompiInvalidArgumentException(
        'country',
        description: 'Country cannot be empty',
      );
    }

    if (region.isEmpty) {
      throw WompiInvalidArgumentException(
        'region',
        description: 'Region cannot be empty',
      );
    }

    if (city.isEmpty) {
      throw WompiInvalidArgumentException(
        'city',
        description: 'City cannot be empty',
      );
    }

    if (!WompiFieldValidator.isValidPhoneNumber(phoneNumber)) {
      throw WompiInvalidArgumentException(
        'phoneNumber',
        description: 'Invalid phone number format',
      );
    }
  }

  /// Primary address data
  ///
  /// For example:
  /// - 34th Street # 56 - 78
  final String addressLine1;

  /// Secondary address data
  ///
  /// For example:
  /// - Apartment 502, Tower I
  final String? addressLine2;

  /// Country of shipment in ISO 3166-1 Alpha-2 format (2 capital letters)
  ///
  /// For example:
  /// - CO
  final String country;

  /// Department / State / Region (as applicable)
  ///
  /// For example:
  /// - Antioquia
  final String region;

  /// City or municipality
  ///
  /// For example:
  /// - Medellín
  final String city;

  /// Name of recipient
  ///
  /// For example:
  /// - Miguel Vega
  final String? name;

  /// Receiver's phone number
  ///
  /// For example:
  /// - 3109999999
  final String phoneNumber;

  /// Postal Code
  ///
  /// For example:
  /// - 111111
  final String? postalCode;

  /// Creates a copy of this [WompiWebCheckoutShippingAddressInfo] with the
  /// given fields replaced with the new values.
  WompiWebCheckoutShippingAddressInfo copyWith({
    String? addressLine1,
    String? addressLine2,
    String? country,
    String? region,
    String? city,
    String? name,
    String? phoneNumber,
    String? postalCode,
  }) {
    return WompiWebCheckoutShippingAddressInfo(
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

  @override
  String toString() {
    return '''WompiShippingAddress(addressLine1: $addressLine1, addressLine2: $addressLine2, country: $country, region: $region, city: $city, name: $name, phoneNumber: $phoneNumber, postalCode: $postalCode)''';
  }
}
