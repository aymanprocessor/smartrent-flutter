import 'package:carbo/base/api/services/basic_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/empty_data_widget.dart';
import '../controller/history_controller.dart';
part 'history_tablet_screen.dart';
part 'history_mobile_screen.dart';
part '../widget/expanded_card_info.dart';
part '../widget/expandable_card.dart';
part '../widget/history_card.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: HistoryMobileScreen(),
      tablet: HistoryTabletScreen(),
    );
  }
}
