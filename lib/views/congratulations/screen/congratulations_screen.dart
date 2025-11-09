import 'package:flutter/material.dart';

import '../../../base/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../widget/congratulations_button.dart';
import '../widget/congratulations_image.dart';

part 'congratulations_mobile_screen.dart';
part 'congratulations_tablet_screen.dart';

class CongratulationsScreen extends StatelessWidget {
  CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: CongratulationsMobileScreen(),
      tablet: CongratulationsTabletScreen(),
    );
  }
}
