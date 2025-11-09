import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbo/routes/routes.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../base/utils/basic_import.dart';
import '../controller/all_vendors_dashboard_controller.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../dashboard/model/area_has_type_model.dart';
import '../../dashboard/model/type_has_model.dart';

part 'all_vendors_dashboard_mobile_screen.dart';
part '../widget/all_vendors_filter_box.dart';
part '../widget/all_vendors_car_carousel.dart';
part '../widget/all_vendors_search_button.dart';
part '../widget/all_vendors_app_bar.dart';

class AllVendorsDashboardScreen extends GetView<AllVendorsDashboardController> {
  const AllVendorsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AllVendorsDashboardMobileScreen();
  }
}
