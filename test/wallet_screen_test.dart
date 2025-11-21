import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/models/wallet_balance.dart';
import 'package:carbo/models/wallet_transaction.dart';
import 'package:carbo/views/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:carbo/services/wallet_service.dart';

// Minimal mock service to avoid network calls during widget tests.
class MockWalletService extends WalletService {
  MockWalletService() : super();

  @override
  Future<List<WalletBalance>> getBalance({String? currency}) async {
    return <WalletBalance>[];
  }

  @override
  Future<Map<String, dynamic>> getTransactions({int page = 1, int perPage = 20, String? currency, WalletTransactionType? type}) async {
    return {
      'transactions': <WalletTransaction>[],
      'total': 0,
      'currentPage': page,
      'lastPage': 1,
    };
  }

  @override
  Future<Map<String, dynamic>> topUp({required String amount, required String currency, String? description, String? idempotencyKey}) async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> topUpTest({required String amount, required String currency, String? description, String? idempotencyKey}) async {
    return {
      'transaction_id': 0,
      'amount': amount,
      'currency': currency,
      'balance_after': '0',
      'idempotency_key': idempotencyKey ?? '',
    };
  }

  @override
  Future<Map<String, dynamic>> chargeWalletForBooking({required String amount, required String currency, required String bookingReference, String? idempotencyKey}) async {
    return <String, dynamic>{};
  }

  @override
  Future<WalletTransaction?> getTransactionById(int transactionId) async {
    return null;
  }

  @override
  Future<WalletTransaction?> pollTransactionUntilComplete({required int transactionId, int maxAttempts = 10, Duration initialDelay = const Duration(seconds: 2)}) async {
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletScreen Widget Tests', () {
    late WalletController controller;

    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('should display loading indicator when loading balance',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));
      controller.isLoadingBalance.value = true;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => GetMaterialApp(
            home: const WalletScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should display balance cards when balances loaded',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));
      
      controller.balances.value = [
        WalletBalance(currency: 'SAR', balance: '250.00'),
        WalletBalance(currency: 'USD', balance: '50.00'),
      ];
      controller.isLoadingBalance.value = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => GetMaterialApp(
            home: const WalletScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('SAR'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('250.00'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);
    });

    testWidgets('should display top-up button', (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => GetMaterialApp(
            home: const WalletScreen(),
          ),
        ),
      );

      expect(find.text('Top Up Wallet'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display transaction list when transactions loaded',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));
      
      controller.transactions.value = [
        WalletTransaction(
          id: 1,
          type: WalletTransactionType.topup,
          amount: '100.00',
          currency: 'SAR',
          status: WalletTransactionStatus.completed,
          description: 'Test top-up',
          createdAt: DateTime(2025, 1, 1),
        ),
        WalletTransaction(
          id: 2,
          type: WalletTransactionType.debit,
          amount: '50.00',
          currency: 'SAR',
          status: WalletTransactionStatus.completed,
          description: 'Booking payment',
          createdAt: DateTime(2025, 1, 2),
        ),
      ];
      controller.isLoadingTransactions.value = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => GetMaterialApp(
            home: const WalletScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('Top Up'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('+100.00 SAR'), findsOneWidget);
      expect(find.text('-50.00 SAR'), findsOneWidget);
    });

    testWidgets('should display empty state when no transactions',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));
      controller.transactions.value = [];
      controller.isLoadingTransactions.value = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => GetMaterialApp(
            home: const WalletScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('should display error state on fetch error',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));
      controller.error.value = 'Network error';
      controller.transactions.value = [];
      controller.isLoadingTransactions.value = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => GetMaterialApp(
            home: const WalletScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show top-up dialog when button tapped',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => GetMaterialApp(
            home: const WalletScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Top Up Wallet'));
      await tester.pumpAndSettle();

      expect(find.text('Top Up Wallet'), findsWidgets); // Button + Dialog title
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should refresh on pull-to-refresh gesture',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));
      controller.balances.value = [
        WalletBalance(currency: 'SAR', balance: '100.00'),
      ];
      controller.transactions.value = [];
      controller.isLoadingTransactions.value = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => GetMaterialApp(
            home: const WalletScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Trigger pull-to-refresh
      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      
      await tester.pump();
      
      expect(controller.isRefreshing.value, true);
      
      await tester.pumpAndSettle();
    });

    testWidgets('should display transaction status badges correctly',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));
      
      controller.transactions.value = [
        WalletTransaction(
          id: 1,
          type: WalletTransactionType.topup,
          amount: '100.00',
          currency: 'SAR',
          status: WalletTransactionStatus.pending,
          createdAt: DateTime.now(),
        ),
        WalletTransaction(
          id: 2,
          type: WalletTransactionType.topup,
          amount: '100.00',
          currency: 'SAR',
          status: WalletTransactionStatus.completed,
          createdAt: DateTime.now(),
        ),
        WalletTransaction(
          id: 3,
          type: WalletTransactionType.topup,
          amount: '100.00',
          currency: 'SAR',
          status: WalletTransactionStatus.failed,
          createdAt: DateTime.now(),
        ),
      ];
      controller.isLoadingTransactions.value = false;

      await tester.pumpWidget(
        GetMaterialApp(
          home: const WalletScreen(),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('FAILED'), findsOneWidget);
    });

    testWidgets('should show pending indicator for optimistic balance changes',
        (WidgetTester tester) async {
      controller = Get.put(WalletController(walletService: MockWalletService()));
      
      controller.balances.value = [
        WalletBalance(currency: 'SAR', balance: '200.00'),
      ];
      controller.optimisticBalanceChanges['SAR'] = -50.0;

      await tester.pumpWidget(
        GetMaterialApp(
          home: const WalletScreen(),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pending), findsOneWidget);
      expect(find.text('150.00'), findsOneWidget); // 200 - 50
    });
  });
}
