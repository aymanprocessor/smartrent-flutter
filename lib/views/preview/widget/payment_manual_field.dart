part of '../screen/preview_screen.dart';

class PaymentManualField extends StatelessWidget {
  PaymentManualField({super.key});

  final controller = Get.put(PreviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(Strings.paymentInstructions),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _bodyWidget(context),
          Obx(() => controller.isBookingLoading ? Loader() : const SizedBox()),
        ],
      ),
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
          if (controller.isBookingLoading == false) _buttonWidget(context),
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
    return Center(
      child: PrimaryButton(
        title: Strings.submit,
        onPressed: () {
          controller.bookingManualProcess();
        },
      ),
    );
  }
}
