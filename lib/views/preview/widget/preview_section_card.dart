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
              _cardSection(
                Strings.PickUpLocation,
                bookController.locationController.text,
              ),
              _cardSection(
                Strings.destination,
                bookController.destinationController.text,
              ),
              _cardSection(
                Strings.PickUpdate,
                Get.find<DashboardController>().selectedDate.value,
              ),
              _cardSection(
                Strings.PickUpTime,
                Get.find<DashboardController>().selectedTime.value,
              ),
              _cardSection(
                Strings.roundTripDate,
                bookController.selectedRoundDate.value.isEmpty
                    ? 'N/A'
                    : bookController.selectedRoundDate.value,
              ),
              _cardSection(
                Strings.roundTripTime,
                bookController.selectedRoundTime.value.isEmpty
                    ? 'N/A'
                    : bookController.selectedRoundTime.value,
              ),
              // _cardSection(Strings.carModel, controller.carModel.value),
              // _cardSection(Strings.carNumber, controller.carNumber.value),
              _cardSection(
                Strings.distance,
                '${bookController.distanceController.text} KM',
              ),
              _cardSection(
                Strings.rate,
                '${double.parse(Get.find<BookingController>().Fees.value).toStringAsFixed(0)}/KM USD',
              ),
              _cardSection(
                Strings.totalRent,
                '${Get.find<BookingController>().totalFees.value.toStringAsFixed(BasicServices.precision.value)} USD',
              ),
              Obx(
                () => _cardSection(
                  Strings.totalPayable,
                  '${controller.totalPayable.value.toStringAsFixed(BasicServices.precision.value)} USD',
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
