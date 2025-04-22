import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:wompi_web_checkout/src/exceptions/wompi_exceptions.dart';
import 'package:wompi_web_checkout/src/models/checkout_data.dart';

/// A class that handles Wompi web checkout integration.
class WompiWebCheckout {
  /// Creates a new instance of [WompiWebCheckout].
  ///
  /// [publicKey] is the public key for your Wompi account.
  /// [integrityKey] is the integrity key for your Wompi account.
  WompiWebCheckout({required this.publicKey, required this.integrityKey}) {
    if (publicKey.isEmpty) {
      throw WompiInvalidArgumentException(
        'publicKey',
        description: 'Public key cannot be empty.',
      );
    }
    if (integrityKey.isEmpty) {
      throw WompiInvalidArgumentException(
        'integrityKey',
        description: 'Integrity key cannot be empty.',
      );
    }
  }

  /// The public key used for Wompi integration.
  final String publicKey;

  /// The integrity key used for Wompi integration.
  final String integrityKey;

  final Uri _baseUrl = Uri.parse('https://checkout.wompi.co/p/');

  /// Asymmetric cryptographic hash to validate the integrity of the
  /// transaction information.
  ///
  ///
  Future<String> _getSignatureIntegrityKey({
    required String reference,
    required int amountInCents,
    required String currency,
    DateTime? expirationTime,
  }) async {
    if (reference.isEmpty ||
        amountInCents.toString().isEmpty ||
        currency.isEmpty) {
      throw WompiInvalidSignatureIntegrityArgumentsException();
    }

    String? concatenated;

    if (expirationTime != null) {
      final expirationTimeString = expirationTime.toIso8601String();
      concatenated =
          '$reference$amountInCents$currency$expirationTimeString$integrityKey';
    } else {
      concatenated = '$reference$amountInCents$currency$integrityKey';
    }

    if (concatenated.isEmpty) {
      throw WompiInvalidSignatureIntegrityException();
    }

    final List<int> bytes = utf8.encode(concatenated);
    final digest = sha256.convert(bytes);

    final hashHex =
        digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return hashHex;
  }

  /// Generates the checkout URL for the given payment data.
  ///
  /// Returns a [Uri] that points to the Wompi checkout page.
  Future<Uri> getCheckoutUri(WompiWebCheckoutData paymentData) async {
    final paymentDataQueryParams = paymentData.getCheckoutQueryParams();

    final signatureIntegrity = await _getSignatureIntegrityKey(
      reference: paymentData.reference,
      amountInCents: paymentData.amountInCents,
      currency: paymentData.currency,
      expirationTime: paymentData.expirationTime,
    );

    final queryParams = {
      'public-key': publicKey,
      'signature:integrity': signatureIntegrity,
      ...paymentDataQueryParams,
    };

    return _baseUrl.replace(queryParameters: queryParams);
  }
}
