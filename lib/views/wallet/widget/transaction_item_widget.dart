import 'package:carbo/models/wallet_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TransactionItemWidget extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionItemWidget({
    required this.transaction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
              DateFormat('MMM dd, yyyy • hh:mm aa').format(transaction.createdAt),
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
}
