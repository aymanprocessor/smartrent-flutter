import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopUpDialogWidget extends StatefulWidget {
  final WalletController controller;
  final BuildContext context;

  const TopUpDialogWidget({
    required this.controller,
    required this.context,
    super.key,
  });

  @override
  State<TopUpDialogWidget> createState() => _TopUpDialogWidgetState();
}

class _TopUpDialogWidgetState extends State<TopUpDialogWidget> {
  late final TextEditingController _amountController;
  late final RxString _selectedCurrency;
  late final RxBool _useTestTopUp;
  final List<String> _availableCurrencies = ['SAR', 'USD', 'EGP'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _selectedCurrency = 'SAR'.obs;
    _useTestTopUp = false.obs;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.appLTopUpWallet ?? 'Top Up Wallet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAmountTextField(l10n),
          const SizedBox(height: 16),
          _buildCurrencyDropdown(l10n),
          const SizedBox(height: 8),
          if (kDebugMode) _buildTestTopUpCheckbox(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: Text(l10n?.appLCancel ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _handleTopUpSubmit(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: Text(l10n?.appLYesContinue ?? 'Continue'),
        ),
      ],
    );
  }

  Widget _buildAmountTextField(AppLocalizations? l10n) {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: l10n?.appLAmount ?? 'Amount',
        hintText: l10n?.appLEnterAmount ?? 'Enter amount',
        prefixIcon: const Icon(Icons.attach_money),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCurrencyDropdown(AppLocalizations? l10n) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: _selectedCurrency.value,
        decoration: InputDecoration(
          labelText: l10n?.appLCurrency ?? 'Currency',
          border: const OutlineInputBorder(),
        ),
        items: _availableCurrencies
            .map(
              (currency) => DropdownMenuItem(
                value: currency,
                child: Text(currency),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) _selectedCurrency.value = value;
        },
      ),
    );
  }

  Widget _buildTestTopUpCheckbox() {
    return Obx(
      () => CheckboxListTile(
        value: _useTestTopUp.value,
        onChanged: (v) => _useTestTopUp.value = v ?? false,
        title: const Text('Use test top-up (QA only)'),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Future<void> _handleTopUpSubmit(BuildContext context) async {
    final amount = _amountController.text.trim();
    if (amount.isEmpty || double.tryParse(amount) == null) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    Get.back();

    if (_useTestTopUp.value) {
      await _handleTestTopUp(context, amount);
    } else {
      await _handleRegularTopUp(context, amount);
    }
  }

  Future<void> _handleTestTopUp(BuildContext context, String amount) async {
    final result = await widget.controller.initiateTopUpTest(
      amount: amount,
      currency: _selectedCurrency.value,
    );

    if (result != null) {
      final l10n = AppLocalizations.of(context);
      Get.snackbar(
        l10n?.appLTopUpSuccess ?? 'Wallet top-up successful!',
        '${result['amount']} ${result['currency']} credited',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _handleRegularTopUp(BuildContext context, String amount) async {
    final result = await widget.controller.initiateTopUp(
      amount: amount,
      currency: _selectedCurrency.value,
    );

    if (result != null) {
      _openPayTabsPayment(
        result['payment_url'],
        result['wallet_transaction_id'],
      );
    }
  }

  void _openPayTabsPayment(String paymentUrl, int transactionId) {
    Get.toNamed(
      '/paytabs-payment',
      arguments: {'url': paymentUrl},
    )?.then((_) {
      widget.controller.startPollingTransaction(transactionId);
    });
  }
}
