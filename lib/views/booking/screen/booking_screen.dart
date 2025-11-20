import 'package:carbo/routes/routes.dart';
import 'package:flutter/material.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/custom_date_picker.dart';
import '../../../base/widgets/custom_time_picker.dart';
import '../controller/booking_controller.dart';
part 'booking_tablet_screen.dart';
part 'booking_mobile_screen.dart';
part '../widget/booking_all_fields.dart';

class BookingScreen extends GetView<BookingController> {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: BookingMobileScreen(),
      tablet: BookingTabletScreen(),
    );
  }
}
