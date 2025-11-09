part of 'update_profile_screen.dart';

class UpdateProfileTabletScreen extends GetView<UpdateProfileController> {
  const UpdateProfileTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('UpdateProfile Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
