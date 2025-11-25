import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../../../../base/api/services/auth_services.dart';
import '../../../../base/api/services/profile_kyc_service.dart';
import '../../../../base/utils/next_action_guard.dart';
import '../../../../base/widgets/custom_snackbar.dart';
import '../../../../base/widgets/logger.dart';
import '../../../../languages/strings.dart';

class OtpLoginController extends GetxController {
  final log = logger(OtpLoginController);
  final mobileController = TextEditingController();
  final otpController = TextEditingController();

  RxString mobileCode = '+966'.obs; // Default to Saudi Arabia
  RxBool isMobileValid = false.obs;
  RxBool isOtpSent = false.obs;
  RxBool isOtpDisabled = false.obs; // Track if OTP is disabled by server
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

  // Send OTP to user's mobile
  // If OTP is disabled (otp_disabled: true), directly login without OTP
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

    if (result != null) {
      // Update expires time from server response
      expiresInMinutes.value = result.expiresInMinutes;
      
      // Check if OTP is disabled - direct login without OTP
      if (result.otpDisabled) {
        log.i('OTP is disabled, proceeding with direct login...');
        isOtpDisabled.value = true;
        
        // Call direct login (verify endpoint without OTP code)
        await _loginDirectWithoutOtp();
      } else {
        // OTP is enabled - show OTP input screen
        log.i('OTP is enabled, waiting for user to enter OTP...');
        isOtpDisabled.value = false;
        isOtpSent.value = true;
        _isLoading.value = false;
        Get.snackbar(
          Strings.otpSent,
          Strings.checkMobileForOtp,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      _isLoading.value = false;
    }
  }

  // Direct login without OTP (when OTP is disabled)
  Future<void> _loginDirectWithoutOtp() async {
    log.i('Attempting direct login without OTP for mobile: ${mobileCode.value}${mobileController.text}');
    
    final loginResult = await AuthServices.loginViaMobileWithoutOtp(
      mobileCode: mobileCode.value,
      mobile: mobileController.text,
      isLoading: _isLoading,
    );

    _isLoading.value = false;

    if (loginResult != null) {
      log.i('Direct login successful!');
      // Clear form after successful login
      mobileController.clear();
      otpController.clear();
      otp.value = '';
      isOtpSent.value = false;
      isOtpDisabled.value = false;
      // Navigation is handled in AuthServices.loginViaMobileWithoutOtp
    } else {
      log.e('Direct login failed');
      CustomSnackBar.error(
        'Failed to login. Please try again.',
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
      // Check if OTP became disabled (edge case: server config changed)
      if (result.otpDisabled) {
        log.i('OTP disabled during resend, attempting direct login...');
        isOtpDisabled.value = true;
        _isLoading.value = true;
        await _loginDirectWithoutOtp();
        return;
      }
      
      // OTP still enabled - reset OTP input
      otp.value = '';
      otpController.clear();
      expiresInMinutes.value = result.expiresInMinutes;
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

    _isLoading.value = true;

    // Use new service with next_action support
    final response = await ProfileKycService.verifyOtpWithNextAction(
      mobileCode: mobileCode.value,
      mobile: mobileController.text,
      otpCode: otp.value,
    );

    _isLoading.value = false;

    if (response != null && response.success && response.data != null) {
      // Clear form
      mobileController.clear();
      otpController.clear();
      otp.value = '';
      isOtpSent.value = false;

      // Use NextActionGuard to handle routing based on next_action
      await NextActionGuard.handlePostAuth(response.data!);
    } else {
      CustomSnackBar.error(
        response?.message ?? 'Failed to verify OTP. Please try again.',
      );
    }
  }
}
