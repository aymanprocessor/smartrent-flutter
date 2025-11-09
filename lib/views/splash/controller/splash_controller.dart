import 'package:get/get.dart';

import '../../../base/utils/local_storage.dart';
import '../../../base/utils/navigator_plug.dart';
import '../../../routes/routes.dart';

class SplashController extends GetxController {
  final navigatorPlug = NavigatorPlug();

  @override
  void onReady() {
    super.onReady();
    navigatorPlug.startListening(
      seconds: 3,
      onChanged: () {
        _checkUserAndNavigate();
      },
    );
  }

  void _checkUserAndNavigate() {
    // Check if user is logged in
    if (LocalStorage.isLoggedIn) {
      // User exists, navigate to dashboard
      Get.offAndToNamed(Routes.dashboardScreen);
    } else {
      // User doesn't exist, navigate to OTP login screen (default)
      Get.offAndToNamed(Routes.otpLoginScreen);
    }
  }

  @override
  void onClose() {
    navigatorPlug.stopListening();
    super.onClose();
  }
}
