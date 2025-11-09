import 'package:carbo/views/update_profile/controller/update_profile_controller.dart';
import 'package:get/get.dart';
import '../views/dashboard/controller/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => UpdateProfileController());
  }
}
