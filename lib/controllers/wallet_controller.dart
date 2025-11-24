import 'dart:async';
import 'package:carbo/models/wallet_balance.dart';
import 'package:carbo/models/wallet_transaction.dart';
import 'package:carbo/views/wallet/service/wallet_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class WalletController extends GetxController with WidgetsBindingObserver {
  final WalletService _walletService;
  final Logger log = Logger();

  WalletController({WalletService? walletService})
      : _walletService = walletService ?? WalletService();

  // Reactive state
  final RxList<WalletBalance> balances = <WalletBalance>[].obs;
  final RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  final RxBool isLoadingBalance = false.obs;
  final RxBool isLoadingTransactions = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;

  // Optimistic state tracking
  final RxMap<String, double> optimisticBalanceChanges = <String, double>{}.obs;
  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchBalance();
    fetchTransactions();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _walletService.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log.i('App resumed, refreshing wallet data');
      refresh();
    }
  }

  /// Get total balance for a specific currency (including optimistic changes)
  double getBalanceForCurrency(String currency) {
    final balance = balances.firstWhereOrNull((b) => b.currency == currency);
    final baseBalance = balance?.balanceAsDouble ?? 0.0;
    final optimisticChange = optimisticBalanceChanges[currency] ?? 0.0;
    return baseBalance + optimisticChange;
  }

  /// Fetch wallet balance from server
  Future<void> fetchBalance({String? currency}) async {
    try {
      isLoadingBalance.value = true;
      error.value = '';

      final fetchedBalances = await _walletService.getBalance(currency: currency);
      balances.value = fetchedBalances;

      log.i('Fetched ${fetchedBalances.length} balance(s)');
    } catch (e) {
      error.value = e.toString();
      log.e('Error fetching balance: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch wallet balance',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingBalance.value = false;
    }
  }

  /// Fetch wallet transactions with pagination
  Future<void> fetchTransactions({
    bool loadMore = false,
    String? currency,
    WalletTransactionType? type,
  }) async {
    try {
      if (loadMore) {
        if (!hasMore.value) return;
        currentPage.value++;
      } else {
        isLoadingTransactions.value = true;
        currentPage.value = 1;
        transactions.clear();
      }

      error.value = '';

      final response = await _walletService.getTransactions(
        page: currentPage.value,
        perPage: 20,
        currency: currency,
        type: type,
      );

      final fetchedTransactions = response['transactions'] as List<WalletTransaction>;
      
      if (loadMore) {
        transactions.addAll(fetchedTransactions);
      } else {
        transactions.value = fetchedTransactions;
      }

      totalPages.value = response['lastPage'] ?? 1;
      hasMore.value = currentPage.value < totalPages.value;

      log.i('Fetched ${fetchedTransactions.length} transactions (page ${currentPage.value})');
    } catch (e) {
      error.value = e.toString();
      log.e('Error fetching transactions: $e');
      if (!loadMore) {
        Get.snackbar(
          'Error',
          'Failed to fetch transactions',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  /// Refresh all wallet data (pull-to-refresh)
  Future<void> refresh() async {
    try {
      isRefreshing.value = true;
      await Future.wait([
        fetchBalance(),
        fetchTransactions(),
      ]);
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Initiate wallet top-up via PayTabs
  Future<Map<String, dynamic>?> initiateTopUp({
    required String amount,
    required String currency,
    String? description,
  }) async {
    try {
      error.value = '';
      
      final result = await _walletService.topUp(
        amount: amount,
        currency: currency,
        description: description,
      );

      log.i('Top-up initiated: ${result['wallet_transaction_id']}');
      
      return result;
    } catch (e) {
      error.value = e.toString();
      log.e('Error initiating top-up: $e');
      Get.snackbar(
        'Error',
        'Failed to initiate top-up: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Initiate test-only top-up (QA / development)
  /// Immediately credits the wallet without payment gateway.
  Future<Map<String, dynamic>?> initiateTopUpTest({
    required String amount,
    required String currency,
    String? description,
  }) async {
    try {
      error.value = '';

      final result = await _walletService.topUpTest(
        amount: amount,
        currency: currency,
        description: description,
      );

      log.i('Test top-up completed: ${result['transaction_id']}');

      // Refresh balances and transactions to reflect immediate credit
      await fetchBalance();
      await fetchTransactions();

      Get.snackbar(
        'Success',
        'Test top-up completed',
        snackPosition: SnackPosition.BOTTOM,
      );

      return result;
    } catch (e) {
      error.value = e.toString();
      log.e('Error initiating test top-up: $e');
      Get.snackbar(
        'Error',
        'Failed to perform test top-up: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Start polling transaction status after PayTabs redirect
  void startPollingTransaction(int transactionId) {
    log.i('Starting to poll transaction $transactionId');
    
    _pollTimer?.cancel();
    
    var attempts = 0;
    const maxAttempts = 10;
    var delay = 2;

    _pollTimer = Timer.periodic(Duration(seconds: delay), (timer) async {
      attempts++;
      log.i('Polling attempt $attempts/$maxAttempts for transaction $transactionId');

      final transaction = await _walletService.getTransactionById(transactionId);
      
      if (transaction != null) {
        if (transaction.isCompleted) {
          timer.cancel();
          log.i('Transaction $transactionId completed');
          Get.snackbar(
            'Success',
            'Wallet top-up successful!',
            snackPosition: SnackPosition.BOTTOM,
          );
          await refresh(); // Refresh balance and transactions
          return;
        } else if (transaction.isFailed) {
          timer.cancel();
          log.e('Transaction $transactionId failed');
          Get.snackbar(
            'Failed',
            'Wallet top-up failed',
            snackPosition: SnackPosition.BOTTOM,
          );
          await fetchTransactions(); // Refresh to show failed transaction
          return;
        }
      }

      if (attempts >= maxAttempts) {
        timer.cancel();
        log.w('Max polling attempts reached for transaction $transactionId');
        Get.snackbar(
          'Info',
          'Payment processing - please check transactions later',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  /// Charge wallet for booking with optimistic update
  Future<bool> chargeWalletForBooking({
    required String amount,
    required String currency,
    required String bookingReference,
  }) async {
    final amountDouble = double.tryParse(amount) ?? 0.0;
    final currentBalance = getBalanceForCurrency(currency);

    // Check sufficient balance
    if (currentBalance < amountDouble) {
      error.value = 'Insufficient wallet balance';
      Get.snackbar(
        'Insufficient Balance',
        'Your wallet has insufficient funds. Please top up.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Optimistic update: immediately decrement balance
    _applyOptimisticChange(currency, -amountDouble);

    try {
      error.value = '';
      
      await _walletService.chargeWalletForBooking(
        amount: amount,
        currency: currency,
        bookingReference: bookingReference,
      );

      log.i('Wallet charged successfully for booking $bookingReference');
      
      // Clear optimistic change and fetch actual balance
      _clearOptimisticChange(currency);
      await fetchBalance(currency: currency);
      await fetchTransactions();
      
      return true;
    } catch (e) {
      error.value = e.toString();
      log.e('Error charging wallet: $e');
      
      // Revert optimistic change
      _revertOptimisticChange(currency, amountDouble);
      
      Get.snackbar(
        'Error',
        'Failed to charge wallet: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Apply optimistic balance change
  void _applyOptimisticChange(String currency, double change) {
    final current = optimisticBalanceChanges[currency] ?? 0.0;
    optimisticBalanceChanges[currency] = current + change;
    log.i('Applied optimistic change: $change to $currency');
  }

  /// Revert optimistic change (on error)
  void _revertOptimisticChange(String currency, double amount) {
    final current = optimisticBalanceChanges[currency] ?? 0.0;
    optimisticBalanceChanges[currency] = current + amount; // Add back
    log.i('Reverted optimistic change: $amount for $currency');
    
    // Show visual feedback
    balances.refresh();
  }

  /// Clear optimistic changes for a currency
  void _clearOptimisticChange(String currency) {
    optimisticBalanceChanges.remove(currency);
  }

  /// Check if wallet can cover amount
  bool canCoverAmount(String currency, double amount) {
    return getBalanceForCurrency(currency) >= amount;
  }

  /// Get primary currency balance (first in list or specified)
  WalletBalance? getPrimaryCurrencyBalance([String? preferredCurrency]) {
    if (balances.isEmpty) return null;
    
    if (preferredCurrency != null) {
      return balances.firstWhereOrNull((b) => b.currency == preferredCurrency);
    }
    
    return balances.first;
  }
}
