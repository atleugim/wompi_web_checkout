import 'package:wompi_web_checkout/wompi_web_checkout.dart';

/// Payment data for Wompi checkout
class WompiWebCheckoutData {
  /// Creates a new [WompiWebCheckoutData] instance with the required payment
  /// information.
  ///
  /// The `amountInCents`, `reference`, and `customerData` are required
  /// parameters.
  ///
  /// Optional parameters include:
  /// - `currency`: Defaults to 'COP' (Colombian Peso)
  /// - `redirectUrl`: URL to redirect after payment completion
  /// - `expirationTime`: Payment expiration date and time
  /// - `shippingAddress`: Delivery address information
  WompiWebCheckoutData({
    required this.amountInCents,
    required this.reference,
    this.customerInfo,
    this.shippingAddressInfo,
    this.currency = 'COP',
    this.redirectUrl,
    this.expirationTime,
  }) {
    if (currency != 'COP') {
      throw WompiInvalidArgumentException(
        'currency',
        description:
            'Only COP (Colombian Peso) is currently supported for currency.',
      );
    }

    if (amountInCents <= 0) {
      throw WompiInvalidArgumentException(
        'amountInCents',
        description: 'Amount in cents must be greater than 0.',
      );
    }

    if (amountInCents > 1000000000000) {
      throw WompiInvalidArgumentException(
        'amountInCents',
        description:
            'Amount in cents must be less than or equal to 1000000000000.',
      );
    }

    if (reference.isEmpty) {
      throw WompiInvalidArgumentException(
        'reference',
        description: 'Reference cannot be empty.',
      );
    }

    if (expirationTime != null && expirationTime!.isBefore(DateTime.now())) {
      throw WompiInvalidArgumentException(
        'expirationTime',
        description: 'Expiration time must be in the future.',
      );
    }

    if (redirectUrl != null &&
        (Uri.tryParse(redirectUrl!)?.hasScheme ?? false) == false) {
      throw WompiInvalidArgumentException(
        'redirectUrl',
        description: 'Redirect URL must be a valid URL.',
      );
    }
  }

  /// Total amount in cents of the transaction.
  ///
  /// For example:
  /// - For $1000 you write 100000
  ///
  /// The amount must be:
  /// - Minimum: 1 cent
  /// - Maximum: 1000000000000 cents
  final int amountInCents;

  /// Currency in which the transaction is to be made.
  ///
  /// Currently only supports Colombian Peso (COP).
  final String currency;

  /// URL to which the user is taken after making the payment.
  ///
  /// For example:
  /// - https://mitienda.com.co/pago/resultado
  final String? redirectUrl;

  /// Unique reference in the database of each business.
  ///
  /// For example:
  /// - TUPtdnVugyU40XlkhixhhGE6uYV2gh89
  final String reference;

  /// Date and time in ISO8601 format (UTC+0000), activates a countdown timer
  /// indicating the time remaining until the expiration of the payment start
  /// date.
  ///
  /// For example:
  /// - 2023-06-09T20:28:50.000Z
  final DateTime? expirationTime;

  /// Customer information for Wompi payments
  final WompiWebCheckoutCustomerInfo? customerInfo;

  /// Shipping address information for Wompi payments
  final WompiWebCheckoutShippingAddressInfo? shippingAddressInfo;

  /// Converts the payment data into a map of URL query parameters for Wompi
  /// web checkout.
  Map<String, String> getCheckoutQueryParams() {
    final params = <String, String>{
      'currency': currency,
      'amount-in-cents': amountInCents.toString(),
      'reference': reference,
    };

    if (redirectUrl != null) {
      params['redirect-url'] = redirectUrl!;
    }

    if (expirationTime != null) {
      params['expiration-time'] = expirationTime!.toIso8601String();
    }

    if (customerInfo != null) {
      params.addAll({
        if (customerInfo!.email != null)
          'customer-data:email': customerInfo!.email!,
        if (customerInfo!.fullName != null)
          'customer-data:full-name': customerInfo!.fullName!,
        if (customerInfo!.phoneNumber != null)
          'customer-data:phone-number': customerInfo!.phoneNumber!,
        if (customerInfo!.legalId != null)
          'customer-data:legal-id': customerInfo!.legalId!,
        if (customerInfo!.legalIdType != null)
          'customer-data:legal-id-type': customerInfo!.legalIdType!.code,
      });
    }

    if (shippingAddressInfo != null) {
      params.addAll({
        'shipping-address:address-line-1': shippingAddressInfo!.addressLine1,
        'shipping-address:country': shippingAddressInfo!.country,
        'shipping-address:region': shippingAddressInfo!.region,
        'shipping-address:city': shippingAddressInfo!.city,
        'shipping-address:phone-number': shippingAddressInfo!.phoneNumber,
        if (shippingAddressInfo!.addressLine2 != null)
          'shipping-address:address-line-2': shippingAddressInfo!.addressLine2!,
        if (shippingAddressInfo!.name != null)
          'shipping-address:name': shippingAddressInfo!.name!,
        if (shippingAddressInfo!.postalCode != null)
          'shipping-address:postal-code': shippingAddressInfo!.postalCode!,
      });
    }

    return params;
  }

  @override
  String toString() {
    return '''WompiPaymentData(currency: $currency, amountInCents: $amountInCents, reference: $reference, redirectUrl: $redirectUrl, expirationTime: $expirationTime, customerData: $customerInfo, shippingAddress: $shippingAddressInfo)''';
  }
}
