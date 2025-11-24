part of 'wallet_screen.dart';

class WalletTabletScreen extends StatelessWidget {
  const WalletTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 900 ? screenWidth * 0.8 : screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appLMyWallet ?? 'My Wallet'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: CustomScrollView(
              slivers: [
                // Balance Cards Section - Grid Layout for Tablet
                SliverToBoxAdapter(
                  child: _buildTabletBalanceSection(controller, context),
                ),

                // Top-up Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TopUpButtonWidget(
                            controller: controller,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transactions Header
                SliverToBoxAdapter(
                  child: TransactionsHeaderWidget(controller: controller),
                ),

                // Transactions List
                TransactionsListWidget(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTabletBalanceSection(
    WalletController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.appLWalletBalance ?? 'Wallet Balance',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          BalanceCardWidget(controller: controller),
        ],
      ),
    );
  }
}
