import 'package:carbo/base/widgets/custom_time_picker.dart';
import 'package:carbo/routes/routes.dart';
import 'package:dynamic_languages/dynamic_languages.dart';
import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/custom_date_picker.dart';
import '../controller/booking_controller.dart';
part 'booking_tablet_screen.dart';
part 'booking_mobile_screen.dart';
part '../widget/booking_all_fields.dart';
part '../widget/round_trip_check.dart';

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
