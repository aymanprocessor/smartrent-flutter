import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../../base/api/services/auth_services.dart';
// OTP removed: Strings and Routes imports no longer needed
// import '../../../../languages/strings.dart';
// import '../../../../routes/routes.dart';

class RegisterController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool agree = false.obs;
  RxString mobileCode = '+966'.obs; // Default to Saudi Arabia
  // OTP verification removed: isMobileVerified removed

  get onRegistration => registrationProcess();
  // OTP removed: onSendOtp removed
  get onPrivacyPolicy => '';

  RxBool isFormValid = false.obs;
  RxBool isMobileValid = false.obs;

  @override
  void onInit() {
    mobileController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
    firstNameController.addListener(_updateFormValidity);
    lastNameController.addListener(_updateFormValidity);
    mobileController.addListener(_validateMobile);
    super.onInit();
  }

  @override
  void onClose() {
    // Remove listeners and dispose controllers to avoid callbacks after dispose
    try {
      mobileController.removeListener(_updateFormValidity);
      mobileController.removeListener(_validateMobile);
    } catch (_) {}
    try {
      passwordController.removeListener(_updateFormValidity);
      firstNameController.removeListener(_updateFormValidity);
      lastNameController.removeListener(_updateFormValidity);
    } catch (_) {}
    mobileController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailAddressController.dispose();
    super.onClose();
  }

  void _validateMobile() {
    try {
      if (mobileController.text.isEmpty) {
        isMobileValid.value = false;
        return;
      }

      // Parse phone number with country code
      final phoneNumber = PhoneNumber.parse(
        mobileCode.value + mobileController.text,
      );

      // Validate phone number
      isMobileValid.value = phoneNumber.isValid();
    } catch (e) {
      isMobileValid.value = false;
    }
  }

  void _updateFormValidity() {
    isFormValid.value =
        mobileController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        isMobileValid.value;
        // OTP removed: isMobileVerified check removed
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // OTP removed: _isOtpLoading and isOtpLoading removed
  // OTP removed: sendOtpAndNavigate removed

  // Complete registration (OTP check removed)
  registrationProcess() async {
    // OTP removed: no isMobileVerified check

    return AuthServices.registrationProcess(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      mobileCode: mobileCode.value,
      mobile: mobileController.text,
      email: emailAddressController.text.isEmpty
          ? null
          : emailAddressController.text,
      password: passwordController.text,
      country: 'Saudi Arabia', // Default country
      isLoading: _isLoading,
    );
  }
}
