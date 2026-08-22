import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  const publicKey = 'pub_test_X0zDA9xoKdePzhd8a0x9HAez7HgGO2fH';
  const integrityKey = 'test_integrity_key_123';

  late WompiWebCheckout wompi;

  setUp(() {
    wompi = WompiWebCheckout(
      publicKey: publicKey,
      integrityKey: integrityKey,
    );
  });

  group('WompiWebCheckout constructor', () {
    test('creates an instance with valid keys', () {
      expect(
        WompiWebCheckout(
          publicKey: publicKey,
          integrityKey: integrityKey,
        ),
        isA<WompiWebCheckout>(),
      );
    });

    test('throws when the public key is empty', () {
      expect(
        () => WompiWebCheckout(
          publicKey: '',
          integrityKey: integrityKey,
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.map((e) => e.field),
            'fields',
            contains('publicKey'),
          ),
        ),
      );
    });

    test('throws when the integrity key is empty', () {
      expect(
        () => WompiWebCheckout(
          publicKey: publicKey,
          integrityKey: '',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.map((e) => e.field),
            'fields',
            contains('integrityKey'),
          ),
        ),
      );
    });

    test('reports both keys at once when both are empty', () {
      expect(
        () => WompiWebCheckout(publicKey: '', integrityKey: ''),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.length,
            'error count',
            2,
          ),
        ),
      );
    });

    test('throws when the public key has an unrecognized format', () {
      expect(
        () => WompiWebCheckout(
          publicKey: 'pub_staging_123',
          integrityKey: integrityKey,
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'publicKey',
          ),
        ),
      );
    });

    test('throws when the integrity key has an unrecognized format', () {
      expect(
        () => WompiWebCheckout(
          publicKey: publicKey,
          integrityKey: 'some_secret_123',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'integrityKey',
          ),
        ),
      );
    });
  });

  group('WompiWebCheckout.environment', () {
    test('is sandbox for pub_test_ keys', () {
      expect(wompi.environment, WompiEnvironment.sandbox);
    });

    test('is production for pub_prod_ keys', () {
      final prodWompi = WompiWebCheckout(
        publicKey: 'pub_prod_Kw4aC0rZVgLZQn209NbEKPuXLzBD28Zx',
        integrityKey: 'prod_integrity_Z5mMke9x0k8gpErbDqwrJXMqsI6SFli6',
      );

      expect(prodWompi.environment, WompiEnvironment.production);
    });
  });

  group('WompiWebCheckout.getCheckoutUri', () {
    test('points to the Wompi web checkout host', () {
      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(amountInCents: 10000, reference: 'ref_123'),
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'checkout.wompi.co');
      expect(uri.path, '/p/');
    });

    test('points to the Panamanian host when the country is Panama', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      final uri = panamaWompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
        ),
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'checkout.wompi.pa');
      expect(uri.path, '/p/');
      expect(uri.queryParameters['currency'], 'USD');
    });

    test('defaults to Colombia', () {
      expect(wompi.country, WompiCountry.colombia);
    });

    test('derives the currency from the country', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      final data = WompiCheckoutData(
        amountInCents: 10000,
        reference: 'ref_123',
      );

      expect(wompi.getCheckoutUri(data).queryParameters['currency'], 'COP');
      expect(
        panamaWompi.getCheckoutUri(data).queryParameters['currency'],
        'USD',
      );
    });

    test('rejects the consumption tax for Panama', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      expect(
        () => panamaWompi.getCheckoutUri(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            taxes: WompiTaxes(consumption: 800),
          ),
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'taxes.consumption',
          ),
        ),
      );
    });

    test('accepts the ITBMS reported through the VAT field in Panama', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      final uri = panamaWompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          taxes: WompiTaxes(vat: 700),
        ),
      );

      expect(uri.queryParameters['tax-in-cents:vat'], '700');
    });

    test('accepts the consumption tax for Colombia', () {
      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          taxes: WompiTaxes(vat: 1900, consumption: 800),
        ),
      );

      expect(uri.queryParameters['tax-in-cents:consumption'], '800');
    });

    test('throws when the expiration time has already passed', () {
      final expired = WompiCheckoutData(
        amountInCents: 10000,
        reference: 'ref_123',
        expirationTime: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(
        () => wompi.getCheckoutUri(expired),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'expirationTime',
          ),
        ),
      );
    });

    test('throws when the legal ID type does not match the country', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      expect(
        () => panamaWompi.getCheckoutUri(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            customerData: WompiCustomerData(
              legalId: '123456789',
              legalIdType: WompiLegalIdType.nit,
            ),
          ),
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'legalIdType',
          ),
        ),
      );
    });

    test('accepts a legal ID type that matches the country', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      final uri = panamaWompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          customerData: WompiCustomerData(
            legalId: '123456789',
            legalIdType: WompiLegalIdType.ruc,
          ),
        ),
      );

      expect(uri.queryParameters['customer-data:legal-id-type'], 'RUC');
    });

    test('percent-encodes the values that need it', () {
      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          redirectUrl: 'https://mystore.com/ok?a=1&b=2',
          customerData: WompiCustomerData(
            email: 'lola+test@perez.com',
            fullName: 'Lola Pérez',
            phoneNumber: '3019777777',
            phoneNumberPrefix: '+57',
          ),
        ),
      );

      // Round-tripping through Uri must give back the original values,
      // so nothing leaks into the query structure.
      final params = uri.queryParameters;

      expect(params['redirect-url'], 'https://mystore.com/ok?a=1&b=2');
      expect(params['customer-data:email'], 'lola+test@perez.com');
      expect(params['customer-data:full-name'], 'Lola Pérez');
      expect(params['customer-data:phone-number-prefix'], '+57');
      expect(params['reference'], 'ref_123');
    });

    test('includes the required transaction parameters', () {
      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(amountInCents: 10000, reference: 'ref_123'),
      );

      expect(uri.queryParameters['public-key'], publicKey);
      expect(uri.queryParameters['currency'], 'COP');
      expect(uri.queryParameters['amount-in-cents'], '10000');
      expect(uri.queryParameters['reference'], 'ref_123');
      expect(uri.queryParameters['signature:integrity'], isNotEmpty);
    });

    test('generates the integrity signature from the official docs example',
        () {
      // Golden test vector taken from the official Wompi documentation:
      // https://docs.wompi.co/docs/colombia/widget-checkout-web/
      final docsWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: 'prod_integrity_Z5mMke9x0k8gpErbDqwrJXMqsI6SFli6',
      );

      final uri = docsWompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 2490000,
          reference: 'sk8-438k4-xmxm392-sn2m',
        ),
      );

      expect(
        uri.queryParameters['signature:integrity'],
        '37c8407747e595535433ef8f6a811d853cd943046624a0ec04662b17bbf33bf5',
      );
    });

    test('concatenates the expiration time in the signature when present', () {
      final expirationTime = DateTime.utc(2030, 6, 9, 20, 28, 50);

      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 2490000,
          reference: 'sk8-438k4-xmxm392-sn2m',
          expirationTime: expirationTime,
        ),
      );

      const concatenated = 'sk8-438k4-xmxm392-sn2m2490000COP'
          '2030-06-09T20:28:50.000Z$integrityKey';
      final expected = sha256.convert(utf8.encode(concatenated)).toString();

      expect(uri.queryParameters['signature:integrity'], expected);
      expect(
        uri.queryParameters['expiration-time'],
        '2030-06-09T20:28:50.000Z',
      );
    });

    test('signs USD transactions for Panama', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      final uri = panamaWompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 2490000,
          reference: 'sk8-438k4-xmxm392-sn2m',
        ),
      );

      const concatenated = 'sk8-438k4-xmxm392-sn2m2490000USD$integrityKey';
      final expected = sha256.convert(utf8.encode(concatenated)).toString();

      expect(uri.queryParameters['signature:integrity'], expected);
    });

    test('normalizes the expiration time to UTC milliseconds', () {
      // DateTime.now() carries microseconds on the VM; Wompi documents
      // millisecond precision.
      final local = DateTime.now().add(const Duration(days: 1));
      final expected = DateTime.fromMillisecondsSinceEpoch(
        local.millisecondsSinceEpoch,
        isUtc: true,
      );

      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          expirationTime: local,
        ),
      );

      final serialized = uri.queryParameters['expiration-time']!;

      expect(serialized, expected.toIso8601String());
      expect(RegExp(r'\.\d{3}Z$').hasMatch(serialized), isTrue);

      final concatenated =
          'ref_12310000COP${expected.toIso8601String()}$integrityKey';

      expect(
        uri.queryParameters['signature:integrity'],
        sha256.convert(utf8.encode(concatenated)).toString(),
      );
    });

    test('generates the Panamanian signature for the docs example values', () {
      // The Panama docs publish the Colombian hash for their USD
      // example, which is wrong. This is the real one.
      final docsWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: 'prod_integrity_Z5mMke9x0k8gpErbDqwrJXMqsI6SFli6',
        country: WompiCountry.panama,
      );

      final uri = docsWompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 2490000,
          reference: 'sk8-438k4-xmxm392-sn2m',
        ),
      );

      expect(
        uri.queryParameters['signature:integrity'],
        '80a19fcdd34370420981269bf16b74f3dc824ac6140f76b1f8ac3363b5824031',
      );
    });

    test('never leaks the integrity key', () {
      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(amountInCents: 10000, reference: 'ref_123'),
      );

      expect(uri.toString(), isNot(contains(integrityKey)));
      expect(wompi.toString(), isNot(contains(integrityKey)));
    });

    test('signs the expiration time exactly as it is sent', () {
      // The URL and the signature must use the same truncated string.
      final local = DateTime.now().add(const Duration(days: 1));

      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 2490000,
          reference: 'sk8-438k4-xmxm392-sn2m',
          expirationTime: local,
        ),
      );

      final concatenated = 'sk8-438k4-xmxm392-sn2m2490000COP'
          '${uri.queryParameters['expiration-time']}$integrityKey';

      expect(
        uri.queryParameters['signature:integrity'],
        sha256.convert(utf8.encode(concatenated)).toString(),
      );
    });

    test('includes every optional parameter when provided', () {
      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 11900000,
          reference: 'order-123',
          redirectUrl: 'https://mystore.com/payments/result',
          collectShipping: true,
          collectCustomerLegalId: true,
          taxes: WompiTaxes(vat: 1900000, consumption: 80000),
          paymentMethodReferences: WompiPaymentMethodReferences(
            referenceOne: '190.0.0.1',
            referenceTwo: '20230609',
            referenceThree: '123456789',
          ),
          customerData: WompiCustomerData(
            email: 'lola@perez.com',
            fullName: 'Lola Perez',
            phoneNumber: '3019777777',
            phoneNumberPrefix: '+57',
            legalId: '123456789',
            legalIdType: WompiLegalIdType.cc,
          ),
          shippingAddress: WompiShippingAddress(
            addressLine1: 'Carrera 123 #4-5',
            addressLine2: 'apto 123',
            country: 'CO',
            region: 'Cundinamarca',
            city: 'Bogota',
            phoneNumber: '3019988888',
            name: 'Pedro Perez',
            postalCode: '110111',
          ),
        ),
      );

      final params = uri.queryParameters;

      expect(params['redirect-url'], 'https://mystore.com/payments/result');
      expect(params['collect-shipping'], 'true');
      expect(params['collect-customer-legal-id'], 'true');
      expect(params['tax-in-cents:vat'], '1900000');
      expect(params['tax-in-cents:consumption'], '80000');
      expect(params['payment-method:reference-one'], '190.0.0.1');
      expect(params['payment-method:reference-two'], '20230609');
      expect(params['payment-method:reference-three'], '123456789');
      expect(params['customer-data:email'], 'lola@perez.com');
      expect(params['customer-data:full-name'], 'Lola Perez');
      expect(params['customer-data:phone-number'], '3019777777');
      expect(params['customer-data:phone-number-prefix'], '+57');
      expect(params['customer-data:legal-id'], '123456789');
      expect(params['customer-data:legal-id-type'], 'CC');
      expect(params['shipping-address:address-line-1'], 'Carrera 123 #4-5');
      expect(params['shipping-address:address-line-2'], 'apto 123');
      expect(params['shipping-address:country'], 'CO');
      expect(params['shipping-address:region'], 'Cundinamarca');
      expect(params['shipping-address:city'], 'Bogota');
      expect(params['shipping-address:phone-number'], '3019988888');
      expect(params['shipping-address:name'], 'Pedro Perez');
      expect(params['shipping-address:postal-code'], '110111');
    });

    test('sends the checkout language for Panama', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      final uri = panamaWompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 10000,
          reference: 'ref_123',
          defaultLanguage: WompiLanguage.english,
        ),
      );

      expect(uri.queryParameters['default-language'], 'en');
    });

    test('rejects the checkout language for Colombia', () {
      expect(
        () => wompi.getCheckoutUri(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            defaultLanguage: WompiLanguage.spanish,
          ),
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'defaultLanguage',
          ),
        ),
      );
    });

    test('aggregates every country mismatch at once', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      expect(
        () => panamaWompi.getCheckoutUri(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            taxes: WompiTaxes(consumption: 800),
            defaultLanguage: WompiLanguage.english,
            paymentMethodReferences: WompiPaymentMethodReferences(
              referenceOne: '190.0.0.1',
            ),
            customerData: WompiCustomerData(
              legalId: '123456789',
              legalIdType: WompiLegalIdType.nit,
            ),
            expirationTime: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.map((e) => e.field),
            'fields',
            containsAll(<String>[
              'legalIdType',
              'taxes.consumption',
              'paymentMethodReferences',
              'expirationTime',
            ]),
          ),
        ),
      );
    });

    test('rejects payment method references for Panama', () {
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      expect(
        () => panamaWompi.getCheckoutUri(
          WompiCheckoutData(
            amountInCents: 10000,
            reference: 'ref_123',
            paymentMethodReferences: WompiPaymentMethodReferences(
              referenceOne: '190.0.0.1',
            ),
          ),
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'paymentMethodReferences',
          ),
        ),
      );
    });

    test('sends the parameters shared by both countries to Panama', () {
      // Everything not gated per country must go through unchanged.
      final panamaWompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
        country: WompiCountry.panama,
      );

      final uri = panamaWompi.getCheckoutUri(
        WompiCheckoutData(
          amountInCents: 9500,
          reference: 'ref_123',
          redirectUrl: 'https://mystore.com/payments/result',
          expirationTime: DateTime.utc(2030, 6, 9, 20, 28, 50),
          collectShipping: true,
          collectCustomerLegalId: true,
          taxes: WompiTaxes(vat: 700),
          customerData: WompiCustomerData(
            email: 'lola@perez.com',
            fullName: 'Lola Perez',
            phoneNumber: '60123456',
            phoneNumberPrefix: '+507',
            legalId: '123456789',
            legalIdType: WompiLegalIdType.ruc,
          ),
          shippingAddress: WompiShippingAddress(
            addressLine1: 'Calle 50',
            addressLine2: 'Piso 3',
            country: 'PA',
            region: 'Panama',
            city: 'Ciudad de Panama',
            phoneNumber: '60123456',
            name: 'Pedro Perez',
            postalCode: '0801',
          ),
        ),
      );

      final params = uri.queryParameters;

      expect(params['currency'], 'USD');
      expect(params['redirect-url'], 'https://mystore.com/payments/result');
      expect(params['expiration-time'], '2030-06-09T20:28:50.000Z');
      expect(params['collect-shipping'], 'true');
      expect(params['collect-customer-legal-id'], 'true');
      expect(params['tax-in-cents:vat'], '700');
      expect(params['customer-data:phone-number-prefix'], '+507');
      expect(params['customer-data:legal-id-type'], 'RUC');
      expect(params['shipping-address:address-line-2'], 'Piso 3');
      expect(params['shipping-address:name'], 'Pedro Perez');
      expect(params['shipping-address:postal-code'], '0801');
    });

    test('omits collect flags when they are false', () {
      final uri = wompi.getCheckoutUri(
        WompiCheckoutData(amountInCents: 10000, reference: 'ref_123'),
      );

      expect(uri.queryParameters.containsKey('collect-shipping'), isFalse);
      expect(
        uri.queryParameters.containsKey('collect-customer-legal-id'),
        isFalse,
      );
    });
  });
}
