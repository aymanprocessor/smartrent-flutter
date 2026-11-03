import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/themes/token.dart';
import '../../../base/widgets/app_cached_image.dart';
import '../../../languages/strings.dart';

class DocumentImagePicker extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? imageUrl;
  final String? imagePath;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRemove;
  final bool isRequired;

  const DocumentImagePicker({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.badge_rounded,
    this.imageUrl,
    this.imagePath,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.onRemove,
    this.isRequired = false,
  });

  bool get _hasImage =>
      (imagePath != null && imagePath!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _hasImage
              ? const Color(0xFF10B981).withOpacity(0.35)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _buildHeader(context),
          const SizedBox(height: 14),

          // Upload or Preview Zone
          if (!_hasImage)
            _buildEmptyUploadZone(context)
          else
            _buildImagePreviewZone(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Leading Icon Container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hasImage
                ? const Color(0xFFECFDF5)
                : CustomColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _hasImage ? Icons.check_circle_rounded : icon,
            color: _hasImage ? const Color(0xFF059669) : CustomColor.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),

        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Status Tag
        if (_hasImage)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF059669),
                  size: 13,
                ),
                SizedBox(width: 4),
                Text(
                  'تم الرفع',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else if (isRequired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Color(0xFFE11D48),
                  size: 12,
                ),
                SizedBox(width: 3),
                Text(
                  'مطلوب',
                  style: TextStyle(
                    color: Color(0xFFE11D48),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyUploadZone(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSourcePickerModal(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: CustomColor.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 26,
                  color: CustomColor.primary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'اضغط هنا لرفع المستند',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'التقط صورة واضحة بالكاميرا أو اختر من الاستوديو',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 14),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionChip(
                    icon: Icons.camera_alt_rounded,
                    label: DynamicLanguage.key(Strings.camera),
                    onTap: onPickFromCamera,
                    isPrimary: true,
                  ),
                  const SizedBox(width: 10),
                  _actionChip(
                    icon: Icons.photo_library_rounded,
                    label: DynamicLanguage.key(Strings.gallery),
                    onTap: onPickFromGallery,
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary ? CustomColor.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? CustomColor.primary
                  : const Color(0xFFCBD5E1),
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: CustomColor.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isPrimary ? Colors.white : const Color(0xFF334155),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewZone(BuildContext context) {
    return Column(
      children: [
        // Image Frame
        GestureDetector(
          onTap: () => _openFullscreenViewer(context),
          child: Container(
            height: 185,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image renderer
                  if (imagePath != null && imagePath!.isNotEmpty)
                    Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 185,
                    )
                  else if (imageUrl != null && imageUrl!.isNotEmpty)
                    AppCachedImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 185,
                      errorWidget: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 40,
                          color: Colors.white54,
                        ),
                      ),
                    ),

                  // Subtle gradient overlay at top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top Pill & Fullscreen Zoom icon
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF34D399),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'صورة جاهزة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom tap-to-expand hint
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'اضغط للمعاينة والتكبير',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Action Buttons Row (Change / Delete)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showSourcePickerModal(context),
                icon: const Icon(Icons.sync_rounded, size: 16),
                label: Text(DynamicLanguage.key(Strings.changePhoto)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: Color(0xFFEF4444)),
                label: Text(
                  DynamicLanguage.key(Strings.delete),
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFFFEF2F2),
                  side: BorderSide(
                    color: const Color(0xFFFCA5A5).withOpacity(0.6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSourcePickerModal(BuildContext context) {
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
              // Drag handle
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

              Text(
                'اختيار صورة المستند',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // Camera Card
              _pickerOptionTile(
                icon: Icons.camera_alt_rounded,
                title: DynamicLanguage.key(Strings.camera),
                subtitle: 'التقاط صورة واضحة الآن مباشرة',
                iconColor: CustomColor.primary,
                iconBgColor: CustomColor.primary.withOpacity(0.08),
                onTap: () {
                  Navigator.pop(context);
                  onPickFromCamera();
                },
              ),

              const SizedBox(height: 10),

              // Gallery Card
              _pickerOptionTile(
                icon: Icons.photo_library_rounded,
                title: DynamicLanguage.key(Strings.gallery),
                subtitle: 'اختيار صورة محفوظة مسبقاً من جهازك',
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFEF3C7),
                onTap: () {
                  Navigator.pop(context);
                  onPickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullscreenViewer(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: imagePath != null && imagePath!.isNotEmpty
                        ? Image.file(File(imagePath!))
                        : AppCachedImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'اسحب أو كبّر بإصبعين للتأكد من وضوح بيانات المستند',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
