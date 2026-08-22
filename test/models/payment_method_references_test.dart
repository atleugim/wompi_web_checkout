import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiPaymentMethodReferences', () {
    test('creates a valid instance with a single reference', () {
      final references = WompiPaymentMethodReferences(
        referenceOne: '190.0.0.1',
      );

      expect(references.referenceOne, '190.0.0.1');
      expect(references.referenceTwo, isNull);
      expect(references.referenceThree, isNull);
    });

    test('throws when no reference is provided', () {
      expect(
        WompiPaymentMethodReferences.new,
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'paymentMethodReferences',
          ),
        ),
      );
    });

    test('accepts a valid yyyymmdd date in reference two', () {
      expect(
        WompiPaymentMethodReferences(referenceTwo: '20230609').referenceTwo,
        '20230609',
      );
    });

    for (final invalid in <String>[
      '2023-06-09',
      '202306',
      '20231301',
      '20230231',
      '09062023',
      'yyyymmdd',
    ]) {
      test('rejects "$invalid" as reference two', () {
        expect(
          () => WompiPaymentMethodReferences(referenceTwo: invalid),
          throwsA(
            isA<WompiValidationException>().having(
              (e) => e.errors.single.field,
              'field',
              'referenceTwo',
            ),
          ),
        );
      });
    }

    test('throws when a provided reference is blank', () {
      expect(
        () => WompiPaymentMethodReferences(referenceOne: '  '),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'referenceOne',
          ),
        ),
      );
    });

    test('copyWith keeps the current value for a null argument', () {
      final original = WompiPaymentMethodReferences(
        referenceOne: '190.0.0.1',
        referenceTwo: '20230609',
      );

      final copy = original.copyWith(referenceOne: '190.0.0.2');

      expect(copy.referenceOne, '190.0.0.2');
      expect(copy.referenceTwo, '20230609');
    });

    test('clear removes the flagged reference', () {
      final original = WompiPaymentMethodReferences(
        referenceOne: '190.0.0.1',
        referenceTwo: '20230609',
      );

      final cleared = original.clear(referenceTwo: true);

      expect(cleared.referenceOne, '190.0.0.1');
      expect(cleared.referenceTwo, isNull);
      expect(original.referenceTwo, '20230609');
    });

    test('clear throws when it would leave no reference at all', () {
      final original = WompiPaymentMethodReferences(
        referenceOne: '190.0.0.1',
      );

      expect(
        () => original.clear(referenceOne: true),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'paymentMethodReferences',
          ),
        ),
      );
    });

    test('supports value equality', () {
      final a = WompiPaymentMethodReferences(referenceOne: '190.0.0.1');
      final b = WompiPaymentMethodReferences(referenceOne: '190.0.0.1');
      final c = WompiPaymentMethodReferences(referenceOne: '190.0.0.2');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });
}
