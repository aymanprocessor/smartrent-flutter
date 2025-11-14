import 'dart:convert';
import 'package:carbo/views/preview/controller/preview_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../../base/widgets/custom_app_bar.dart';
import '../../../base/widgets/custom_snackbar.dart';
import '../../../base/widgets/loader.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../../congratulations/model/congratulations_model.dart';
import '../../congratulations/screen/congratulations_screen.dart';

class WebPaymentScreen extends StatelessWidget {
  WebPaymentScreen({super.key});
  final controller = Get.put(PreviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(''),
      body: Obx(
        () => controller.isLoading ? const Loader() : _bodyWidget(context),
      ),
    );
  }

  _bodyWidget(BuildContext context) {
    // Handle nullable data - must check before accessing fields
    final data = controller.bookingConfirmModel.data;
    
    if (data == null || data.redirectUrl == null || data.redirectUrl!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Payment URL not available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    final paymentUrl = data.redirectUrl!;

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(paymentUrl)),
      onWebViewCreated: (InAppWebViewController inAppWebViewController) {},
      onProgressChanged:
          (InAppWebViewController inAppWebViewController, int progress) {},
      onLoadStop: (InAppWebViewController inAppWebViewController, url) async {
        if (url != null) {
          String? pageContent = await inAppWebViewController.evaluateJavascript(
            source: "document.body.innerText",
          );

          print("Page Content: $pageContent"); // Debugging

          if (pageContent != null && pageContent.isNotEmpty) {
            try {
              Map<String, dynamic> parsedJson = json.decode(pageContent);

              if (parsedJson.containsKey('type')) {
                if (parsedJson['type'] == 'success') {
                  Congratulation congratulation = Congratulation(
                    details: parsedJson['message']['success'].first,
                    route: Routes.dashboardScreen,
                    buttonText: Strings.backToHome,
                    type: Strings.payment,
                  );
                  Get.offAll(
                    () => CongratulationsScreen(),
                    arguments: congratulation,
                  );
                } else if (parsedJson['type'] == 'error') {
                  Get.close(1);
                  CustomSnackBar.error(parsedJson['message']['error'].first);
                }
              } else {
                print("Error: 'type' key not found in JSON.");
              }
            } catch (e) {
              print("Error parsing JSON: $e");
            }
          }
        }
      },
    );
  }
}
