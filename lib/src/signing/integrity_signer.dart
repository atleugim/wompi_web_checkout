import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:wompi_web_checkout/src/models/checkout_data.dart';
import 'package:wompi_web_checkout/src/models/wompi_country.dart';
import 'package:wompi_web_checkout/src/utils/validation_error_collector.dart';

/// How a checkout URL gets its `signature:integrity`.
///
/// Wompi signs `<Reference><Amount><Currency>[<ExpirationTime>]` with the
/// integrity secret. That secret may live in the app (hashing locally) or
/// stay on the merchant's server, which returns the hash already
/// computed.
sealed class IntegritySigner {
  const IntegritySigner();

  /// The `signature:integrity` value for [data] on a [country] checkout.
  String signatureFor(WompiCheckoutData data, WompiCountry country);

  /// Adds to [errors] every problem found in the signing material.
  void validate(ValidationErrorCollector errors);
}

/// Computes the signature in the app, from the integrity secret.
///
/// The secret ships inside the binary, so [ServerIntegritySigner] is
/// preferable for security when a backend can do the signing.
final class LocalIntegritySigner extends IntegritySigner {
  /// Creates a signer that hashes with [integrityKey].
  ///
  /// Surrounding whitespace is dropped: the secret goes straight into
  /// the hash, so a stray newline from an `.env` file or a dashboard
  /// copy-paste would silently produce a signature Wompi rejects.
  LocalIntegritySigner(String integrityKey)
      : integrityKey = integrityKey.trim();

  /// The integrity secret (`test_integrity_...` / `prod_integrity_...`).
  final String integrityKey;

  /// Prefix of a sandbox integrity secret.
  static const String sandboxPrefix = 'test_integrity_';

  /// Prefix of a production integrity secret.
  static const String productionPrefix = 'prod_integrity_';

  @override
  String signatureFor(WompiCheckoutData data, WompiCountry country) {
    // The values concatenated in the order Wompi requires:
    // `<Reference><Amount><Currency>[<ExpirationTime>]<IntegritySecret>`.
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

    buffer.write(integrityKey);

    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }

  @override
  void validate(ValidationErrorCollector errors) {
    if (integrityKey.isEmpty) {
      errors.add(
        field: 'integrityKey',
        message: 'Integrity key cannot be empty.',
      );
    } else if (!integrityKey.startsWith(sandboxPrefix) &&
        !integrityKey.startsWith(productionPrefix)) {
      errors.add(
        field: 'integrityKey',
        message: 'Integrity key must start with "test_integrity_" '
            '(sandbox) or "prod_integrity_" (production).',
      );
    }
  }
}

/// Uses a signature already computed by the merchant's backend.
///
/// The secret never reaches the app, which is what Wompi recommends. The
/// signature covers the reference,
/// the amount, the currency and the expiration time, so it is valid for
/// exactly one payment: get a fresh one per transaction.
final class ServerIntegritySigner extends IntegritySigner {
  /// Creates a signer that replays [integritySignature].
  ///
  /// Surrounding whitespace is dropped: a digest read from an HTTP body
  /// or a file often arrives with a trailing newline, and whitespace is
  /// never part of a hexadecimal digest.
  ServerIntegritySigner(String integritySignature)
      : integritySignature = integritySignature.trim();

  /// The SHA-256 hash returned by the backend, as 64 hexadecimal
  /// characters.
  final String integritySignature;

  static final RegExp _sha256Hex = RegExp(r'^[A-Fa-f0-9]{64}$');

  @override
  String signatureFor(WompiCheckoutData data, WompiCountry country) =>
      integritySignature;

  @override
  void validate(ValidationErrorCollector errors) {
    if (integritySignature.isEmpty) {
      errors.add(
        field: 'integritySignature',
        message: 'Integrity signature cannot be empty.',
      );
    } else if (!_sha256Hex.hasMatch(integritySignature)) {
      errors.add(
        field: 'integritySignature',
        message: 'Integrity signature must be a SHA-256 hash: 64 '
            'hexadecimal characters. Your backend has to hash '
            '"<Reference><Amount><Currency>[<ExpirationTime>]'
            '<IntegritySecret>" and return the result.',
      );
    }
  }
}
