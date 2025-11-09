import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../assets/assets.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/divider.dart';
import '../../../base/widgets/double_side_text_widget.dart';
import 'congratulations_info.dart';

class CongratulationsMain extends StatelessWidget {
  const CongratulationsMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildSuccessIcon(), const CongratulationsInfo()]);
  }

  Widget _buildDivider() {
    return DividerWidget(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.2),
    );
  }

  Widget _buildInfoRow(String key, String value) {
    return DoubleSideTextWidget(
      keys: key,
      value: value,
      valueStyle: TypographyStyle.bodyMedium,
    );
  }

  Widget _buildSuccessIcon() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.6),
      child: SvgPicture.asset(
        Assets.icons.success,
        height: Dimensions.heightSize * 12,
      ),
    );
  }
}
