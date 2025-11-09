part of '../screen/preview_screen.dart';

class PaymentSelectionWidget extends GetView<PreviewController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            padding: EdgeInsets.only(
              top: Dimensions.verticalSize * 0.5,
              bottom: Dimensions.verticalSize * 0.2,
            ),
            Strings.payWIth,
            fontWeight: FontWeight.bold,
          ),

          // Cash Payment Option
          GestureDetector(
            onTap: () {
              controller.changePaymentMethod(0);
              print(controller.selectedMethodText);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultHorizontalSize,
                vertical: Dimensions.verticalSize * 0.4,
              ),
              decoration: BoxDecoration(
                color: controller.selectedMethod.value == 0
                    ? CustomColor.primary
                    : CustomColor.whiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CustomColor.primary, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.selectedMethod.value == 0
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: controller.selectedMethod.value == 0
                        ? CustomColor.whiteColor
                        : CustomColor.primary,
                  ),
                  Sizes.width.v10,
                  TextWidget(
                    Strings.cashPayment,
                    color: controller.selectedMethod.value == 0
                        ? CustomColor.whiteColor
                        : CustomColor.primary,
                  ),
                ],
              ),
            ),
          ),

          Sizes.height.v10,
          GestureDetector(
            onTap: () {
              controller.changePaymentMethod(1);
              print(controller.selectedMethodText);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultHorizontalSize,
                vertical: Dimensions.verticalSize * 0.4,
              ),
              decoration: BoxDecoration(
                color: controller.selectedMethod.value == 1
                    ? CustomColor.primary
                    : CustomColor.whiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CustomColor.primary, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.selectedMethod.value == 1
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: controller.selectedMethod.value == 1
                        ? CustomColor.whiteColor
                        : CustomColor.primary,
                  ),
                  Sizes.width.v10,
                  TextWidget(
                    Strings.onlinePayment,
                    color: controller.selectedMethod.value == 1
                        ? CustomColor.whiteColor
                        : CustomColor.primary,
                  ),
                ],
              ),
            ),
          ),
          Sizes.height.v10,
          Obx(
            () => Column(
              children: [
                if (controller.selectedMethod.value == 1) ...[
                  CustomDropDown<PaymentGateway>(
                    decoration: BoxDecoration(
                      color: CustomColor.whiteColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radius * 0.6,
                      ),
                    ),
                    itemsList: controller.paymentGatewayList,
                    selectMethod: RxString(Strings.selectMethod),
                    onChanged: (v) {
                      controller.selectPaymentGateway.value = v!;
                      controller.paymentTypes.value = v.type;
                      controller.currencyList.clear();
                      v.currencies.forEach((v) {
                        controller.currencyList.add(
                          Currency(
                            id: v.id,
                            name: v.name,
                            updatedAt: v.updatedAt,
                            createdAt: v.createdAt,
                            image: v.image,
                            alias: v.alias,
                            currencyCode: v.currencyCode,
                            currencySymbol: v.currencySymbol,
                            fixedCharge: v.fixedCharge,
                            maxLimit: v.maxLimit,
                            minLimit: v.maxLimit,
                            paymentGatewayId: v.paymentGatewayId,
                            percentCharge: v.percentCharge,
                            rate: v.rate,
                          ),
                        );
                      });
                    },
                  ),
                  Sizes.height.v10,
                  CustomDropDown<Currency>(
                    decoration: BoxDecoration(
                      color: CustomColor.whiteColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radius * 0.6,
                      ),
                    ),
                    itemsList: controller.currencyList,
                    selectMethod: RxString(Strings.selectCurrency),
                    onChanged: (v) {
                      controller.selectedCurrency.value = v!;
                      controller.alias.value = v.alias;
                      controller.currencyName.value = v.name;
                      print(controller.alias.value);
                      controller.exRent.value = v.rate.toDouble();
                      controller.percentCharge.value = v.percentCharge
                          .toDouble();
                      controller.fixeCharge.value = v.fixedCharge.toDouble();
                      controller.calculateAllCharges();
                    },
                  ),
                  Sizes.height.v10,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
