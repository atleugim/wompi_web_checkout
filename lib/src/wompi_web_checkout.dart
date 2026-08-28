import 'dart:developer';

import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';
import 'package:wompi_web_checkout/src/models/checkout_data.dart';
import 'package:wompi_web_checkout/src/models/wompi_country.dart';
import 'package:wompi_web_checkout/src/models/wompi_environment.dart';
import 'package:wompi_web_checkout/src/signing/integrity_signer.dart';
import 'package:wompi_web_checkout/src/utils/validation_error_collector.dart';

/// A client for the Wompi **Web Checkout** integration.
///
/// Builds integrity-signed checkout URLs that take the payer to Wompi's
/// hosted checkout page. Pick a constructor by where the integrity
/// secret lives:
///
/// ```dart
/// // The secret stays on your server, which returns the signature for
/// // this exact payment. Preferable for security.
/// final wompi = WompiWebCheckout.fromServer(
///   publicKey: 'pub_test_X0zDA9xoKdePzhd8a0x9HAez7HgGO2fH',
///   integritySignature: '<SIGNATURE_FROM_YOUR_BACKEND>',
/// );
///
/// // The app holds the secret and signs on its own.
/// final wompi = WompiWebCheckout.fromClient(
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
  /// Creates a [WompiWebCheckout] client that computes the signature in
  /// the app, from the integrity secret.
  ///
  /// The secret ships with the app, so [WompiWebCheckout.fromServer] is
  /// preferable for security when you have a backend that can sign — see
  /// [the Wompi documentation](https://docs.wompi.co/docs/colombia/widget-checkout-web/#paso-3-genera-una-firma-de-integridad).
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
  WompiWebCheckout.fromClient({
    required String publicKey,
    required String integrityKey,
    WompiCountry country = WompiCountry.colombia,
  }) : this._(
          publicKey: publicKey,
          signer: LocalIntegritySigner(integrityKey),
          country: country,
        );

  /// Creates a [WompiWebCheckout] client that uses a signature computed
  /// by your backend, so the integrity secret never reaches the app.
  ///
  /// This is the arrangement
  /// [Wompi recommends](https://docs.wompi.co/docs/colombia/widget-checkout-web/#paso-3-genera-una-firma-de-integridad).
  /// Your server hashes
  /// `<Reference><Amount><Currency>[<ExpirationTime>]<IntegritySecret>`
  /// with SHA-256 and returns the hexadecimal digest.
  ///
  /// The signature covers the payment, not the merchant: it is only
  /// valid for the reference, amount, currency and expiration time it
  /// was computed for. **Build one client per payment** — reusing an
  /// instance for a different [WompiCheckoutData] produces a URL Wompi
  /// rejects.
  ///
  /// - [publicKey]: the public commerce key (`pub_test_...` or
  ///   `pub_prod_...`). It is not a secret — Wompi puts it in the
  ///   checkout URL — so it is safe to keep in the app.
  /// - [integritySignature]: the 64 hexadecimal characters returned by
  ///   your backend for this payment.
  /// - [country]: the country of the merchant account. It must be the
  ///   one whose currency your backend signed.
  ///
  /// Throws a [WompiValidationException] if the public key or the
  /// signature is empty or has an unrecognized format.
  WompiWebCheckout.fromServer({
    required String publicKey,
    required String integritySignature,
    WompiCountry country = WompiCountry.colombia,
  }) : this._(
          publicKey: publicKey,
          signer: ServerIntegritySigner(integritySignature),
          country: country,
        );

  WompiWebCheckout._({
    required String publicKey,
    required IntegritySigner signer,
    required this.country,
  })  : publicKey = publicKey.trim(),
        _signer = signer {
    _validateCredentials();
  }

  /// The public commerce key used to identify the merchant.
  ///
  /// Stored without surrounding whitespace: it travels in the checkout
  /// URL, where a stray newline would be percent-encoded into it.
  final String publicKey;

  /// The country of the merchant account.
  ///
  /// Determines the checkout host ([WompiCountry.checkoutHost]) and the
  /// only currency accepted for payments ([WompiCountry.currency]).
  final WompiCountry country;

  /// Kept private on purpose: neither the secret nor the signature must
  /// be exposed beyond the signed URL.
  final IntegritySigner _signer;

  static const String _sandboxPublicKeyPrefix = 'pub_test_';
  static const String _productionPublicKeyPrefix = 'pub_prod_';

  /// The environment these credentials belong to, derived from the
  /// [publicKey] prefix.
  WompiEnvironment get environment =>
      publicKey.startsWith(_productionPublicKeyPrefix)
          ? WompiEnvironment.production
          : WompiEnvironment.sandbox;

  /// Whether the integrity secret lives in this app.
  ///
  /// `true` for [WompiWebCheckout.fromClient], `false` for
  /// [WompiWebCheckout.fromServer].
  bool get signsLocally => switch (_signer) {
        LocalIntegritySigner() => true,
        ServerIntegritySigner() => false,
      };

  /// A debug build is the one where neither toolchain constant is set,
  /// which also keeps the warning out of profile builds.
  static const bool _isDebugMode = !bool.fromEnvironment('dart.vm.product') &&
      !bool.fromEnvironment('dart.vm.profile');

  /// Generates the Web Checkout URL for [data], carrying the
  /// `signature:integrity` this client was built to produce.
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
        'signature:integrity': _signer.signatureFor(data, country),
        'currency': country.currency.code,
        ...data.toQueryParameters(),
      },
    );
  }

  /// Validates the credentials given to a constructor and warns about
  /// production keys used in a debug build.
  void _validateCredentials() {
    final errors = ValidationErrorCollector();

    if (publicKey.isEmpty) {
      errors.add(field: 'publicKey', message: 'Public key cannot be empty.');
    } else if (!publicKey.startsWith(_sandboxPublicKeyPrefix) &&
        !publicKey.startsWith(_productionPublicKeyPrefix)) {
      errors.add(
        field: 'publicKey',
        message: 'Public key must start with "pub_test_" (sandbox) or '
            '"pub_prod_" (production).',
      );
    }

    _signer.validate(errors);

    errors.throwIfAny();

    if (_isDebugMode && environment == WompiEnvironment.production) {
      log(
        'WompiWebCheckout is running in debug mode with PRODUCTION '
        'credentials. Payments created with these keys are real '
        'transactions. Use your sandbox keys (pub_test_...) while '
        'developing.',
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
}
