part of '../screen/booking_screen.dart';

class BookingAllFields extends GetView<BookingController> {
  const BookingAllFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: crossStart,
        children: [
          _othersInputField(),
          if (controller.isChecked.value == true) ...[
            Sizes.height.v5,
            _roundTripField(context),
          ],
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
      ),
    );
  }

  _roundTripField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomDatePicker(
            showBorder: true,
            label: Strings.PickUpdate,
            selectedDate: controller.selectedRoundDate,
          ),
        ),
        Sizes.width.v10,
        Expanded(
          child: CustomTimePicker(
            showBorder: true,
            label: Strings.PickUpTime,
            selectedTime: controller.selectedRoundTime,
          ),
        ),
      ],
    );
  }

  _othersInputField() {
    return Column(
      children: [
        PrimaryInputWidget(
          controller: controller.emailController,
          label: Strings.email,
          hintText: Strings.email,
          readOnly: true,
          textInputType: TextInputType.emailAddress,
          showBorderSide: true,
        ),
        Sizes.height.betweenInputBox,
        PrimaryInputWidget(
          controller: controller.mobileController,
          label: Strings.Phone,
          hintText: Strings.Phone,
          textInputType: TextInputType.phone,
          showBorderSide: true,
        ),
        Sizes.height.betweenInputBox,
        Row(
          children: [
            Expanded(
              child: PrimaryInputWidget(
                textInputType: TextInputType.number,
                controller: controller.distanceController,
                label: Strings.distance,
                hintText: Strings.distance,
                showBorderSide: true,
              ),
            ),
            Sizes.width.v10,
            Expanded(
              child: PrimaryInputWidget(
                controller: controller.destinationController,
                label: Strings.destination,
                hintText: Strings.destination,
                showBorderSide: true,
              ),
            ),
          ],
        ),

        Sizes.height.betweenInputBox,
        // Deliver toggle: when true, pickup location is shown and required
        Obx(
          () => Row(
            children: [
              Checkbox(
                value: controller.isDeliver.value,
                onChanged: (v) => controller.isDeliver.value = v ?? false,
              ),
              const SizedBox(width: 8),
              Text('توصيل السيارة'),
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
        RoundTripCheck(),
      ],
    );
  }
}
