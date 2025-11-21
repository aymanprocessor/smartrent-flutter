import 'package:carbo/controllers/wallet_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';

/// Helper class to integrate wallet with booking payment flow
class WalletPaymentHelper {
  /// Check if wallet can cover booking amount, if not calculate shortfall
  static Future<Map<String, dynamic>> checkWalletForBooking({
    required String amount,
    required String currency,
  }) async {
    final controller = Get.find<WalletController>();
    final amountDouble = double.tryParse(amount) ?? 0.0;
    final availableBalance = controller.getBalanceForCurrency(currency);

    if (availableBalance >= amountDouble) {
      return {
        'canCover': true,
        'availableBalance': availableBalance,
        'shortfall': 0.0,
      };
    } else {
      return {
        'canCover': false,
        'availableBalance': availableBalance,
        'shortfall': amountDouble - availableBalance,
      };
    }
  }

  /// Process booking payment - use wallet if sufficient, otherwise PayTabs
  static Future<bool> processBookingPayment({
    required String amount,
    required String currency,
    required String bookingReference,
  }) async {
    final controller = Get.find<WalletController>();
    final amountDouble = double.tryParse(amount) ?? 0.0;
    final availableBalance = controller.getBalanceForCurrency(currency);

    // Full wallet payment
    if (availableBalance >= amountDouble) {
      return await controller.chargeWalletForBooking(
        amount: amount,
        currency: currency,
        bookingReference: bookingReference,
      );
    }

    // Partial wallet + PayTabs for remainder
    if (availableBalance > 0) {
      final shortfall = amountDouble - availableBalance;
      
      // Show confirmation dialog for partial payment
      final l10n = AppLocalizations.of(Get.context!);
        final partialMessage = l10n?.appLPartialPaymentMessage(
          availableBalance.toStringAsFixed(2),
          currency,
          shortfall.toStringAsFixed(2),
          ) ??
          'Your wallet has ${availableBalance.toStringAsFixed(2)} $currency.\nPay ${shortfall.toStringAsFixed(2)} $currency via card?';
      final usePartial = await Get.defaultDialog<bool>(
        title: l10n?.appLPartialWalletPayment ?? 'Partial Wallet Payment',
        middleText: partialMessage,
        textConfirm: l10n?.appLYesContinue ?? 'Yes, Continue',
        textCancel: l10n?.appLCancel ?? 'Cancel',
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );

      if (usePartial != true) return false;

      // Charge available wallet amount first
      final walletCharged = await controller.chargeWalletForBooking(
        amount: availableBalance.toStringAsFixed(2),
        currency: currency,
        bookingReference: bookingReference,
      );

      if (!walletCharged) return false;

      // Return shortfall info for PayTabs processing
      // Caller should handle PayTabs flow for remaining amount
      return true; // Wallet portion successful, caller handles card payment
    }

    // No wallet balance - full PayTabs payment
    return false; // Indicates caller should use full PayTabs flow
  }

  /// Show wallet balance selector for multi-currency wallets
  static Future<String?> selectCurrencyForPayment(List<String> availableCurrencies) async {
    if (availableCurrencies.length == 1) {
      return availableCurrencies.first;
    }

    final controller = Get.find<WalletController>();
    
    final l10n = AppLocalizations.of(Get.context!);
    return await Get.defaultDialog<String>(
      title: l10n?.appLSelectCurrency ?? 'Select Currency',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableCurrencies.map((currency) {
          final balance = controller.getBalanceForCurrency(currency);
          return ListTile(
            title: Text(currency),
            subtitle: Text(
                '${l10n?.appLWalletBalance ?? 'Balance'}: ${balance.toStringAsFixed(2)}'),
            onTap: () => Get.back(result: currency),
          );
        }).toList(),
      ),
    );
  }
}
