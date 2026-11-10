import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:carbo/models/wallet_transaction.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';

class TransactionDetailSheet extends StatelessWidget {
  final WalletTransaction transaction;
  final String title;
  final String? bookingId;
  final bool isCredit;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.title,
    this.bookingId,
    required this.isCredit,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final currencyDisplay = isRtl ? 'ر.س' : transaction.currency;

    final formattedAmount =
        '${isCredit ? '+' : '-'}${transaction.amount} $currencyDisplay';
    final dateStr =
        DateFormat('dd MMMM yyyy', isRtl ? 'ar' : 'en').format(transaction.createdAt);
    final timeStr = DateFormat('hh:mm a', isRtl ? 'ar' : 'en').format(transaction.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 22.h),

          // Icon
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 30.sp),
          ),
          SizedBox(height: 14.h),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),

          // Amount
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: isCredit ? const Color(0xFF059669) : const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 10.h),

          // Status Badge
          _buildStatusBadge(context),
          SizedBox(height: 24.h),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
          SizedBox(height: 18.h),

          // Info Rows
          _buildInfoRow(
            label: l10n?.appLTransactionId ?? 'معرّف المعاملة',
            value: '#TRX-${transaction.id}',
            canCopy: true,
            context: context,
          ),
          if (bookingId != null) ...[
            SizedBox(height: 12.h),
            _buildInfoRow(
              label: 'رقم الحجز',
              value: '#$bookingId',
              canCopy: true,
              context: context,
            ),
          ],
          SizedBox(height: 12.h),
          _buildInfoRow(
            label: l10n?.appLTransactionDate ?? 'التاريخ والوقت',
            value: '$dateStr • $timeStr',
          ),
          if (transaction.balanceBefore != null && transaction.balanceBefore!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _buildInfoRow(
              label: 'الرصيد قبل العملية',
              value: '${transaction.balanceBefore} $currencyDisplay',
            ),
          ],
          if (transaction.balanceAfter != null && transaction.balanceAfter!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _buildInfoRow(
              label: 'الرصيد بعد العملية',
              value: '${transaction.balanceAfter} $currencyDisplay',
            ),
          ],
          if (transaction.description != null &&
              transaction.description!.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            _buildDescriptionBox(transaction.description!.trim()),
          ],

          SizedBox(height: 24.h),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF334155),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'إغلاق',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color bg;
    Color fg;
    String text;

    switch (transaction.status) {
      case WalletTransactionStatus.completed:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        text = 'مكتمل بنجاح';
        break;
      case WalletTransactionStatus.pending:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        text = 'قيد المعالجة';
        break;
      case WalletTransactionStatus.failed:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        text = 'فشلت المعاملة';
        break;
      case WalletTransactionStatus.cancelled:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        text = 'ملغية';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            transaction.status == WalletTransactionStatus.completed
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            size: 14.sp,
            color: fg,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool canCopy = false,
    BuildContext? context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (canCopy && context != null) ...[
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value.replaceAll('#', '')));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم النسخ'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 14.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionBox(String desc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل المعاملة:',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF334155),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
