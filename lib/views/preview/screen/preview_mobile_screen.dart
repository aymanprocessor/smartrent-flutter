part of 'preview_screen.dart';

class PreviewMobileScreen extends GetView<PreviewController> {
  const PreviewMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(controller.dashboardController.carToken);
    print(BasicServices.precision.value);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => controller.isLoading
            ? Loader()
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.defaultHorizontalSize,
                  vertical: Dimensions.verticalSize,
                ),
                child: Obx(
                  () => PrimaryButton(
                    isLoading: controller.isBookingLoading,
                    title: Strings.ConfirmBooking,
                    onPressed: () {
                      controller.handlePaymentProcess();
                    },
                  ),
                ),
              ),
      ),
      appBar: CustomAppBar(centerTitle: false, Strings.bookingPreview),
      body: Obx(() => controller.isLoading ? Loader() : _bodyWidget(context)),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        children: [PaymentSelectionWidget(), PreviewSectionCard()],
      ),
    );
  }
}
