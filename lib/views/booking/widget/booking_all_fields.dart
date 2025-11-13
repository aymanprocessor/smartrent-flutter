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
        _deliverySection(),
        Sizes.height.betweenInputBox,
        _pricingInfoSection(),
        Sizes.height.betweenInputBox,
        PrimaryInputWidget(
          skipEnterText: true,
          optionalText: Strings.Optional,
          label: Strings.note,
          maxLines: 4,
          controller: controller.noteController,
          hintText: Strings.writeHere,
          textInputType: TextInputType.name,
          showBorderSide: true,
        ),
      ],
    );
  }

  /// Main input fields: Email, Phone, Quantity (Days or Distance)
  _othersInputField() {
    return Column(
      children: [
        // Email field (read-only, from profile)
        PrimaryInputWidget(
          controller: controller.emailController,
          label: Strings.email,
          hintText: Strings.email,
          readOnly: true,
          textInputType: TextInputType.emailAddress,
          showBorderSide: true,
        ),
        Sizes.height.betweenInputBox,
        
        // Phone field (from profile)
        PrimaryInputWidget(
          controller: controller.mobileController,
          label: Strings.Phone,
          hintText: Strings.Phone,
          textInputType: TextInputType.phone,
          showBorderSide: true,
        ),
        Sizes.height.betweenInputBox,
        
        // Dynamic Quantity field (Days or Distance based on pricing type)
        Obx(
          () => PrimaryInputWidget(
            textInputType: TextInputType.number,
            controller: controller.quantityController,
            label: controller.getQuantityLabel(),
            hintText: controller.getQuantityHint(),
            showBorderSide: true,
          ),
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
              ),
              const SizedBox(width: 8),
              Text(DynamicLanguage.isLoading ? '' : DynamicLanguage.key('توصيل السيارة')),
            ],
          ),
        ),
        Sizes.height.v5,
        
        // Show pickup location only when deliver is enabled
        Obx(
          () => controller.isDeliver.value
              ? PrimaryInputWidget(
                  controller: controller.locationController,
                  label: Strings.PickUpLocation,
                  hintText: Strings.PickUpLocation,
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
                          ? 'السعر في اليوم' 
                          : 'السعر في الكيلومتر'),
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
                        : DynamicLanguage.key('إجمالي الإيجار'),
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
                          : DynamicLanguage.key('رسوم التوصيل'),
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
                          : DynamicLanguage.key('الضريبة'),
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
                          : DynamicLanguage.key('الإجمالي'),
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

