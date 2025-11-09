import 'package:carbo/views/notification/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/utils/dimensions.dart';
import '../../../base/utils/size.dart';
import '../../../base/widgets/custom_app_bar.dart';
import '../../../base/widgets/primary_button.dart';
import '../../../languages/strings.dart';

class RePaymentManualField extends StatelessWidget {
  RePaymentManualField({super.key});

  final controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(Strings.paymentInstructions),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: ListView(children: [_inputsWidget(context)]),
    );
  }

  _inputsWidget(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: mainMin,
        children: [
          ...controller.inputFields.map((element) {
            return element;
          }).toList(),
          Sizes.height.btnInputTitleAndBox,
          _filePickerWidget(context),
          Sizes.height.btnInputTitleAndBox,
          _buttonWidget(context),
        ],
      ),
    );
  }

  _filePickerWidget(BuildContext context) {
    return Visibility(
      visible: controller.inputFileFields.isNotEmpty,
      child: Flexible(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 1.6,
          ),
          itemCount: controller.inputFileFields.length,
          itemBuilder: (BuildContext context, int index) {
            return controller.inputFileFields[index];
          },
        ),
      ),
    );
  }

  _buttonWidget(BuildContext context) {
    return Obx(
      () => PrimaryButton(
        title: Strings.submit,
        isLoading: controller.isRepaymentLoading,
        onPressed: () {
          controller.rePaymentProcess();
        },
      ),
    );
  }
}
