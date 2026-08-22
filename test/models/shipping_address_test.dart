import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiShippingAddress', () {
    WompiShippingAddress buildAddress() {
      return WompiShippingAddress(
        addressLine1: 'Calle 123',
        addressLine2: 'Apto 502',
        country: 'CO',
        region: 'Antioquia',
        city: 'Medellin',
        name: 'Test User',
        phoneNumber: '3001234567',
        postalCode: '050001',
      );
    }

    test('creates a valid instance with all fields', () {
      final address = buildAddress();

      expect(address.addressLine1, 'Calle 123');
      expect(address.addressLine2, 'Apto 502');
      expect(address.country, 'CO');
      expect(address.region, 'Antioquia');
      expect(address.city, 'Medellin');
      expect(address.name, 'Test User');
      expect(address.phoneNumber, '3001234567');
      expect(address.postalCode, '050001');
    });

    test('creates a valid instance with the required fields only', () {
      final address = WompiShippingAddress(
        addressLine1: 'Calle 123',
        country: 'CO',
        region: 'Antioquia',
        city: 'Medellin',
        phoneNumber: '3001234567',
      );

      expect(address.addressLine2, isNull);
      expect(address.name, isNull);
      expect(address.postalCode, isNull);
    });

    test('aggregates every missing or invalid required field', () {
      expect(
        () => WompiShippingAddress(
          addressLine1: '',
          country: '',
          region: '',
          city: '',
          phoneNumber: '',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.map((e) => e.field),
            'fields',
            containsAll(<String>[
              'addressLine1',
              'country',
              'region',
              'city',
              'phoneNumber',
            ]),
          ),
        ),
      );
    });

    test('throws for a malformed country code', () {
      expect(
        () => WompiShippingAddress(
          addressLine1: 'Calle 123',
          country: 'col',
          region: 'Antioquia',
          city: 'Medellin',
          phoneNumber: '3001234567',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'country',
          ),
        ),
      );
    });

    test('throws for an invalid phone number', () {
      expect(
        () => WompiShippingAddress(
          addressLine1: 'Calle 123',
          country: 'CO',
          region: 'Antioquia',
          city: 'Medellin',
          phoneNumber: 'invalid-phone',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'phoneNumber',
          ),
        ),
      );
    });

    test('throws when an optional field is provided but empty', () {
      expect(
        () => WompiShippingAddress(
          addressLine1: 'Calle 123',
          country: 'CO',
          region: 'Antioquia',
          city: 'Medellin',
          phoneNumber: '3001234567',
          name: '',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'name',
          ),
        ),
      );
    });

    test('copyWith returns a new instance with the replaced fields', () {
      final original = buildAddress();
      final copy = original.copyWith(city: 'Bogota');

      expect(copy.city, 'Bogota');
      expect(copy.addressLine1, 'Calle 123');
      expect(original.city, 'Medellin');
    });

    test('supports value equality', () {
      final a = buildAddress();
      final b = buildAddress();
      final c = buildAddress().copyWith(city: 'Bogota');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('clear removes only the flagged optional fields', () {
      final original = WompiShippingAddress(
        addressLine1: 'Carrera 123 # 4-5',
        addressLine2: 'Apto 502',
        country: 'CO',
        region: 'Antioquia',
        city: 'Medellin',
        phoneNumber: '3109999999',
        name: 'Miguel Vega',
        postalCode: '050001',
      );

      final cleared = original.clear(addressLine2: true, postalCode: true);

      expect(cleared.addressLine2, isNull);
      expect(cleared.postalCode, isNull);
      expect(cleared.name, 'Miguel Vega');
      expect(cleared.addressLine1, 'Carrera 123 # 4-5');
      expect(original.addressLine2, 'Apto 502');
    });
  });
}
