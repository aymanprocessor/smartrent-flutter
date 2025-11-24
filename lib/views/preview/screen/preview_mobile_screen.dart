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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Test Booking Button (for testing/QA)
                    PrimaryButton(
                      title: '🧪 Test Booking (No Payment)',
                      // KYC gating removed: always enabled (respecting controller loading state)
                      disable: false,
                      onPressed: () {
                        controller.testConfirmBooking();
                      },
                    ),
                    const SizedBox(height: 12),
                    // Confirm Booking Button (normal flow)
                    Obx(
                      () => PrimaryButton(
                        isLoading: controller.isBookingLoading,
                        title: Strings.ConfirmBooking,
                        // KYC gating removed: allow pressing; controller will handle payment flow
                        disable: false,
                        onPressed: () {
                          controller.handlePaymentProcess();
                        },
                      ),
                    ),
                  ],
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
        children: [PreviewSectionCard()],
      ),
    );
  }
}
