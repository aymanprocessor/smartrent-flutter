import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../base/utils/basic_import.dart';
import '../controller/preview_controller.dart';

class AuthorizeGatewayScreen extends StatelessWidget {
  AuthorizeGatewayScreen({super.key});

  final passwordKey = GlobalKey<FormState>();
  final controller = Get.put(PreviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(Strings.debitCardPayment),
      body: _bodyWidget(context),
    );
  }

  ListView _bodyWidget(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSize * 0.9,
      ),
      physics: const BouncingScrollPhysics(),
      children: [_inputWidget(context), _buttonWidget(context)],
    );
  }

  Form _inputWidget(BuildContext context) {
    return Form(
      key: passwordKey,
      child: Column(
        children: [
          Sizes.height.v15,
          PrimaryInputWidget(
            controller: controller.cardNumberController,
            label: Strings.cardNumber,
            hintText: "0000 0000 0000 0000",
            skipEnterText: true,
            textInputType: TextInputType.number,
            // color: CustomColor.whiteColor,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberFormatter(),
            ],
          ),
          Sizes.height.v10,
          PrimaryInputWidget(
            controller: controller.cardExpiryController,
            label: Strings.expirationDate,
            // color: CustomColor.whiteColor,
            hintText: "YY/MM",
            skipEnterText: true,
            textInputType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ExpiryDateFormatter(),
            ],
          ),
          Sizes.height.v10,
          PrimaryInputWidget(
            controller: controller.cardCVCController,
            label: Strings.cvv,
            // color: CustomColor.whiteColor,
            skipEnterText: true,

            hintText: "123",
            textInputType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Container _buttonWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Dimensions.verticalSize),
      child: Obx(
        () => controller.isAuthorizeLoading
            ? const Loader()
            : PrimaryButton(
                onPressed: () {
                  if (passwordKey.currentState!.validate()) {
                    controller.authorizeSubmitProcess();
                  }
                },
                title: Strings.confirm,
              ),
      ),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 2) {
      text = "${text.substring(0, 2)}/${text.substring(2)}";
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatted = digitsOnly.replaceAllMapped(
      RegExp(r".{1,4}"),
      (match) => "${match.group(0)} ",
    );
    return TextEditingValue(
      text: formatted.trim(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
