import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../base/api/services/paytabs_service.dart';
import '../../../base/widgets/custom_snackbar.dart';
import '../controller/preview_controller.dart';

class PayTabsPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String transactionRef;

  const PayTabsPaymentScreen({
    Key? key,
    required this.paymentUrl,
    required this.transactionRef,
  }) : super(key: key);

  @override
  State<PayTabsPaymentScreen> createState() => _PayTabsPaymentScreenState();
}

class _PayTabsPaymentScreenState extends State<PayTabsPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final PreviewController previewController = Get.find<PreviewController>();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check if redirected to return URL
            if (url.contains('/payment/return') || 
                url.contains('payment-success') || 
                url.contains('payment-callback')) {
              _handlePaymentReturn();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if user is being redirected back to the app
            if (request.url.contains('/payment/return') || 
                request.url.contains('payment-success') || 
                request.url.contains('payment-callback')) {
              _handlePaymentReturn();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentReturn() async {
    // Show loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      // Verify payment with backend
      final result = await PayTabsService.verifyPayment(widget.transactionRef);

      // Close loading dialog
      Get.back();
      // Close payment screen
      Get.back();

      if (result != null && result['success'] == true) {
        // Payment successful
        final data = result['data'];
        final status = data['status'];

        if (status == 'A') {
          // Payment approved
          previewController.handlePaymentSuccess(widget.transactionRef);
        } else {
          // Payment not approved
          CustomSnackBar.error('Payment failed. Status: $status');
        }
      } else {
        // Verification failed
        CustomSnackBar.error('Payment verification failed');
      }
    } catch (e) {
      // Close loading dialog
      Get.back();
      // Close payment screen
      Get.back();
      CustomSnackBar.error('Error verifying payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Confirm before closing
            Get.dialog(
              AlertDialog(
                title: const Text('Cancel Payment'),
                content: const Text(
                  'Are you sure you want to cancel this payment?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(), // Close dialog
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.back(); // Close payment screen
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
