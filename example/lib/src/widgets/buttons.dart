import 'package:cuid2/cuid2.dart';
import 'package:flutter/material.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';
import 'package:wompi_webview_example/src/widgets/button.dart';
import 'package:wompi_webview_example/src/widgets/webview.dart';

class WompiPaymentButtons extends StatefulWidget {
  const WompiPaymentButtons({super.key});

  @override
  State<WompiPaymentButtons> createState() => _WompiPaymentButtonsState();
}

class _WompiPaymentButtonsState extends State<WompiPaymentButtons> {
  final wompiCheckout = WompiWebCheckout(
    publicKey: '<YOUR_PUBLIC_KEY>',
    integrityKey: '<YOUR_INTEGRITY_KEY>',
  );

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, textAlign: TextAlign.center)),
      );
    }
  }

  Future<void> _pay(WompiWebCheckoutData paymentData) async {
    try {
      final url = await wompiCheckout.getCheckoutUri(paymentData);

      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute<bool>(
            builder:
                (context) => PaymentWebview(
                  url: url,
                  redirectUrl: paymentData.redirectUrl,
                ),
          ),
        );

        if (result == null) {
          _showSnackBar('Payment cancelled');
        } else {
          _showSnackBar(result ? 'Payment in progress' : 'Payment failed');
        }
      }
    } on WompiException catch (err) {
      if (mounted) {
        _showSnackBar(err.message);
      }
    } on Exception catch (err) {
      _showSnackBar(err.toString());
    }
  }

  Future<void> _payWithBasicData() async {
    try {
      await _pay(
        WompiWebCheckoutData(
          amountInCents: 10000000,
          reference: cuid(),
          redirectUrl: 'https://example.com',
        ),
      );
    } on WompiException catch (err) {
      _showSnackBar(err.message);
    } on Exception catch (err) {
      _showSnackBar(err.toString());
    }
  }

  Future<void> _payWithBasicAndCustomerInfo() async {
    try {
      await _pay(
        WompiWebCheckoutData(
          amountInCents: 10000000,
          reference: cuid(),
          redirectUrl: 'https://example.com',
          customerInfo: const WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'John Doe',
            phoneNumber: '3991111111',
            legalId: '1234567890',
            legalIdType: WompiLegalId.cc,
          ),
        ),
      );
    } on WompiException catch (err) {
      _showSnackBar(err.message);
    } on Exception catch (err) {
      _showSnackBar(err.toString());
    }
  }

  Future<void> _payWithCompleteData() async {
    try {
      await _pay(
        WompiWebCheckoutData(
          amountInCents: 10000000,
          reference: cuid(),
          redirectUrl: 'https://example.com',
          expirationTime: DateTime.now().add(const Duration(days: 1)),
          customerInfo: const WompiWebCheckoutCustomerInfo(
            email: 'test@example.com',
            fullName: 'John Doe',
            phoneNumber: '3991111111',
            legalId: '1234567890',
            legalIdType: WompiLegalId.cc,
          ),
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
        ),
      );
    } on WompiException catch (err) {
      _showSnackBar(err.message);
    } on Exception catch (err) {
      _showSnackBar(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PayWithWompiButton(
            onPressed: _payWithBasicData,
            text: 'Pay with basic data',
          ),
          const SizedBox(height: 16),
          PayWithWompiButton(
            onPressed: _payWithBasicAndCustomerInfo,
            text: 'Pay with basic and customer info',
          ),
          const SizedBox(height: 16),
          PayWithWompiButton(
            onPressed: _payWithCompleteData,
            text: 'Pay with complete data',
          ),
        ],
      ),
    );
  }
}
