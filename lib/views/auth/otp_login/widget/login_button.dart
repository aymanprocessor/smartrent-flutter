part of '../screen/otp_login_screen.dart';

class LoginButtonWidget extends GetView<OtpLoginController> {
  const LoginButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.5),
      child: Obx(() {
        // If OTP is sent, show verify button
        if (controller.isOtpSent.value) {
          return PrimaryButton(
            isLoading: controller.isLoading,
            title: Strings.verifyAndLogin,
            disable: !controller.isOtpValid.value,
            onPressed: () {
              if (controller.isOtpValid.value) {
                controller.onVerifyOtp;
              }
            },
          );
        }
        
        // Otherwise show send OTP button
        return PrimaryButton(
          isLoading: controller.isLoading,
          title: Strings.sendOtp,
          disable: !controller.isMobileValid.value,
          onPressed: () {
            if (controller.isMobileValid.value) {
              controller.onSendOtp;
            }
          },
        );
      }),
    );
  }
}
