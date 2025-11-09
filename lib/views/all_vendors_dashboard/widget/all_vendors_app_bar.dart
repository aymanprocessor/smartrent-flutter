part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsAppBar extends GetView<AllVendorsDashboardController> implements PreferredSizeWidget {
  const AllVendorsAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CustomColor.primary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: CustomColor.whiteColor),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'All Vendors Cars',
        style: TextStyle(
          color: CustomColor.whiteColor,
          fontSize: Dimensions.titleLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: CustomColor.whiteColor),
          onPressed: () {
            controller.clearFilters();
            controller.getAllTypes();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
