import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../../../../base/api/services/auth_services.dart';
import '../../../../languages/strings.dart';

class OtpLoginController extends GetxController {
  final mobileController = TextEditingController();
  final otpController = TextEditingController();

  RxString mobileCode = '+966'.obs; // Default to Saudi Arabia
  RxBool isMobileValid = false.obs;
  RxBool isOtpSent = false.obs;
  RxString otp = ''.obs;
  RxBool isOtpValid = false.obs;
  RxInt expiresInMinutes = 10.obs;

  get onSendOtp => sendOtpProcess();
  get onVerifyOtp => verifyOtpProcess();

  @override
  void onInit() {
    mobileController.addListener(_validateMobile);
    ever<String>(otp, (val) => isOtpValid.value = val.length == 6);
    super.onInit();
  }

  @override
  void onClose() {
    try {
      mobileController.removeListener(_validateMobile);
    } catch (_) {}
    mobileController.dispose();
    otpController.dispose();
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

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isResending = false.obs;
  bool get isResending => _isResending.value;

  // Send OTP to user's WhatsApp
  sendOtpProcess() async {
    if (!isMobileValid.value) {
      Get.snackbar(
        Strings.invalidPhoneNumber,
        Strings.pleaseEnterValidPhone,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isLoading.value = true;

    final result = await AuthServices.sendUserOtp(
      mobileCode: mobileCode.value,
      mobile: mobileController.text,
      isLoading: _isLoading,
    );

    _isLoading.value = false;

    if (result != null) {
      isOtpSent.value = true;
      Get.snackbar(
        Strings.otpSent,
        Strings.checkMobileForOtp,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Resend OTP
  resendOtpProcess() async {
    if (!isMobileValid.value) {
      return;
    }

    _isResending.value = true;

    final result = await AuthServices.sendUserOtp(
      mobileCode: mobileCode.value,
      mobile: mobileController.text,
      isLoading: _isResending,
    );

    _isResending.value = false;

    if (result != null) {
      // Reset OTP input
      otp.value = '';
      otpController.clear();
      Get.snackbar(
        Strings.otpSent,
        Strings.checkMobileForOtp,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Verify OTP and login
  verifyOtpProcess() async {
    if (otp.value.length != 6) {
      Get.snackbar(
        Strings.invalidOtp,
        Strings.enterSixDigitOtp,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    return AuthServices.verifyUserOtp(
      mobileCode: mobileCode.value,
      mobile: mobileController.text,
      otpCode: otp.value,
      isLoading: _isLoading,
    ).then((value) {
      if (value != null) {
        // Clear form
        mobileController.clear();
        otpController.clear();
        otp.value = '';
        isOtpSent.value = false;
      }
    });
  }
}
