import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final noteController = TextEditingController();
  final mobileController = TextEditingController();
  final quantityController = TextEditingController(); // Days or Distance
  
  RxBool isFormValid = false.obs;
  RxBool isDeliver = false.obs;
  
  // Pricing and car data
  Rxn<Pricing> selectedPricing = Rxn<Pricing>();
  RxString pricingType = ''.obs; // 'per_day' or 'per_km'
  RxString pricingUnit = ''.obs; // 'day', 'km', etc.
  RxDouble deliveryCharge = 0.0.obs;
  RxDouble subtotal = 0.0.obs;
  RxDouble total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
    _setupListeners();
    
    // Check if car was passed as argument
    if (Get.arguments != null && Get.arguments is Map) {
      final car = Get.arguments['car'];
      if (car is VendorCar) {
        initializeWithCar(car);
      }
    }
  }

  void _initializeUserData() {
    // Auto-fill email and phone from user profile
    emailController.text = LocalStorage.email;
    mobileController.text = LocalStorage.number;
  }

  void _setupListeners() {
    // Set up listeners for form validation
    emailController.addListener(_updateFormValidity);
    quantityController.addListener(() {
      _updateFormValidity();
      _calculateCharges();
    });
    mobileController.addListener(_updateFormValidity);
    locationController.addListener(_updateFormValidity);
    
    // Recalculate when delivery toggle changes
    ever(isDeliver, (_) {
      _updateFormValidity();
      _calculateCharges();
    });
  }

  /// Initialize booking with selected car and pricing info
  void initializeWithCar(VendorCar car) {
    selectedPricing.value = car.pricing;
    pricingType.value = car.pricing.type;
    pricingUnit.value = car.pricing.unit;
    _updateFormValidity();
  }

  void _updateFormValidity() {
    isFormValid.value =
        emailController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        // pickup location is required only when isDeliver is true
        (isDeliver.value ? locationController.text.isNotEmpty : true) &&
        mobileController.text.isNotEmpty;
  }

  void _calculateCharges() {
    if (selectedPricing.value == null) return;

    double quantity = double.tryParse(quantityController.text) ?? 0;
    double price = selectedPricing.value!.price;
    
    // Calculate subtotal based on quantity and price
    subtotal.value = quantity * price;
    
    // Add delivery charge if enabled
    if (isDeliver.value) {
      // You can set a fixed delivery charge or make it dynamic
      // For now, let's assume 10% of subtotal as delivery charge
      deliveryCharge.value = subtotal.value * 0.1;
    } else {
      deliveryCharge.value = 0;
    }
    
    total.value = subtotal.value + deliveryCharge.value;
  }

  /// Get label for quantity input based on pricing type
  String getQuantityLabel() {
    switch (pricingType.value) {
      case 'per_day':
        return 'عدد الأيام'; // Number of Days
      case 'per_km':
        return 'المسافة'; // Distance
      default:
        return 'الكمية'; // Quantity
    }
  }

  /// Get hint text for quantity input based on pricing type
  String getQuantityHint() {
    switch (pricingType.value) {
      case 'per_day':
        return 'أدخل عدد الأيام'; // Enter number of days
      case 'per_km':
        return 'أدخل المسافة بـ ${pricingUnit.value}'; // Enter distance in km/miles
      default:
        return 'أدخل الكمية'; // Enter quantity
    }
  }

  /// Get price display text
  String getPriceDisplayText() {
    if (selectedPricing.value == null) return '';
    final pricing = selectedPricing.value!;
    return '${pricing.price.toStringAsFixed(0)} ${pricing.currency}/${pricing.unit}';
  }

  @override
  void onClose() {
    try {
      emailController.removeListener(_updateFormValidity);
      quantityController.removeListener(_updateFormValidity);
      mobileController.removeListener(_updateFormValidity);
      locationController.removeListener(_updateFormValidity);
    } catch (_) {}

    dateController.dispose();
    timeController.dispose();
    emailController.dispose();
    locationController.dispose();
    noteController.dispose();
    mobileController.dispose();
    quantityController.dispose();
    super.onClose();
  }

  /// Prepare booking data for submission
  Map<String, dynamic> getBookingData() {
    return {
      'email': emailController.text,
      'phone': mobileController.text,
      'quantity': quantityController.text,
      'pricing_type': pricingType.value,
      'pricing_unit': pricingUnit.value,
      'delivery_required': isDeliver.value,
      'delivery_location': isDeliver.value ? locationController.text : null,
      'notes': noteController.text,
      'subtotal': subtotal.value,
      'delivery_charge': deliveryCharge.value,
      'total': total.value,
    };
  }
}

