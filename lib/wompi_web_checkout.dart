/// A pure Dart client for the Wompi **Web Checkout**.
///
/// Build integrity-signed checkout URLs and let your customers complete
/// their payments on Wompi's hosted checkout page, from any Dart or
/// Flutter application.
///
/// ```dart
/// import 'package:wompi_web_checkout/wompi_web_checkout.dart';
///
/// // Your backend signs the payment, so the integrity secret never
/// // reaches the app. Preferable for security.
/// final wompi = WompiWebCheckout.fromServer(
///   publicKey: 'pub_test_...',
///   integritySignature: '<SIGNATURE_FROM_YOUR_BACKEND>',
/// );
///
/// // Or the app holds the secret and signs on its own:
/// final wompi = WompiWebCheckout.fromClient(
///   publicKey: 'pub_test_...',
///   integrityKey: 'test_integrity_...',
/// );
///
/// final uri = wompi.getCheckoutUri(
///   WompiCheckoutData(
///     amountInCents: 4950000,
///     reference: 'order-123',
///     redirectUrl: 'https://mystore.com/payments/result',
///   ),
/// );
/// ```
library;

export 'src/exceptions/wompi_exception.dart';
export 'src/models/checkout_data.dart';
export 'src/models/customer_data.dart';
export 'src/models/legal_id_type.dart';
export 'src/models/payment_method_references.dart';
export 'src/models/shipping_address.dart';
export 'src/models/taxes.dart';
export 'src/models/wompi_country.dart';
export 'src/models/wompi_currency.dart';
export 'src/models/wompi_environment.dart';
export 'src/models/wompi_language.dart';
export 'src/wompi_web_checkout.dart';
