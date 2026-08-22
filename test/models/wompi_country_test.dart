import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiCountry', () {
    test('Colombia matches the documented configuration', () {
      const country = WompiCountry.colombia;

      expect(country.checkoutHost, 'checkout.wompi.co');
      expect(country.currency, WompiCurrency.cop);
      expect(country.currency.code, 'COP');
      expect(country.supportsConsumptionTax, isTrue);
      expect(country.supportsDefaultLanguage, isFalse);
      expect(country.supportsPaymentMethodReferences, isTrue);
      expect(country.displayName, 'Colombia');
      const colombianTypes = <String>[
        'CC',
        'CE',
        'NIT',
        'PP',
        'TI',
        'DNI',
        'RG',
        'OTHER',
      ];

      expect(
        country.legalIdTypes.map((type) => type.code),
        containsAll(colombianTypes),
      );
      expect(country.legalIdTypes, isNot(contains(WompiLegalIdType.ruc)));
    });

    test('Panama matches the documented configuration', () {
      const country = WompiCountry.panama;

      expect(country.checkoutHost, 'checkout.wompi.pa');
      expect(country.currency, WompiCurrency.usd);
      expect(country.currency.code, 'USD');
      expect(country.supportsConsumptionTax, isFalse);
      expect(country.supportsDefaultLanguage, isTrue);
      expect(country.supportsPaymentMethodReferences, isFalse);
      expect(country.displayName, 'Panama');
      expect(
        country.legalIdTypes.map((type) => type.code),
        <String>['CC', 'CE', 'RUC', 'PP'],
      );
    });

    test('every legal ID type belongs to at least one country', () {
      final supported = {
        ...WompiCountry.colombia.legalIdTypes,
        ...WompiCountry.panama.legalIdTypes,
      };

      expect(supported, containsAll(WompiLegalIdType.values));
    });
  });

  group('country capability matrix', () {
    test('every optional parameter is supported by at least one country', () {
      // A capability nobody supports would make the field dead code.
      for (final supported in <Iterable<bool>>[
        WompiCountry.values.map((c) => c.supportsConsumptionTax),
        WompiCountry.values.map((c) => c.supportsDefaultLanguage),
        WompiCountry.values.map((c) => c.supportsPaymentMethodReferences),
      ]) {
        expect(supported, contains(true));
      }
    });

    test('the two countries differ in exactly the documented ways', () {
      expect(
        WompiCountry.colombia.supportsConsumptionTax,
        isNot(WompiCountry.panama.supportsConsumptionTax),
      );
      expect(
        WompiCountry.colombia.supportsDefaultLanguage,
        isNot(WompiCountry.panama.supportsDefaultLanguage),
      );
      expect(
        WompiCountry.colombia.supportsPaymentMethodReferences,
        isNot(WompiCountry.panama.supportsPaymentMethodReferences),
      );
    });
  });

  group('WompiLanguage', () {
    test('exposes the documented codes', () {
      expect(WompiLanguage.spanish.code, 'es');
      expect(WompiLanguage.english.code, 'en');
    });
  });
}
