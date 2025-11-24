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

    bool isKycVerified() {
      final kycStatus = LocalStorage.kycStatus;
      return kycStatus == 1; // 1 = Approved/Verified
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/background/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Column(
          children: [
            // KYC Status Sticky Note (only show if not verified)
            if (!isKycVerified())
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSize * 0.8,
                  vertical: Dimensions.paddingSize * 0.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.amber.shade300, width: 1.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LocalStorage.kycStatus == 2
                          ? Icons.schedule_rounded
                          : Icons.warning_amber_rounded,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    SizedBox(width: Dimensions.widthSize * 0.75),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocalStorage.kycStatus == 2
                                ? DynamicLanguage.key(Strings.kycPending)
                                : DynamicLanguage.key(Strings.kycVerification),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                              fontSize: Dimensions.bodyLarge,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            LocalStorage.kycStatus == 2
                                ? DynamicLanguage.key(Strings.kycPendingReview)
                                : DynamicLanguage.key(Strings.completeKycToEnableBooking),
                            style: TextStyle(
                              color: Colors.amber.shade700,
                              fontSize: Dimensions.bodySmall * 0.9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Dimensions.widthSize * 0.5),
                    InkWell(
                      onTap: LocalStorage.kycStatus == 2
                          ? null
                          : () => Get.toNamed(Routes.kycSubmissionScreen),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSize * 0.6,
                          vertical: Dimensions.paddingSize * 0.25,
                        ),
                        decoration: BoxDecoration(
                          color: LocalStorage.kycStatus == 2
                              ? Colors.grey.shade400
                              : Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          LocalStorage.kycStatus == 2 ? 'Pending' : 'Complete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: Dimensions.bodySmall * 0.85,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: GetBuilder<AllVendorsDashboardController>(
                builder: (vendorController) {
                  // Use CustomScrollView to avoid nested scrollable conflict
                  return AllVendorsCarListView();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
