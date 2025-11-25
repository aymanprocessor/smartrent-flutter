import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../../base/utils/local_storage.dart';
import '../../../base/utils/navigator_plug.dart';
import '../../../base/services/realtime_service.dart';
import '../../../base/widgets/logger.dart';
import '../../../routes/routes.dart';
import '../../../../debug/print_auth_token.dart';

// Logger instance
final log = logger(SplashController);
class SplashController extends GetxController {
  final navigatorPlug = NavigatorPlug();

  @override
  void onReady() {
    super.onReady();
    // In debug builds, print whether auth tokens exist when splash is shown.
    if (kDebugMode) {
      // Fire-and-forget; don't block splash navigation.
      printAuthTokenDebug(revealRaw: true);
    }

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
      // Reconnect to realtime service if user is logged in
      _reconnectRealtimeService();
      // User exists, navigate to dashboard
      Get.offAndToNamed(Routes.dashboardScreen);
    } else {
      // User doesn't exist, navigate to OTP login screen (default)
      Get.offAndToNamed(Routes.otpLoginScreen);
    }
  }

  /// Reconnect to Pusher realtime service on app restart
  Future<void> _reconnectRealtimeService() async {
    final userId = LocalStorage.userId;
    if (userId > 0) {
      try {
        final realtime = RealtimeService();
        await realtime.init();
        await realtime.subscribeToUserChannel(userId);
        log.i('[SplashController] Reconnected realtime for userId: $userId');
      } catch (e) {
        log.e('[SplashController] Failed to reconnect realtime: $e');
      }
    }else{
      log.w('[SplashController] Invalid userId: $userId');
    }
  }

  @override
  void onClose() {
    navigatorPlug.stopListening();
    super.onClose();
  }
}
