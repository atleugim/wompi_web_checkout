import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiLegalIdType', () {
    test('exposes the Wompi API codes', () {
      expect(WompiLegalIdType.cc.code, 'CC');
      expect(WompiLegalIdType.ce.code, 'CE');
      expect(WompiLegalIdType.nit.code, 'NIT');
      expect(WompiLegalIdType.pp.code, 'PP');
      expect(WompiLegalIdType.ti.code, 'TI');
      expect(WompiLegalIdType.dni.code, 'DNI');
      expect(WompiLegalIdType.rg.code, 'RG');
      expect(WompiLegalIdType.ruc.code, 'RUC');
      expect(WompiLegalIdType.other.code, 'OTHER');
    });

    group('fromCode', () {
      test('parses every valid code', () {
        for (final type in WompiLegalIdType.values) {
          expect(WompiLegalIdType.fromCode(type.code), type);
        }
      });

      test('is case insensitive and ignores surrounding whitespace', () {
        expect(WompiLegalIdType.fromCode('cc'), WompiLegalIdType.cc);
        expect(WompiLegalIdType.fromCode(' nit '), WompiLegalIdType.nit);
      });

      test('throws for an unknown code', () {
        expect(
          () => WompiLegalIdType.fromCode('PASSPORT'),
          throwsA(isA<WompiValidationException>()),
        );
      });
    });

    group('tryFromCode', () {
      test('returns the matching type for a valid code', () {
        expect(WompiLegalIdType.tryFromCode('CC'), WompiLegalIdType.cc);
        expect(WompiLegalIdType.tryFromCode('RUC'), WompiLegalIdType.ruc);
      });

      test('returns null for null or unknown codes', () {
        expect(WompiLegalIdType.tryFromCode(null), isNull);
        expect(WompiLegalIdType.tryFromCode('PASSPORT'), isNull);
      });
    });
  });

  group('WompiCountry.legalIdTypes', () {
    test('Colombia lists only the Colombian document types', () {
      expect(
        WompiCountry.colombia.legalIdTypes,
        containsAll(<WompiLegalIdType>[
          WompiLegalIdType.cc,
          WompiLegalIdType.ce,
          WompiLegalIdType.nit,
          WompiLegalIdType.pp,
          WompiLegalIdType.ti,
          WompiLegalIdType.dni,
          WompiLegalIdType.rg,
          WompiLegalIdType.other,
        ]),
      );
      expect(
        WompiCountry.colombia.legalIdTypes,
        isNot(contains(WompiLegalIdType.ruc)),
      );
    });

    test('Panama lists only the Panamanian document types', () {
      expect(
        WompiCountry.panama.legalIdTypes,
        containsAll(<WompiLegalIdType>[
          WompiLegalIdType.cc,
          WompiLegalIdType.ce,
          WompiLegalIdType.ruc,
          WompiLegalIdType.pp,
        ]),
      );
      expect(
        WompiCountry.panama.legalIdTypes,
        isNot(contains(WompiLegalIdType.nit)),
      );
    });
  });
}
