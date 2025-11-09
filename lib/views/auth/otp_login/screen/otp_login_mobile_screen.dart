part of '../screen/otp_login_screen.dart';

class OtpLoginMobileScreen extends GetView<OtpLoginController> {
  const OtpLoginMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.background,
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
        children: [
          BrandLogo(),
          HeadingWidget(),
          Obx(() => controller.isOtpSent.value
              ? OtpInputWidget()
              : MobileInputWidget()),
          LoginButtonWidget(),
          Sizes.height.v30,
        ],
      ),
    );
  }
}
