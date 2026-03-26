part of '../screen/booking_screen.dart';

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
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFF0B5FA5),
          iconBg: const Color(0xFFE3F0FB),
          title: DynamicLanguage.key(Strings.bookingDetails),
          child: _quantityAndDateTime(),
        ),
        const SizedBox(height: 14),
        _buildDeliveryCard(),
        const SizedBox(height: 14),
        _buildPricingCard(),
        const SizedBox(height: 14),
        _buildNoteCard(),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Section card wrapper ─────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: const Color(0xFFE8ECF0), indent: 16, endIndent: 16),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  // ── Quantity + date + time ──────────────────────────────────────────────
  Widget _quantityAndDateTime() {
    return Column(
      children: [
        // Quantity field
        Obx(() => _styledInput(
          icon: controller.pricingType.value == 'per_day'
              ? Icons.calendar_month_rounded
              : Icons.route_rounded,
          child: PrimaryInputWidget(
            textInputType: TextInputType.number,
            controller: controller.quantityController,
            label: controller.getQuantityLabel(),
            hintText: controller.getQuantityHint(),
            showBorderSide: false,
            skipEnterText: true,
          ),
        )),
        const SizedBox(height: 12),
        // Pickup date
        _styledInput(
          icon: Icons.event_rounded,
          child: CustomDatePicker(
            selectedDate: controller.pickupDate,
            label: DynamicLanguage.key(Strings.PickUpdate),
            subtitle: DynamicLanguage.key(Strings.SelectADate),
            showBorder: false,
          ),
        ),
        const SizedBox(height: 12),
        // Pickup time
        _styledInput(
          icon: Icons.schedule_rounded,
          child: CustomTimePicker(
            selectedTime: controller.pickupTime,
            label: DynamicLanguage.key(Strings.PickUpTime),
            subtitle: DynamicLanguage.key(Strings.SelectATime),
            showBorder: false,
          ),
        ),
      ],
    );
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
                    onTap: () => controller.isDeliver.value = !controller.isDeliver.value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 28,
                      decoration: BoxDecoration(
                        color: controller.isDeliver.value
                            ? const Color(0xFF0B5FA5)
                            : const Color(0xFFDDE3EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
            // Location picker (shown when delivery enabled)
            Obx(() {
              if (!controller.isDeliver.value) return const SizedBox.shrink();
              return Column(
                children: [
                  Divider(height: 1, color: const Color(0xFFE8ECF0), indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildLocationPickerButton(),
                  ),
                ],
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
      return GestureDetector(
        onTap: () {
          final vendorLoc = controller.selectedCar.value?.vendorLocation;
          LatLng? center;
          double? radiusMeters;
          if (vendorLoc != null && vendorLoc.latitude != null && vendorLoc.longitude != null) {
            center = LatLng(vendorLoc.latitude!, vendorLoc.longitude!);
            if (vendorLoc.radiusKm != null) {
              radiusMeters = vendorLoc.radiusKm! * 1000.0;
            }
          }
          Get.to(() => LocationPickerWidget(
            onLocationSelected: (location) {
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

  // ── Pricing card ──────────────────────────────────────────────────────────
  Widget _buildPricingCard() {
    return Obx(() {
      final currency = _cur(controller.selectedPricing.value?.currency);
      final hasTotal = controller.total.value > 0;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0B5FA5), Color(0xFF1A8CFF)],
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
                  Text(
                    DynamicLanguage.key(Strings.totalRent),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.2)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Price per unit
                  _pricingRow(
                    DynamicLanguage.key(controller.pricingType.value == 'per_day'
                        ? Strings.pricePerDay
                        : Strings.pricePerKm),
                    '${_smartPrice(controller.effectivePrice.value > 0 ? controller.effectivePrice.value : (controller.selectedPricing.value?.price ?? 0))} $currency',
                    isWhite: true,
                    isSubtle: true,
                  ),
                  // Subtotal
                  if (controller.quantityController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _pricingRow(
                      DynamicLanguage.key(Strings.totalRent),
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
                      '${_smartPrice(controller.deliveryCharge.value)} $currency',
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
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isWhite ? Colors.white : const Color(0xFF0B5FA5),
          ),
        ),
      ],
    );
  }

  // ── Note card ─────────────────────────────────────────────────────────────
  Widget _buildNoteCard() {
    return _buildSectionCard(
      icon: Icons.edit_note_rounded,
      iconColor: const Color(0xFFFF8C00),
      iconBg: const Color(0xFFFFF3E0),
      title: DynamicLanguage.key(Strings.note),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3ECF5), width: 1.2),
        ),
        child: PrimaryInputWidget(
          skipEnterText: true,
          optionalText: DynamicLanguage.key(Strings.Optional),
          label: DynamicLanguage.key(Strings.note),
          maxLines: 4,
          controller: controller.noteController,
          hintText: DynamicLanguage.key(Strings.writeHere),
          textInputType: TextInputType.name,
          showBorderSide: false,
        ),
      ),
    );
  }
}

