import 'package:carbo/base/utils/basic_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../controller/notification_controller.dart';
import '../widget/logo_widget.dart';

class NotificationMobileScreen extends GetView<NotificationController> {
  const NotificationMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        Strings.notification,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading && controller.notificationModel == null) {
          return const Center(child: Loader());
        }

        if (controller.hasError && controller.notificationModel == null) {
          return _errorWidget(context);
        }

        return SafeArea(
          child: RefreshIndicator(
            color: CustomColor.primary,
            backgroundColor: Colors.white,
            onRefresh: () => controller.getNotificationInfo(),
            child: Column(
              children: [
                // Filter Tab Bar
                if (controller.hasNotifications) _buildFilterBar(),

                // Notifications List or Filter Empty State
                Expanded(
                  child: _buildListOrEmpty(context),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFilterBar() {
    return Obx(() {
      final currentFilter = controller.selectedFilter.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 0.8,
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _filterChip(
                label: 'الكل',
                count: controller.allCount,
                isSelected: currentFilter == 'all',
                onTap: () => controller.setFilter('all'),
              ),
              SizedBox(width: 8.w),
              _filterChip(
                label: 'الحجوزات',
                count: controller.bookingsCount,
                isSelected: currentFilter == 'bookings',
                onTap: () => controller.setFilter('bookings'),
              ),
              SizedBox(width: 8.w),
              _filterChip(
                label: 'المالية والمحفظة',
                count: controller.financeCount,
                isSelected: currentFilter == 'finance',
                onTap: () => controller.setFilter('finance'),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _filterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? CustomColor.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? CustomColor.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : CustomColor.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListOrEmpty(BuildContext context) {
    if (!controller.hasNotifications) {
      return _buildEmptyState(
        title: 'لا توجد إشعارات حتى الآن',
        subtitle:
            'سنرسل لك إشعاراً فور تأكيد حجزك أو عند وجود أي تحديث جديد على حسابك.',
      );
    }

    final notifications = controller.filteredNotifications;

    if (notifications.isEmpty) {
      return _buildEmptyState(
        title: 'لا توجد إشعارات في هذا التصنيف',
        subtitle: 'جرّب الانتقال إلى تصنيف آخر لعرض إشعاراتك.',
        showAction: true,
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return LogoWidget(
          index,
          notificationItem: notifications[index],
        );
      },
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    bool showAction = false,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84.r,
                height: 84.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.primary.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Icon(
                    Iconsax.notification_1,
                    size: 40.r,
                    color: CustomColor.primary,
                  ),
                ),
              ).animate().scale(
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
              SizedBox(height: 20.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ),
              if (showAction) ...[
                SizedBox(height: 20.h),
                OutlinedButton.icon(
                  onPressed: () => controller.setFilter('all'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomColor.primary,
                    side: BorderSide(color: CustomColor.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 8.h,
                    ),
                  ),
                  icon: Icon(Iconsax.refresh, size: 16.r),
                  label: const Text('عرض كل الإشعارات'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF1F2),
              ),
              child: Icon(
                Iconsax.info_circle,
                size: 36.r,
                color: const Color(0xFFE11D48),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'تعذر تحميل الإشعارات',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => controller.getNotificationInfo(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              ),
              icon: Icon(Iconsax.refresh, size: 18.r),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
