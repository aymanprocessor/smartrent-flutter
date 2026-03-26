part of '../screen/update_profile_screen.dart';

class DeletePop extends GetView<UpdateProfileController> {
  const DeletePop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(_R.lg)),
      ),
      padding: const EdgeInsets.fromLTRB(_S.x3, _S.x2, _S.x3, _S.x4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _C.border,
              borderRadius: BorderRadius.circular(_R.full),
            ),
          ),
          const SizedBox(height: _S.x3),
          // Warning icon
          Container(
            padding: const EdgeInsets.all(_S.x2),
            decoration: BoxDecoration(
              color: _C.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                size: 32, color: _C.error),
          ),
          const SizedBox(height: _S.x2),
          Text(
            DynamicLanguage.key(Strings.delete),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: _S.x1),
          Text(
            DynamicLanguage.key(Strings.areYouSureDelete),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: _C.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: _S.x3),
          PrimaryButton(
            title: Strings.cancel,
            onPressed: () {
              Navigator.pop(context);
            },
            buttonColor: _C.surfaceMuted,
            borderColor: _C.surfaceMuted,
            buttonTextColor: _C.textPrimary,
          ),
          const SizedBox(height: _S.x1h),
          Obx(
            () => PrimaryButton(
              title: Strings.delete,
              isLoading: Get.put(LoginController()).isLoading,
              onPressed: () {
                Get.put(LoginController()).deleteAccountProcess();
              },
              buttonColor: _C.error,
              borderColor: _C.error,
            ),
          ),
        ],
      ),
    );
  }
}
