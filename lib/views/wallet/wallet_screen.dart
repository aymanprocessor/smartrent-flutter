import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/base/themes/token.dart';
import 'widgets/balance_header.dart';
import 'widgets/transactions_section.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // Smooth luxury gradient backdrop at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 310.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF06233E),
                      const Color(0xFF0B5FA5),
                      const Color(0xFF0B5FA5).withOpacity(0.85),
                      const Color(0xFFF8FAFC),
                    ],
                    stops: const [0.0, 0.45, 0.78, 1.0],
                  ),
                ),
              ),
            ),

            // Top ambient decorative glow
            Positioned(
              top: -50.h,
              right: -30.w,
              child: Container(
                width: 200.w,
                height: 200.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                color: CustomColor.primary,
                backgroundColor: Colors.white,
                edgeOffset: 80.h,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Sleek Top App Bar with official BackButtonWidget
                    SliverToBoxAdapter(
                      child: _buildTopBar(context),
                    ),

                    // Modern Digital Wallet Card + Quick Actions
                    SliverToBoxAdapter(
                      child: BalanceHeader(controller: controller),
                    ),

                    // Recent Transactions Section
                    TransactionsSection(controller: controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prominent circular back button matching Notification style
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: CustomColor.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ),

          // Centered Title in Arabic
          Text(
            'محفظتي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),

          // Balanced spacer to keep title perfectly centered
          SizedBox(width: 44.w),
        ],
      ),
    );
  }
}
