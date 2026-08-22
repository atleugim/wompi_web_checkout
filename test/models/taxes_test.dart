import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiTaxes', () {
    test('creates a valid instance with vat only', () {
      final taxes = WompiTaxes(vat: 1900000);

      expect(taxes.vat, 1900000);
      expect(taxes.consumption, isNull);
    });

    test('creates a valid instance with consumption only', () {
      final taxes = WompiTaxes(consumption: 80000);

      expect(taxes.vat, isNull);
      expect(taxes.consumption, 80000);
    });

    test('creates a valid instance with both taxes', () {
      final taxes = WompiTaxes(vat: 1900000, consumption: 80000);

      expect(taxes.vat, 1900000);
      expect(taxes.consumption, 80000);
    });

    test('throws when no tax is provided', () {
      expect(
        WompiTaxes.new,
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'taxes',
          ),
        ),
      );
    });

    test('throws for negative amounts', () {
      expect(
        () => WompiTaxes(vat: -1, consumption: -1),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.length,
            'error count',
            2,
          ),
        ),
      );
    });

    test('copyWith returns a new instance with the replaced fields', () {
      final original = WompiTaxes(vat: 1900000);
      final copy = original.copyWith(consumption: 80000);

      expect(copy.vat, 1900000);
      expect(copy.consumption, 80000);
      expect(original.consumption, isNull);
    });

    test('supports value equality', () {
      final a = WompiTaxes(vat: 1900000);
      final b = WompiTaxes(vat: 1900000);
      final c = WompiTaxes(vat: 1);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('clear removes the flagged tax', () {
      final original = WompiTaxes(vat: 1900, consumption: 800);

      final cleared = original.clear(consumption: true);

      expect(cleared.vat, 1900);
      expect(cleared.consumption, isNull);
      expect(original.consumption, 800);
    });

    test('clear throws when it would leave no tax at all', () {
      final original = WompiTaxes(vat: 1900);

      expect(
        () => original.clear(vat: true),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'taxes',
          ),
        ),
      );
    });
  });
}
