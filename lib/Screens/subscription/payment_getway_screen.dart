import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../Const/api_config.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.planId, required this.businessId});

  final String planId;
  final String businessId;

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController controller;
  final ImagePicker _imagePicker = ImagePicker();
  late final String paymentUrl;

  static const String successUrl = 'order-status?status=success';
  static const String failureUrl = 'order-status?status=failed';

  @override
  void initState() {
    super.initState();

    // Construct Payment URL securely
    paymentUrl = '${APIConfig.domain}payments-gateways/${widget.planId}/${widget.businessId}?platform=app';
    print(paymentUrl);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.contains(successUrl)) {
              Navigator.pop(context, true);
              return;
            }
            if (url.contains(failureUrl)) {
              Navigator.pop(context, false);
              return;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));

    // Handle File Upload for Android
    if (Platform.isAndroid) {
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setOnShowFileSelector(_androidImagePicker);
    }
  }

  Future<List<String>> _androidImagePicker(FileSelectorParams params) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final fileUri = Uri.file(pickedFile.path);
      return [fileUri.toString()];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.S.of(context).paymentGateway),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

// Optional: You can keep these if you use them elsewhere, or remove if unused.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lang.S.of(context).paymentSuccess)),
      body: Center(child: Text(lang.S.of(context).paymentWasSuccessful)),
    );
  }
}

class FailureScreen extends StatelessWidget {
  const FailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lang.S.of(context).paymentFailed)),
      body: Center(child: Text(lang.S.of(context).paymentFailedPleaseTryAgain)),
    );
  }
}
