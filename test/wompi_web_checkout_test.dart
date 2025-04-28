import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiWebCheckout', () {
    late WompiWebCheckout wompi;
    const publicKey = 'pub_test_123';
    const integrityKey = 'test_integrity_key_123';

    setUp(() {
      wompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
      );
    });

    test('should throw exception when public key is empty', () {
      expect(
        () => WompiWebCheckout(publicKey: '', integrityKey: integrityKey),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception when integrity key is empty', () {
      expect(
        () => WompiWebCheckout(publicKey: publicKey, integrityKey: ''),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should generate valid checkout URL', () async {
      final checkoutData = WompiWebCheckoutData(
        reference: 'test_ref_123',
        amountInCents: 10000,
        customerInfo: WompiWebCheckoutCustomerInfo(
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: '3001234567',
        ),
      );

      final uri = await wompi.getCheckoutUri(checkoutData);

      expect(uri.scheme, 'https');
      expect(uri.host, 'checkout.wompi.co');
      expect(uri.path, '/p/');
      expect(uri.queryParameters['public-key'], publicKey);
      expect(uri.queryParameters['reference'], 'test_ref_123');
      expect(uri.queryParameters['amount-in-cents'], '10000');
      expect(uri.queryParameters['currency'], 'COP');
    });

    test('should generate valid checkout URL with expiration time', () async {
      final expirationTime = DateTime.now().add(const Duration(days: 1));
      final checkoutData = WompiWebCheckoutData(
        reference: 'test_ref_123',
        amountInCents: 10000,
        customerInfo: WompiWebCheckoutCustomerInfo(
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: '3001234567',
        ),
        expirationTime: expirationTime,
      );

      final uri = await wompi.getCheckoutUri(checkoutData);

      expect(uri.queryParameters['expiration-time'], isNotNull);
    });
  });

  group('WompiWebCheckoutData', () {
    test('should create valid checkout data', () {
      final checkoutData = WompiWebCheckoutData(
        reference: 'test_ref_123',
        amountInCents: 10000,
        customerInfo: WompiWebCheckoutCustomerInfo(
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: '3001234567',
        ),
      );

      expect(checkoutData.reference, 'test_ref_123');
      expect(checkoutData.amountInCents, 10000);
      expect(checkoutData.currency, 'COP');
      expect(checkoutData.customerInfo?.email, 'test@example.com');
    });

    test('should convert to query parameters correctly', () {
      final checkoutData = WompiWebCheckoutData(
        reference: 'test_ref_123',
        amountInCents: 10000,
        customerInfo: WompiWebCheckoutCustomerInfo(
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: '3001234567',
        ),
      );

      final params = checkoutData.getCheckoutQueryParams();

      expect(params['reference'], 'test_ref_123');
      expect(params['amount-in-cents'], '10000');
      expect(params['currency'], 'COP');
      expect(params['customer-data:email'], 'test@example.com');
      expect(params['customer-data:full-name'], 'Test User');
      expect(params['customer-data:phone-number'], '3001234567');
    });
  });

  group('WompiWebCheckoutData Validations', () {
    test('should throw exception for empty reference', () {
      expect(
        () => WompiWebCheckoutData(
          reference: '',
          amountInCents: 10000,
          customerInfo: WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'Test User',
            phoneNumber: '3001234567',
          ),
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for invalid currency', () {
      expect(
        () => WompiWebCheckoutData(
          reference: 'test_ref_123',
          amountInCents: 10000,
          currency: 'USD',
          customerInfo: WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'Test User',
            phoneNumber: '3001234567',
          ),
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for zero amount', () {
      expect(
        () => WompiWebCheckoutData(
          reference: 'test_ref_123',
          amountInCents: 0,
          customerInfo: WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'Test User',
            phoneNumber: '3001234567',
          ),
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for negative amount', () {
      expect(
        () => WompiWebCheckoutData(
          reference: 'test_ref_123',
          amountInCents: -100,
          customerInfo: WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'Test User',
            phoneNumber: '3001234567',
          ),
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for amount exceeding maximum', () {
      expect(
        () => WompiWebCheckoutData(
          reference: 'test_ref_123',
          amountInCents: 1000000000001,
          customerInfo: WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'Test User',
            phoneNumber: '3001234567',
          ),
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for past expiration time', () {
      expect(
        () => WompiWebCheckoutData(
          reference: 'test_ref_123',
          amountInCents: 10000,
          expirationTime: DateTime.now().subtract(const Duration(days: 1)),
          customerInfo: WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'Test User',
            phoneNumber: '3001234567',
          ),
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for invalid redirect URL', () {
      expect(
        () => WompiWebCheckoutData(
          reference: 'test_ref_123',
          amountInCents: 10000,
          redirectUrl: 'invalid-url',
          customerInfo: WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'Test User',
            phoneNumber: '3001234567',
          ),
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });
  });

  group('WompiWebCheckoutCustomerInfo', () {
    test('should create valid customer info with all fields', () {
      final customerInfo = WompiWebCheckoutCustomerInfo(
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '3001234567',
        legalId: '123456789',
        legalIdType: WompiLegalId.cc,
      );

      expect(customerInfo.email, 'test@example.com');
      expect(customerInfo.fullName, 'Test User');
      expect(customerInfo.phoneNumber, '3001234567');
      expect(customerInfo.legalId, '123456789');
      expect(customerInfo.legalIdType, WompiLegalId.cc);
    });

    test('should create valid customer info with minimal fields', () {
      final customerInfo = WompiWebCheckoutCustomerInfo(
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '3001234567',
      );

      expect(customerInfo.email, 'test@example.com');
      expect(customerInfo.fullName, 'Test User');
      expect(customerInfo.phoneNumber, '3001234567');
      expect(customerInfo.legalId, isNull);
      expect(customerInfo.legalIdType, isNull);
    });

    test('should throw exception for invalid email format', () {
      expect(
        () => WompiWebCheckoutCustomerInfo(
          email: 'invalid-email',
          fullName: 'Test User',
          phoneNumber: '3001234567',
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for empty full name', () {
      expect(
        () => WompiWebCheckoutCustomerInfo(
          email: 'test@example.com',
          fullName: '',
          phoneNumber: '3001234567',
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for invalid phone number', () {
      expect(
        () => WompiWebCheckoutCustomerInfo(
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: 'invalid-phone-number',
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });
  });

  group('WompiWebCheckoutShippingAddress', () {
    late WompiWebCheckout wompi;
    const publicKey = 'pub_test_123';
    const integrityKey = 'test_integrity_key_123';

    setUp(() {
      wompi = WompiWebCheckout(
        publicKey: publicKey,
        integrityKey: integrityKey,
      );
    });

    test('should create valid shipping address with all fields', () {
      final shippingAddress = WompiWebCheckoutShippingAddressInfo(
        addressLine1: 'Calle 123',
        addressLine2: 'Apto 502',
        country: 'CO',
        region: 'Antioquia',
        city: 'Medellin',
        name: 'Test User',
        phoneNumber: '3001234567',
        postalCode: '050001',
      );

      expect(shippingAddress.addressLine1, 'Calle 123');
      expect(shippingAddress.addressLine2, 'Apto 502');
      expect(shippingAddress.country, 'CO');
      expect(shippingAddress.region, 'Antioquia');
      expect(shippingAddress.city, 'Medellin');
      expect(shippingAddress.name, 'Test User');
      expect(shippingAddress.phoneNumber, '3001234567');
      expect(shippingAddress.postalCode, '050001');
    });

    test('should create valid shipping address with minimal fields', () {
      final shippingAddress = WompiWebCheckoutShippingAddressInfo(
        addressLine1: 'Calle 123',
        country: 'CO',
        region: 'Antioquia',
        city: 'Medellin',
        phoneNumber: '3001234567',
      );

      expect(shippingAddress.addressLine1, 'Calle 123');
      expect(shippingAddress.addressLine2, isNull);
      expect(shippingAddress.country, 'CO');
      expect(shippingAddress.region, 'Antioquia');
      expect(shippingAddress.city, 'Medellin');
      expect(shippingAddress.name, isNull);
      expect(shippingAddress.phoneNumber, '3001234567');
      expect(shippingAddress.postalCode, isNull);
    });

    test('should throw exception for empty address line 1', () {
      expect(
        () => WompiWebCheckoutShippingAddressInfo(
          addressLine1: '',
          country: 'CO',
          region: 'Antioquia',
          city: 'Medellin',
          phoneNumber: '3001234567',
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for empty country', () {
      expect(
        () => WompiWebCheckoutShippingAddressInfo(
          addressLine1: 'Calle 123',
          country: '',
          region: 'Antioquia',
          city: 'Medellin',
          phoneNumber: '3001234567',
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for empty region', () {
      expect(
        () => WompiWebCheckoutShippingAddressInfo(
          addressLine1: 'Calle 123',
          country: 'CO',
          region: '',
          city: 'Medellin',
          phoneNumber: '3001234567',
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for empty city', () {
      expect(
        () => WompiWebCheckoutShippingAddressInfo(
          addressLine1: 'Calle 123',
          country: 'CO',
          region: 'Antioquia',
          city: '',
          phoneNumber: '3001234567',
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should throw exception for invalid phone number', () {
      expect(
        () => WompiWebCheckoutShippingAddressInfo(
          addressLine1: 'Calle 123',
          country: 'CO',
          region: 'Antioquia',
          city: 'Medellin',
          phoneNumber: 'invalid-phone',
        ),
        throwsA(isA<WompiInvalidArgumentException>()),
      );
    });

    test('should generate valid checkout URL with shipping address', () async {
      final checkoutData = WompiWebCheckoutData(
        reference: 'test_ref_123',
        amountInCents: 10000,
        customerInfo: WompiWebCheckoutCustomerInfo(
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: '3001234567',
        ),
        shippingAddressInfo: WompiWebCheckoutShippingAddressInfo(
          addressLine1: 'Calle 123',
          city: 'Medellin',
          region: 'Antioquia',
          country: 'CO',
          postalCode: '110111',
          phoneNumber: '3001234567',
        ),
      );

      final uri = await wompi.getCheckoutUri(checkoutData);

      expect(uri.queryParameters['shipping-address:address-line-1'], isNotNull);
      expect(uri.queryParameters['shipping-address:city'], 'Medellin');
      expect(uri.queryParameters['shipping-address:region'], 'Antioquia');
      expect(uri.queryParameters['shipping-address:country'], 'CO');
    });
  });
}
