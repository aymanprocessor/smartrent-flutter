part of 'update_profile_screen.dart';

class UpdateProfileMobileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(LocalStorage.userCountryCode);
    print('----------------------------------------------------------');
    print(controller.countrySelectMethod);
    return Scaffold(
      bottomNavigationBar: controller.isUpdateLoading
          ? Loader()
          : (controller.isLoading ? null : _buttonWidget(context)),
      appBar: CustomAppBar(
        centerTitle: false,
        action: [DeleteButton()],
        Strings.editProfile,
      ),
      body: controller.isLoading ? Loader() : _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        children: [ProfileImagePicker(), ProfileInputWidget()],
      ),
    );
  }

  _buttonWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize,
      ),
      child: Obx(
        () => PrimaryButton(
          title: Strings.update,
          disable: false,
          isLoading: controller.isUpdateLoading,
          onPressed: () {
            controller.updateProfile();
          },
        ),
      ),
    );
  }
}
