import 'package:flutter/material.dart';
import 'package:carbo/controllers/wallet_controller.dart';

/// QuickActions is now integrated directly into BalanceHeader for a cohesive modern card UI.
/// This widget is maintained for backwards compatibility.
class QuickActions extends StatelessWidget {
  final WalletController controller;

  const QuickActions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
