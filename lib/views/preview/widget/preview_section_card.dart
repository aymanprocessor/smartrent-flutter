part of '../screen/preview_screen.dart';

class PreviewSectionCard extends GetView<PreviewController> {
  PreviewSectionCard({super.key});

  final bookController = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.5,
          ),
          Strings.preview,
          fontWeight: FontWeight.bold,
          fontSize: Dimensions.titleSmall,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.5,
            horizontal: Dimensions.defaultHorizontalSize,
          ),
          decoration: BoxDecoration(
            color: CustomColor.whiteColor,
            borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
          ),
          child: Column(
            children: [
              if (bookController.isDeliver.value)
                _cardSection(
                  Strings.PickUpLocation,
                  bookController.locationController.text,
                ),
              if (bookController.isDeliver.value)
                _cardSection(
                  Strings.PickUpdate,
                  Get.find<DashboardController>().selectedDate.value,
                ),
              if (bookController.isDeliver.value)
                _cardSection(
                  Strings.PickUpTime,
                  Get.find<DashboardController>().selectedTime.value,
                ),
              _cardSection(
                Strings.quantity,
                bookController.quantityController.text,
              ),
              if (bookController.isDeliver.value)
                _cardSection(
                  Strings.deliveryCar,
                  'Yes',
                ),
              _cardSection(
                bookController.pricingType.value == 'per_day' 
                  ? Strings.pricePerDay
                  : Strings.pricePerKm,
                '${bookController.selectedPricing.value?.price ?? 0} ${bookController.selectedPricing.value?.currency ?? 'USD'}',
              ),
              _cardSection(
                Strings.totalRent,
                '${bookController.subtotal.value.toStringAsFixed(BasicServices.precision.value)} ${bookController.selectedPricing.value?.currency ?? 'USD'}',
              ),
              if (bookController.isDeliver.value)
                _cardSection(
                  Strings.deliveryCharge,
                  '${bookController.deliveryCharge.value.toStringAsFixed(BasicServices.precision.value)} ${bookController.selectedPricing.value?.currency ?? 'USD'}',
                ),
              if (bookController.selectedCar.value != null &&
                  bookController.selectedCar.value!.taxEnabled &&
                  bookController.taxAmount.value > 0)
                _cardSection(
                  Strings.tax,
                  '${bookController.taxAmount.value.toStringAsFixed(BasicServices.precision.value)} ${bookController.selectedPricing.value?.currency ?? 'USD'}',
                ),
              Obx(
                () => _cardSection(
                  Strings.totalPayable,
                  '${bookController.total.value.toStringAsFixed(BasicServices.precision.value)} ${bookController.selectedPricing.value?.currency ?? 'USD'}',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _cardSection(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.verticalSize * 0.25,
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: Row(
        mainAxisAlignment: mainSpaceBet,
        children: [
          TextWidget(title, fontSize: Dimensions.titleSmall),
          TextWidget(
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            value,
            fontWeight: FontWeight.w500,
            color: CustomColor.primary,
            fontSize: Dimensions.titleSmall,
          ),
        ],
      ),
    );
  }
}
