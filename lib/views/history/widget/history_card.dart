part of '../screen/history_screen.dart';

class HistoryCard extends GetView<HistoryController> {
  final int index;

  const HistoryCard(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final info = controller.historyList[index];
    return Obx(
      () => Card(
        margin: EdgeInsets.symmetric(
          vertical: Dimensions.verticalSize * 0.2,
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        elevation: 0,
        child: Column(
          children: [
            ListTile(
              title: TextWidget(
                info.cars.carModel ?? '-',
                typographyStyle: TypographyStyle.titleMedium,
              ),
              subtitle: Row(
                children: [
                  CircleAvatar(
                    radius: Dimensions.radius * 0.3,
                    backgroundColor: info.status == 1
                        ? Colors.orange
                        : info.status == 2
                        ? Colors.blue
                        : info.status == 3
                        ? CustomColor.primary
                        : CustomColor.rejected,
                  ),
                  Sizes.width.v5,
                  TextWidget(
                    info.status == 1
                        ? Strings.pending
                        : info.status == 2
                        ? Strings.ongoing
                        : info.status == 3
                        ? Strings.complete
                        : Strings.reject,
                    typographyStyle: TypographyStyle.labelMedium,
                  ),
                ],
              ),
              trailing: TextWidget(
                info.pickupDate.toString().substring(0, 11),
                // info.pickupDate.toString(),
                typographyStyle: TypographyStyle.bodySmall,
                color: CustomColor.primary,
                fontWeight: FontWeight.w700,
              ),
              onTap: () => controller.toggleCardExpansion(index),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.isExpanded[index].value ? h * 0.3 : 0,
              child: ExpandedCardInfo(index),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
  }
}
