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
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (WebResourceError error) {
                log('Error: ${error.url}', name: 'PaymentWebview');
                log('Error: ${error.description}', name: 'PaymentWebview');
              },
              onNavigationRequest: (NavigationRequest request) {
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
          )
          ..loadRequest(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wompi Payment')),
      body: WebViewWidget(controller: controller),
    );
  }
}
