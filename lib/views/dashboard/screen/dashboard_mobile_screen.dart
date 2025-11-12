part of 'dashboard_screen.dart';

class DashboardMobileScreen extends GetView<DashboardController> {
  DashboardMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomWidget(
        index: controller.selectedCarIndex.value,
      ),
      extendBody: true,
      drawer: DrawerMobileScreen(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Dimensions.appBarHeight * 1.3),
        child: TopAppBarWidget(),
      ),
      body: Obx(() => controller.isLoading ? Loader() : _bodyWidget(context)),
    );
  }

  _bodyWidget(BuildContext context) {
    // Initialize the AllVendors controller once
    if (!Get.isRegistered<AllVendorsDashboardController>()) {
      Get.put(AllVendorsDashboardController(), permanent: true);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/background/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        GetBuilder<AllVendorsDashboardController>(
          builder: (vendorController) {
            // Use CustomScrollView to avoid nested scrollable conflict
            return AllVendorsCarListView();
          },
        ),
      ],
    );
  }
}
