import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebview extends StatefulWidget {
  const PaymentWebview({required this.url, this.redirectUrl, super.key});

  final Uri url;
  final String? redirectUrl;

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    log('URL: ${widget.url}', name: 'PaymentWebview');
    controller = WebViewController();
    unawaited(_setupController());
  }

  Future<void> _setupController() async {
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.white);
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (error) {
          log('Error: ${error.url}', name: 'PaymentWebview');
          log('Error: ${error.description}', name: 'PaymentWebview');
        },
        onNavigationRequest: (request) {
          if (widget.redirectUrl != null) {
            final redirectUrl = Uri.parse(widget.redirectUrl!);
            final requestUrl = Uri.parse(request.url);

            if (requestUrl.host == redirectUrl.host) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    await controller.loadRequest(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wompi Payment')),
      body: WebViewWidget(controller: controller),
    );
  }
}
