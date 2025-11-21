import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/models/wallet_balance.dart';
import 'package:carbo/models/wallet_transaction.dart';
import 'package:carbo/services/wallet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MockWalletService extends WalletService {
  List<WalletBalance> _mockBalances = [];
  List<WalletTransaction> _mockTransactions = [];
  bool shouldFail = false;

  MockWalletService() : super(client: http.Client());

  void setMockBalances(List<WalletBalance> balances) {
    _mockBalances = balances;
  }

  void setMockTransactions(List<WalletTransaction> transactions) {
    _mockTransactions = transactions;
  }

  @override
  Future<List<WalletBalance>> getBalance({String? currency}) async {
    if (shouldFail) throw Exception('Mock failure');
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockBalances;
  }

  @override
  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int perPage = 20,
    String? currency,
    WalletTransactionType? type,
  }) async {
    if (shouldFail) throw Exception('Mock failure');
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'transactions': _mockTransactions,
      'total': _mockTransactions.length,
      'currentPage': page,
      'lastPage': 1,
    };
  }

  @override
  Future<Map<String, dynamic>> topUp({
    required String amount,
    required String currency,
    String? description,
    String? idempotencyKey,
  }) async {
    if (shouldFail) throw Exception('Mock failure');
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'payment_url': 'https://mock.paytabs.com/pay/test',
      'wallet_transaction_id': 999,
      'status': 'pending',
      'idempotency_key': idempotencyKey ?? 'mock-key',
    };
  }

  @override
  Future<Map<String, dynamic>> chargeWalletForBooking({
    required String amount,
    required String currency,
    required String bookingReference,
    String? idempotencyKey,
  }) async {
    if (shouldFail) throw Exception('Insufficient balance');
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'transaction_id': 888,
      'new_balance': '150.00',
      'idempotency_key': idempotencyKey ?? 'mock-key',
    };
  }

  @override
  Future<WalletTransaction?> getTransactionById(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _mockTransactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<WalletTransaction?> pollTransactionUntilComplete({
    required int transactionId,
    int maxAttempts = 10,
    Duration initialDelay = const Duration(seconds: 2),
  }) async {
    return getTransactionById(transactionId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletController', () {
    late WalletController controller;
    late MockWalletService mockService;

    setUp(() {
      Get.testMode = true;
      mockService = MockWalletService();
      controller = WalletController(walletService: mockService);
    });

    tearDown(() {
      controller.dispose();
      Get.reset();
    });

    group('fetchBalance', () {
      test('should load balances successfully', () async {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '100.00'),
          WalletBalance(currency: 'USD', balance: '50.00'),
        ]);

        await controller.fetchBalance();

        expect(controller.balances.length, 2);
        expect(controller.balances[0].currency, 'SAR');
        expect(controller.isLoadingBalance.value, false);
        expect(controller.error.value, isEmpty);
      });

      test('should handle fetch error', () async {
        mockService.shouldFail = true;

        await controller.fetchBalance();

        expect(controller.balances.length, 0);
        expect(controller.error.value, isNotEmpty);
        expect(controller.isLoadingBalance.value, false);
      });
    });

    group('fetchTransactions', () {
      test('should load transactions successfully', () async {
        mockService.setMockTransactions([
          WalletTransaction(
            id: 1,
            type: WalletTransactionType.topup,
            amount: '100.00',
            currency: 'SAR',
            status: WalletTransactionStatus.completed,
            createdAt: DateTime.now(),
          ),
        ]);

        await controller.fetchTransactions();

        expect(controller.transactions.length, 1);
        expect(controller.transactions[0].id, 1);
        expect(controller.isLoadingTransactions.value, false);
      });

      test('should handle pagination', () async {
        mockService.setMockTransactions([
          WalletTransaction(
            id: 1,
            type: WalletTransactionType.topup,
            amount: '100.00',
            currency: 'SAR',
            status: WalletTransactionStatus.completed,
            createdAt: DateTime.now(),
          ),
        ]);

        await controller.fetchTransactions();
        expect(controller.currentPage.value, 1);

        // Load more would increment page
        await controller.fetchTransactions(loadMore: true);
        expect(controller.currentPage.value, 2);
      });
    });

    group('getBalanceForCurrency', () {
      test('should return balance for specified currency', () {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '200.00'),
        ]);
        
        controller.balances.value = mockService._mockBalances;

        final balance = controller.getBalanceForCurrency('SAR');
        expect(balance, 200.0);
      });

      test('should return 0 for missing currency', () {
        final balance = controller.getBalanceForCurrency('USD');
        expect(balance, 0.0);
      });

      test('should include optimistic changes', () {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '200.00'),
        ]);
        
        controller.balances.value = mockService._mockBalances;
        controller.optimisticBalanceChanges['SAR'] = -50.0;

        final balance = controller.getBalanceForCurrency('SAR');
        expect(balance, 150.0); // 200 - 50
      });
    });

    group('initiateTopUp', () {
      test('should initiate top-up successfully', () async {
        final result = await controller.initiateTopUp(
          amount: '100.00',
          currency: 'SAR',
        );

        expect(result, isNotNull);
        expect(result!['payment_url'], isNotEmpty);
        expect(result['wallet_transaction_id'], 999);
      });

      test('should handle top-up error', () async {
        mockService.shouldFail = true;

        final result = await controller.initiateTopUp(
          amount: '100.00',
          currency: 'SAR',
        );

        expect(result, isNull);
        expect(controller.error.value, isNotEmpty);
      });
    });

    group('chargeWalletForBooking', () {
      test('should charge wallet when sufficient balance', () async {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '200.00'),
        ]);
        controller.balances.value = mockService._mockBalances;

        final success = await controller.chargeWalletForBooking(
          amount: '50.00',
          currency: 'SAR',
          bookingReference: 'BK123',
        );

        expect(success, true);
      });

      test('should fail when insufficient balance', () async {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '10.00'),
        ]);
        controller.balances.value = mockService._mockBalances;

        final success = await controller.chargeWalletForBooking(
          amount: '50.00',
          currency: 'SAR',
          bookingReference: 'BK123',
        );

        expect(success, false);
        expect(controller.error.value, contains('Insufficient'));
      });

      test('should apply and revert optimistic updates on error', () async {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '200.00'),
        ]);
        controller.balances.value = mockService._mockBalances;
        mockService.shouldFail = true;

        final initialBalance = controller.getBalanceForCurrency('SAR');
        
        final success = await controller.chargeWalletForBooking(
          amount: '50.00',
          currency: 'SAR',
          bookingReference: 'BK123',
        );

        expect(success, false);
        
        // Balance should be reverted after error
        final finalBalance = controller.getBalanceForCurrency('SAR');
        expect(finalBalance, initialBalance);
      });
    });

    group('canCoverAmount', () {
      test('should return true when balance is sufficient', () {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '200.00'),
        ]);
        controller.balances.value = mockService._mockBalances;

        expect(controller.canCoverAmount('SAR', 100.0), true);
        expect(controller.canCoverAmount('SAR', 200.0), true);
      });

      test('should return false when balance is insufficient', () {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '50.00'),
        ]);
        controller.balances.value = mockService._mockBalances;

        expect(controller.canCoverAmount('SAR', 100.0), false);
      });
    });

    group('refresh', () {
      test('should refresh both balance and transactions', () async {
        mockService.setMockBalances([
          WalletBalance(currency: 'SAR', balance: '100.00'),
        ]);
        mockService.setMockTransactions([
          WalletTransaction(
            id: 1,
            type: WalletTransactionType.topup,
            amount: '100.00',
            currency: 'SAR',
            status: WalletTransactionStatus.completed,
            createdAt: DateTime.now(),
          ),
        ]);

        await controller.refresh();

        expect(controller.balances.length, 1);
        expect(controller.transactions.length, 1);
        expect(controller.isRefreshing.value, false);
      });
    });
  });
}
