import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiCustomerData', () {
    test('creates a valid instance with all fields', () {
      final customer = WompiCustomerData(
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '3001234567',
        phoneNumberPrefix: '+57',
        legalId: '123456789',
        legalIdType: WompiLegalIdType.cc,
      );

      expect(customer.email, 'test@example.com');
      expect(customer.fullName, 'Test User');
      expect(customer.phoneNumber, '3001234567');
      expect(customer.phoneNumberPrefix, '+57');
      expect(customer.legalId, '123456789');
      expect(customer.legalIdType, WompiLegalIdType.cc);
    });

    test('creates a valid empty instance', () {
      expect(WompiCustomerData(), isA<WompiCustomerData>());
    });

    test('throws for an invalid email format', () {
      expect(
        () => WompiCustomerData(email: 'invalid-email'),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'email',
          ),
        ),
      );
    });

    test('throws for an empty full name', () {
      expect(
        () => WompiCustomerData(fullName: '  '),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'fullName',
          ),
        ),
      );
    });

    test('throws for a phone number with letters', () {
      expect(
        () => WompiCustomerData(
          phoneNumber: 'invalid-phone',
          phoneNumberPrefix: '+57',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.map((e) => e.field),
            'fields',
            contains('phoneNumber'),
          ),
        ),
      );
    });

    test('throws for a phone number with the country code embedded', () {
      expect(
        () => WompiCustomerData(
          phoneNumber: '+573001234567',
          phoneNumberPrefix: '+57',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.map((e) => e.field),
            'fields',
            contains('phoneNumber'),
          ),
        ),
      );
    });

    test('throws for an invalid phone number prefix', () {
      expect(
        () => WompiCustomerData(
          phoneNumber: '3001234567',
          phoneNumberPrefix: '57',
        ),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'phoneNumberPrefix',
          ),
        ),
      );
    });

    test('requires the prefix when the phone number is provided', () {
      expect(
        () => WompiCustomerData(phoneNumber: '3001234567'),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'phoneNumberPrefix',
          ),
        ),
      );
    });

    test('requires the phone number when the prefix is provided', () {
      expect(
        () => WompiCustomerData(phoneNumberPrefix: '+57'),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'phoneNumber',
          ),
        ),
      );
    });

    test('requires the legal ID type when the legal ID is provided', () {
      expect(
        () => WompiCustomerData(legalId: '123456789'),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'legalIdType',
          ),
        ),
      );
    });

    test('requires the legal ID when the legal ID type is provided', () {
      expect(
        () => WompiCustomerData(legalIdType: WompiLegalIdType.cc),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'legalId',
          ),
        ),
      );
    });

    test('copyWith returns a new instance with the replaced fields', () {
      final original = WompiCustomerData(email: 'old@example.com');
      final copy = original.copyWith(email: 'new@example.com');

      expect(copy.email, 'new@example.com');
      expect(original.email, 'old@example.com');
    });

    test('supports value equality', () {
      final a = WompiCustomerData(email: 'test@example.com');
      final b = WompiCustomerData(email: 'test@example.com');
      final c = WompiCustomerData(email: 'other@example.com');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('clear removes only the flagged fields', () {
      final original = WompiCustomerData(
        email: 'lola@perez.com',
        fullName: 'Lola Perez',
        phoneNumber: '3019777777',
        phoneNumberPrefix: '+57',
      );

      final cleared = original.clear(
        phoneNumber: true,
        phoneNumberPrefix: true,
      );

      expect(cleared.phoneNumber, isNull);
      expect(cleared.phoneNumberPrefix, isNull);
      expect(cleared.email, 'lola@perez.com');
      expect(cleared.fullName, 'Lola Perez');
    });

    test('clear enforces the pairs Wompi requires together', () {
      final original = WompiCustomerData(
        phoneNumber: '3019777777',
        phoneNumberPrefix: '+57',
      );

      expect(
        () => original.clear(phoneNumber: true),
        throwsA(
          isA<WompiValidationException>().having(
            (e) => e.errors.single.field,
            'field',
            'phoneNumber',
          ),
        ),
      );
    });
  });
}
