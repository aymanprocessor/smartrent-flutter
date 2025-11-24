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
          () {
            // Show button and, when disabled, a compact list of missing fields to help users.
            final disabled = !controller.isFormValid.value;
            final missing = controller.getMissingFields();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  title: Strings.continuee,
                  // Button enabled based solely on form validity.
                  disable: disabled,
                  onPressed: () {
                    if (controller.isFormValid.value) {
                      Get.toNamed(Routes.previewScreen,
                          arguments: controller.getBookingData());
                    }
                  },
                ),
                if (disabled && missing.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DynamicLanguage.key(Strings.pleaseFillOutTheField),
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade700),
                        ),
                        SizedBox(height: 6),
                        ...missing.map((m) => Text('• ' + m, style: TextStyle(color: Colors.red.shade700))).toList(),
                      ],
                    ),
                  ),
                ]
              ],
            );
          },
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
