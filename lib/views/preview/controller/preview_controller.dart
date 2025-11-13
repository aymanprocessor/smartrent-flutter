import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:carbo/views/preview/model/booking_preview_model.dart';
import 'package:carbo/views/preview/widget/authorize_payment_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../base/widgets/logger.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/api/model/common_success_model.dart';
import '../../../base/api/services/paytabs_service.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../../congratulations/model/congratulations_model.dart';
import '../../congratulations/screen/congratulations_screen.dart';
import '../model/booking_confirm_model.dart';
import '../model/manual_input_model.dart';
import '../screen/preview_screen.dart';
import '../widget/web_payment_screen.dart';
import '../widget/paytabs_payment_screen.dart';

class PreviewController extends GetxController {
  final log = logger(PreviewController);
  final dashboardController = Get.find<DashboardController>();

  List<TextEditingController> inputFieldControllers = [];
  RxList inputFields = [].obs;
  RxList inputFileFields = [].obs;
  RxBool hasFile = false.obs;
  RxString selectType = "".obs;
  List<String> listImagePath = [];
  List<String> listFieldName = [];

  var identifier = "".obs;
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCVCController = TextEditingController();

  updateImageData(String fieldName, String imagePath) {
    if (listFieldName.contains(fieldName)) {
      int itemIndex = listFieldName.indexOf(fieldName);
      listImagePath[itemIndex] = imagePath;
    } else {
      listFieldName.add(fieldName);
      listImagePath.add(imagePath);
    }
    update();
  }

  String? getImagePath(String fieldName) {
    if (listFieldName.contains(fieldName)) {
      int itemIndex = listFieldName.indexOf(fieldName);
      return listImagePath[itemIndex];
    }
    return null;
  }

  Rxn<PaymentGateway> selectPaymentGateway = Rxn<PaymentGateway>();
  final List<PaymentGateway> paymentGatewayList = [];
  Rxn<Currency> selectedCurrency = Rxn<Currency>();
  final List<Currency> currencyList = [];
  
  // Store booking data from new pricing-based booking flow
  Rxn<Map<String, dynamic>> bookingData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    // Check if booking data was passed from booking screen
    if (Get.arguments != null && Get.arguments is Map) {
      bookingData.value = Get.arguments;
    }
    getPreviewData();
  }

  var selectedMethod = RxInt(0);

  var paymentType = Rx<PaymentType>(
    PaymentType(onlinePayment: "online-payment", cash: 'cash'),
  );

  String get selectedMethodText {
    totalPayable.value = 0.00;
    return selectedMethod.value == 0
        ? paymentType.value.cash
        : paymentType.value.onlinePayment;
  }

  void changePaymentMethod(int method) {
    selectedMethod.value = method;
  }

  void handlePaymentProcess() {
    if (selectedMethodText == 'cash') {
      cashBookedProcess();
    } else if (alias.value.contains('manual')) {
      paymentManualInsert();
    } else if (alias.value.contains('paytabs') || 
               paymentTypes.value.contains('paytabs')) {
      // Handle PayTabs payment
      processPayTabsPayment();
    } else {
      bookingProcessAuto();
    }
  }

  ///=> GET ALL BOOKING PREVIEW INFO

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  late BookingPreviewModel _bookingPreviewModel;

  BookingPreviewModel get bookingPreviewModel => _bookingPreviewModel;

  Future<BookingPreviewModel?> getPreviewData() async {
    // Validate that car ID is available before requesting
    if (dashboardController.selectedCarId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No car selected. Please select a car first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Await the request so we can detect failures and provide a local fallback
    BookingPreviewModel? result = await RequestProcess().request<BookingPreviewModel>(
      queryParams: {
        'token': dashboardController.carToken.value,
        'car_id': dashboardController.selectedCarId.value,
      },
      fromJson: BookingPreviewModel.fromJson,
      apiEndpoint: ApiEndpoint.getBookingPreview,
      isLoading: _isLoading,
      showErrorMessage: true,
      onSuccess: (value) {
        _bookingPreviewModel = value!;
        
  // Debug logging to check API response
  log.i('=== PREVIEW DATA DEBUG ===');
  log.i('Car ID from API: ${_bookingPreviewModel.data.car.id}');
  log.i('Car Slug from API: ${_bookingPreviewModel.data.car.slug}');
  log.i('Car Model from API: ${_bookingPreviewModel.data.car.carModel}');
  log.i('Full car data: ${_bookingPreviewModel.data.car.toJson()}');
  log.i('========================');
        
        _getPreviewALlData();
        // Clear existing list before adding new gateways to prevent duplicates
        paymentGatewayList.clear();
        _bookingPreviewModel.data.paymentGateways.forEach((v) {
          paymentGatewayList.add(
            PaymentGateway(
              status: v.status,
              type: v.type,
              desc: v.desc,
              currencies: v.currencies,
              crypto: v.crypto,
              id: v.id,
              name: v.name,
            ),
          );
        });
      },
    );

    // If the API failed (returned null) try to fill minimal required data from
    // the locally cached car list (dashboardController.cars). This prevents
    // immediate booking failure when preview API is temporarily returning
    // malformed JSON (see logs). It's a best-effort fallback.
    if (result == null) {
      try {
        final selectedId = dashboardController.selectedCarId.value;
        final localCar = dashboardController.cars.firstWhere(
          (c) => c.id.toString() == selectedId,
        );

        // Map available local fields to preview controller values
        slug.value = localCar.slug;
        Id.value = localCar.id.toString();
        carModel.value = localCar.carModel;
        // Local model doesn't contain carNumber in all responses — leave empty
        carNumber.value = '';

        Get.snackbar(
          'Notice',
          'Preview data unavailable from server — using cached car data.' + (kDebugMode ? '\n(Dev: raw response logged)' : ''),
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
  // No local fallback available — bubble up nothing and allow UI to show
  // validation when user tries to proceed with booking.
  log.e('Preview fallback: no local car found for id ${dashboardController.selectedCarId.value}');
      }
    }

    return result;
  }

  void _getPreviewALlData() {
    carModel.value = _bookingPreviewModel.data.car.carModel;
    carNumber.value = _bookingPreviewModel.data.car.carNumber;
    pickupTime.value = _bookingPreviewModel.data.bookingDetails.pickupTime;
    slug.value = _bookingPreviewModel.data.car.slug;
    Id.value = _bookingPreviewModel.data.car.id.toString();
    cashBalance.value = _bookingPreviewModel.data.paymentType.cash;
    onlinePayment.value = _bookingPreviewModel.data.paymentType.onlinePayment;
    
  // Debug: Check if values were actually set
  log.i('=== AFTER SETTING VALUES ===');
  log.i('slug.value: "${slug.value}"');
  log.i('Id.value: "${Id.value}"');
  log.i('carModel.value: "${carModel.value}"');
    
    // Fallback: If API didn't return valid car ID, use selectedCarId
    if (Id.value.isEmpty || Id.value == 'null') {
      log.e('WARNING: Car ID is empty/null, using fallback from dashboardController');
      Id.value = dashboardController.selectedCarId.value;
      log.i('Fallback Id.value: "${Id.value}"');
    }
    
    log.i('===========================');
  }

  /// Return the selected car's area id if available.
  /// This helps satisfy backend validation that may require `car_area`.
  int? _getSelectedCarAreaId() {
    try {
      final selId = dashboardController.selectedCarId.value.isNotEmpty
          ? dashboardController.selectedCarId.value
          : Id.value;
    final matches = dashboardController.cars
      .where((c) => c.id.toString() == selId)
      .toList(growable: false);
    if (matches.isEmpty) return null;
    return matches.first.carAreaId;
    } catch (e) {
      log.w('Could not determine selected car area id: $e');
      return null;
    }
  }

  RxString paymentTypes = ''.obs;
  RxString alias = ''.obs;
  RxString currencyName = ''.obs;

  // RxString rate = ''.obs;
  RxString carModel = ''.obs;
  RxString carNumber = ''.obs;
  RxString pickupTime = ''.obs;
  RxString pickupDate = ''.obs;
  RxString slug = ''.obs;
  RxString Id = ''.obs;
  RxString cashBalance = ''.obs;
  RxString onlinePayment = ''.obs;

  ///=> CONFIRM BOOKING PROCESS

  final _isBookingLoading = false.obs;

  bool get isBookingLoading => _isBookingLoading.value;

  late BookingConfirmModel _bookingConfirmModel;

  BookingConfirmModel get bookingConfirmModel => _bookingConfirmModel;

  Future<BookingConfirmModel?> bookingProcessAuto() async {
    // Validate car identifiers before sending booking request
    if (slug.value.isEmpty || Id.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Car information is missing. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

  // include car_area when possible to satisfy backend validation
  final int? _selectedCarAreaId = _getSelectedCarAreaId();

    Map<String, dynamic> inputBody = {
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text,
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text,
      'mobile': bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text,
      'credentials': bookingData.value?['email'] ?? LocalStorage.email,
      'car_slug': slug.value,
      'car_id': Id.value,
      'gateway_type': paymentTypes.value,
      'gateway_currency': alias.value,
      'payment': selectedMethodText,
      'token': dashboardController.carToken.value,
      'fees': (bookingData.value?['total'] ?? 0).toString(),
      // New pricing fields
      'quantity': bookingData.value?['quantity'],
      'pricing_type': bookingData.value?['pricing_type'],
      'delivery_required': bookingData.value?['delivery_required'] ?? false,
      // 'transaction_id': fees.value,
    };
    if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId;
    return RequestProcess().request<BookingConfirmModel>(
      fromJson: BookingConfirmModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        _bookingConfirmModel = value!;
        identifier.value = _bookingConfirmModel.data.identifier;
        if (alias.value.contains('authorize')) {
          Get.to(AuthorizeGatewayScreen());
        } else {
          Get.to(() => WebPaymentScreen());
        }
      },
    );
  }

  Future<CommonSuccessModel?> cashBookedProcess() async {
    // Validate car identifiers before sending booking request
    if (slug.value.isEmpty || Id.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Car information is missing. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

  final int? _selectedCarAreaId = _getSelectedCarAreaId();

  Map<String, dynamic> inputBody = {
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text,
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text,
      'mobile': bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text,
      'credentials': bookingData.value?['email'] ?? LocalStorage.email,
      'car_slug': slug.value,
      'car_id': Id.value,
      'payment': selectedMethodText,
      'token': dashboardController.carToken.value,
      'fees': (bookingData.value?['total'] ?? 0).toString(),
      // New pricing fields
      'quantity': bookingData.value?['quantity'],
      'pricing_type': bookingData.value?['pricing_type'],
      'delivery_required': bookingData.value?['delivery_required'] ?? false,
    };
  if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId;
    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  }

  ///=> Get manual payment input field

  late ManualInputModel _manualInputModel;

  ManualInputModel get manualInputModel => _manualInputModel;

  Future<ManualInputModel?> paymentManualInsert() async {
    return RequestProcess().request<ManualInputModel>(
      fromJson: ManualInputModel.fromJson,
      apiEndpoint: ApiEndpoint.getManualPaymentField,
      isLoading: _isBookingLoading,
      showSuccessMessage: false,
      showResult: true,
      queryParams: {'alias': alias.value},
      onSuccess: (value) {
        _manualInputModel = value!;
        var data = _manualInputModel.data.inputFields;
        getManualDynamicInputField(
          data: data,
          inputFieldControllers: inputFieldControllers,
          inputFields: inputFields,
          inputFileFields: inputFileFields,
          hasFile: hasFile,
          selectType: selectType,
        );
        Get.toNamed(Routes.paymentManualField);
      },
    );
  }

  ///=> manual payment process

  late CommonSuccessModel _commonSuccessModel;

  CommonSuccessModel get commonSuccessModel => _commonSuccessModel;

  Future<CommonSuccessModel?> bookingManualProcess() async {
    // Validate car identifiers before sending booking request
    if (slug.value.isEmpty || Id.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Car information is missing. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

  final int? _selectedCarAreaId = _getSelectedCarAreaId();

  Map<String, String> inputBody = {
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text,
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text,
      'mobile': bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text,
      'credentials': bookingData.value?['email'] ?? LocalStorage.email,
      'car_slug': slug.value,
      'car_id': Id.value,
      'gateway_type': paymentTypes.value,
      'gateway_currency': alias.value,
      'payment': selectedMethodText,
      'token': dashboardController.carToken.value,
      'fees': (bookingData.value?['total'] ?? 0).toString(),
    };
  if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId.toString();
    final data = _manualInputModel.data.inputFields;

    for (int i = 0; i < data.length; i += 1) {
      if (data[i].type != 'file') {
        inputBody[data[i].name] = inputFieldControllers[i].text;
      }
    }
    inputFileFields.clear();
    inputFields.clear();
    listImagePath.clear();
    listFieldName.clear();
    inputFieldControllers.clear();
    update();

    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      fieldList: listFieldName,
      pathList: listImagePath,
      onSuccess: (value) {
        inputFileFields.clear();
        inputFields.clear();
        listImagePath.clear();
        listFieldName.clear();
        inputFieldControllers.clear();
        update();
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  }

  void _confirmation(CommonSuccessModel commonSuccessModel) {
    Congratulation congratulation = Congratulation(
      details: Strings.bookingSuccessfully,
      route: Routes.dashboardScreen,
      buttonText: Strings.backToHome,
      type: Strings.payment,
    );

    Get.to(() => CongratulationsScreen(), arguments: congratulation);
  }

  RxDouble totalPayable = 0.0.obs;

  RxDouble exRent = 0.0.obs;
  RxDouble percentCharge = 0.0.obs;
  RxDouble fixeCharge = 0.0.obs;
  RxDouble conversionAmount = 0.0.obs;
  RxDouble totalCharge = 0.0.obs;

  void calculateAllCharges() {
    conversionAmount.value =
        exRent.value * (bookingData.value?['total'] ?? Get.find<BookingController>().total.value);

    // Calculate the percent charge based on the conversion amount
    percentCharge.value = percentCharge.value / 100 * conversionAmount.value;

    // Calculate the total charge
    totalCharge.value = fixeCharge.value + percentCharge.value;

    // Calculate the total payable amount
    totalPayable.value = conversionAmount.value + totalCharge.value;
  }

  // Authorize Submit
  final _isAuthorizeLoading = false.obs;
  bool get isAuthorizeLoading => _isAuthorizeLoading.value;

  late CommonSuccessModel _authorizeModel;
  CommonSuccessModel get authorizeModel => _authorizeModel;

  Future<CommonSuccessModel?> authorizeSubmitProcess() async {
    Map<String, dynamic> inputBody = {
      "identifier": identifier.value,
      "card_number": cardNumberController.text,
      "date": cardExpiryController.text,
      "code": cardCVCController.text,
    };
    return RequestProcess().request(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.authorizeSubmit,
      body: inputBody,
      method: HttpMethod.POST,
      isLoading: _isAuthorizeLoading,
      onSuccess: (value) {
        _authorizeModel = value!;
        Congratulation congratulation = Congratulation(
          details: Strings.paymentSuccessful,
          route: Routes.dashboardScreen,
          buttonText: Strings.backToHome,
          type: Strings.payment,
        );
        Get.offAll(() => CongratulationsScreen(), arguments: congratulation);
      },
    );
  }

  // PayTabs Payment Processing
  RxString paytabsTransactionRef = ''.obs;
  final _isPayTabsLoading = false.obs;
  bool get isPayTabsLoading => _isPayTabsLoading.value;

  /// Process payment through PayTabs
  Future<void> processPayTabsPayment() async {
    // Validate car identifiers before sending booking request
    if (slug.value.isEmpty || Id.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Car information is missing. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isPayTabsLoading.value = true;

    try {
      // Prepare booking details for PayTabs
      final bookingController = Get.find<BookingController>();
    final cartId = 'BOOKING_${DateTime.now().millisecondsSinceEpoch}';
    final amount = totalPayable.value > 0 
          ? totalPayable.value 
          : (bookingData.value?['total'] ?? bookingController.total.value);
    final int? _selectedCarAreaId = _getSelectedCarAreaId();

      // Create payment with PayTabs
      final paymentResult = await PayTabsService.createPayment(
        cartId: cartId,
        cartAmount: amount,
        cartDescription: 'Car rental booking for ${carModel.value}',
        customerName: LocalStorage.model.toString(), // Use actual customer name
        customerEmail: LocalStorage.email,
        customerPhone: bookingController.mobileController.text,
        customerCity: bookingController.locationController.text,
        customerCountry: 'SAU',
        language: 'en',
        userDefined: {
          'car_id': Id.value,
          'car_slug': slug.value,
          'location': bookingData.value?['delivery_location'] ?? bookingController.locationController.text,
          'fees': amount.toString(),
          if (_selectedCarAreaId != null) 'car_area': _selectedCarAreaId,
        },
      );

      _isPayTabsLoading.value = false;

      if (paymentResult != null && paymentResult['success'] == true) {
        final data = paymentResult['data'];
        final paymentUrl = data['payment_url'];
        paytabsTransactionRef.value = data['transaction_ref'];

        // Navigate to PayTabs payment screen
        Get.to(() => PayTabsPaymentScreen(
          paymentUrl: paymentUrl,
          transactionRef: paytabsTransactionRef.value,
        ));
      } else {
        Get.snackbar(
          'Error',
          'Failed to create payment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _isPayTabsLoading.value = false;
      log.e('PayTabs Payment Error: $e');
      Get.snackbar(
        'Error',
        'An error occurred while processing payment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Handle successful PayTabs payment
  void handlePaymentSuccess(String transactionRef) async {
    // Validate car identifiers
    if (slug.value.isEmpty || Id.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Car information is missing. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Submit booking with payment confirmation
    final int? _selectedCarAreaId = _getSelectedCarAreaId();

    Map<String, dynamic> inputBody = {
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text,
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text,
      'mobile': bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text,
      'credentials': bookingData.value?['email'] ?? LocalStorage.email,
      'car_slug': slug.value,
      'car_id': Id.value,
      'gateway_type': 'paytabs',
      'gateway_currency': alias.value,
      'payment': selectedMethodText,
      'token': dashboardController.carToken.value,
      'fees': (bookingData.value?['total'] ?? 0).toString(),
      'transaction_ref': transactionRef,
      // New pricing fields
      'quantity': bookingData.value?['quantity'],
      'pricing_type': bookingData.value?['pricing_type'],
      'delivery_required': bookingData.value?['delivery_required'] ?? false,
    };
    if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId;

    RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  }
}
