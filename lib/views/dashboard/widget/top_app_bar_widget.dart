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
        () => CachedNetworkImage(
          imageUrl: BasicServices.appBasicLogoWhite.value,
          placeholder: (context, url) => const Text(''),
          errorWidget: (context, url, error) => const Text(''),
          height: MediaQuery.of(context).size.height * 0.023,
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
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Text(''),
                          imageUrl: profileImageUrl,
                          errorWidget: (context, url, error) =>
                              _buildFallbackImage(defaultImageUrl),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
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
