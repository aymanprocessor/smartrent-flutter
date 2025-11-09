part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsCarCarousel extends GetView<AllVendorsDashboardController> {
  const AllVendorsCarCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sliderHeight = MediaQuery.of(context).size.height * 0.28;
    
    return Obx(() {
      return controller.cars.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize,
                  ),
                  child: Text(
                    'Available Cars (${controller.cars.length})',
                    style: TextStyle(
                      fontSize: Dimensions.titleLarge,
                      fontWeight: FontWeight.bold,
                      color: CustomColor.typography.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.verticalSize),
                CarouselSlider.builder(
                  itemCount: controller.cars.length,
                  itemBuilder: (context, index, realIndex) {
                    final car = controller.cars[index];
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        // Store selected car info in main DashboardController
                        try {
                          final dashController = Get.find<DashboardController>();
                          dashController.selectedCarId.value = car.id.toString();
                          dashController.carToken.value = controller.carToken.value;
                          // Also add the car to the dashboard controller's cars list if not exists
                          if (!dashController.cars.any((c) => c.id == car.id)) {
                            dashController.cars.add(car);
                          }
                        } catch (e) {
                          // DashboardController might not be loaded, just use local controller
                          controller.selectedCarId.value = car.id.toString();
                        }
                        Get.toNamed(Routes.bookingScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
                        margin: EdgeInsets.symmetric(
                          horizontal: Dimensions.horizontalSize * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: CustomColor.whiteColor,
                          borderRadius: BorderRadius.circular(Dimensions.radius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Car Image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
                                child: CachedNetworkImage(
                                  imageUrl: car.imagesOrPlaceholder.first.startsWith('http')
                                      ? car.imagesOrPlaceholder.first
                                      : '${controller.carImgUrl.value}${car.imagesOrPlaceholder.first}',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      color: CustomColor.primary,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Image.asset(
                                    'assets/logo/logo_carbo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: Dimensions.verticalSize * 0.5),
                            
                            // Car Title
                            Text(
                              car.carTitle?.en?.carTitle ?? car.carModel,
                              style: TextStyle(
                                fontSize: Dimensions.titleMedium,
                                fontWeight: FontWeight.bold,
                                color: CustomColor.typography,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Dimensions.verticalSize * 0.3),
                            
                            // Car Details
                            Row(
                              children: [
                                Icon(Icons.directions_car, 
                                  size: Dimensions.iconSizeDefault * 0.7,
                                  color: CustomColor.primary,
                                ),
                                SizedBox(width: Dimensions.horizontalSize * 0.3),
                                Text(
                                  '${car.carType} • ${car.carYear}',
                                  style: TextStyle(
                                    fontSize: Dimensions.bodySmall,
                                    color: CustomColor.typography.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.verticalSize * 0.3),
                            
                            // Seats and Fee
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.event_seat,
                                      size: Dimensions.iconSizeDefault * 0.7,
                                      color: CustomColor.primary,
                                    ),
                                    SizedBox(width: Dimensions.horizontalSize * 0.3),
                                    Text(
                                      '${car.seat} Seats',
                                      style: TextStyle(
                                        fontSize: Dimensions.bodySmall,
                                        color: CustomColor.typography.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${car.fees}',
                                  style: TextStyle(
                                    fontSize: Dimensions.titleMedium,
                                    fontWeight: FontWeight.bold,
                                    color: CustomColor.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: sliderHeight,
                    viewportFraction: 0.85,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      controller.currentIndex.value = index;
                      controller.selectedCarIndex.value = index;
                    },
                  ),
                ),
                SizedBox(height: Dimensions.verticalSize),
                
                // Book Now Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize * 2,
                  ),
                  child: PrimaryButton(
                    title: Strings.bookNow,
                    onPressed: () {
                      if (controller.cars.isNotEmpty) {
                        final car = controller.cars[controller.selectedCarIndex.value];
                        // Store selected car info in main DashboardController
                        try {
                          final dashController = Get.find<DashboardController>();
                          dashController.selectedCarId.value = car.id.toString();
                          dashController.carToken.value = controller.carToken.value;
                          // Also add the car to the dashboard controller's cars list if not exists
                          if (!dashController.cars.any((c) => c.id == car.id)) {
                            dashController.cars.add(car);
                          }
                        } catch (e) {
                          // DashboardController might not be loaded
                          controller.selectedCarId.value = car.id.toString();
                        }
                        Get.toNamed(Routes.bookingScreen);
                      }
                    },
                  ),
                ),
              ],
            )
          : SizedBox();
    });
  }
}
