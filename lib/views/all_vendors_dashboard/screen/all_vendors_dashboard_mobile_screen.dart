part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsDashboardMobileScreen
    extends GetView<AllVendorsDashboardController> {
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
        body: Obx(() => controller.isLoad ? Loader() : AllVendorsCarListView()),
      ),
    );
  }
}
