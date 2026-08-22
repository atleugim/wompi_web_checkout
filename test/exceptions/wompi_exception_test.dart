import 'package:test/test.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

void main() {
  group('WompiValidationException', () {
    test('exposes an unmodifiable list of errors', () {
      final exception = WompiValidationException([
        const WompiFieldError(field: 'reference', message: 'Cannot be empty.'),
      ]);

      expect(exception.errors, hasLength(1));
      expect(
        () => exception.errors.add(
          const WompiFieldError(field: 'other', message: 'other'),
        ),
        throwsUnsupportedError,
      );
    });

    test('builds a message describing every error', () {
      final exception = WompiValidationException([
        const WompiFieldError(field: 'reference', message: 'Cannot be empty.'),
        const WompiFieldError(
          field: 'amountInCents',
          message: 'Must be greater than 0.',
        ),
      ]);

      expect(exception.message, contains('2 validation errors'));
      expect(exception.message, contains('reference: Cannot be empty.'));
      expect(
        exception.message,
        contains('amountInCents: Must be greater than 0.'),
      );
      expect(exception.toString(), contains('WompiValidationException'));
    });
  });
}
