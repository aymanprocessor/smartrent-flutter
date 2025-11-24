part of '../screen/dashboard_screen.dart';

class FindCarButton extends GetView<DashboardController> {
  const FindCarButton({Key? key}) : super(key: key);

  bool _isKycVerified() {
    final kycStatus = LocalStorage.kycStatus;
    return kycStatus == 1; // 1 = Approved/Verified
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
          vertical: Dimensions.verticalSize,
        ),
        child: PrimaryButton(
          isLoading: controller.isSearchingCar,
          title: Strings.findCar,
          disable: !_isKycVerified(),
          onPressed: _isKycVerified()
              ? () {
                  controller.searchAllCar();
                }
              : () {
                  Get.snackbar(
                    DynamicLanguage.key(Strings.kycRequired),
                    DynamicLanguage.key(Strings.pleaseCompleteKycVerification),
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.amber.shade700,
                    colorText: Colors.white,
                  );
                },
        ),
      ),
    );
  }
}
