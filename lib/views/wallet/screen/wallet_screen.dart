import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:carbo/views/wallet/widget/balance_card_widget.dart';
import 'package:carbo/views/wallet/widget/topup_button_widget.dart';
import 'package:carbo/views/wallet/widget/transactions_header_widget.dart';
import 'package:carbo/views/wallet/widget/transactions_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../base/utils/basic_import.dart';

part 'wallet_mobile_screen.dart';
part 'wallet_tablet_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: WalletMobileScreen(),
      tablet: WalletTabletScreen(),
    );
  }
}
