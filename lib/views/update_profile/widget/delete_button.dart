part of '../screen/update_profile_screen.dart';

class DeleteButton extends GetView<UpdateProfileController> {
  const DeleteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.radius * 1.5),
            ),
          ),
          builder: (BuildContext context) {
            return DeletePop();
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 0.8,
          vertical: Dimensions.verticalSize * 0.2,
        ),
        child: TextWidget(
          Strings.delete,
          fontSize: Dimensions.titleSmall * 0.9,
          fontWeight: FontWeight.w500,
          color: CustomColor.whiteColor,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
        ),
      ),
    );
  }
}
