import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:carbo/controllers/wallet_controller.dart';
import 'topup_bottom_sheet.dart';

class BalanceHeader extends StatelessWidget {
  final WalletController controller;

  const BalanceHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: Column(
        children: [
          Obx(() {
            final isLoading = controller.isLoadingBalance.value;
            final currency = controller.selectedCurrency.value;
            final balance = controller.getBalanceForCurrency(currency);
            final hasOptimisticChange =
                controller.optimisticBalanceChanges[currency] != null;
            final isHidden = controller.isBalanceHidden.value;

            return _buildDigitalCard(
              context,
              isLoading: isLoading,
              currency: currency,
              balance: balance,
              hasOptimisticChange: hasOptimisticChange,
              isHidden: isHidden,
            );
          }),
          SizedBox(height: 16.h),
          _buildTopUpButton(context),
        ],
      ),
    );
  }

  Widget _buildDigitalCard(
    BuildContext context, {
    required bool isLoading,
    required String currency,
    required double balance,
    required bool hasOptimisticChange,
    required bool isHidden,
  }) {
    if (isLoading && controller.balances.isEmpty) {
      return _buildShimmerCard();
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final currencyDisplay = isRtl ? 'ر.س' : currency;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF06233E),
            Color(0xFF0B5FA5),
            Color(0xFF1373C3),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5FA5).withOpacity(0.32),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Ambient soft glowing orbs
            Positioned(
              top: -30.h,
              right: isRtl ? null : -30.w,
              left: isRtl ? -30.w : null,
              child: Container(
                width: 150.w,
                height: 150.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF38BDF8).withOpacity(0.22),
                ),
              ),
            ),
            Positioned(
              bottom: -40.h,
              left: isRtl ? null : -20.w,
              right: isRtl ? -20.w : null,
              child: Container(
                width: 140.w,
                height: 140.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFA726).withOpacity(0.14),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Available Balance Label & Eye Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الرصيد المتاح',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),

                      // Privacy Toggle (Eye icon)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.toggleBalanceVisibility();
                        },
                        child: Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isHidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Animated Balance Number
                  isHidden
                      ? Text(
                          '••••••••',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        )
                      : TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 900),
                          tween: Tween(begin: 0.0, end: balance),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            final formatted =
                                NumberFormat('#,##0.00', 'en_US').format(value);
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  formatted,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  currencyDisplay,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                  // Optimistic pending state if any
                  if (hasOptimisticChange) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade400.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.amber.shade200.withOpacity(0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_top_rounded,
                            color: Colors.amber.shade200,
                            size: 13.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'جاري معالجة العملية...',
                            style: TextStyle(
                              color: Colors.amber.shade100,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showTopUpSheet(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF0B5FA5),
                Color(0xFF1976D2),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B5FA5).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'شحن المحفظة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopUpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopUpBottomSheet(controller: controller),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      height: 170.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller.shimmerController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2.0 * controller.shimmerController.value, 0),
                end: Alignment(1.0 + 2.0 * controller.shimmerController.value, 0),
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
