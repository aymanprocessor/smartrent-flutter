part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsDashboardMobileScreen extends GetView<AllVendorsDashboardController> {
  const AllVendorsDashboardMobileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: CustomColor.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: CustomColor.whiteColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: CustomColor.background,
        appBar: AllVendorsAppBar(),
        body: Obx(
          () => controller.isLoad
              ? Loader()
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.getAllTypes();
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: Dimensions.verticalSize),
                        AllVendorsFilterBox(),
                        SizedBox(height: Dimensions.verticalSize),
                        AllVendorsSearchButton(),
                        SizedBox(height: Dimensions.verticalSize * 2),
                        
                        // Show cars if available
                        Obx(() => controller.cars.isNotEmpty
                            ? Column(
                                children: [
                                  AllVendorsCarCarousel(),
                                  SizedBox(height: Dimensions.verticalSize),
                                ],
                              )
                            : SizedBox()),
                        
                        SizedBox(height: Dimensions.verticalSize * 3),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
