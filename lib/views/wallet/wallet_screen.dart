import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:carbo/models/wallet_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appLMyWallet ?? 'My Wallet'),
        elevation: 0,
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              // Balance Cards Section
              SliverToBoxAdapter(
                child: _buildBalanceSection(controller),
              ),

              // Top-up Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: ElevatedButton.icon(
                    onPressed: () => _showTopUpDialog(context, controller),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)?.appLTopUpWallet ?? 'Top Up Wallet'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48.h),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

              // Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.appLRecentTransactions ?? 'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (controller.isRefreshing.value)
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),

              // Transactions List or Loading/Error States
              if (controller.isLoadingTransactions.value && controller.transactions.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(AppLocalizations.of(context)?.appLLoadingTransactions ?? 'Loading transactions...'),
                      ],
                    ),
                  ),
                )
              else if (controller.error.value.isNotEmpty && controller.transactions.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
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
                          child: Text(AppLocalizations.of(Get.context!)?.appLRetry ?? 'Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (controller.transactions.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48.sp, color: Colors.grey),
                        SizedBox(height: 16.h),
                        Text(AppLocalizations.of(context)?.appLNoTransactions ?? 'No transactions yet'),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == controller.transactions.length) {
                        // Load more indicator
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
                      return _buildTransactionItem(transaction);
                    },
                    childCount: controller.transactions.length + 
                        (controller.hasMore.value ? 1 : 0),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection(WalletController controller) {
    if (controller.isLoadingBalance.value && controller.balances.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (controller.balances.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: Column(
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 48.sp, color: Colors.grey),
                SizedBox(height: 8.h),
                Text(AppLocalizations.of(Get.context!)?.appLNoWalletBalance ?? 'No wallet balance available'),
              ],
            ),
          ),
        ),
      );
    }

    // Display only default currency (SAR)
    final defaultCurrency = 'SAR';
    final defaultBalance = controller.balances.firstWhereOrNull(
      (b) => b.currency == defaultCurrency,
    ) ?? controller.balances.first; // Fallback to first if SAR not found

    final displayBalance = controller.getBalanceForCurrency(defaultBalance.currency);
    final hasOptimisticChange = 
        controller.optimisticBalanceChanges.containsKey(defaultBalance.currency);

    return SizedBox(
      height: 160.h,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        elevation: 4,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(Get.context!).primaryColor,
                Theme.of(Get.context!).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    defaultBalance.currency,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white.withOpacity(0.8),
                    size: 24.sp,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(Get.context!)?.appLAvailableBalance ?? 'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        displayBalance.toStringAsFixed(2),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasOptimisticChange)
                        Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: Tooltip(
                            message: 'Processing...',
                            child: Icon(
                              Icons.pending,
                              color: Colors.amber,
                              size: 16.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransaction transaction) {
    final isCredit = transaction.type == WalletTransactionType.topup ||
        transaction.type == WalletTransactionType.refundWallet;
    final icon = _getTransactionIcon(transaction.type);
    final color = _getTransactionColor(transaction.type);
    final statusColor = _getStatusColor(transaction.status);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        title: Text(
          _getTransactionTitle(transaction.type),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null)
              Text(
                transaction.description!,
                style: TextStyle(fontSize: 12.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 2.h),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}${transaction.amount} ${transaction.currency}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                transaction.status.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return Icons.add_circle;
      case WalletTransactionType.debit:
        return Icons.remove_circle;
      case WalletTransactionType.refundWallet:
      case WalletTransactionType.refundCard:
        return Icons.replay;
    }
  }

  Color _getTransactionColor(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return Colors.green;
      case WalletTransactionType.debit:
        return Colors.red;
      case WalletTransactionType.refundWallet:
      case WalletTransactionType.refundCard:
        return Colors.blue;
    }
  }

  Color _getStatusColor(WalletTransactionStatus status) {
    switch (status) {
      case WalletTransactionStatus.completed:
        return Colors.green;
      case WalletTransactionStatus.pending:
        return Colors.orange;
      case WalletTransactionStatus.failed:
        return Colors.red;
      case WalletTransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getTransactionTitle(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return 'Top Up';
      case WalletTransactionType.debit:
        return 'Payment';
      case WalletTransactionType.refundWallet:
        return 'Refund to Wallet';
      case WalletTransactionType.refundCard:
        return 'Refund to Card';
    }
  }

  void _showTopUpDialog(BuildContext context, WalletController controller) {
    final amountController = TextEditingController();
    final selectedCurrency = 'SAR'.obs;
    final availableCurrencies = ['SAR', 'USD', 'EGP'];
    final useTestTopUp = false.obs;
    final l10n = AppLocalizations.of(context);

    Get.dialog(
      AlertDialog(
        title: Text(l10n?.appLTopUpWallet ?? 'Top Up Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n?.appLAmount ?? 'Amount',
                hintText: l10n?.appLEnterAmount ?? 'Enter amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedCurrency.value,
                decoration: InputDecoration(
                  labelText: l10n?.appLCurrency ?? 'Currency',
                  border: const OutlineInputBorder(),
                ),
                items: availableCurrencies
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedCurrency.value = value;
                },
              ),
            ),
            SizedBox(height: 8.h),
            // Show test-topup option only in debug mode
            if (kDebugMode)
              Obx(
                () => CheckboxListTile(
                  value: useTestTopUp.value,
                  onChanged: (v) => useTestTopUp.value = v ?? false,
                  title: const Text('Use test top-up (QA only)'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.appLCancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = amountController.text.trim();
              if (amount.isEmpty || double.tryParse(amount) == null) {
                Get.snackbar('Error', 'Please enter a valid amount');
                return;
              }

              Get.back(); // Close dialog

              if (useTestTopUp.value) {
                // Call test top-up (immediately credits wallet)
                final result = await controller.initiateTopUpTest(
                  amount: amount,
                  currency: selectedCurrency.value,
                );

                if (result != null) {
                  // already refreshed in controller; show additional feedback
                  Get.snackbar(
                    l10n?.appLTopUpSuccess ?? 'Wallet top-up successful!',
                    '${result['amount']} ${result['currency']} credited',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              } else {
                final result = await controller.initiateTopUp(
                  amount: amount,
                  currency: selectedCurrency.value,
                );

                if (result != null) {
                  // Open PayTabs payment page
                  _openPayTabsPayment(
                    result['payment_url'],
                    result['wallet_transaction_id'],
                    controller,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.appLYesContinue ?? 'Continue'),
          ),
        ],
      ),
    );
  }

  void _openPayTabsPayment(
    String paymentUrl,
    int transactionId,
    WalletController controller,
  ) {
    // Navigate to PayTabs payment screen (using existing infrastructure)
    // After return, start polling
    Get.toNamed(
      '/paytabs-payment',
      arguments: {'url': paymentUrl},
    )?.then((_) {
      // Start polling after user returns from payment
      controller.startPollingTransaction(transactionId);
    });
  }
}
