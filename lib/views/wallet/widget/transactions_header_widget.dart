import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TransactionsHeaderWidget extends StatelessWidget {
  final WalletController controller;

  const TransactionsHeaderWidget({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)?.appLRecentTransactions ??
                'Recent Transactions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Obx(
            () {
              if (controller.isRefreshing.value) {
                return SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
