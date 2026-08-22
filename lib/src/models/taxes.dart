import 'package:meta/meta.dart';
import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';
import 'package:wompi_web_checkout/src/utils/validation_error_collector.dart';

/// Tax breakdown of a payment, in cents.
///
/// Informational only: Wompi does not add these to the transaction, so
/// they must already be part of `WompiCheckoutData.amountInCents`. At
/// least one tax must be provided.
@immutable
final class WompiTaxes {
  /// Creates a [WompiTaxes] instance.
  ///
  /// Throws a [WompiValidationException] if both values are `null` or if
  /// any of them is negative.
  WompiTaxes({this.vat, this.consumption}) {
    final errors = ValidationErrorCollector();

    if (vat != null && vat! < 0) {
      errors.add(
        field: 'vat',
        message: 'VAT must be greater than or equal to 0.',
      );
    }
    if (consumption != null && consumption! < 0) {
      errors.add(
        field: 'consumption',
        message: 'Consumption tax must be greater than or equal to 0.',
      );
    }
    if (vat == null && consumption == null) {
      errors.add(
        field: 'taxes',
        message: 'At least one tax (vat or consumption) must be provided.',
      );
    }

    errors.throwIfAny();
  }

  /// Value Added Tax (IVA) included in the transaction amount, in cents.
  final int? vat;

  /// Consumption tax included in the transaction amount, in cents.
  final int? consumption;

  /// Creates a copy with the given fields replaced.
  ///
  /// A `null` argument keeps the current value; use [clear] to remove a
  /// tax.
  WompiTaxes copyWith({int? vat, int? consumption}) {
    return WompiTaxes(
      vat: vat ?? this.vat,
      consumption: consumption ?? this.consumption,
    );
  }

  /// Creates a copy with the taxes flagged `true` removed.
  ///
  /// Throws a [WompiValidationException] if it would leave none — drop
  /// the whole field with `WompiCheckoutData.clear(taxes: true)`
  /// instead.
  WompiTaxes clear({bool vat = false, bool consumption = false}) {
    return WompiTaxes(
      vat: vat ? null : this.vat,
      consumption: consumption ? null : this.consumption,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WompiTaxes &&
          runtimeType == other.runtimeType &&
          vat == other.vat &&
          consumption == other.consumption;

  @override
  int get hashCode => Object.hash(vat, consumption);

  @override
  String toString() => 'WompiTaxes(vat: $vat, consumption: $consumption)';
}
