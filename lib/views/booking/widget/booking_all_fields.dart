part of '../screen/booking_screen.dart';

/// Reusable tactile bounce animation on tap
class _BouncyPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _BouncyPress({
    required this.child,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  State<_BouncyPress> createState() => _BouncyPressState();
}

class _BouncyPressState extends State<_BouncyPress> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final canTap = widget.isEnabled && widget.onTap != null;
    return GestureDetector(
      onTapDown: canTap ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: canTap ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: canTap ? () => setState(() => _isPressed = false) : null,
      onTap: canTap ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class BookingAllFields extends GetView<BookingController> {
  const BookingAllFields({Key? key}) : super(key: key);

  /// Format price: 200 when whole, 200.50 when fractional
  static String _smartPrice(num v) {
    return v == v.truncate() ? v.truncate().toString() : v.toStringAsFixed(2);
  }

  /// Map ISO currency code to display symbol
  static String _cur(String? code) {
    switch (code?.toUpperCase()) {
      case 'SAR': return 'ر.س';
      case 'AED': return 'د.إ';
      case 'KWD': return 'د.ك';
      case 'BHD': return 'د.ب';
      case 'QAR': return 'ر.ق';
      case 'OMR': return 'ر.ع';
      case 'EGP': return 'ج.م';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default:    return code ?? 'ر.س';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          icon: Icons.calendar_month_rounded,
          iconColor: const Color(0xFF0B5FA5),
          iconBg: const Color(0xFFE3F0FB),
          title: DynamicLanguage.key(Strings.bookingDetails),
          child: _quantityAndDateTime(context),
        ).animate().fadeIn(duration: 320.ms, delay: 50.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        _buildDeliveryCard()
            .animate().fadeIn(duration: 320.ms, delay: 100.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        _buildInsuranceCard()
            .animate().fadeIn(duration: 320.ms, delay: 150.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        _buildPricingCard()
            .animate().fadeIn(duration: 320.ms, delay: 200.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        _buildKmAllowanceCard()
            .animate().fadeIn(duration: 320.ms, delay: 250.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        _buildNoteCard()
            .animate().fadeIn(duration: 320.ms, delay: 300.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 12),
      ],
    );
  }

  // ── Section card wrapper ─────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5FA5).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Divider(height: 1, color: const Color(0xFFE8ECF0), indent: 16, endIndent: 16),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  // ── Date & Time Display Formatters ──────────────────────────────────────
  static String _formatDisplayDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final isArabic = DynamicLanguage.selectedLanguage.value == 'ar';
      const arMonths = [
        '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      const enMonths = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      if (isArabic && month >= 1 && month <= 12) {
        return '$day ${arMonths[month]} $year';
      } else if (!isArabic && month >= 1 && month <= 12) {
        return '${enMonths[month]} $day, $year';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  static String _formatDisplayTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return timeStr;
      int hour = int.parse(parts[0]);
      final minute = parts[1].padLeft(2, '0');
      final isArabic = DynamicLanguage.selectedLanguage.value == 'ar';
      final isPm = hour >= 12;
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      final period = isArabic ? (isPm ? 'م' : 'ص') : (isPm ? 'PM' : 'AM');
      return '$hour:$minute $period';
    } catch (_) {
      return timeStr;
    }
  }

  static String? _getReturnDisplay(String dateStr, String timeStr, int days) {
    if (dateStr.isEmpty || days <= 0) return null;
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return null;
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final returnDt = dt.add(Duration(days: days));
      final returnDateStr =
          '${returnDt.year}-${returnDt.month.toString().padLeft(2, '0')}-${returnDt.day.toString().padLeft(2, '0')}';
      final formattedDate = _formatDisplayDate(returnDateStr);
      final formattedTime = timeStr.isNotEmpty ? _formatDisplayTime(timeStr) : '';
      if (formattedTime.isNotEmpty) {
        return '$formattedDate ($formattedTime)';
      }
      return formattedDate;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime initial = today;
    if (controller.pickupDate.value.isNotEmpty) {
      try {
        final p = controller.pickupDate.value.split('-');
        initial = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
        if (initial.isBefore(today)) initial = today;
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B5FA5),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0D1B2A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF0B5FA5)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.pickupDate.value = formatted;
      controller.dateController.text = formatted;
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    HapticFeedback.lightImpact();
    TimeOfDay initial = TimeOfDay.now();
    if (controller.pickupTime.value.isNotEmpty) {
      try {
        final p = controller.pickupTime.value.split(':');
        initial = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
      } catch (_) {}
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B5FA5),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0D1B2A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF0B5FA5)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      controller.pickupTime.value = formatted;
      controller.timeController.text = formatted;
    }
  }

  // ── Booking Details Section (Ultra-Modern, Magical & Sleek) ──────────────
  Widget _quantityAndDateTime(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Duration / Counter Card
        Obx(() {
          if (controller.pricingType.value == 'per_day') {
            return _buildModernDurationCard();
          }
          // per_km or unknown — keep clean input
          return _styledInput(
            icon: Icons.route_rounded,
            child: PrimaryInputWidget(
              textInputType: TextInputType.number,
              controller: controller.quantityController,
              label: controller.getQuantityLabel(),
              hintText: controller.getQuantityHint(),
              showBorderSide: false,
              skipEnterText: true,
            ),
          );
        }),
        const SizedBox(height: 12),

        // 2. Schedule Grid: Side-by-Side Pickup Date & Time Tiles
        _buildScheduleGrid(context),

        // 3. Smart Return Schedule Banner (Calculates & displays expected return date & time)
        _buildSmartReturnBanner(),
      ],
    );
  }

  /// Modern Duration Card with Animated Counter & Quick Presets
  Widget _buildModernDurationCard() {
    // Ensure quantityController is initialized if empty
    if (controller.quantityController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.quantityController.text.isEmpty) {
          controller.setRentalDays(controller.rentalDays.value);
        }
      });
    }

    final int currentDays = controller.rentalDays.value;
    final isArabic = DynamicLanguage.selectedLanguage.value == 'ar';

    String durationSuffix(int count) {
      if (isArabic) {
        if (count == 1) return 'يوم';
        if (count == 2) return 'يومان';
        if (count <= 10) return 'أيام';
        return 'يومًا';
      }
      return count == 1 ? 'Day' : 'Days';
    }

    void setDays(int days) {
      if (days < 1 || days > 90) return;
      HapticFeedback.lightImpact();
      controller.setRentalDays(days);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBF4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Label & helper pill
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B5FA5).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.date_range_rounded, color: Color(0xFF0B5FA5), size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                DynamicLanguage.key(Strings.rentalDays),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              // Helper badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: currentDays >= 5
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentDays >= 5
                      ? (isArabic ? '✨ تأمين يومي متاح' : '✨ Daily Insurance Available')
                      : (isArabic ? 'حجز قياسي' : 'Standard'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: currentDays >= 5 ? const Color(0xFF2E7D32) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Counter Control: [ − ]    4 أيام    [ + ]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3ECF5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B5FA5).withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minus button (on right in Arabic RTL, on left in English LTR)
                _BouncyPress(
                  isEnabled: currentDays > 1,
                  onTap: currentDays > 1 ? () => setDays(currentDays - 1) : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: currentDays > 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: currentDays > 1 ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      Icons.remove_rounded,
                      color: currentDays > 1 ? const Color(0xFF0D1B2A) : const Color(0xFFCBD5E1),
                      size: 20,
                    ),
                  ),
                ),

                // Center Number & Suffix with smooth animated switcher
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.25),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Text(
                        '$currentDays',
                        key: ValueKey<int>(currentDays),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0B5FA5),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      durationSuffix(currentDays),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                // Plus button (on left in Arabic RTL, on right in English LTR)
                _BouncyPress(
                  isEnabled: currentDays < 90,
                  onTap: currentDays < 90 ? () => setDays(currentDays + 1) : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B5FA5), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B5FA5).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Side-by-Side Modern Schedule Grid (Pickup Date & Pickup Time)
  Widget _buildScheduleGrid(BuildContext context) {
    return Obx(() {
      final dateVal = controller.pickupDate.value;
      final timeVal = controller.pickupTime.value;
      final hasDate = dateVal.isNotEmpty;
      final hasTime = timeVal.isNotEmpty;
      final isArabic = DynamicLanguage.selectedLanguage.value == 'ar';

      return Row(
        children: [
          // ── Tile 1: Pickup Date ──────────────────────────────
          Expanded(
            child: _BouncyPress(
              onTap: () => _pickDate(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasDate ? const Color(0xFFF0F7FF) : const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasDate ? const Color(0xFF0B5FA5) : const Color(0xFFE2EBF4),
                    width: hasDate ? 1.8 : 1.2,
                  ),
                  boxShadow: hasDate
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0B5FA5).withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: hasDate ? const Color(0xFF0B5FA5) : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: hasDate ? Colors.white : const Color(0xFF64748B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DynamicLanguage.key(Strings.PickUpdate),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasDate ? const Color(0xFF0B5FA5) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasDate ? _formatDisplayDate(dateVal) : (isArabic ? 'حدد التاريخ' : 'Select date'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: hasDate ? FontWeight.w700 : FontWeight.w500,
                              color: hasDate ? const Color(0xFF0D1B2A) : const Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Tile 2: Pickup Time ──────────────────────────────
          Expanded(
            child: _BouncyPress(
              onTap: () => _pickTime(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasTime ? const Color(0xFFF0F7FF) : const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasTime ? const Color(0xFF0B5FA5) : const Color(0xFFE2EBF4),
                    width: hasTime ? 1.8 : 1.2,
                  ),
                  boxShadow: hasTime
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0B5FA5).withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: hasTime ? const Color(0xFF0B5FA5) : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time_rounded,
                        color: hasTime ? Colors.white : const Color(0xFF64748B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DynamicLanguage.key(Strings.PickUpTime),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasTime ? const Color(0xFF0B5FA5) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasTime ? _formatDisplayTime(timeVal) : (isArabic ? 'حدد الوقت' : 'Select time'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: hasTime ? FontWeight.w700 : FontWeight.w500,
                              color: hasTime ? const Color(0xFF0D1B2A) : const Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Smart Return Schedule Banner calculating return date in real-time
  Widget _buildSmartReturnBanner() {
    return Obx(() {
      final dateVal = controller.pickupDate.value;
      final timeVal = controller.pickupTime.value;
      final int days = controller.rentalDays.value;
      final returnInfo = _getReturnDisplay(dateVal, timeVal, days);
      if (returnInfo == null || returnInfo.isEmpty) return const SizedBox.shrink();

      final isArabic = DynamicLanguage.selectedLanguage.value == 'ar';

      return AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B5FA5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sync_alt_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'موعد الإرجاع المتوقع' : 'Expected Return Schedule',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      returnInfo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C4A6E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _styledInput({required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3ECF5), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: const Color(0xFF0B5FA5), size: 20),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ── Delivery card ─────────────────────────────────────────────────────────
  Widget _buildDeliveryCard() {
    return Obx(() {
      if (!controller.isDeliveryAvailable()) return const SizedBox.shrink();
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B5FA5).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Toggle row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Obx(() => Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: controller.isDeliver.value
                          ? const Color(0xFF0B5FA5).withOpacity(0.1)
                          : const Color(0xFFF0F4F8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: controller.isDeliver.value
                          ? const Color(0xFF0B5FA5)
                          : const Color(0xFF9EAAB8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DynamicLanguage.key(Strings.deliveryCar),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        if (controller.deliverySource.value == 'zone' &&
                            controller.deliveryDistance.value != null)
                          Text(
                            '${controller.deliveryDistance.value!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF0B5FA5),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Text(
                            DynamicLanguage.key(Strings.deliveryCharge),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7A8D),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Custom animated toggle
                  GestureDetector(
                    key: const Key('delivery_toggle'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.isDeliver.value = !controller.isDeliver.value;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOutCubic,
                      width: 52,
                      height: 28,
                      decoration: BoxDecoration(
                        color: controller.isDeliver.value
                            ? const Color(0xFF0B5FA5)
                            : const Color(0xFFDDE3EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOutCubic,
                        alignment: controller.isDeliver.value
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
            // Location picker with smooth accordion expand
            Obx(() {
              return AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: controller.isDeliver.value
                    ? Column(
                        children: [
                          Divider(height: 1, color: const Color(0xFFE8ECF0), indent: 16, endIndent: 16),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildLocationPickerButton(),
                          ),
                          if (controller.deliverySource.value == 'none')
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  border: Border.all(color: const Color(0xFFFF9800)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: Color(0xFFE65100), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        DynamicLanguage.key(Strings.outOfDeliveryRange),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF7B4000),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              );
            }),
          ],
        ),
      );
    });
  }

  /// Build location picker button that navigates to map
  Widget _buildLocationPickerButton() {
    return Obx(() {
      final hasLocation = controller.pickupLocation.value != null;
      return _BouncyPress(
        onTap: () async {
          HapticFeedback.lightImpact();
          final selectedCar = controller.selectedCar.value;
          if (selectedCar == null) return;

          final vendorLoc = selectedCar.vendorLocation;
          LatLng? center;
          double? radiusMeters;

          // Set center location if available
          if (vendorLoc != null && vendorLoc.latitude != null && vendorLoc.longitude != null) {
            center = LatLng(vendorLoc.latitude!, vendorLoc.longitude!);
          }

          // Fetch delivery zones from API for coverage radius
          if (selectedCar.branchId != null && center != null) {
            final deliveryService = Get.find<DeliveryService>();
            final zonesResponse = await deliveryService.fetchDeliveryZones(
              branchId: selectedCar.branchId!,
            );

            if (zonesResponse != null && zonesResponse.isSuccess && zonesResponse.data?.coverage?.isValid == true) {
              radiusMeters = zonesResponse.data!.coverage!.maxKm! * 1000.0;
            }
          }

          Get.to(() => LocationPickerWidget(
            onLocationSelected: (location) {
              debugPrint('[LocationPicker] Location selected: ${location.address}');
              controller.pickupLocation.value = location;
              controller.pickupLatitude.value = location.latitude;
              controller.pickupLongitude.value = location.longitude;
            },
            initialLocation: controller.pickupLocation.value,
            center: center,
            radiusMeters: radiusMeters,
          ));
        },
        child: Container(
          key: const Key('location_picker'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: hasLocation
                ? const Color(0xFFE3F0FB)
                : const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasLocation
                  ? const Color(0xFF0B5FA5)
                  : const Color(0xFFDDE3EA),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasLocation
                      ? const Color(0xFF0B5FA5)
                      : const Color(0xFFE8ECF0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: hasLocation ? Colors.white : const Color(0xFF9EAAB8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DynamicLanguage.key(Strings.PickUpLocation),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: hasLocation
                            ? const Color(0xFF0B5FA5)
                            : const Color(0xFF6B7A8D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (hasLocation) ...[
                      Text(
                        controller.pickupLocation.value!.address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D1B2A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${controller.pickupLocation.value!.latitude.toStringAsFixed(4)}, ${controller.pickupLocation.value!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9EAAB8),
                        ),
                      ),
                    ] else
                      Text(
                        DynamicLanguage.key(Strings.PickUpLocation),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9EAAB8),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                hasLocation
                    ? Icons.edit_location_alt_rounded
                    : Icons.chevron_right_rounded,
                color: hasLocation
                    ? const Color(0xFF0B5FA5)
                    : const Color(0xFF9EAAB8),
                size: 22,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Insurance card (Interactive & Animated) ──────────────────────────────
  Widget _buildInsuranceCard() {
    return _buildSectionCard(
      icon: Icons.shield_rounded,
      iconColor: const Color(0xFF2E7D32),
      iconBg: const Color(0xFFE8F5E9),
      title: DynamicLanguage.key(Strings.appLInsuranceType),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Insurance Option Card
          Obx(() {
            final isArabic = DynamicLanguage.selectedLanguage.value == 'ar';
            final currency = _cur(controller.selectedPricing.value?.currency);
            final isSelected = controller.selectedInsuranceType.value == 'daily';
            final isAllowed = controller.isDailyInsuranceAllowed.value;
            final dailyAmount = controller.insuranceDailyAmount.value > 0
                ? controller.insuranceDailyAmount.value
                : (controller.selectedCar.value?.dailyInsuranceAmount ?? 0.0);
            final minDays = controller.dailyInsuranceMinDays.value ?? controller.selectedCar.value?.dailyInsuranceMinDays;

            return _buildInsuranceOptionItem(
              title: DynamicLanguage.key(Strings.appLDailyInsurance),
              priceText: isAllowed && dailyAmount > 0
                  ? '+${_smartPrice(dailyAmount)} $currency / ${isArabic ? 'يوم' : 'day'}'
                  : null,
              lockText: !isAllowed
                  ? (controller.dailyInsuranceDisabledReason.value ??
                      (isArabic ? 'متاح للحجوزات من $minDays أيام فأكثر' : 'Available for $minDays+ days'))
                  : null,
              icon: Icons.today_rounded,
              isSelected: isSelected && isAllowed,
              isEnabled: isAllowed,
              onTap: () {
                if (!isAllowed) {
                  HapticFeedback.mediumImpact();
                  final msg = controller.dailyInsuranceDisabledReason.value ??
                      (isArabic
                          ? 'التأمين اليومي متاح فقط للحجوزات من $minDays أيام فأكثر. يمكنك زيادة مدة الحجز لتفعيله.'
                          : 'Daily insurance is available for bookings of $minDays days or more. Increase rental duration to unlock.');
                  Get.snackbar(
                    isArabic ? 'تنبيه التأمين اليومي' : 'Daily Insurance Notice',
                    msg,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1E293B),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    duration: const Duration(seconds: 3),
                    icon: const Icon(Icons.lock_clock_rounded, color: Color(0xFFF59E0B)),
                  );
                  return;
                }
                HapticFeedback.lightImpact();
                controller.selectInsuranceType('daily');
              },
            );
          }),
          const SizedBox(height: 12),
          // Excess Liability Insurance Option Card
          Obx(() {
            final currency = _cur(controller.selectedPricing.value?.currency);
            final isSelected = controller.selectedInsuranceType.value == 'excess_liability';
            final liabilityAmount = controller.insuranceExcessLiabilityAmount.value > 0
                ? controller.insuranceExcessLiabilityAmount.value
                : (controller.selectedCar.value?.excessLiabilityAmount ?? 0.0);

            return _buildInsuranceOptionItem(
              title: DynamicLanguage.key(Strings.appLExcessLiabilityInsurance),
              priceText: liabilityAmount > 0
                  ? '${_smartPrice(liabilityAmount)} $currency'
                  : null,
              lockText: null,
              icon: Icons.security_rounded,
              isSelected: isSelected,
              isEnabled: true,
              onTap: () {
                HapticFeedback.lightImpact();
                controller.selectInsuranceType('excess_liability');
              },
            );
          }),
          // Warning box with smooth AnimatedSize
          Obx(() {
            final isExcessSelected = controller.selectedInsuranceType.value == 'excess_liability';
            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: isExcessSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _buildInsuranceWarning(),
                    )
                  : const SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }

  /// Interactive modern insurance option item with tactile animation
  Widget _buildInsuranceOptionItem({
    required String title,
    String? priceText,
    String? lockText,
    required IconData icon,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return _BouncyPress(
      isEnabled: true,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: !isEnabled
              ? const Color(0xFFF8FAFC)
              : isSelected
                  ? const Color(0xFFF0F7FF)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: !isEnabled
                ? const Color(0xFFE2E8F0)
                : isSelected
                    ? const Color(0xFF0B5FA5)
                    : const Color(0xFFDDE3EA),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0B5FA5).withOpacity(0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon circle (clean & interactive, replaces checkmark)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: !isEnabled
                        ? const Color(0xFFE2E8F0)
                        : isSelected
                            ? const Color(0xFF0B5FA5)
                            : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: !isEnabled
                        ? const Color(0xFF94A3B8)
                        : isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: !isEnabled
                          ? const Color(0xFF94A3B8)
                          : isSelected
                              ? const Color(0xFF0B5FA5)
                              : const Color(0xFF0D1B2A),
                    ),
                  ),
                ),
                // Price text pill (when enabled)
                if (priceText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0B5FA5).withOpacity(0.10)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? const Color(0xFF0B5FA5) : const Color(0xFF334155),
                      ),
                    ),
                  ),
              ],
            ),
            // Lock badge placed underneath
            if (!isEnabled && lockText != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 50),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 5),
                      Text(
                        lockText,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build insurance warning card for excess_liability
  Widget _buildInsuranceWarning() {
    final isArabic = DynamicLanguage.selectedLanguage.value == 'ar';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'تنبيه' : 'Warning',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                // Display message based on app language
                Obx(() {
                  String message = '';
                  if (controller.insuranceMessage.value != null) {
                    final currentLang = DynamicLanguage.selectedLanguage.value;
                    message = controller.insuranceMessage.value![currentLang] ??
                        controller.insuranceMessage.value!['en'] ??
                        '';
                  }
                  if (message.isEmpty) {
                    message = DynamicLanguage.key(Strings.appLInsuranceWarning);
                  }
                  return Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.45,
                    ),
                  );
                }),
                const SizedBox(height: 8),
                // Show insurance amount
                Obx(() {
                  final liabilityAmount = controller.insuranceExcessLiabilityAmount.value > 0
                      ? controller.insuranceExcessLiabilityAmount.value
                      : (controller.selectedCar.value?.excessLiabilityAmount ?? 0.0);
                  if (liabilityAmount <= 0) {
                    return const SizedBox.shrink();
                  }
                  final currency = _cur(controller.selectedPricing.value?.currency);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${DynamicLanguage.key(Strings.appLInsuranceAmount)}: ${_smartPrice(liabilityAmount)} $currency',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Pricing card (Animated Price Breakdown) ───────────────────────────────
  Widget _buildPricingCard() {
    return Obx(() {
      final currency = _cur(controller.selectedPricing.value?.currency);
      final hasTotal = controller.total.value > 0;
      final isArabic = DynamicLanguage.selectedLanguage.value == 'ar';

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0B5FA5), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B5FA5).withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DynamicLanguage.key(Strings.totalRent),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (controller.isPriceLoading.value)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'جارٍ الحساب...' : 'Calculating...',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.2)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                child: Column(
                  children: [
                    // Vehicle Rental (subtotal)
                    if (controller.subtotal.value > 0) ...[
                      _pricingRow(
                        isArabic ? 'إيجار السيارة' : 'Vehicle Rental',
                        '${_smartPrice(controller.subtotal.value)} $currency',
                        isWhite: true,
                        isSubtle: true,
                      ),
                    ],
                    // Delivery charge
                    if (controller.isDeliver.value && controller.deliveryCharge.value > 0) ...[
                      const SizedBox(height: 8),
                      _pricingRow(
                        DynamicLanguage.key(Strings.deliveryCharge),
                        controller.deliverySource.value == 'zone' &&
                                controller.deliveryDistance.value != null
                            ? '${_smartPrice(controller.deliveryCharge.value)} $currency (${controller.deliveryDistance.value!.toStringAsFixed(1)} km)'
                            : '${_smartPrice(controller.deliveryCharge.value)} $currency',
                        isWhite: true,
                        isSubtle: true,
                      ),
                    ],
                    // Daily Insurance (only when daily is selected and amount > 0)
                    if (controller.selectedInsuranceType.value == 'daily' && controller.insuranceSubtotal.value > 0) ...[
                      const SizedBox(height: 8),
                      _pricingRow(
                        DynamicLanguage.key(Strings.appLDailyInsurance),
                        '${_smartPrice(controller.insuranceSubtotal.value)} $currency',
                        isWhite: true,
                        isSubtle: true,
                      ),
                    ],
                    // Tax
                    if (controller.selectedCar.value != null &&
                        controller.selectedCar.value!.taxEnabled &&
                        controller.taxAmount.value > 0) ...[
                      const SizedBox(height: 8),
                      _pricingRow(
                        DynamicLanguage.key(Strings.tax),
                        '${_smartPrice(controller.taxAmount.value)} $currency',
                        isWhite: true,
                        isSubtle: true,
                      ),
                    ],
                    // Total
                    if (hasTotal) ...[
                      const SizedBox(height: 12),
                      Divider(color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 8),
                      _pricingRow(
                        DynamicLanguage.key(Strings.total),
                        '${_smartPrice(controller.total.value)} $currency',
                        isWhite: true,
                        isTotal: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _pricingRow(String label, String value, {
    bool isWhite = false,
    bool isSubtle = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isWhite
                ? (isSubtle ? Colors.white.withOpacity(0.75) : Colors.white)
                : (isSubtle ? const Color(0xFF6B7A8D) : const Color(0xFF0D1B2A)),
          ),
        ),
        // Smooth slide & fade transition for changing price values
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isWhite ? Colors.white : const Color(0xFF0B5FA5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKmAllowanceCard() {
    return Obx(() {
      final car = controller.selectedCar.value;
      if (car?.kmOverageCharge == null || car!.kmOverageCharge! <= 0) {
        return const SizedBox.shrink();
      }

      final kmStr = _smartPrice(car.kmAllowance ?? 0);
      final chargeStr = _smartPrice(car.kmOverageCharge ?? 0);
      final appLocalizations = AppLocalizations.of(Get.context!);
      final message = appLocalizations?.appLKmAllowanceMessage(chargeStr, kmStr) ?? '';

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF0B5FA5).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B5FA5).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Color(0xFF0B5FA5), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DynamicLanguage.key(Strings.kmAllowanceLabel),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: const Color(0xFF0B5FA5).withOpacity(0.10),
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0D1B2A),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Note card (Clean design without "اختياري" and with optimized inner padding) ──
  Widget _buildNoteCard() {
    return _buildSectionCard(
      icon: Icons.edit_note_rounded,
      iconColor: const Color(0xFFFF8C00),
      iconBg: const Color(0xFFFFF3E0),
      title: DynamicLanguage.key(Strings.note),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3ECF5), width: 1.2),
        ),
        child: TextFormField(
          controller: controller.noteController,
          maxLines: 4,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0D1B2A),
            height: 1.45,
          ),
          decoration: InputDecoration(
            hintText: DynamicLanguage.key(Strings.writeHere),
            hintStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
