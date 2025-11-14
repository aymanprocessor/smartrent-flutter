import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:carbo/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart';
import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:carbo/languages/strings.dart';
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
  
  // Pickup date and time observables
  RxString pickupDate = ''.obs;
  RxString pickupTime = ''.obs;
  
  RxBool isFormValid = false.obs;
  RxBool isDeliver = false.obs;
  
  // Pricing and car data
  Rxn<VendorCar> selectedCar = Rxn<VendorCar>();
  Rxn<Pricing> selectedPricing = Rxn<Pricing>();
  RxString pricingType = ''.obs; // 'per_day' or 'per_km'
  RxString pricingUnit = ''.obs; // 'day', 'km', etc.
  RxDouble deliveryCharge = 0.0.obs;
  RxDouble subtotal = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
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
    
    // Listen to pickup date and time changes
    ever(pickupDate, (_) => _updateFormValidity());
    ever(pickupTime, (_) => _updateFormValidity());
    
    // Recalculate when delivery toggle changes
    ever(isDeliver, (_) {
      _updateFormValidity();
      _calculateCharges();
    });
  }

  /// Initialize booking with selected car and pricing info
  void initializeWithCar(VendorCar car) {
    selectedCar.value = car;
    selectedPricing.value = car.pricing;
    pricingType.value = car.pricing.type;
    pricingUnit.value = car.pricing.unit;
    _updateFormValidity();
  }

  void _updateFormValidity() {
    isFormValid.value =
        emailController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        pickupDate.value.isNotEmpty &&
        pickupTime.value.isNotEmpty &&
        // pickup location is required only when isDeliver is true
        (isDeliver.value ? locationController.text.isNotEmpty : true) &&
        mobileController.text.isNotEmpty;
  }

  void _calculateCharges() {
    if (selectedPricing.value == null || selectedCar.value == null) return;

    double quantity = double.tryParse(quantityController.text) ?? 0;
    double price = selectedPricing.value!.price;
    
    // Calculate subtotal based on quantity and price
    subtotal.value = quantity * price;
    
    // Add delivery charge if enabled (use car's delivery price)
    if (isDeliver.value && selectedCar.value!.deliveryPrice != null) {
      deliveryCharge.value = selectedCar.value!.deliveryPrice!;
    } else {
      deliveryCharge.value = 0;
    }
    
    // Calculate tax if enabled
    if (selectedCar.value!.taxEnabled) {
      taxAmount.value = (subtotal.value + deliveryCharge.value) * 
                        (selectedCar.value!.taxPercentage / 100);
    } else {
      taxAmount.value = 0;
    }
    
    // Total = subtotal + delivery + tax
    total.value = subtotal.value + deliveryCharge.value + taxAmount.value;
  }

  /// Get label for quantity input based on pricing type
  String getQuantityLabel() {
    switch (pricingType.value) {
      case 'per_day':
        return Strings.rentalDays; // Number of rental days
      case 'per_km':
        return Strings.distance; // Distance
      default:
        return Strings.quantity; // Quantity
    }
  }

  /// Get hint text for quantity input based on pricing type
  String getQuantityHint() {
    switch (pricingType.value) {
      case 'per_day':
        return Strings.enterDays;
      case 'per_km':
        return Strings.enterDistance;
      default:
        return Strings.enterQuantity;
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
    // Try to get booking token from multiple sources
    String bookingToken = '';
    
    // First, try DashboardController
    try {
      final dashboardController = Get.find<DashboardController>();
      if (dashboardController.carToken.value.isNotEmpty) {
        bookingToken = dashboardController.carToken.value;
      }
    } catch (e) {
      // DashboardController not found, try AllVendorsDashboardController
    }
    
    // Second, try AllVendorsDashboardController if DashboardController didn't have token
    if (bookingToken.isEmpty) {
      try {
        final allVendorsController = Get.find<AllVendorsDashboardController>();
        if (allVendorsController.carToken.value.isNotEmpty) {
          bookingToken = allVendorsController.carToken.value;
        }
      } catch (e) {
        // AllVendorsDashboardController not found
      }
    }
    
    // Final fallback: use LocalStorage token if available
    if (bookingToken.isEmpty) {
      bookingToken = LocalStorage.token;
    }
    
    return {
      'email': emailController.text,
      'phone': mobileController.text,
      'quantity': quantityController.text,
      'pickup_date': pickupDate.value,
      'pickup_time': pickupTime.value,
      'pricing_type': pricingType.value,
      'pricing_unit': pricingUnit.value,
      'delivery_required': isDeliver.value,
      'delivery_location': isDeliver.value ? locationController.text : null,
      'notes': noteController.text,
      'subtotal': subtotal.value,
      'delivery_charge': deliveryCharge.value,
      'tax_amount': taxAmount.value,
      'tax_enabled': selectedCar.value?.taxEnabled ?? false,
      'tax_percentage': selectedCar.value?.taxPercentage ?? 0,
      'total': total.value,
      'car_id': selectedCar.value?.id,
      'id': selectedCar.value?.id,  // Added: explicit id field for preview screen
      'car_name': '${selectedCar.value?.make} ${selectedCar.value?.model}',
      'currency': selectedCar.value?.currency ?? 'SAR',
      'token': bookingToken,  // Booking token from vendor cars API or fallback
    };
  }
}

