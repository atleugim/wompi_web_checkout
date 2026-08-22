import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';

/// Type of the payer's identity document.
///
/// The full catalog; which types a payment accepts depends on the
/// merchant's country (`WompiCountry.legalIdTypes`), checked when the
/// URL is generated.
enum WompiLegalIdType {
  /// Cédula de Ciudadanía (CO) / Cédula (PA). Both countries.
  cc('CC'),

  /// Cédula de Extranjería (CO) / Cédula de Panameño Nacido en
  /// Extranjero (PA). Both countries.
  ce('CE'),

  /// Colombian tax identification number. Colombia only.
  nit('NIT'),

  /// Passport. Both countries.
  pp('PP'),

  /// Tarjeta de Identidad, for minors. Colombia only.
  ti('TI'),

  /// National identity document. Colombia only.
  dni('DNI'),

  /// Brazilian Registro Geral. Colombia only.
  rg('RG'),

  /// Registro Único de Contribuyente. Panama only.
  ruc('RUC'),

  /// Any other type of document. Colombia only.
  other('OTHER');

  const WompiLegalIdType(this.code);

  /// The code expected by the Wompi API for this document type.
  final String code;

  /// The [WompiLegalIdType] whose [code] matches, ignoring case and
  /// surrounding whitespace.
  ///
  /// Throws a [WompiValidationException] if nothing matches.
  static WompiLegalIdType fromCode(String code) {
    final type = tryFromCode(code);
    if (type == null) {
      throw WompiValidationException([
        WompiFieldError(
          field: 'legalIdType',
          message: 'Unknown legal ID type code "$code".',
        ),
      ]);
    }
    return type;
  }

  /// The [WompiLegalIdType] whose [code] matches, or `null` if none
  /// does. Ignores case and surrounding whitespace.
  static WompiLegalIdType? tryFromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toUpperCase();
    for (final type in values) {
      if (type.code == normalized) return type;
    }
    return null;
  }
}
