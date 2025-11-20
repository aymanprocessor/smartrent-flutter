import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'remote_language_service.dart';

/// I18n service that provides unified access to translations
/// Priority: 1) Runtime server translations, 2) Generated ARB translations, 3) Fallback to key
class I18nService extends GetxController {
  static const String _storageKey = 'selectedLanguage';
  final GetStorage _storage = GetStorage();
  
  // Observable current language
  final Rx<Locale> _currentLocale = const Locale('en').obs;
  Locale get currentLocale => _currentLocale.value;
  
  // Loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  RxBool get isLoadingValue => _isLoading;
  
  // Runtime translations from server (cached)
  final Map<String, Map<String, String>> _runtimeTranslations = {};
  
  // Available languages from server
  final RxList<LanguageModel> _languages = <LanguageModel>[].obs;
  List<LanguageModel> get languages => _languages;
  
  // Remote service
  late RemoteLanguageService _remoteService;
  
  // Cache for AppLocalizations instance
  AppLocalizations? _cachedAppLocalizations;
  
  @override
  void onInit() {
    super.onInit();
    _remoteService = RemoteLanguageService(this);
    _loadSavedLanguage();
  }
  
  /// Initialize with server URL to fetch runtime translations
  Future<void> init({required String url}) async {
    _isLoading.value = true;
    
    try {
      // Fetch from remote service
      await _remoteService.fetchTranslations(url);
      _isLoading.value = false;
    } catch (e) {
      debugPrint('I18n init error: $e');
      _isLoading.value = false;
    }
  }
  
  /// Get translation for a key using AppLocalizations getter map
  String key(String translationKey, {BuildContext? context}) {
    // Priority 1: Runtime translations from server (if available)
    final currentLangCode = _currentLocale.value.languageCode;
    if (_runtimeTranslations.containsKey(currentLangCode)) {
      final translation = _runtimeTranslations[currentLangCode]![translationKey];
      if (translation != null && translation.isNotEmpty) {
        return translation;
      }
    }
    
    // Priority 2: Generated ARB translations via AppLocalizations
    try {
      // Create AppLocalizations for current locale if not cached
      if (_cachedAppLocalizations == null || 
          _cachedAppLocalizations!.localeName != currentLangCode) {
        // Use the lookupAppLocalizations function to get the correct implementation
        _cachedAppLocalizations = lookupAppLocalizations(Locale(currentLangCode));
      }
      
      // Use the getter map to retrieve translation
      final translation = _translationGetters[translationKey]?.call(_cachedAppLocalizations!);
      if (translation != null && translation.isNotEmpty) {
        return translation;
      }
    } catch (e) {
      debugPrint('AppLocalizations error for key $translationKey: $e');
    }
    
    // Priority 3: Fallback to key itself
    return translationKey;
  }
  
  /// Getter map for all translations - maps key names to AppLocalizations getters
  static final Map<String, String Function(AppLocalizations)> _translationGetters = {
    'appLPleaseFillOutTheField': (l) => l.appLPleaseFillOutTheField,
    'appLFrom': (l) => l.appLFrom,
    'appLFromGallery': (l) => l.appLFromGallery,
    'appLFromCamera': (l) => l.appLFromCamera,
    'appLHistory': (l) => l.appLHistory,
    'appLPrivacyPolicy': (l) => l.appLPrivacyPolicy,
    'appLPreview': (l) => l.appLPreview,
    'appLLogOutAlert': (l) => l.appLLogOutAlert,
    'appLAboutUs': (l) => l.appLAboutUs,
    'appLBookingPreview': (l) => l.appLBookingPreview,
    'appLPayment': (l) => l.appLPayment,
    'appLConfirmation': (l) => l.appLConfirmation,
    'appLSuccess': (l) => l.appLSuccess,
    'appLBackToHome': (l) => l.appLBackToHome,
    'appLServerError': (l) => l.appLServerError,
    'appLPaymentInstructions': (l) => l.appLPaymentInstructions,
    'appLNewToCarbo': (l) => l.appLNewToCarbo,
    'appLAgreeToTerms': (l) => l.appLAgreeToTerms,
    'appLSpeed': (l) => l.appLSpeed,
    'appLKmCharge': (l) => l.appLKmCharge,
    'appLHelpCenter': (l) => l.appLHelpCenter,
    'appLAcceleration': (l) => l.appLAcceleration,
    'appLTotalBooked': (l) => l.appLTotalBooked,
    'appLCompleteRide': (l) => l.appLCompleteRide,
    'appLRoundTrip': (l) => l.appLRoundTrip,
    'appLBookingReject': (l) => l.appLBookingReject,
    'appLTopSpeed': (l) => l.appLTopSpeed,
    'appLPeakPower': (l) => l.appLPeakPower,
    'appLPending': (l) => l.appLPending,
    'appLPleaseWait': (l) => l.appLPleaseWait,
    'appLSetting': (l) => l.appLSetting,
    'appLOngoing': (l) => l.appLOngoing,
    'appLComplete': (l) => l.appLComplete,
    'appLReject': (l) => l.appLReject,
    'appLRange': (l) => l.appLRange,
    'appLDetails': (l) => l.appLDetails,
    'appLReview': (l) => l.appLReview,
    'appLPerMonth': (l) => l.appLPerMonth,
    'appLBookNow': (l) => l.appLBookNow,
    'appLBookYorCarVendor': (l) => l.appLBookYorCarVendor,
    'appLBook': (l) => l.appLBook,
    'appLCarNumber': (l) => l.appLCarNumber,
    'appLTotalSeat': (l) => l.appLTotalSeat,
    'appLExperience': (l) => l.appLExperience,
    'appLCarModel': (l) => l.appLCarModel,
    'appLYourLocation': (l) => l.appLYourLocation,
    'appLLogin': (l) => l.appLLogin,
    'appLNotification': (l) => l.appLNotification,
    'appLNoNotification': (l) => l.appLNoNotification,
    'appLNoHistory': (l) => l.appLNoHistory,
    'appLLoginNow': (l) => l.appLLoginNow,
    'appLRegisterNow': (l) => l.appLRegisterNow,
    'appLEmail': (l) => l.appLEmail,
    'appLForgotPassword': (l) => l.appLForgotPassword,
    'appLAlreadyHaveAnAccount': (l) => l.appLAlreadyHaveAnAccount,
    'appLFirstName': (l) => l.appLFirstName,
    'appLLastName': (l) => l.appLLastName,
    'appLPickUpLocation': (l) => l.appLPickUpLocation,
    'appLWriteHere': (l) => l.appLWriteHere,
    'appLDestination': (l) => l.appLDestination,
    'appLDistance': (l) => l.appLDistance,
    'appLPickUpdate': (l) => l.appLPickUpdate,
    'appLStatus': (l) => l.appLStatus,
    'appLNoCarFindMessage': (l) => l.appLNoCarFindMessage,
    'appLTotalAmount': (l) => l.appLTotalAmount,
    'appLTotalRent': (l) => l.appLTotalRent,
    'appLRate': (l) => l.appLRate,
    'appLTotalPayable': (l) => l.appLTotalPayable,
    'appLPickUpTime': (l) => l.appLPickUpTime,
    'appLEmailAddress': (l) => l.appLEmailAddress,
    'appLPassword': (l) => l.appLPassword,
    'appLIHaveAgreedWith': (l) => l.appLIHaveAgreedWith,
    'appLTermsOfUse': (l) => l.appLTermsOfUse,
    'appLSendOtp': (l) => l.appLSendOtp,
    'appLError': (l) => l.appLError,
    'appLPleaseEnterTheCode': (l) => l.appLPleaseEnterTheCode,
    'appLWeSentADigitCode': (l) => l.appLWeSentADigitCode,
    'appLDidntGetTheCode': (l) => l.appLDidntGetTheCode,
    'appLResend': (l) => l.appLResend,
    'appLSubmit': (l) => l.appLSubmit,
    'appLLogInTitleText': (l) => l.appLLogInTitleText,
    'appLResetPasswordTitleText': (l) => l.appLResetPasswordTitleText,
    'appLResetPasswordDescriptionText': (l) => l.appLResetPasswordDescriptionText,
    'appLLogInDescriptionText': (l) => l.appLLogInDescriptionText,
    'appLYouCanResend': (l) => l.appLYouCanResend,
    'appLSkip': (l) => l.appLSkip,
    'appLNewPassword': (l) => l.appLNewPassword,
    'appLConfirmPassword': (l) => l.appLConfirmPassword,
    'appLChangePassword': (l) => l.appLChangePassword,
    'appLOldPassword': (l) => l.appLOldPassword,
    'appLResetPassword': (l) => l.appLResetPassword,
    'appLResetPasswordTile': (l) => l.appLResetPasswordTile,
    'appLResetPasswordDes': (l) => l.appLResetPasswordDes,
    'appLCountry': (l) => l.appLCountry,
    'appLSelectArea': (l) => l.appLSelectArea,
    'appLSelectADate': (l) => l.appLSelectADate,
    'appLSelectType': (l) => l.appLSelectType,
    'appLSelectModel': (l) => l.appLSelectModel,
    'appLSelectYear': (l) => l.appLSelectYear,
    'appLPhone': (l) => l.appLPhone,
    'appLAddress': (l) => l.appLAddress,
    'appLCity': (l) => l.appLCity,
    'appLState': (l) => l.appLState,
    'appLZipCode': (l) => l.appLZipCode,
    'appLUpdate': (l) => l.appLUpdate,
    'appLEditProfile': (l) => l.appLEditProfile,
    'appLDelete': (l) => l.appLDelete,
    'appLSelectATime': (l) => l.appLSelectATime,
    'appLFindCar': (l) => l.appLFindCar,
    'appLNote': (l) => l.appLNote,
    'appLRoundTripDate': (l) => l.appLRoundTripDate,
    'appLRoundTripTime': (l) => l.appLRoundTripTime,
    'appLOptional': (l) => l.appLOptional,
    'appLNoDataFound': (l) => l.appLNoDataFound,
    'appLBookingSuccessfully': (l) => l.appLBookingSuccessfully,
    'appLConfirm': (l) => l.appLConfirm,
    'appLPayWIth': (l) => l.appLPayWIth,
    'appLNoContentAvailable': (l) => l.appLNoContentAvailable,
    'appLSelectCurrency': (l) => l.appLSelectCurrency,
    'appLSelectCountry': (l) => l.appLSelectCountry,
    'appLSelectMethod': (l) => l.appLSelectMethod,
    'appLConfirmBooking': (l) => l.appLConfirmBooking,
    'appLLanguage': (l) => l.appLLanguage,
    'appLAreYouSure': (l) => l.appLAreYouSure,
    'appLAreYouSureDelete': (l) => l.appLAreYouSureDelete,
    'appLLocationNotAbleAble': (l) => l.appLLocationNotAbleAble,
    'appLLogOut': (l) => l.appLLogOut,
    'appLLogOu': (l) => l.appLLogOu,
    'appLCancel': (l) => l.appLCancel,
    'appLLongTitle': (l) => l.appLLongTitle,
    'appLLongText': (l) => l.appLLongText,
    'appLContactUs': (l) => l.appLContactUs,
    'appLRestart': (l) => l.appLRestart,
    'appLSeats': (l) => l.appLSeats,
    'appLYears': (l) => l.appLYears,
    'appLEnter': (l) => l.appLEnter,
    'appLCashPayment': (l) => l.appLCashPayment,
    'appLOnlinePayment': (l) => l.appLOnlinePayment,
    'appLContinuee': (l) => l.appLContinuee,
    'appLCvv': (l) => l.appLCvv,
    'appLCardNumber': (l) => l.appLCardNumber,
    'appLExpirationDate': (l) => l.appLExpirationDate,
    'appLDebitCardPayment': (l) => l.appLDebitCardPayment,
    'appLPaymentSuccessful': (l) => l.appLPaymentSuccessful,
    'appLMobileNumber': (l) => l.appLMobileNumber,
    'appLEnterMobileNumber': (l) => l.appLEnterMobileNumber,
    'appLVerifyOtp': (l) => l.appLVerifyOtp,
    'appLOtpVerification': (l) => l.appLOtpVerification,
    'appLEnterOtp': (l) => l.appLEnterOtp,
    'appLVerifyAndLogin': (l) => l.appLVerifyAndLogin,
    'appLVerifyAndContinue': (l) => l.appLVerifyAndContinue,
    'appLLoginWithPassword': (l) => l.appLLoginWithPassword,
    'appLLoginWithOtp': (l) => l.appLLoginWithOtp,
    'appLInvalidPhoneNumber': (l) => l.appLInvalidPhoneNumber,
    'appLPleaseEnterValidPhone': (l) => l.appLPleaseEnterValidPhone,
    'appLInvalidOtp': (l) => l.appLInvalidOtp,
    'appLOtpSent': (l) => l.appLOtpSent,
    'appLCheckMobileForOtp': (l) => l.appLCheckMobileForOtp,
    'appLMobileVerified': (l) => l.appLMobileVerified,
    'appLMobileVerifiedSuccessfully': (l) => l.appLMobileVerifiedSuccessfully,
    'appLMobileNotVerified': (l) => l.appLMobileNotVerified,
    'appLVerifyMobileFirst': (l) => l.appLVerifyMobileFirst,
    'appLResendOtp': (l) => l.appLResendOtp,
    'appLCountryCode': (l) => l.appLCountryCode,
    'appLEnterSixDigitOtp': (l) => l.appLEnterSixDigitOtp,
    'appLAvailableCars': (l) => l.appLAvailableCars,
    'appLCarsAvailable': (l) => l.appLCarsAvailable,
    'appLLoadMore': (l) => l.appLLoadMore,
    'appLAvailable': (l) => l.appLAvailable,
    'appLLimited': (l) => l.appLLimited,
    'appLInsuranceIncluded': (l) => l.appLInsuranceIncluded,
    'appLAutomatic': (l) => l.appLAutomatic,
    'appLPetrol': (l) => l.appLPetrol,
    'appLTransmission': (l) => l.appLTransmission,
    'appLFuelType': (l) => l.appLFuelType,
    'appLNoCarsFound': (l) => l.appLNoCarsFound,
    'appLTryDifferentFilters': (l) => l.appLTryDifferentFilters,
    'appLSortBy': (l) => l.appLSortBy,
    'appLPriceLowToHigh': (l) => l.appLPriceLowToHigh,
    'appLPriceHighToLow': (l) => l.appLPriceHighToLow,
    'appLPopularity': (l) => l.appLPopularity,
    'appLRating': (l) => l.appLRating,
    'appLPullToRefresh': (l) => l.appLPullToRefresh,
    'appLRefreshing': (l) => l.appLRefreshing,
    'appLAllCars': (l) => l.appLAllCars,
    'appLFilterBy': (l) => l.appLFilterBy,
    'appLRentalDays': (l) => l.appLRentalDays,
    'appLDay': (l) => l.appLDay,
    'appLPricePerDay': (l) => l.appLPricePerDay,
    'appLPricePerKm': (l) => l.appLPricePerKm,
    'appLDeliveryCharge': (l) => l.appLDeliveryCharge,
    'appLDeliveryCar': (l) => l.appLDeliveryCar,
    'appLTax': (l) => l.appLTax,
    'appLTotal': (l) => l.appLTotal,
    'appLQuantity': (l) => l.appLQuantity,
    'appLEnterDays': (l) => l.appLEnterDays,
    'appLEnterDistance': (l) => l.appLEnterDistance,
    'appLEnterQuantity': (l) => l.appLEnterQuantity,
  };
  
  /// Change current language
  Future<void> changeLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);
    _currentLocale.value = newLocale;
    
    // Save to local storage
    await _storage.write(_storageKey, languageCode);
    
    // Update GetX locale if using GetMaterialApp
    Get.updateLocale(newLocale);
    
    _currentLocale.refresh();
  }
  
  /// Get current text direction
  TextDirection get languageDirection {
    return _currentLocale.value.languageCode == 'ar' 
        ? TextDirection.rtl 
        : TextDirection.ltr;
  }
  
  /// Load saved language from storage
  void _loadSavedLanguage() {
    final savedLang = _storage.read<String>(_storageKey);
    if (savedLang != null && savedLang.isNotEmpty) {
      _currentLocale.value = Locale(savedLang);
    }
  }
  
  /// Update runtime translations from server
  void updateRuntimeTranslations(String languageCode, Map<String, String> translations) {
    _runtimeTranslations[languageCode] = translations;
  }
  
  /// Update available languages list
  void updateLanguages(List<LanguageModel> languagesList) {
    _languages.value = languagesList;
  }
}

/// Language model
class LanguageModel {
  final String code;
  final String name;
  final String direction;
  
  LanguageModel({
    required this.code,
    required this.name,
    this.direction = 'ltr',
  });
  
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] ?? json['language_code'] ?? '',
      name: json['name'] ?? json['language_name'] ?? '',
      direction: json['direction'] ?? 'ltr',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'direction': direction,
    };
  }
}

/// Global singleton instance
final I18n = Get.put(I18nService(), permanent: true);
