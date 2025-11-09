import 'package:carbo/base/api/services/basic_services.dart';
import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/dynamic_image_widget.dart';
import '../controller/preview_controller.dart';
import '../model/booking_preview_model.dart';
import '../model/manual_input_model.dart';
part 'preview_tablet_screen.dart';
part 'preview_mobile_screen.dart';
part '../widget/preview_section_card.dart';
part '../widget/payment_selection_widget.dart';
part '../widget/get_manual_dynamic_input_field.dart';
part '../widget/payment_manual_field.dart';

class PreviewScreen extends GetView<PreviewController> {
  const PreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: PreviewMobileScreen(),
      tablet: PreviewTabletScreen(),
    );
  }
}
