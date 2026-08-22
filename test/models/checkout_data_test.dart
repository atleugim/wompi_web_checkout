import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiCheckoutData', () {
    test('creates a valid instance with the required fields only', () {
      final data = WompiCheckoutData(
        amountInCents: 10000,
        reference: 'ref_123',
      );

      expect(data.amountInCents, 10000);
      expect(data.reference, 'ref_123');
      expect(data.redirectUrl, isNull);
      expect(data.expirationTime, isNull);
      expect(data.customerData, isNull);
      expect(data.shippingAddress, isNull);
      expect(data.taxes, isNull);
      expect(data.paymentMethodReferences, isNull);
      expect(data.defaultLanguage, isNull);
      expect(data.collectShipping, isFalse);
      expect(data.collectCustomerLegalId, isFalse);
    });

    test('toQueryParameters returns only the required parameters by default',
        () {
      final data = WompiCheckoutData(
        amountInCents: 10000,
        reference: 'ref_123',
      );

      expect(data.toQueryParameters(), {
        'amount-in-cents': '10000',
        'reference': 'ref_123',
      });
    });

    test('toQueryParameters does not include the currency', () {
      final data = WompiCheckoutData(
        amountInCents: 10000,
        reference: 'ref_123',
      );

      expect(data.toQueryParameters().containsKey('currency'), isFalse);
    });

    test('aggregates every validation error at once', () {
      expect(
        () => WompiCheckoutData(
          amountInCents: 0,
          reference: ' ',
          redirectUrl: 'not-a-url',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.map((e) => e.field),
            'fields',
            containsAll(<String>[
              'amountInCents',
              'reference',
              'redirectUrl',
            ]),
          ),
        ),
      );
    });

    test('throws when the amount is negative', () {
      expect(
        () => WompiCheckoutData(amountInCents: -100, reference: 'ref_123'),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'amountInCents',
          ),
        ),
      );
    });

    group('reference', () {
      test('accepts alphanumeric values with dashes and underscores', () {
        expect(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'order-123_ABC',
          ).reference,
          'order-123_ABC',
        );
      });

      for (final invalid in <String>[
        'order 123',
        'order#123',
        'order&123',
        'órden-123',
        'order/123',
      ]) {
        test('rejects "$invalid"', () {
          expect(
            () => WompiCheckoutData(amountInCents: 10000, reference: invalid),
            throwsA(
              isA<WompiValidationException>().having(
                (e) => e.errors.single.field,
                'field',
                'reference',
              ),
            ),
          );
        });
      }
    });

    group('redirectUrl', () {
      test('accepts both http and https URLs', () {
        expect(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            redirectUrl: 'http://localhost:8080/result',
          ).redirectUrl,
          'http://localhost:8080/result',
        );
        expect(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            redirectUrl: 'https://mystore.com/result',
          ).redirectUrl,
          'https://mystore.com/result',
        );
      });

      test('rejects a URL without a scheme or host', () {
        expect(
          () => WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            redirectUrl: 'mystore.com/result',
          ),
          throwsA(isA<WompiValidationException>()),
        );
      });
    });

    group('expirationTime', () {
      test('is normalized to UTC with millisecond precision', () {
        final data = WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          expirationTime: DateTime.utc(2030, 6, 9, 20, 28, 50, 123, 456),
        );

        expect(data.expirationTime!.isUtc, isTrue);
        expect(data.expirationTime!.microsecond, 0);
        expect(data.expirationTime!.millisecond, 123);
        expect(
          data.toQueryParameters()['expiration-time'],
          '2030-06-09T20:28:50.123Z',
        );
      });

      test('serializes a local time as UTC', () {
        final local = DateTime(2030, 6, 9, 20, 28, 50);
        final data = WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          expirationTime: local,
        );

        expect(
          data.toQueryParameters()['expiration-time'],
          local.toUtc().toIso8601String(),
        );
      });

      test('a past date is accepted here and rejected by the client', () {
        // WompiWebCheckout is the one that rejects an expired payment.
        expect(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            expirationTime: DateTime.now().subtract(const Duration(days: 1)),
          ),
          isA<WompiCheckoutData>(),
        );
      });
    });

    test(
        'serializes the default language (validated per country by the '
        'client)', () {
      final data = WompiCheckoutData(
        amountInCents: 10000,
        reference: 'ref_123',
        defaultLanguage: WompiLanguage.english,
      );

      expect(data.toQueryParameters()['default-language'], 'en');
    });

    test('serializes the payment method references', () {
      final data = WompiCheckoutData(
        amountInCents: 10000,
        reference: 'ref_123',
        paymentMethodReferences: WompiPaymentMethodReferences(
          referenceOne: '190.0.0.1',
          referenceTwo: '20230609',
          referenceThree: '123456789',
        ),
      );

      final params = data.toQueryParameters();

      expect(params['payment-method:reference-one'], '190.0.0.1');
      expect(params['payment-method:reference-two'], '20230609');
      expect(params['payment-method:reference-three'], '123456789');
    });

    group('copyWith', () {
      test('returns a new instance with the replaced fields', () {
        final original = WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
        );

        final copy = original.copyWith(
          amountInCents: 20000,
          collectShipping: true,
        );

        expect(copy.amountInCents, 20000);
        expect(copy.reference, 'ref_123');
        expect(copy.collectShipping, isTrue);
        expect(original.amountInCents, 10000);
      });

      test('keeps the untouched nullable fields', () {
        final original = WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          redirectUrl: 'https://mystore.com/result',
          expirationTime: DateTime.utc(2030),
        );

        final copy = original.copyWith(amountInCents: 20000);

        expect(copy.redirectUrl, 'https://mystore.com/result');
        expect(copy.expirationTime, DateTime.utc(2030));
      });

      test('treats a null argument as "keep the current value"', () {
        final original = WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          redirectUrl: 'https://mystore.com/result',
        );

        expect(
          // The call that must be a no-op instead of clearing.
          // ignore: avoid_redundant_argument_values
          original.copyWith(redirectUrl: null).redirectUrl,
          'https://mystore.com/result',
        );
      });
    });

    group('clear', () {
      test('removes only the fields flagged true', () {
        final original = WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          redirectUrl: 'https://mystore.com/result',
          expirationTime: DateTime.utc(2030),
          taxes: WompiTaxes(vat: 1900),
          defaultLanguage: WompiLanguage.english,
          collectShipping: true,
        );

        final cleared = original.clear(
          redirectUrl: true,
          expirationTime: true,
          taxes: true,
        );

        expect(cleared.redirectUrl, isNull);
        expect(cleared.expirationTime, isNull);
        expect(cleared.taxes, isNull);
        expect(cleared.defaultLanguage, WompiLanguage.english);
        expect(cleared.amountInCents, 10000);
        expect(cleared.reference, 'ref_123');
        expect(cleared.collectShipping, isTrue);
      });

      test('leaves the original untouched', () {
        final original = WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          redirectUrl: 'https://mystore.com/result',
        );

        final cleared = original.clear(redirectUrl: true);

        expect(cleared.redirectUrl, isNull);
        expect(original.redirectUrl, 'https://mystore.com/result');
      });

      test('returns an equal instance when nothing is flagged', () {
        final original = WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          redirectUrl: 'https://mystore.com/result',
        );

        expect(original.clear(), equals(original));
      });
    });

    test('supports value equality', () {
      final a = WompiCheckoutData(amountInCents: 10000, reference: 'ref_123');
      final b = WompiCheckoutData(amountInCents: 10000, reference: 'ref_123');
      final c = WompiCheckoutData(amountInCents: 20000, reference: 'ref_123');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });
}
