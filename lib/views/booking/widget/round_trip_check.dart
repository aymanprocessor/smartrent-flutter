part of '../screen/booking_screen.dart';

class RoundTripCheck extends GetView<BookingController> {
  RoundTripCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.verticalSize * 0.4),
      child: Row(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              controller.isChecked.value = !controller.isChecked.value;
            },
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Obx(
                  () => Container(
                    height: 18.0,
                    width: 18.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: controller.isChecked.value
                            ? CustomColor.primary
                            : CustomColor.disableColor,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                      color: controller.isChecked.value
                          ? CustomColor.primary
                          : Colors.transparent,
                    ),
                    child: controller.isChecked.value
                        ? Icon(Icons.check, color: Colors.white, size: 17.0)
                        : null,
                  ),
                ),
                Sizes.width.v5,
                TextWidget(
                  Strings.roundTrip,
                  fontSize: Dimensions.titleSmall * 0.9,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
