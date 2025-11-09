import 'package:get/get.dart';

import '../model/congratulations_model.dart';

class CongratulationsController extends GetxController {
  Rx<Congratulation> congratulationDetails =
      (Get.arguments as Congratulation).obs;
  RxString route = (Get.arguments as Congratulation).route.obs;
  RxString buttonText = (Get.arguments as Congratulation).buttonText.obs;
}
