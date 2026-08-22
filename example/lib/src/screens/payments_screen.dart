import 'package:flutter/material.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';
import 'package:wompi_webview_example/src/widgets/buttons.dart';

/// The sample payments, for the client configured in the setup screen.
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({required this.checkout, super.key});

  /// The client built from the credentials entered on the setup screen.
  final WompiWebCheckout checkout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProduction = checkout.environment == WompiEnvironment.production;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wompi Payment Form'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${checkout.country.checkoutHost} · '
              '${checkout.country.currency.code} · '
              '${checkout.environment.name}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isProduction)
              MaterialBanner(
                backgroundColor: theme.colorScheme.errorContainer,
                content: const Text(
                  'These are PRODUCTION credentials. Any payment you '
                  'complete here is a real transaction.',
                ),
                actions: const [SizedBox.shrink()],
              ),
            Expanded(child: WompiPaymentButtons(checkout: checkout)),
          ],
        ),
      ),
    );
  }
}
