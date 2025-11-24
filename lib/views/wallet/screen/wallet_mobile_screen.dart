part of 'wallet_screen.dart';

class WalletMobileScreen extends StatelessWidget {
  const WalletMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appLMyWallet ?? 'My Wallet'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          slivers: [
            // Balance Cards Section
            SliverToBoxAdapter(
              child: BalanceCardWidget(controller: controller),
            ),

            // Top-up Button
            SliverToBoxAdapter(
              child: TopUpButtonWidget(controller: controller, context: context),
            ),

            // Transactions Header
            SliverToBoxAdapter(
              child: TransactionsHeaderWidget(controller: controller),
            ),

            // Transactions List or Loading/Error States
            TransactionsListWidget(controller: controller),
          ],
        ),
      ),
    );
  }
}
