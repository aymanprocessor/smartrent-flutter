import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/base/localization/dynamic_language_shim.dart';
import 'package:carbo/base/widgets/app_cached_image.dart';
import 'package:carbo/base/services/location_service.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:carbo/routes/routes.dart';
import 'package:carbo/views/common/html_screen.dart';
import '../controller/vendor_cars_controller.dart';

// Widget parts
part '../widget/vendor_car_card.dart';
part '../widget/vendor_cars_skeleton.dart';
part '../widget/vendor_cars_empty_state.dart';
part '../widget/vendor_cars_error_state.dart';
part '../widget/vendor_cars_filter_chips.dart';
part '../widget/vendor_cars_sort_dropdown.dart';
part '../widget/vendor_cars_header.dart';
part '../widget/vendor_cars_guest_drawer.dart';
part '../widget/vendor_cars_brand_filter.dart';

/// Main screen for displaying vendor cars with filtering and booking
class VendorCarsScreen extends GetView<VendorCarsController> {
  const VendorCarsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.background,
      appBar: _buildAppBar(context),
      drawer: const VendorCarsGuestDrawer(),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: CustomColor.whiteColor,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: Icon(
            Icons.menu_rounded,
            color: CustomColor.typography,
            size: 24,
          ),
        ),
      ),
      title: null,
      centerTitle: false,
      actions: [
        // Refresh button
        IconButton(
          onPressed: () => controller.refreshCars(),
          icon: Obx(
            () => controller.isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomColor.primary,
                    ),
                  )
                : Icon(Icons.refresh_rounded, color: CustomColor.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.isLoading && controller.vendorCars.isEmpty) {
        return const VendorCarsSkeletonLoader();
      }

      // Error state
      if (controller.hasError && controller.vendorCars.isEmpty) {
        return VendorCarsErrorState(
          message: controller.errorMessage.value,
          onRetry: () => controller.fetchVendorCars(),
        );
      }

      // Empty state
      if (controller.vendorCars.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshCars,
          color: CustomColor.primary,
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: VendorCarsEmptyState(),
          ),
        );
      }

      // Main content
      return RefreshIndicator(
        onRefresh: controller.refreshCars,
        color: CustomColor.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Spacing
            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize),
            ),

            // Header with count and sort
            const SliverToBoxAdapter(child: VendorCarsHeader()),

            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 0.75),
            ),

            // Brand filter
            const SliverToBoxAdapter(child: VendorCarsBrandFilter()),

            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 0.75),
            ),

            // Location permission banner
            if (controller.locationPermissionDenied.value)
              SliverToBoxAdapter(
                child: _buildLocationPermissionBanner(context),
              ),

            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 0.5),
            ),

            // Quick filter chips
            const SliverToBoxAdapter(child: VendorCarsFilterChips()),

            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 0.75),
            ),

            // Car cards list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Load more indicator at the end
                  if (index == controller.vendorCars.length) {
                    return _buildLoadMoreButton();
                  }

                  final car = controller.vendorCars[index];
                  return Obx(
                    () => _buildShimmerWrapper(
                      isLoading: controller.isCheckingDelivery.value,
                      child: VendorCarCard(
                        car: car,
                        onBookNow: () => controller.onBookNowTap(car),
                      ),
                    ),
                  );
                },
                childCount:
                    controller.vendorCars.length +
                    (controller.hasMore.value ? 1 : 0),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 3),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadMoreButton() {
    return Obx(
      () => controller.isLoadingMore
          ? Padding(
              padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
              child: Center(
                child: CircularProgressIndicator(color: CustomColor.primary),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () => controller.fetchVendorCars(loadMore: true),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    DynamicLanguage.key(Strings.loadMore),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomColor.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    side: BorderSide(color: CustomColor.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLocationPermissionBanner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: Container(
        padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 20,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DynamicLanguage.key(Strings.LocationPermissionDenied),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DynamicLanguage.key(Strings.OpenSettings),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final locationService = Get.find<LocationService>();
                await locationService.openAppSettings();
                await controller.retryDeliveryCheck();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                DynamicLanguage.key(Strings.OpenSettings),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerWrapper({
    required bool isLoading,
    required Widget child,
  }) {
    if (!isLoading) return child;

    return Stack(
      children: [
        Opacity(opacity: 0.5, child: child),
        Positioned.fill(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultHorizontalSize,
                vertical: Dimensions.verticalSize * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
