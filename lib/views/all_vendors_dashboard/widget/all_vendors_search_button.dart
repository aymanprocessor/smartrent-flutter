part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsSearchButton extends GetView<AllVendorsDashboardController> {
  const AllVendorsSearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: Obx(
        () => PrimaryButton(
          title: 'Search Cars',
          isLoading: controller.isSearchingCar,
          onPressed: () {
            controller.searchAllVendorsCars();
          },
        ),
      ),
    );
  }
}
