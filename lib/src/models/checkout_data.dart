import 'package:meta/meta.dart';
import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';
import 'package:wompi_web_checkout/src/models/customer_data.dart';
import 'package:wompi_web_checkout/src/models/payment_method_references.dart';
import 'package:wompi_web_checkout/src/models/shipping_address.dart';
import 'package:wompi_web_checkout/src/models/taxes.dart';
import 'package:wompi_web_checkout/src/models/wompi_language.dart';
import 'package:wompi_web_checkout/src/utils/query_params.dart';
import 'package:wompi_web_checkout/src/utils/validation_error_collector.dart';
import 'package:wompi_web_checkout/src/utils/validators.dart';

/// Payment data for a Wompi Web Checkout transaction.
///
/// Only [amountInCents] and [reference] are required; the optional
/// fields pre-fill the checkout forms. The currency is not here: it
/// comes from the merchant's country, set on `WompiWebCheckout`.
///
/// Every field is validated on creation, and a
/// [WompiValidationException] reports **all** the problems found at
/// once.
@immutable
final class WompiCheckoutData {
  /// Creates a [WompiCheckoutData] instance with the payment information.
  ///
  /// Throws a [WompiValidationException] if any field is invalid.
  WompiCheckoutData({
    required this.amountInCents,
    required this.reference,
    this.redirectUrl,
    DateTime? expirationTime,
    this.customerData,
    this.shippingAddress,
    this.taxes,
    this.paymentMethodReferences,
    this.defaultLanguage,
    this.collectShipping = false,
    this.collectCustomerLegalId = false,
  }) : expirationTime = _normalizeExpirationTime(expirationTime) {
    final errors = ValidationErrorCollector();

    if (amountInCents <= 0) {
      errors.add(
        field: 'amountInCents',
        message: 'Amount in cents must be greater than 0.',
      );
    }
    if (reference.trim().isEmpty) {
      errors.add(field: 'reference', message: 'Reference cannot be empty.');
    } else if (!WompiValidators.isValidReference(reference)) {
      errors.add(
        field: 'reference',
        message: 'Reference must be alphanumeric and may only include '
            'dashes ("-") or underscores ("_").',
      );
    }
    if (redirectUrl != null && !WompiValidators.isValidHttpUrl(redirectUrl!)) {
      errors.add(
        field: 'redirectUrl',
        message: 'Redirect URL must be an absolute http(s) URL.',
      );
    }

    errors.throwIfAny();
  }

  /// Total amount of the transaction, **in cents**.
  ///
  /// For example, to charge COP $49.500 use `4950000`.
  final int amountInCents;

  /// Unique payment reference in the merchant's system, alphanumeric and
  /// optionally with dashes (`-`) or underscores (`_`).
  ///
  /// Once used for a payment, a reference cannot be used again.
  final String reference;

  /// URL to which the payer is redirected after completing the payment.
  ///
  /// Wompi appends the transaction `id` as a query parameter.
  final String? redirectUrl;

  /// Date and time at which the payment expires, activating a countdown
  /// in the checkout.
  ///
  /// Stored in UTC with millisecond precision, the ISO 8601 format Wompi
  /// expects (e.g. `2023-06-09T20:28:50.000Z`). It must be in the future
  /// when the checkout URL is generated — the client checks that then,
  /// not here, so checkout data stays safe to store and reuse.
  final DateTime? expirationTime;

  /// Payer information used to pre-fill the checkout contact form.
  final WompiCustomerData? customerData;

  /// Shipping address information used to pre-fill the shipping form.
  final WompiShippingAddress? shippingAddress;

  /// Tax breakdown of the payment, in cents.
  ///
  /// Informational only: taxes must already be included in
  /// [amountInCents]. Panama reports the ITBMS through [WompiTaxes.vat]
  /// and rejects the consumption tax.
  final WompiTaxes? taxes;

  /// Extra references forwarded to the payment method.
  ///
  /// Colombia only.
  final WompiPaymentMethodReferences? paymentMethodReferences;

  /// Language the checkout page is rendered in (`default-language`).
  ///
  /// Panama only. When omitted, Wompi picks its own default.
  final WompiLanguage? defaultLanguage;

  /// Whether the checkout shows the shipping information view,
  /// pre-filled with [shippingAddress] when it was provided.
  final bool collectShipping;

  /// Whether the checkout activates the identity document field,
  /// pre-filled with [WompiCustomerData.legalId] when it was provided.
  final bool collectCustomerLegalId;

  /// Truncates [value] to UTC milliseconds: `DateTime.now()` carries
  /// microseconds on the VM, which `toIso8601String` would emit as six
  /// fractional digits — a format Wompi does not document.
  static DateTime? _normalizeExpirationTime(DateTime? value) {
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: true,
    );
  }

  /// The [Wompi query parameters](https://docs.wompi.co/docs/colombia/widget-checkout-web/#web-checkout)
  /// for this payment data.
  ///
  /// Excludes `public-key`, `currency` and `signature:integrity`, which
  /// the checkout client adds when building the final URL.
  Map<String, String> toQueryParameters() {
    return <String, String>{
      'amount-in-cents': '$amountInCents',
      'reference': reference,
      if (redirectUrl != null) 'redirect-url': redirectUrl!,
      if (expirationTime != null)
        'expiration-time': expirationTime!.toIso8601String(),
      if (defaultLanguage != null) 'default-language': defaultLanguage!.code,
      if (collectShipping) 'collect-shipping': 'true',
      if (collectCustomerLegalId) 'collect-customer-legal-id': 'true',
      ...?customerData?.toQueryParams(),
      ...?shippingAddress?.toQueryParams(),
      ...?taxes?.toQueryParams(),
      ...?paymentMethodReferences?.toQueryParams(),
    };
  }

  /// Creates a copy with the given fields replaced.
  ///
  /// A `null` argument keeps the current value; use [clear] to remove an
  /// optional field.
  WompiCheckoutData copyWith({
    int? amountInCents,
    String? reference,
    String? redirectUrl,
    DateTime? expirationTime,
    WompiCustomerData? customerData,
    WompiShippingAddress? shippingAddress,
    WompiTaxes? taxes,
    WompiPaymentMethodReferences? paymentMethodReferences,
    WompiLanguage? defaultLanguage,
    bool? collectShipping,
    bool? collectCustomerLegalId,
  }) {
    return WompiCheckoutData(
      amountInCents: amountInCents ?? this.amountInCents,
      reference: reference ?? this.reference,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      expirationTime: expirationTime ?? this.expirationTime,
      customerData: customerData ?? this.customerData,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      taxes: taxes ?? this.taxes,
      paymentMethodReferences:
          paymentMethodReferences ?? this.paymentMethodReferences,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      collectShipping: collectShipping ?? this.collectShipping,
      collectCustomerLegalId:
          collectCustomerLegalId ?? this.collectCustomerLegalId,
    );
  }

  /// Creates a copy with the fields flagged `true` removed, which
  /// [copyWith] cannot do:
  ///
  /// ```dart
  /// final withoutExpiration = data.clear(expirationTime: true);
  /// ```
  WompiCheckoutData clear({
    bool redirectUrl = false,
    bool expirationTime = false,
    bool customerData = false,
    bool shippingAddress = false,
    bool taxes = false,
    bool paymentMethodReferences = false,
    bool defaultLanguage = false,
  }) {
    return WompiCheckoutData(
      amountInCents: amountInCents,
      reference: reference,
      redirectUrl: redirectUrl ? null : this.redirectUrl,
      expirationTime: expirationTime ? null : this.expirationTime,
      customerData: customerData ? null : this.customerData,
      shippingAddress: shippingAddress ? null : this.shippingAddress,
      taxes: taxes ? null : this.taxes,
      paymentMethodReferences:
          paymentMethodReferences ? null : this.paymentMethodReferences,
      defaultLanguage: defaultLanguage ? null : this.defaultLanguage,
      collectShipping: collectShipping,
      collectCustomerLegalId: collectCustomerLegalId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WompiCheckoutData &&
          runtimeType == other.runtimeType &&
          amountInCents == other.amountInCents &&
          reference == other.reference &&
          redirectUrl == other.redirectUrl &&
          expirationTime == other.expirationTime &&
          customerData == other.customerData &&
          shippingAddress == other.shippingAddress &&
          taxes == other.taxes &&
          paymentMethodReferences == other.paymentMethodReferences &&
          defaultLanguage == other.defaultLanguage &&
          collectShipping == other.collectShipping &&
          collectCustomerLegalId == other.collectCustomerLegalId;

  @override
  int get hashCode => Object.hash(
        amountInCents,
        reference,
        redirectUrl,
        expirationTime,
        customerData,
        shippingAddress,
        taxes,
        paymentMethodReferences,
        defaultLanguage,
        collectShipping,
        collectCustomerLegalId,
      );

  @override
  String toString() {
    return 'WompiCheckoutData(amountInCents: $amountInCents, '
        'reference: $reference, redirectUrl: $redirectUrl, '
        'expirationTime: $expirationTime, customerData: $customerData, '
        'shippingAddress: $shippingAddress, taxes: $taxes, '
        'paymentMethodReferences: $paymentMethodReferences, '
        'defaultLanguage: $defaultLanguage, '
        'collectShipping: $collectShipping, '
        'collectCustomerLegalId: $collectCustomerLegalId)';
  }
}
