part of '../screen/drawer_screen.dart';

class ProfileHeaderWidget extends GetView<DashboardController> {
  const ProfileHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (LocalStorage.isLoggedIn) {
          Get.back();
          Get.toNamed(Routes.update_profileScreen);
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
      children: [
        Sizes.height.v30,
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2.5, color: CustomColor.primary),
              ),
              child: AppCachedImage(
                imageUrl: controller.userProfileImage.value,
                width: Dimensions.radius * 9,
                height: Dimensions.radius * 9,
                fit: BoxFit.cover,
                shape: BoxShape.circle,
                useShimmer: true,
                errorWidget: AppCachedImage(
                  imageUrl: controller.userDefaultImageUrl.value,
                  width: Dimensions.radius * 9,
                  height: Dimensions.radius * 9,
                  fit: BoxFit.cover,
                  shape: BoxShape.circle,
                  useShimmer: false,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: CustomColor.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Sizes.height.v10,
        Column(
          crossAxisAlignment: crossStart,
          children: [
            TextWidget(
              controller.userFullName.value,
              fontSize: Dimensions.titleLarge,
              fontWeight: FontWeight.w500,
            ),
            TextWidget(
              controller.userEmail.value,
              fontSize: Dimensions.titleSmall,
            ),
          ],
        ),
      ],
    ),
    );
  }
}
