part of '../screen/update_profile_screen.dart';

class DeleteButton extends GetView<UpdateProfileController> {
  const DeleteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: _S.x1),
      child: IconButton(
        tooltip: DynamicLanguage.key(Strings.delete),
        style: IconButton.styleFrom(
          backgroundColor: _C.white.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_R.xs),
          ),
        ),
        icon: const Icon(Icons.delete_outline_rounded,
            color: _C.white, size: 20),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(_R.lg)),
            ),
            builder: (BuildContext ctx) {
              return const DeletePop();
            },
          );
        },
      ),
    );
  }
}
