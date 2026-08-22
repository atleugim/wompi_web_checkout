import 'package:flutter/material.dart';
import 'package:wompi_web_checkout/wompi_web_checkout.dart';
import 'package:wompi_webview_example/src/screens/payments_screen.dart';

/// Asks for the merchant credentials and country, then builds the
/// [WompiWebCheckout] client used by the rest of the example.
///
/// Nothing is persisted: the keys live only for the session, so no
/// credential is ever committed to this repository.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _publicKeyController = TextEditingController();
  final _integrityKeyController = TextEditingController();

  WompiCountry _country = WompiCountry.colombia;
  bool _obscureIntegrityKey = true;
  String? _publicKeyError;
  String? _integrityKeyError;

  @override
  void dispose() {
    _publicKeyController.dispose();
    _integrityKeyController.dispose();
    super.dispose();
  }

  /// Builds the client and, if the keys are good, moves on.
  ///
  /// The package is the one validating: its [WompiFieldError.field] maps
  /// straight onto the form fields, so there is no validation logic
  /// duplicated here.
  void _continue() {
    setState(() {
      _publicKeyError = null;
      _integrityKeyError = null;
    });

    try {
      final checkout = WompiWebCheckout(
        publicKey: _publicKeyController.text.trim(),
        integrityKey: _integrityKeyController.text.trim(),
        country: _country,
      );

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => PaymentsScreen(checkout: checkout),
        ),
      );
    } on WompiValidationException catch (err) {
      setState(() {
        for (final error in err.errors) {
          switch (error.field) {
            case 'publicKey':
              _publicKeyError = error.message;
            case 'integrityKey':
              _integrityKeyError = error.message;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Wompi Web Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your keys from the Wompi commerce dashboard '
                '(Developers > Secrets for technical integration). Use '
                'sandbox keys so no real money moves.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _publicKeyController,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Public key',
                  hintText: 'pub_test_...',
                  border: const OutlineInputBorder(),
                  errorText: _publicKeyError,
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _integrityKeyController,
                autocorrect: false,
                obscureText: _obscureIntegrityKey,
                decoration: InputDecoration(
                  labelText: 'Integrity key',
                  hintText: 'test_integrity_...',
                  border: const OutlineInputBorder(),
                  errorText: _integrityKeyError,
                  errorMaxLines: 3,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureIntegrityKey
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscureIntegrityKey = !_obscureIntegrityKey,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Country', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<WompiCountry>(
                segments: [
                  for (final country in WompiCountry.values)
                    ButtonSegment(
                      value: country,
                      label: Text(
                        '${country.displayName} '
                        '(${country.currency.code})',
                      ),
                    ),
                ],
                selected: {_country},
                onSelectionChanged:
                    (selection) => setState(() => _country = selection.first),
              ),
              const SizedBox(height: 8),
              Text(
                'Determines the checkout host (${_country.checkoutHost}), '
                'the currency and which optional parameters are accepted.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _continue,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
