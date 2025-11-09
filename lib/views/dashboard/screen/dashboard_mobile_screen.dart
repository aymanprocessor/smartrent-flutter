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
    return RefreshIndicator(
      color: CustomColor.primary,
      onRefresh: () async {
        controller.clearData();
        controller.getDashboardInfo();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          ListView(
            children: [
              // Button to navigate to All Vendors Dashboard
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.defaultHorizontalSize,
                  vertical: Dimensions.verticalSize * 0.5,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.allVendorsDashboardScreen);
                  },
                  icon: Icon(Icons.explore, color: CustomColor.whiteColor),
                  label: Text(
                    'Browse All Vendors Cars',
                    style: TextStyle(
                      color: CustomColor.whiteColor,
                      fontSize: Dimensions.titleMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.secondary,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.verticalSize * 0.6,
                      horizontal: Dimensions.horizontalSize,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius),
                    ),
                  ),
                ),
              ),
              SelectTypeBox(),
              TimeDateBox(),
              FindCarButton(),
              CarCarouselSlider(),
            ],
          ),
        ],
      ),
    );
  }
}
