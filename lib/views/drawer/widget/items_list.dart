part of '../screen/drawer_screen.dart';

class OthersWidgets extends StatelessWidget {
  const OthersWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Sizes.height.v20,
        _itemCard(
          Icons.lock_open_outlined,
          Strings.changePassword,
          () => Get.toNamed(Routes.change_passwordScreen),
        ),
        _itemCard(
          Icons.notifications_none,
          Strings.notification,
          () => Get.toNamed(Routes.notificationScreen),
        ),
        _itemCard(
          Icons.history,
          Strings.history,
          () => Get.toNamed(Routes.historyScreen),
        ),
        _itemCard(
          Icons.language,
          Strings.language,
          () => Get.toNamed(Routes.settingScreen),
        ),
        _itemCard(
          Icons.headphones,

          DynamicLanguage.isLoading
              ? ""
              : DynamicLanguage.key(Strings.contactUs),
          () => Get.to(() => WebViewScreen(title: Strings.contactUs)),
        ),
        _itemCard(
          Icons.privacy_tip_outlined,
          DynamicLanguage.isLoading
              ? ""
              : DynamicLanguage.key(Strings.privacyPolicy),
          () => Get.to(() => WebViewScreen(title: Strings.privacyPolicy)),
        ),
        _itemCard(
          Icons.info_outline,
          Strings.aboutUs,
          () => Get.to(() => WebViewScreen(title: Strings.aboutUs)),
        ),
        _itemCard(
          Icons.logout,
          Strings.logOut,
          () {
            Get.back();
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radius * 1.5),
                ),
              ),
              builder: (BuildContext context) {
                return LogoutDialog();
              },
            );
          },
          Colors.red, //
        ),
      ],
    );
  }

  _itemCard(IconData icon, String title, VoidCallback onTap, [Color? color]) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 0.5,
        ),
        leading: Icon(icon, color: color ?? CustomColor.primary),
        title: TextWidget(title),
      ),
    );
  }
}
