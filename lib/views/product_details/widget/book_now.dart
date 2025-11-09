part of '../screen/product_details_screen.dart';

class BookNow extends GetView<ProductDetailsController> {
  const BookNow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimensions.verticalSize * 0.5,
        bottom: Dimensions.verticalSize * 0.5,
        left: Dimensions.defaultHorizontalSize,
      ),
      child: Row(
        mainAxisAlignment: mainSpaceBet,
        children: [
          Column(
            crossAxisAlignment: crossStart,
            children: [
              TextWidget('\$15,499', fontWeight: FontWeight.bold),
              TextWidget(Strings.perMonth, fontSize: Dimensions.titleSmall),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: CustomColor.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radius),
                bottomLeft: Radius.circular(Dimensions.radius),
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.verticalSize * 0.3,
              horizontal: Dimensions.defaultHorizontalSize,
            ),
            child: TextWidget(Strings.bookNow, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
