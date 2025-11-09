part of '../screen/otp_login_screen.dart';

class MobileInputWidget extends GetView<OtpLoginController> {
  const MobileInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          // Mobile Number Input with Country Code Picker
          PrimaryInputWidget(
            controller: controller.mobileController,
            label: Strings.mobileNumber,
            hintText: Strings.enterMobileNumber,
            textInputType: TextInputType.phone,
            showBorderSide: true,
            prefixIcon: CountryCodePicker(
              onChanged: (country) {
                controller.mobileCode.value = country.dialCode ?? '+966';
              },
              initialSelection: 'SA',
              favorite: ['+966', '+20', '+971', '+1'],
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              padding: EdgeInsets.zero,
            ),
            suffixIcon: controller.isMobileValid.value
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
          ),
          Sizes.height.v20,
        ],
      ),
    );
  }
}
