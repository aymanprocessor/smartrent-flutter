import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:carbo/views/wallet/widget/transaction_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TransactionsListWidget extends StatelessWidget {
  final WalletController controller;

  const TransactionsListWidget({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.isLoadingTransactions.value &&
            controller.transactions.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.error.value.isNotEmpty &&
            controller.transactions.isEmpty) {
          return _buildErrorState(context);
        }

        if (controller.transactions.isEmpty) {
          return _buildEmptyState(context);
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == controller.transactions.length) {
                if (controller.hasMore.value) {
                  controller.fetchTransactions(loadMore: true);
                  return Padding(
                    padding: EdgeInsets.all(16.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink();
              }

              final transaction = controller.transactions[index];
              return TransactionItemWidget(transaction: transaction);
            },
            childCount: controller.transactions.length +
                (controller.hasMore.value ? 1 : 0),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)?.appLLoadingTransactions ??
                  'Loading transactions...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              controller.error.value,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: controller.refresh,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(Get.context!)?.appLRetry ?? 'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 48.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)?.appLNoTransactions ??
                  'No transactions yet',
            ),
          ],
        ),
      ),
    );
  }
}
