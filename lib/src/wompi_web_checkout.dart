import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';
import 'package:wompi_web_checkout/src/models/checkout_data.dart';
import 'package:wompi_web_checkout/src/models/wompi_country.dart';
import 'package:wompi_web_checkout/src/models/wompi_environment.dart';
import 'package:wompi_web_checkout/src/utils/validation_error_collector.dart';

/// A client for the Wompi **Web Checkout** integration.
///
/// Builds integrity-signed checkout URLs that take the payer to Wompi's
/// hosted checkout page:
///
/// ```dart
/// final wompi = WompiWebCheckout(
///   publicKey: 'pub_test_X0zDA9xoKdePzhd8a0x9HAez7HgGO2fH',
///   integrityKey: 'test_integrity_...',
/// );
///
/// final uri = wompi.getCheckoutUri(
///   WompiCheckoutData(
///     amountInCents: 4950000,
///     reference: 'order-123',
///     redirectUrl: 'https://mystore.com/payments/result',
///   ),
/// );
///
/// // Open [uri] in a browser or a webview to start the payment.
/// ```
final class WompiWebCheckout {
  /// Creates a [WompiWebCheckout] client.
  ///
  /// - [publicKey]: the public commerce key (`pub_test_...` or
  ///   `pub_prod_...`).
  /// - [integrityKey]: the integrity secret (`test_integrity_...` or
  ///   `prod_integrity_...`), found in the commerce dashboard under
  ///   "Developers > Secrets for technical integration". This is **not**
  ///   the private key.
  /// - [country]: the country of the merchant account.
  ///
  /// Throws a [WompiValidationException] if any key is empty or has an
  /// unrecognized format.
  WompiWebCheckout({
    required this.publicKey,
    required String integrityKey,
    this.country = WompiCountry.colombia,
  }) : _integrityKey = integrityKey {
    _validateCredentials();
  }

  /// The public commerce key used to identify the merchant.
  final String publicKey;

  /// The country of the merchant account.
  ///
  /// Determines the checkout host ([WompiCountry.checkoutHost]) and the
  /// only currency accepted for payments ([WompiCountry.currency]).
  final WompiCountry country;

  /// Kept private on purpose: the secret must never be exposed beyond
  /// the signed URL.
  final String _integrityKey;

  static const String _sandboxPublicKeyPrefix = 'pub_test_';
  static const String _productionPublicKeyPrefix = 'pub_prod_';
  static const String _sandboxIntegrityKeyPrefix = 'test_integrity_';
  static const String _productionIntegrityKeyPrefix = 'prod_integrity_';

  /// The environment these credentials belong to, derived from the
  /// [publicKey] prefix.
  WompiEnvironment get environment =>
      publicKey.startsWith(_productionPublicKeyPrefix)
          ? WompiEnvironment.production
          : WompiEnvironment.sandbox;

  /// A debug build is the one where neither toolchain constant is set,
  /// which also keeps the warning out of profile builds.
  static const bool _isDebugMode = !bool.fromEnvironment('dart.vm.product') &&
      !bool.fromEnvironment('dart.vm.profile');

  /// Generates the Web Checkout URL for [data], signed with
  /// `signature:integrity`.
  ///
  /// Redirect the payer to it (browser or webview) to complete the
  /// payment.
  ///
  /// Throws a [WompiValidationException] if [data] is not valid for
  /// [country] — an unsupported legal ID type, consumption tax, checkout
  /// language or payment method reference — or if its `expirationTime`
  /// is not in the future.
  Uri getCheckoutUri(WompiCheckoutData data) {
    _validate(data);

    return Uri.https(
      country.checkoutHost,
      '/p/',
      <String, String>{
        'public-key': publicKey,
        'signature:integrity': _integritySignature(data),
        'currency': country.currency.code,
        ...data.toQueryParameters(),
      },
    );
  }

  /// Validates the credentials given to a constructor and warns about
  /// production keys used in a debug build.
  void _validateCredentials() {
    final errors = ValidationErrorCollector();

    if (publicKey.trim().isEmpty) {
      errors.add(field: 'publicKey', message: 'Public key cannot be empty.');
    } else if (!publicKey.startsWith(_sandboxPublicKeyPrefix) &&
        !publicKey.startsWith(_productionPublicKeyPrefix)) {
      errors.add(
        field: 'publicKey',
        message: 'Public key must start with "pub_test_" (sandbox) or '
            '"pub_prod_" (production).',
      );
    }

    if (_integrityKey.trim().isEmpty) {
      errors.add(
        field: 'integrityKey',
        message: 'Integrity key cannot be empty.',
      );
    } else if (!_integrityKey.startsWith(_sandboxIntegrityKeyPrefix) &&
        !_integrityKey.startsWith(_productionIntegrityKeyPrefix)) {
      errors.add(
        field: 'integrityKey',
        message: 'Integrity key must start with "test_integrity_" '
            '(sandbox) or "prod_integrity_" (production).',
      );
    }

    errors.throwIfAny();

    if (_isDebugMode && environment == WompiEnvironment.production) {
      log(
        'WompiWebCheckout is running in debug mode with PRODUCTION '
        'credentials. Payments created with these keys are real '
        'transactions. Use your sandbox keys (pub_test_... / '
        'test_integrity_...) while developing.',
        level: 900,
        name: 'WompiWebCheckout',
      );
    }
  }

  /// The checks that depend on the merchant or on the clock, and so
  /// cannot live in [WompiCheckoutData] itself.
  void _validate(WompiCheckoutData data) {
    final errors = ValidationErrorCollector();

    final legalIdType = data.customerData?.legalIdType;
    if (legalIdType != null && !country.legalIdTypes.contains(legalIdType)) {
      errors.add(
        field: 'legalIdType',
        message: '"${legalIdType.code}" is not a valid legal ID type for '
            'Wompi ${country.displayName}. Valid types: '
            '${country.legalIdTypes.map((type) => type.code).join(', ')}.',
      );
    }

    if (data.taxes?.consumption != null && !country.supportsConsumptionTax) {
      errors.add(
        field: 'taxes.consumption',
        message: 'The consumption tax is not supported by Wompi '
            '${country.displayName}. Report the ${country.displayName} '
            'tax through WompiTaxes.vat instead.',
      );
    }

    if (data.defaultLanguage != null && !country.supportsDefaultLanguage) {
      errors.add(
        field: 'defaultLanguage',
        message: 'The checkout language cannot be chosen in Wompi '
            '${country.displayName}: "default-language" is only '
            'documented for Wompi Panama.',
      );
    }

    if (data.paymentMethodReferences != null &&
        !country.supportsPaymentMethodReferences) {
      errors.add(
        field: 'paymentMethodReferences',
        message: 'Payment method references are not supported by Wompi '
            '${country.displayName}: "payment-method:reference-one", '
            '"-two" and "-three" are only documented for Wompi Colombia.',
      );
    }

    final expirationTime = data.expirationTime;
    if (expirationTime != null &&
        !expirationTime.isAfter(DateTime.now().toUtc())) {
      errors.add(
        field: 'expirationTime',
        message: 'Expiration time must be in the future.',
      );
    }

    errors.throwIfAny();
  }

  /// SHA-256 of the values concatenated in the order Wompi requires:
  /// `<Reference><Amount><Currency>[<ExpirationTime>]<IntegritySecret>`.
  String _integritySignature(WompiCheckoutData data) {
    final buffer = StringBuffer()
      ..write(data.reference)
      ..write(data.amountInCents)
      ..write(country.currency.code);

    final expirationTime = data.expirationTime;
    if (expirationTime != null) {
      // Normalized by WompiCheckoutData, so this is byte-for-byte the
      // value sent as `expiration-time`.
      buffer.write(expirationTime.toIso8601String());
    }

    buffer.write(_integrityKey);

    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }
}
