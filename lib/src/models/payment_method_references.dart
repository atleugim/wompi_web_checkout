import 'package:meta/meta.dart';
import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';
import 'package:wompi_web_checkout/src/utils/validation_error_collector.dart';
import 'package:wompi_web_checkout/src/utils/validators.dart';

/// Extra references forwarded to the payment method
/// (`payment-method:reference-one`, `-two` and `-three`).
///
/// Documented for Colombia only; a Panamanian checkout rejects them. At
/// least one reference must be provided.
@immutable
final class WompiPaymentMethodReferences {
  /// Creates a [WompiPaymentMethodReferences] instance.
  ///
  /// - [referenceOne]: IP address the payment originates from; Wompi
  ///   falls back to the request's IP when omitted.
  /// - [referenceTwo]: product opening date, in `yyyymmdd` format.
  /// - [referenceThree]: identification number of the beneficiary.
  ///
  /// Throws a [WompiValidationException] if every reference is `null` or
  /// if any provided value is invalid.
  WompiPaymentMethodReferences({
    this.referenceOne,
    this.referenceTwo,
    this.referenceThree,
  }) {
    final errors = ValidationErrorCollector();

    if (referenceOne != null && referenceOne!.trim().isEmpty) {
      errors.add(
        field: 'referenceOne',
        message: 'Reference one cannot be empty when provided.',
      );
    }
    if (referenceTwo != null &&
        !WompiValidators.isValidCompactDate(referenceTwo!)) {
      errors.add(
        field: 'referenceTwo',
        message: 'Reference two must be a date in "yyyymmdd" format '
            '(e.g. "20230609").',
      );
    }
    if (referenceThree != null && referenceThree!.trim().isEmpty) {
      errors.add(
        field: 'referenceThree',
        message: 'Reference three cannot be empty when provided.',
      );
    }
    if (referenceOne == null &&
        referenceTwo == null &&
        referenceThree == null) {
      errors.add(
        field: 'paymentMethodReferences',
        message: 'At least one reference must be provided.',
      );
    }

    errors.throwIfAny();
  }

  /// IP address the payment originates from.
  final String? referenceOne;

  /// Product opening date, in `yyyymmdd` format (e.g. `20230609`).
  final String? referenceTwo;

  /// Identification number of the beneficiary.
  final String? referenceThree;

  /// Creates a copy with the given fields replaced.
  ///
  /// A `null` argument keeps the current value; use [clear] to remove a
  /// reference.
  WompiPaymentMethodReferences copyWith({
    String? referenceOne,
    String? referenceTwo,
    String? referenceThree,
  }) {
    return WompiPaymentMethodReferences(
      referenceOne: referenceOne ?? this.referenceOne,
      referenceTwo: referenceTwo ?? this.referenceTwo,
      referenceThree: referenceThree ?? this.referenceThree,
    );
  }

  /// Creates a copy with the references flagged `true` removed.
  ///
  /// Throws a [WompiValidationException] if it would leave none — drop
  /// the whole field with
  /// `WompiCheckoutData.clear(paymentMethodReferences: true)` instead.
  WompiPaymentMethodReferences clear({
    bool referenceOne = false,
    bool referenceTwo = false,
    bool referenceThree = false,
  }) {
    return WompiPaymentMethodReferences(
      referenceOne: referenceOne ? null : this.referenceOne,
      referenceTwo: referenceTwo ? null : this.referenceTwo,
      referenceThree: referenceThree ? null : this.referenceThree,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WompiPaymentMethodReferences &&
          runtimeType == other.runtimeType &&
          referenceOne == other.referenceOne &&
          referenceTwo == other.referenceTwo &&
          referenceThree == other.referenceThree;

  @override
  int get hashCode => Object.hash(referenceOne, referenceTwo, referenceThree);

  @override
  String toString() {
    return 'WompiPaymentMethodReferences(referenceOne: $referenceOne, '
        'referenceTwo: $referenceTwo, referenceThree: $referenceThree)';
  }
}
