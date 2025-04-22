# Wompi Web Checkout

A Dart package that provides a seamless integration with Wompi's web checkout system, allowing you to easily implement payment processing in your Flutter applications.

- 🔒 Secure payment processing with Wompi
- 🛠️ Simple Dart API

## Getting Started

### Prerequisites

- Dart SDK (>=2.17.0)

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  wompi_web_checkout: ^1.0.0
```

Then run:

```bash
dart pub get
// or
flutter pub get
```

## Usage

1. Import the package:

    ```dart
    import 'package:wompi_web_checkout/wompi_web_checkout.dart';
    ```

2. Initialize the Wompi controller with your keys:

    ```dart
    final wompiCheckout = WompiWebCheckout(
      publicKey: '<YOUR_PUBLIC_KEY>',
      integrityKey: '<YOUR_INTEGRITY_KEY>',
    );
    ```

3. Create a payment with basic data:

    ```dart
    final paymentData = WompiWebCheckoutData(
      amountInCents: 10000000,
      reference: 'unique_reference',
      redirectUrl: 'https://your-domain.com/redirect',
    );
    ```

4. Add customer information (optional):

    ```dart
    final paymentData = WompiWebCheckoutData(
      // ... basic payment data
      customerInfo: const WompiWebCheckoutCustomerInfo(
        email: 'customer@example.com',
        fullName: 'John Doe',
        phoneNumber: '3991111111',
        legalId: '1234567890',
        legalIdType: WompiLegalId.cc,
      ),
    );
    ```

5. Add shipping information (optional):

    ```dart
    final paymentData = WompiWebCheckoutData(
      // ... basic payment data
      // ... customer info
      shippingAddressInfo: const WompiWebCheckoutShippingAddressInfo(
        addressLine1: 'Calle 100 # 100-100',
        country: 'CO',
        region: 'Antioquia',
        city: 'Medellín',
        postalCode: '100001',
        phoneNumber: '3991111111',
        name: 'John Doe',
        addressLine2: 'Apt 1',
      ),
    );
    ```

6. Process the payment:

    ```dart
    try {
      final url = await wompiCheckout.getCheckoutUri(paymentData);
      // Use the URL to redirect the user to the Wompi web checkout page
      print('Checkout URL: $url');
    } on WompiException catch (err) {
      // Handle Wompi exceptions
    } catch (err) {
      // Handle other exceptions
    }
    ```

## Additional Information

You can see the example app in the `/example` folder.

For more detailed information about the Wompi Web Checkout, please refer to the [official documentation](https://docs.wompi.co/docs/colombia/widget-checkout-web/#web-checkout/).

### Contributing

Contributions are welcome! Please feel free to submit a [Pull Request](https://github.com/atleugim/wompi_web_checkout/pulls).

### Issues

If you encounter any issues or have suggestions for improvements, please [open an issue](https://github.com/atleugim/wompi_web_checkout/issues).

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
