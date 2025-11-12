class ApiConfig {
  // static const String mainDomain = "https://smartrent.nextoneplus.com";
  static const String mainDomain = "http://192.168.1.211:8000";
  static const String baseUrl = "$mainDomain/api/v1";
  static const String languageUrl = "$baseUrl/settings/languages";
}

enum ApiEndpoint {
  basicSettings('/settings/basic-settings'),
  getAllCountry('/settings/countries'),
  // Auth
  login('/login'),
  forgotPassword('/password/forgot/find/user'),
  forgotPasswordVerifyCode('/password/forgot/verify/code'),
  resendForgotOtpCode('/password/forgot/resend/code'),
  resetPassword('/password/forgot/reset'),
  register('/register'),
  emailOtpVerify('/authorize/mail/verify/code'),
  resendEmailOtp('/authorize/mail/resend/code'),
  kycInfo('/user/kyc-input-fields'),
  kycSubmit('/user/kyc-submit'),

  // OTP for Mobile Authentication
  sendOtp('/otp/send'),
  verifyOtp('/otp/verify'),
  loginViaOtp('/otp/login-via-otp'),
  resendOtp('/otp/resend'),

  // 2FA
  twoFaInfo('/user/google-2fa'),
  twoFaStatusUpdate('/user/google-2fa/status/update'),
  twoFaOtpVerify('/user/google-2fa/verify/code'),
  logOut('/user/logout'),

  // Dashboard
  dashboardInfo('/user/dashboard'),
  history('/user/car-booking/booking/history'),
  getArea('/user/car-booking/area'),
  getAllTypes('/user/car-booking/type'), // Get all types without area filter
  postAreaHasType('/user/car-booking/area/types'),
  postTypeHasModel('/user/car-booking/type/models'),
  postModelHasYears('/user/car-booking/model/years'),
  searchCar('/user/car-booking/search/car'),
  vendorCars(
    '/vendor/cars',
  ), // New API for all vendor cars with advanced filtering
  notification('/user/notifications'),

  // Profile
  profileInfo('/user/profile/info'),
  updateProfile('/user/profile/info/update'),
  updatePassword('/user/profile/password/update'),
  deleteAccount('/user/profile/delete-account'),

  // Booking confirm
  bookingConfirm('/user/car-booking/confirm'),
  getBookingPreview('/user/car-booking/preview'),

  // Payment
  manualRePayment('/user/car-booking/repayment/submit'),
  getManualPaymentField('/user/car-booking/manual/input-fields'),
  rePayment('/user/car-booking/re-manual/input-fields'),

  // PayTabs
  paytabsCreatePayment('/api/paytabs/create-payment'),
  paytabsVerifyPayment('/api/paytabs/verify-payment'),
  paytabsRefundPayment('/api/paytabs/refund-payment'),
  paytabsPaymentMethods('/api/paytabs/payment-methods'),
  paytabsCurrencies('/api/paytabs/currencies'),

  // Authorize
  authorizeSubmit("/user/car-booking/authorize-payment-submit");

  final String path;

  const ApiEndpoint(this.path);

  /// Returns the full URL with optional query parameters
  String url({Map<String, String>? params}) {
    var fullUrl = "${ApiConfig.baseUrl}$path";
    if (params != null && params.isNotEmpty) {
      fullUrl +=
          '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    return fullUrl;
  }

  /// Convenience method to append query parameters
  String withParams(Map<String, String> params) => url(params: params);
}
