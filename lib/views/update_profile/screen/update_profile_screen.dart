import 'package:carbo/views/auth/login/controller/login_controller.dart';
import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/utils/local_storage.dart';
import '../controller/update_profile_controller.dart';
import '../widget/profile_image_picker.dart';
import '../widget/profle_input_widget.dart';

part 'update_profile_tablet_screen.dart';

part 'update_profile_mobile_screen.dart';

part '../widget/delete_pop.dart';
part '../widget/delete_button.dart';

class UpdateProfileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: UpdateProfileMobileScreen(),
      tablet: UpdateProfileTabletScreen(),
    );
  }
}
