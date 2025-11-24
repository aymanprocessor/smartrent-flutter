import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:carbo/views/wallet/widget/topup_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TopUpButtonWidget extends StatelessWidget {
  final WalletController controller;
  final BuildContext context;

  const TopUpButtonWidget({
    required this.controller,
    required this.context,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ElevatedButton.icon(
        onPressed: () => _showTopUpDialog(context),
        icon: const Icon(Icons.add),
        label: Text(
          AppLocalizations.of(context)?.appLTopUpWallet ?? '',
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 48.h),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context) {
    Get.dialog(
      TopUpDialogWidget(
        controller: controller,
        context: context,
      ),
    );
  }
}
