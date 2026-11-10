import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/themes/token.dart';
import '../../../base/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../controller/kyc_submission_controller.dart';
import '../widget/document_image_picker_widget.dart';

class KycSubmissionScreen extends StatelessWidget {
  const KycSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: KycSubmissionMobileScreen(),
      tablet: KycSubmissionMobileScreen(),
    );
  }
}

class KycSubmissionMobileScreen extends StatelessWidget {
  const KycSubmissionMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<KycSubmissionController>()
        ? Get.find<KycSubmissionController>()
        : Get.put(KycSubmissionController());

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Get.offAllNamed(Routes.dashboardScreen);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(context),
        body: Obx(() {
          if (controller.isFetching.value) {
            return Center(
              child: CircularProgressIndicator(
                color: CustomColor.primary,
                strokeWidth: 2.5,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Status & Progress Card
                _buildHeroCard(context, controller),
                const SizedBox(height: 18),

                // Section Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المستندات المطلوبة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${controller.completedCount} من 2 مكتمل',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: controller.isAllCompleted
                                ? const Color(0xFF059669)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // National ID Card
                Obx(
                  () => DocumentImagePicker(
                    title: DynamicLanguage.key(Strings.nationalId),
                    subtitle: 'صورة واضحة للهوية الوطنية أو الإقامة الأصلية',
                    icon: Icons.badge_rounded,
                    imageUrl: controller.existingNationalIdUrl.value.isNotEmpty
                        ? controller.existingNationalIdUrl.value
                        : null,
                    imagePath: controller.nationalIdFile.value?.path,
                    isRequired: controller.pendingCar != null,
                    onPickFromCamera: () =>
                        controller.pickNationalId(ImageSource.camera),
                    onPickFromGallery: () =>
                        controller.pickNationalId(ImageSource.gallery),
                    onRemove: controller.removeNationalId,
                  ),
                ),

                // Driving License Card
                Obx(
                  () => DocumentImagePicker(
                    title: DynamicLanguage.key(Strings.drivingLicense),
                    subtitle: 'صورة واضحة لرخصة القيادة سارية المفعول',
                    icon: Icons.drive_eta_rounded,
                    imageUrl:
                        controller.existingDrivingLicenseUrl.value.isNotEmpty
                            ? controller.existingDrivingLicenseUrl.value
                            : null,
                    imagePath: controller.drivingLicenseFile.value?.path,
                    isRequired: controller.pendingCar != null,
                    onPickFromCamera: () =>
                        controller.pickDrivingLicense(ImageSource.camera),
                    onPickFromGallery: () =>
                        controller.pickDrivingLicense(ImageSource.gallery),
                    onRemove: controller.removeDrivingLicense,
                  ),
                ),

                const SizedBox(height: 6),

                // Security & Privacy Trust Card
                _buildSecurityTrustCard(),
                const SizedBox(height: 12),
              ],
            ),
          );
        }),
        bottomNavigationBar: _buildStickyBottomCta(controller),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFF8FAFC),
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Get.offAllNamed(Routes.dashboardScreen);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF1E293B),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        DynamicLanguage.key(Strings.requiredDocuments),
        style: const TextStyle(
          fontSize: 17,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showPhotoTipsModal(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: CustomColor.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(
      BuildContext context, KycSubmissionController controller) {
    final isPendingBooking = controller.pendingCar != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            CustomColor.primary,
            const Color(0xFF063A66),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColor.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Pill Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPendingBooking
                      ? Icons.directions_car_filled_rounded
                      : Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  isPendingBooking
                      ? (controller.pendingCarName != null
                          ? 'حجز: ${controller.pendingCarName}'
                          : 'خطوة أخيرة لحجز سيارتك')
                      : 'توثيق الحساب لمرة واحدة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main Header Text
          Text(
            isPendingBooking
                ? 'يرجى تأكيد مستنداتك لإتمام الحجز'
                : 'توثيق المستندات الرسمية',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle Text
          Text(
            isPendingBooking
                ? 'وفقاً للأنظمة، يجب توفر صورة سارية للهوية ورخصة القيادة لتأكيد حجز سيارتك فوراً.'
                : 'تُحفظ مستنداتك بأمان لتتمكن من حجز أي سيارة مستقبلاً بنقرة واحدة ودون انتظار.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Steps Overview Row
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _stepBadge(
                    label: 'الهوية الوطنية',
                    isDone: controller.hasNationalId,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => _stepBadge(
                    label: 'رخصة القيادة',
                    isDone: controller.hasDrivingLicense,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Animated Progress Bar
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: controller.progressRatio,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF34D399),
                ),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBadge({required String label, required bool isDone}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF10B981).withOpacity(0.25)
            : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone
              ? const Color(0xFF34D399).withOpacity(0.5)
              : Colors.white.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: isDone ? const Color(0xFF34D399) : Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDone ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTrustCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF059669),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أمان وخصوصية تامة',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'بياناتك مشفرة ومحمية وفق أعلى معايير الأمان، ولا تُستخدم إلا لإصدار وتوثيق عقود التأجير الرسمية.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomCta(KycSubmissionController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isSubmitting = controller.isLoading.value;
          final isPending =
              controller.pendingCar != null && controller.isAllCompleted;

          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : controller.submitDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.primary,
                disabledBackgroundColor: CustomColor.primary.withOpacity(0.6),
                elevation: 3,
                shadowColor: CustomColor.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isPending
                              ? Icons.arrow_forward_rounded
                              : Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DynamicLanguage.key(
                            isPending
                                ? Strings.saveAndProceed
                                : Strings.update,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),
      ),
    );
  }

  void _showPhotoTipsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'إرشادات تصوير المستندات',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _tipItem(
                icon: Icons.wb_sunny_outlined,
                title: 'إضاءة واضحة ومناسبة',
                description:
                    'تأكد من التقاط الصورة في مكان مضاء جيداً وتجنب انعكاس الفلاش المباشر على الأرقام.',
              ),
              const SizedBox(height: 12),
              _tipItem(
                icon: Icons.crop_free_rounded,
                title: 'ظهور حواف البطاقة كاملة',
                description:
                    'احرص على أن تكون زوايا البطاقة الأربع واضحة داخل إطار الصورة دون اقتطاع.',
              ),
              const SizedBox(height: 12),
              _tipItem(
                icon: Icons.event_available_rounded,
                title: 'سريان الصلاحية والوضوح',
                description:
                    'تأكد من أن الهوية ورخصة القيادة غير منتهية الصلاحية وأن كافة النصوص والأرقام مقروءة بوضوح.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'فهمت ذلك',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: CustomColor.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
