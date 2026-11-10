import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/models/wallet_transaction.dart';
import 'transaction_detail_sheet.dart';

class TransactionsSection extends StatelessWidget {
  final WalletController controller;

  const TransactionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 32.h),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            SizedBox(height: 12.h),
            _buildFilterTabs(context),
            SizedBox(height: 16.h),
            Obx(() => _buildTransactionsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'المعاملات الأخيرة',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: 8.w),
            Obx(() {
              final count = controller.filteredTransactions.length;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              );
            }),
          ],
        ),
        Obx(() {
          if (controller.isRefreshing.value) {
            return SizedBox(
              width: 18.w,
              height: 18.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF0B5FA5)),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final filters = [
      {'id': 'all', 'label': 'الكل'},
      {'id': 'topup', 'label': 'شحن'},
      {'id': 'debit', 'label': 'مدفوعات'},
      {'id': 'refund', 'label': 'استرداد'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Obx(() {
        final currentFilter = controller.selectedFilter.value;
        return Row(
          children: filters.map((f) {
            final isSelected = currentFilter == f['id'];
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.setFilter(f['id']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0B5FA5) : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0B5FA5)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0B5FA5).withOpacity(0.24),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    f['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    if (controller.isLoadingTransactions.value && controller.transactions.isEmpty) {
      return _buildLoadingState();
    }

    final txList = controller.filteredTransactions;

    if (txList.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txList.length + (controller.hasMore.value ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        if (index == txList.length) {
          return _buildLoadMoreButton(context);
        }

        return _TransactionCard(
          transaction: txList[index],
          index: index,
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 10.h),
          height: 76.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 30.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'لا توجد معاملات بعد',
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'ستظهر جميع عمليات الشحن والمدفوعات والمستردات هنا',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: TextButton.icon(
          onPressed: () => controller.fetchTransactions(loadMore: true),
          icon: Icon(
            Icons.expand_more_rounded,
            color: const Color(0xFF0B5FA5),
            size: 18.sp,
          ),
          label: Text(
            'تحميل المزيد',
            style: TextStyle(
              color: const Color(0xFF0B5FA5),
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionParsedInfo {
  final String title;
  final String? bookingId;
  final bool isCredit;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  _TransactionParsedInfo({
    required this.title,
    this.bookingId,
    required this.isCredit,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  final int index;

  const _TransactionCard({
    required this.transaction,
    required this.index,
  });

  _TransactionParsedInfo _parseInfo(BuildContext context) {
    final desc = transaction.description?.trim() ?? '';

    // Regex to extract booking number (e.g., 245683)
    final bookingRegex = RegExp(r'(\d{4,})');
    final match = bookingRegex.firstMatch(desc);
    final bookingId = match != null ? match.group(1) : null;

    if (transaction.type == WalletTransactionType.refundWallet ||
        transaction.type == WalletTransactionType.refundCard) {
      final refundTitle = bookingId != null
          ? 'استرداد حجز #$bookingId'
          : 'استرداد للمحفظة';
      return _TransactionParsedInfo(
        title: refundTitle,
        bookingId: bookingId,
        isCredit: true,
        icon: Icons.replay_rounded,
        iconColor: const Color(0xFFEA580C),
        iconBgColor: const Color(0xFFFFF7ED),
      );
    }

    if (transaction.type == WalletTransactionType.topup) {
      return _TransactionParsedInfo(
        title: 'شحن المحفظة',
        bookingId: null,
        isCredit: true,
        icon: Icons.arrow_downward_rounded,
        iconColor: const Color(0xFF059669),
        iconBgColor: const Color(0xFFECFDF5),
      );
    }

    if (transaction.type == WalletTransactionType.debit) {
      final debitTitle = bookingId != null
          ? 'حجز سيارة #$bookingId'
          : 'دفع حجز';
      return _TransactionParsedInfo(
        title: debitTitle,
        bookingId: bookingId,
        isCredit: false,
        icon: Icons.directions_car_rounded,
        iconColor: const Color(0xFF2563EB),
        iconBgColor: const Color(0xFFEFF6FF),
      );
    }

    return _TransactionParsedInfo(
      title: desc.isNotEmpty ? desc : 'معاملة مالية',
      bookingId: bookingId,
      isCredit: false,
      icon: Icons.receipt_rounded,
      iconColor: const Color(0xFF475569),
      iconBgColor: const Color(0xFFF1F5F9),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _parseInfo(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final currencyDisplay = isRtl ? 'ر.س' : transaction.currency;

    // Clean date and legible time format
    final dateStr = DateFormat('MMM dd', 'ar').format(transaction.createdAt);
    final timeStr = DateFormat('HH:mm').format(transaction.createdAt);
    final formattedDate = '$dateStr • $timeStr';

    final delay = (index < 8 ? index * 45 : 360);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 320 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showDetailSheet(context, info);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Clean Squircle Icon
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: info.iconBgColor,
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Center(
                    child: Icon(
                      info.icon,
                      color: info.iconColor,
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Title and Date (Concise & Clear)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Amount and Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${info.isCredit ? '+' : '-'}${transaction.amount} $currencyDisplay',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: info.isCredit
                            ? const Color(0xFF059669)
                            : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    _buildMiniStatusBadge(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatusBadge() {
    Color bg;
    Color fg;
    String text;

    switch (transaction.status) {
      case WalletTransactionStatus.completed:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        text = 'مكتمل';
        break;
      case WalletTransactionStatus.pending:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        text = 'قيد الانتظار';
        break;
      case WalletTransactionStatus.failed:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        text = 'فشل';
        break;
      case WalletTransactionStatus.cancelled:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        text = 'ملغي';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, _TransactionParsedInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(
        transaction: transaction,
        title: info.title,
        bookingId: info.bookingId,
        isCredit: info.isCredit,
        icon: info.icon,
        iconColor: info.iconColor,
        iconBgColor: info.iconBgColor,
      ),
    );
  }
}
