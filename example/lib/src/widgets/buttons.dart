import 'package:cuid2/cuid2.dart';
import 'package:flutter/material.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';
import 'package:wompi_webview_example/src/widgets/button.dart';
import 'package:wompi_webview_example/src/widgets/webview.dart';

/// The values that differ between the two checkouts, so the sample
/// payments make sense in each country.
typedef CountryFixtures =
    ({
      int amountInCents,
      int completeAmountInCents,
      int vatInCents,
      String phonePrefix,
      String phoneNumber,
      String shippingCountry,
      String region,
      String city,
      String addressLine1,
      WompiLegalIdType legalIdType,
    });

const _fixtures = <WompiCountry, CountryFixtures>{
  WompiCountry.colombia: (
    amountInCents: 10000000, // COP $100.000
    completeAmountInCents: 11900000, // COP $119.000
    vatInCents: 1900000,
    phonePrefix: '+57',
    phoneNumber: '3991111111',
    shippingCountry: 'CO',
    region: 'Antioquia',
    city: 'Medellín',
    addressLine1: 'Calle 100 # 100-100',
    legalIdType: WompiLegalIdType.cc,
  ),
  WompiCountry.panama: (
    amountInCents: 9500, // USD $95
    completeAmountInCents: 10165, // USD $101,65
    vatInCents: 665,
    phonePrefix: '+507',
    phoneNumber: '60123456',
    shippingCountry: 'PA',
    region: 'Panamá',
    city: 'Ciudad de Panamá',
    addressLine1: 'Calle 50, Edificio Tower',
    legalIdType: WompiLegalIdType.ruc,
  ),
};

class WompiPaymentButtons extends StatefulWidget {
  const WompiPaymentButtons({required this.checkout, super.key});

  /// The client built from the credentials entered on the setup screen.
  final WompiWebCheckout checkout;

  @override
  State<WompiPaymentButtons> createState() => _WompiPaymentButtonsState();
}

class _WompiPaymentButtonsState extends State<WompiPaymentButtons> {
  WompiWebCheckout get _wompiCheckout => widget.checkout;

  CountryFixtures get _fixture => _fixtures[_wompiCheckout.country]!;

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, textAlign: TextAlign.center)),
      );
    }
  }

  Future<void> _pay(WompiCheckoutData paymentData) async {
    try {
      final url = _wompiCheckout.getCheckoutUri(paymentData);

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
    } on WompiValidationException catch (err) {
      for (final error in err.errors) {
        _showSnackBar('${error.field}: ${error.message}');
      }
    } on Exception catch (err) {
      _showSnackBar(err.toString());
    }
  }

  Future<void> _payWithBasicData() async {
    await _pay(
      WompiCheckoutData(
        amountInCents: _fixture.amountInCents,
        reference: cuid(),
        redirectUrl: 'https://example.com',
      ),
    );
  }

  Future<void> _payWithBasicAndCustomerInfo() async {
    await _pay(
      WompiCheckoutData(
        amountInCents: _fixture.amountInCents,
        reference: cuid(),
        redirectUrl: 'https://example.com',
        customerData: WompiCustomerData(
          email: 'test@example.com',
          fullName: 'John Doe',
          phoneNumber: _fixture.phoneNumber,
          phoneNumberPrefix: _fixture.phonePrefix,
          legalId: '1234567890',
          legalIdType: _fixture.legalIdType,
        ),
      ),
    );
  }

  Future<void> _payWithCompleteData() async {
    final isColombia = _wompiCheckout.country == WompiCountry.colombia;

    await _pay(
      WompiCheckoutData(
        amountInCents: _fixture.completeAmountInCents,
        reference: cuid(),
        redirectUrl: 'https://example.com',
        expirationTime: DateTime.now().add(const Duration(days: 1)),
        collectShipping: true,
        collectCustomerLegalId: true,
        taxes: WompiTaxes(
          vat: _fixture.vatInCents,
          // Colombia only; Panama reports the ITBMS through the VAT
          // field and rejects this one.
          consumption: isColombia ? 80000 : null,
        ),
        // Colombia only.
        paymentMethodReferences:
            isColombia
                ? WompiPaymentMethodReferences(referenceOne: '190.0.0.1')
                : null,
        // Panama only.
        defaultLanguage: isColombia ? null : WompiLanguage.spanish,
        customerData: WompiCustomerData(
          email: 'test@example.com',
          fullName: 'John Doe',
          phoneNumber: _fixture.phoneNumber,
          phoneNumberPrefix: _fixture.phonePrefix,
          legalId: '1234567890',
          legalIdType: _fixture.legalIdType,
        ),
        shippingAddress: WompiShippingAddress(
          addressLine1: _fixture.addressLine1,
          addressLine2: 'Apt 1',
          country: _fixture.shippingCountry,
          region: _fixture.region,
          city: _fixture.city,
          postalCode: '100001',
          phoneNumber: _fixture.phoneNumber,
          name: 'John Doe',
        ),
      ),
    );
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
