import 'package:wompi_web_checkout/src/exceptions/wompi_exceptions.dart';

/// Supported legal ID types for Wompi payments
enum WompiLegalId {
  /// Colombian Citizenship Card
  cc('CC'),

  /// Colombian Tax ID
  nit('NIT'),

  /// Passport
  pp('PP'),

  /// Foreigner ID
  ce('CE'),

  /// Identity Card
  ti('TI'),

  /// National ID
  dni('DNI'),

  /// General Registry
  rg('RG'),

  /// Other type of ID
  other('OTHER');

  const WompiLegalId(this.code);

  /// The code used by Wompi API for this ID type
  final String code;

  /// Converts a string code to its corresponding [WompiLegalId] enum value
  /// Returns null if the code is null or doesn't match any enum value
  static WompiLegalId fromCode(String? code) {
    if (code == null) {
      throw WompiInvalidArgumentException(
        'code',
        description: 'Code cannot be null',
      );
    }

    return values.byName(code);
  }
}
