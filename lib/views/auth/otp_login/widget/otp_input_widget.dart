part of '../screen/otp_login_screen.dart';

class OtpInputWidget extends GetView<OtpLoginController> {
  const OtpInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // OTP Instruction Text
        Padding(
          padding: EdgeInsets.only(bottom: Dimensions.verticalSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                Strings.weSentADigitCode,
                fontWeight: FontWeight.w500,
                typographyStyle: TypographyStyle.bodyLarge,
              ),
              Sizes.height.v10,
              Obx(() => TextWidget(
                    '${controller.mobileCode.value} ${controller.mobileController.text}',
                    fontWeight: FontWeight.bold,
                    typographyStyle: TypographyStyle.bodyLarge,
                    color: CustomColor.primary,
                  )),
            ],
          ),
        ),
        
        // PIN Code Input
        PinCodeTextField(
          appContext: context,
          controller: controller.otpController,
          length: 6,
          keyboardType: TextInputType.number,
          enableActiveFill: true,
          autoFocus: true,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 50,
            fieldWidth: 45,
            activeFillColor: Colors.white,
            selectedFillColor: Colors.white,
            inactiveFillColor: Colors.grey.shade100,
            activeColor: CustomColor.primary,
            selectedColor: CustomColor.primary,
            inactiveColor: Colors.grey.shade300,
          ),
          onChanged: (value) {
            controller.otp.value = value;
          },
          onCompleted: (value) {
            controller.otp.value = value;
          },
        ),
        
        Sizes.height.v20,
        
        // Resend OTP Section
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextWidget(
                Strings.didntGetTheCode,
                typographyStyle: TypographyStyle.bodyMedium,
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: controller.isResending
                    ? null
                    : () => controller.resendOtpProcess(),
                child: TextWidget(
                  Strings.resendOtp,
                  typographyStyle: TypographyStyle.bodyMedium,
                  color: controller.isResending
                      ? Colors.grey
                      : CustomColor.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        Sizes.height.v30,
      ],
    );
  }
}
