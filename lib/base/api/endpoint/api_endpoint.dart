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

  // OTP for Mobile Authentication
  sendOtp('/otp/send'),
  verifyOtp('/otp/verify'),
  loginViaOtp('/otp/login-via-otp'),
  resendOtp('/otp/resend'),

  // Profile Completion & KYC
  profileComplete('/user/profile/complete'),
  profileStatus('/user/profile/status'),
  kycFields('/user/kyc/fields'),
  kycSubmit('/user/kyc/submit'),
  kycStatus('/user/kyc/status'),

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

  // PayTabs Generic Endpoints (Direct PayTabs calls)
  paytabsCreatePayment('/paytabs/create-payment'),
  paytabsVerifyPayment('/paytabs/verify-payment'),
  paytabsRefundPayment('/paytabs/refund-payment'),
  paytabsPaymentMethods('/paytabs/payment-methods'),
  paytabsCurrencies('/paytabs/currencies'),

  // PayTabs Car Booking Endpoints (Car booking specific)
  paytabsCarBookingVerify('/user/car-booking/paytabs/verify'),
  paytabsCarBookingCallback('/user/car-booking/paytabs/callback'),

  // Authorize
  authorizeSubmit("/user/car-booking/authorize-payment-submit"),

  // Delivery Zone Check
  deliveryCheck('/api/delivery/check'),

  // Wallet Endpoints
  walletBalance('/wallet/balance'),
  walletTransactions('/wallet/transactions'),
  walletTopUp('/wallet/top-up'),
  // QA / test-only top-up endpoint (immediately credits wallet without payment)
  walletTopUpTest('/wallet/topup/test'),
  walletChargeForBooking('/wallet/charge'),
  walletRefundToWallet('/wallet/refund-to-wallet'),
  walletRefundToCard('/wallet/refund-to-card'),
  walletPayTabsWebhook('/wallet/paytabs/webhook'),
  walletPayTabsReturn('/wallet/paytabs/return');

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
