import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/base/widgets/empty_data_widget.dart';
import 'package:flutter/material.dart';
import '../controller/notification_controller.dart';
import '../widget/logo_widget.dart';

class NotificationMobileScreen extends GetView<NotificationController> {
  const NotificationMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(centerTitle: false, Strings.notification),
      body: Obx(() => controller.isLoading ? Loader() : _bodyWidget(context)),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: controller.notificationModel.data.notification.isNotEmpty
          ? ListView(
              padding: EdgeInsets.only(
                left: Dimensions.defaultHorizontalSize * 0.8,
                right: Dimensions.defaultHorizontalSize * 0.8,
                top: Dimensions.verticalSize * 0.5,
              ),
              children: List.generate(
                controller.notificationModel.data.notification.length,
                (index) => LogoWidget(index),
              ),
            )
          : EmptyDataWidget(massage: Strings.noNotification),
    );
  }
}
