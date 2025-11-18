part of '../screen/dashboard_screen.dart';

class TopAppBarWidget extends GetView<DashboardController> {
  TopAppBarWidget({Key? key}) : super(key: key);
  final profileController = Get.put(UpdateProfileController());

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      title: Obx(
        () => AppCachedImage(
          imageUrl: BasicServices.appBasicLogoWhite.value,
          height: MediaQuery.of(context).size.height * 0.023,
          fit: BoxFit.contain,
          useShimmer: false,
        ),
      ),
      actions: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => Get.toNamed(Routes.update_profileScreen),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Dimensions.defaultHorizontalSize,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: CustomColor.primary),
            ),
            child: Obx(() {
              final profileImageUrl = controller.userProfileImage.value;
              final defaultImageUrl = controller.userDefaultImageUrl.value;

              bool isValidUrl(String url) {
                return url.isNotEmpty &&
                    (url.startsWith('http://') || url.startsWith('https://'));
              }

              return CircleAvatar(
                radius: Dimensions.radius * 1.2,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: isValidUrl(profileImageUrl)
                      ? AppCachedImage(
                          imageUrl: profileImageUrl,
                          width: Dimensions.radius * 2.4,
                          height: Dimensions.radius * 2.4,
                          fit: BoxFit.cover,
                          shape: BoxShape.circle,
                          useShimmer: true,
                          errorWidget: _buildFallbackImage(defaultImageUrl),
                        )
                      : _buildFallbackImage(defaultImageUrl),
                ),
              );
            }),
          ),
        ),
      ],
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  _buildFallbackImage(String url) {
    if (url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(),
      );
    } else {
      return Container();
    }
  }
}
