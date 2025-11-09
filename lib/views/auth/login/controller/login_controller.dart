import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../../../../base/api/services/auth_services.dart';
// OTP removed: Strings and Routes imports removed
// import '../../../../languages/strings.dart';
// import '../../../../routes/routes.dart';

class LoginController extends GetxController {
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isFormValid = false.obs;
  RxString mobileCode = '+966'.obs; // Default to Saudi Arabia
  // OTP removed: isOtpMode removed
  RxBool isMobileValid = false.obs;

  get onLogInProcess => logInProcess();
  // OTP removed: onSendOtp removed

  @override
  void onInit() {
    mobileController.addListener(_updateFormValidity);
    mobileController.addListener(_validateMobile);
    passwordController.addListener(_updateFormValidity);
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
    } catch (_) {}
    mobileController.dispose();
    passwordController.dispose();
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
    // OTP removed: always password mode
    isFormValid.value =
        mobileController.text.isNotEmpty &&
        isMobileValid.value &&
        passwordController.text.isNotEmpty;
  }

  // OTP removed: toggleLoginMode removed
  // OTP removed: _isOtpLoading and isOtpLoading removed
  // OTP removed: sendOtpAndNavigate removed

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Login with password
  logInProcess() async {
    final credentials = mobileCode.value + mobileController.text;

    return AuthServices.logInService(
      credentials: credentials,
      password: passwordController.text,
      isLoading: _isLoading,
    ).then((value) {
      mobileController.clear();
      passwordController.clear();
    });
  }

  logOutProcess() async {
    return AuthServices.logOutService(isLoading: _isLoading);
  }

  deleteAccountProcess() async {
    return AuthServices.deleteAccountServices(isLoading: _isLoading);
  }
}
