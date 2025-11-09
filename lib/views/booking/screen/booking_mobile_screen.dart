part of 'booking_screen.dart';

class BookingMobileScreen extends GetView<BookingController> {
  const BookingMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
          vertical: Dimensions.verticalSize,
        ),
        child: Obx(
          () => PrimaryButton(
            title: Strings.continuee,
            disable: !controller.isFormValid.value,
            onPressed: () {
              if (controller.isFormValid.value) {
                controller.calculateAllCharges();
                Get.toNamed(Routes.previewScreen);
              }
            },
          ),
        ),
      ),
      appBar: CustomAppBar(
        centerTitle: false,
        DynamicLanguage.key(Strings.bookYorCar),
      ),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        children: [Sizes.height.v20, BookingAllFields()],
      ),
    );
  }
}
