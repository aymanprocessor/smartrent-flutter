part of '../screen/booking_screen.dart';

class BookingAllFields extends GetView<BookingController> {
  const BookingAllFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        _othersInputField(),
        Sizes.height.betweenInputBox,
        _pickupDateTimeSection(),
        Sizes.height.betweenInputBox,
        _deliverySection(),
        Sizes.height.betweenInputBox,
        _pricingInfoSection(),
        Sizes.height.betweenInputBox,
        PrimaryInputWidget(
          skipEnterText: true,
          optionalText: DynamicLanguage.key(Strings.Optional),
          label: DynamicLanguage.key(Strings.note),
          maxLines: 4,
          controller: controller.noteController,
          hintText: DynamicLanguage.key(Strings.writeHere),
          textInputType: TextInputType.name,
          showBorderSide: true,
        ),
      ],
    );
  }

  /// Main input fields: Quantity (Days or Distance)
  _othersInputField() {
    return Obx(
      () => PrimaryInputWidget(
        textInputType: TextInputType.number,
        controller: controller.quantityController,
        label: controller.getQuantityLabel(),
        hintText: controller.getQuantityHint(),
        showBorderSide: true,
      ),
    );
  }

  /// Pickup Date and Time Section
  _pickupDateTimeSection() {
    return Column(
      children: [
        // Pickup Date
        CustomDatePicker(
          selectedDate: controller.pickupDate,
          label: DynamicLanguage.key(Strings.PickUpdate),
          subtitle: DynamicLanguage.key(Strings.SelectADate),
          showBorder: true,
        ),
        Sizes.height.betweenInputBox,
        
        // Pickup Time
        CustomTimePicker(
          selectedTime: controller.pickupTime,
          label: DynamicLanguage.key(Strings.PickUpTime),
          subtitle: DynamicLanguage.key(Strings.SelectATime),
          showBorder: true,
        ),
      ],
    );
  }

  /// Delivery Section: Checkbox and Location Input
  _deliverySection() {
    return Obx(
      () {
        // Hide delivery section entirely if delivery is not available
        if (!controller.isDeliveryAvailable()) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Obx(
              () => Row(
                children: [
                  Checkbox(
                    value: controller.isDeliver.value,
                    onChanged: (v) => controller.isDeliver.value = v ?? false,
                    // use app primary color when checked
                    fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.selected)) return CustomColor.primary;
                      return null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(DynamicLanguage.isLoading ? '' : DynamicLanguage.key(Strings.deliveryCar)),
                ],
              ),
            ),
            Sizes.height.v5,
            
            // Show pickup location map picker only when deliver is enabled
            Obx(
              () => controller.isDeliver.value
                  ? _buildLocationPickerButton()
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  /// Build location picker button that navigates to map
  Widget _buildLocationPickerButton() {
    return Obx(
      () {
        final hasLocation = controller.pickupLocation.value != null;
        return GestureDetector(
          onTap: () {
            // Determine center and radius from selected car's vendorLocation if available
            final vendorLoc = controller.selectedCar.value?.vendorLocation;
            LatLng? center;
            double? radiusMeters;
            if (vendorLoc != null && vendorLoc.latitude != null && vendorLoc.longitude != null) {
              center = LatLng(vendorLoc.latitude!, vendorLoc.longitude!);
              if (vendorLoc.radiusKm != null) {
                radiusMeters = vendorLoc.radiusKm! * 1000.0;
              }
            }

            Get.to(
              () => LocationPickerWidget(
                onLocationSelected: (location) {
                  controller.pickupLocation.value = location;
                  controller.pickupLatitude.value = location.latitude;
                  controller.pickupLongitude.value = location.longitude;
                },
                initialLocation: controller.pickupLocation.value,
                center: center,
                radiusMeters: radiusMeters,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: hasLocation ? CustomColor.primary : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: hasLocation ? CustomColor.primary : Colors.grey.shade400,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DynamicLanguage.key(Strings.PickUpLocation),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (hasLocation)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.pickupLocation.value!.address,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Lat: ${controller.pickupLocation.value!.latitude.toStringAsFixed(4)}, Lng: ${controller.pickupLocation.value!.longitude.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      else
                        Text(
                          DynamicLanguage.key(Strings.PickUpLocation),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: CustomColor.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pricing Summary Section
  _pricingInfoSection() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price per unit (Price per day / Price per km)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DynamicLanguage.isLoading
                      ? ''
                      : DynamicLanguage.key(controller.pricingType.value == 'per_day' 
                          ? Strings.pricePerDay
                          : Strings.pricePerKm),
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  controller.getPriceDisplayText(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Sizes.height.v10,
            
            // Subtotal (shows quantity × price)
            if (controller.quantityController.text.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DynamicLanguage.isLoading
                        ? ''
                        : DynamicLanguage.key(Strings.totalRent),
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${controller.subtotal.value.toStringAsFixed(2)} ${controller.selectedPricing.value?.currency ?? 'SAR'}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            
            // Delivery Charge (if enabled)
            if (controller.isDeliver.value && controller.deliveryCharge.value > 0)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DynamicLanguage.isLoading
                          ? ''
                          : DynamicLanguage.key(Strings.deliveryCharge),
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${controller.deliveryCharge.value.toStringAsFixed(2)} ${controller.selectedPricing.value?.currency ?? 'SAR'}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            
            // Tax Amount (if enabled)
            if (controller.selectedCar.value != null &&
                controller.selectedCar.value!.taxEnabled &&
                controller.taxAmount.value > 0)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DynamicLanguage.isLoading
                          ? ''
                          : DynamicLanguage.key(Strings.tax),
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${controller.taxAmount.value.toStringAsFixed(2)} ${controller.selectedPricing.value?.currency ?? 'SAR'}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            
            // Total
            if (controller.total.value > 0)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DynamicLanguage.isLoading
                          ? ''
                          : DynamicLanguage.key(Strings.total),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${controller.total.value.toStringAsFixed(2)} ${controller.selectedPricing.value?.currency ?? 'SAR'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

