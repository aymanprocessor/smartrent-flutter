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
        
        // Show pickup location only when deliver is enabled
        Obx(
          () => controller.isDeliver.value
              ? PrimaryInputWidget(
                  controller: controller.locationController,
                  label: DynamicLanguage.key(Strings.PickUpLocation),
                  hintText: DynamicLanguage.key(Strings.PickUpLocation),
                  showBorderSide: true,
                )
              : const SizedBox.shrink(),
        ),
      ],
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

