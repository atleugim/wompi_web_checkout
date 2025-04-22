import 'package:flutter/material.dart';
import 'package:wompi_webview_example/src/widgets/buttons.dart';

class ExampleWompiWebview extends StatelessWidget {
  const ExampleWompiWebview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wompi Payment Form')),
      body: const SafeArea(child: WompiPaymentButtons()),
    );
  }
}
