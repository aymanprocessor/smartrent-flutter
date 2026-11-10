import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../base/themes/token.dart';
import '../controller/notification_controller.dart';
import '../model/notification_model.dart';

enum NotificationTypeCategory {
  bookingConfirmed,
  bookingCreated,
  refund,
  paymentRejected,
  general,
}

class LogoWidget extends GetView<NotificationController> {
  final int index;
  final Notification? notificationItem;

  const LogoWidget(this.index, {this.notificationItem, super.key});

  @override
  Widget build(BuildContext context) {
    final notification = notificationItem ??
        (controller.notificationModel != null &&
                index < controller.notificationModel!.data.notification.length
            ? controller.notificationModel!.data.notification[index]
            : null);

    if (notification == null) {
      return const SizedBox.shrink();
    }

    final category = _resolveCategory(notification);
    final visual = _getVisuals(category);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Category Icon Squircle
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: visual.lightBackground,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: visual.accentColor.withValues(alpha: 0.16),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    visual.icon,
                    color: visual.accentColor,
                    size: 22.r,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Content: Title, Time & Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: Title and Timestamp
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            notification.message.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              height: 1.25,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.clock,
                              size: 11.r,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              _formatArabicDate(notification.createdAt),
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Notification Message Body
                    Text(
                      notification.message.message,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: (index * 40).clamp(0, 360)))
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }

  NotificationTypeCategory _resolveCategory(Notification notification) {
    final title = notification.message.title.toLowerCase();
    final body = notification.message.message.toLowerCase();
    final type = notification.type.toLowerCase();

    // 1. Refunds / Wallet returns
    if (title.contains('استرداد') ||
        body.contains('استرداد') ||
        body.contains('محفظتك') ||
        title.contains('refund') ||
        type.contains('refund')) {
      return NotificationTypeCategory.refund;
    }

    // 2. Payment Rejections / Warnings
    if (title.contains('رفض') ||
        title.contains('reject') ||
        type.contains('reject')) {
      return NotificationTypeCategory.paymentRejected;
    }

    // 3. Booking Confirmed
    if (title.contains('تأكيد') ||
        title.contains('مؤكد') ||
        title.contains('مقبول') ||
        type.contains('accept')) {
      return NotificationTypeCategory.bookingConfirmed;
    }

    // 4. Booking Created
    if (title.contains('إنشاء') ||
        title.contains('طلب جديد') ||
        title.contains('booking') ||
        type.contains('request')) {
      return NotificationTypeCategory.bookingCreated;
    }

    // 5. Money/Wallet updates
    if (body.contains('محفظ') ||
        body.contains('مبلغ') ||
        type.contains('money') ||
        type.contains('pay')) {
      return NotificationTypeCategory.refund;
    }

    return NotificationTypeCategory.general;
  }

  _VisualConfig _getVisuals(NotificationTypeCategory category) {
    switch (category) {
      case NotificationTypeCategory.bookingConfirmed:
        return _VisualConfig(
          accentColor: const Color(0xFF10B981), // Emerald Green
          lightBackground: const Color(0xFFECFDF5),
          icon: Iconsax.tick_circle,
        );
      case NotificationTypeCategory.bookingCreated:
        return _VisualConfig(
          accentColor: CustomColor.primary, // Deep Logo Blue
          lightBackground: const Color(0xFFEFF6FF),
          icon: Iconsax.calendar_tick,
        );
      case NotificationTypeCategory.refund:
        return _VisualConfig(
          accentColor: const Color(0xFF0284C7), // Sky Blue / Cyan
          lightBackground: const Color(0xFFF0F9FF),
          icon: Iconsax.money_recive,
        );
      case NotificationTypeCategory.paymentRejected:
        return _VisualConfig(
          accentColor: const Color(0xFFE11D48), // Rose
          lightBackground: const Color(0xFFFFF1F2),
          icon: Iconsax.close_circle,
        );
      case NotificationTypeCategory.general:
        return _VisualConfig(
          accentColor: const Color(0xFF6366F1), // Indigo
          lightBackground: const Color(0xFFEEF2FF),
          icon: Iconsax.notification,
        );
    }
  }

  String _formatArabicDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'م' : 'ص';
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    if (difference.inDays == 0 && now.day == dt.day) {
      if (difference.inMinutes < 1) return 'الآن';
      if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} د';
      return 'اليوم • $timeStr';
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != dt.day)) {
      return 'أمس • $timeStr';
    } else {
      const months = [
        '',
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ];
      final monthName = (dt.month >= 1 && dt.month <= 12)
          ? months[dt.month]
          : dt.month.toString();
      return '${dt.day} $monthName • $timeStr';
    }
  }
}

class _VisualConfig {
  final Color accentColor;
  final Color lightBackground;
  final IconData icon;

  _VisualConfig({
    required this.accentColor,
    required this.lightBackground,
    required this.icon,
  });
}
