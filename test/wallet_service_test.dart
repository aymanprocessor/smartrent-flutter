import 'dart:convert';
import 'package:carbo/models/wallet_transaction.dart';
import 'package:carbo/views/wallet/service/wallet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('WalletService', () {
    late WalletService walletService;
    
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Provide a mock handler for path_provider plugin used by GetStorage
      final tempDir = Directory.systemTemp.createTempSync();
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'getApplicationDocumentsDirectory') return tempDir.path;
        if (call.method == 'getTemporaryDirectory') return tempDir.path;
        return tempDir.path;
      });

      await GetStorage.init();
    });

    setUp(() {
      // Tests will provide mock client
    });

    tearDown(() {
      walletService.dispose();
    });

    group('getBalance', () {
      test('should return list of balances on success', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), contains('/wallet/balance'));
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'balances': [
                  {'currency': 'SAR', 'balance': '250.00'},
                  {'currency': 'USD', 'balance': '50.00'},
                ]
              }
            }),
            200,
          );
        });

        walletService = WalletService(client: mockClient);
        final balances = await walletService.getBalance();

        expect(balances, hasLength(2));
        expect(balances[0].currency, 'SAR');
        expect(balances[0].balance, '250.00');
        expect(balances[1].currency, 'USD');
        expect(balances[1].balance, '50.00');
      });

      test('should filter by currency when specified', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), contains('currency=SAR'));
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'balances': [
                  {'currency': 'SAR', 'balance': '250.00'},
                ]
              }
            }),
            200,
          );
        });

        walletService = WalletService(client: mockClient);
        final balances = await walletService.getBalance(currency: 'SAR');

        expect(balances, hasLength(1));
        expect(balances[0].currency, 'SAR');
      });

      test('should throw exception on network error', () async {
        final mockClient = MockClient((request) async {
          throw Exception('Network error');
        });

        walletService = WalletService(client: mockClient);

        expect(
          () => walletService.getBalance(),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception on non-200 status', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Unauthorized', 401);
        });

        walletService = WalletService(client: mockClient);

        expect(
          () => walletService.getBalance(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTransactions', () {
      test('should return paginated transactions', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), contains('/wallet/transactions'));
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'data': [
                  {
                    'id': 1,
                    'type': 'topup',
                    'amount': '100.00',
                    'currency': 'SAR',
                    'status': 'completed',
                    'balance_before': '0.00',
                    'balance_after': '100.00',
                    'description': 'Top up',
                    'created_at': '2025-01-01T00:00:00Z',
                  }
                ],
                'total': 1,
                'current_page': 1,
                'last_page': 1,
              }
            }),
            200,
          );
        });

        walletService = WalletService(client: mockClient);
        final response = await walletService.getTransactions();

        final transactions = response['transactions'] as List<WalletTransaction>;
        expect(transactions, hasLength(1));
        expect(transactions[0].id, 1);
        expect(transactions[0].type, WalletTransactionType.topup);
        expect(transactions[0].status, WalletTransactionStatus.completed);
      });

      test('should include query parameters', () async {
        final mockClient = MockClient((request) async {
          final uri = request.url;
          expect(uri.queryParameters['page'], '2');
          expect(uri.queryParameters['per_page'], '10');
          expect(uri.queryParameters['currency'], 'USD');
          
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'data': [],
                'total': 0,
                'current_page': 2,
                'last_page': 1,
              }
            }),
            200,
          );
        });

        walletService = WalletService(client: mockClient);
        await walletService.getTransactions(
          page: 2,
          perPage: 10,
          currency: 'USD',
        );
      });
    });

    group('topUp', () {
      test('should return payment URL and transaction ID', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), contains('/wallet/top-up'));
          expect(request.method, 'POST');
          
          final body = json.decode(request.body);
          expect(body['amount'], '100.00');
          expect(body['currency'], 'SAR');
          expect(body['idempotency_key'], isNotNull);

          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'payment_url': 'https://paytabs.com/pay/abc123',
                'wallet_transaction_id': 42,
                'status': 'pending',
              }
            }),
            201,
          );
        });

        walletService = WalletService(client: mockClient);
        final result = await walletService.topUp(
          amount: '100.00',
          currency: 'SAR',
        );

        expect(result['payment_url'], contains('paytabs.com'));
        expect(result['wallet_transaction_id'], 42);
        expect(result['status'], 'pending');
        expect(result['idempotency_key'], isNotNull);
      });

      test('should include idempotency key in header', () async {
        final testKey = 'test-idempotency-key-123';
        
        final mockClient = MockClient((request) async {
          expect(request.headers['Idempotency-Key'], testKey);
          
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'payment_url': 'https://paytabs.com/pay/abc123',
                'wallet_transaction_id': 42,
                'status': 'pending',
              }
            }),
            201,
          );
        });

        walletService = WalletService(client: mockClient);
        await walletService.topUp(
          amount: '100.00',
          currency: 'SAR',
          idempotencyKey: testKey,
        );
      });

      test('should throw exception on duplicate idempotency (409)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            json.encode({
              'success': false,
              'message': 'Duplicate transaction',
            }),
            409,
          );
        });

        walletService = WalletService(client: mockClient);

        expect(
          () => walletService.topUp(amount: '100.00', currency: 'SAR'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('topUpTest', () {
      test('should call test topup endpoint and return transaction details', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), contains('/wallet/topup/test'));
          expect(request.method, 'POST');

          final body = json.decode(request.body);
          expect(body['amount'], '10.00');
          expect(body['currency'], 'SAR');
          expect(body['idempotency_key'], isNotNull);

          return http.Response(
            json.encode({
              'success': true,
              'message': 'Top-up completed successfully (test)',
              'data': {
                'transaction_id': 789,
                'amount': '10.00',
                'currency': 'SAR',
                'balance_after': '110.00',
              }
            }),
            200,
          );
        });

        walletService = WalletService(client: mockClient);
        final result = await walletService.topUpTest(
          amount: '10.00',
          currency: 'SAR',
        );

        expect(result['transaction_id'], 789);
        expect(result['amount'], '10.00');
        expect(result['currency'], 'SAR');
        expect(result['balance_after'], '110.00');
        expect(result['idempotency_key'], isNotNull);
      });
    });

    group('chargeWalletForBooking', () {
      test('should charge wallet successfully', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), contains('/wallet/charge'));
          
          final body = json.decode(request.body);
          expect(body['amount'], '50.00');
          expect(body['currency'], 'SAR');
          expect(body['booking_reference'], 'BK123');

          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'transaction_id': 10,
                'new_balance': '200.00',
              }
            }),
            200,
          );
        });

        walletService = WalletService(client: mockClient);
        final result = await walletService.chargeWalletForBooking(
          amount: '50.00',
          currency: 'SAR',
          bookingReference: 'BK123',
        );

        expect(result['transaction_id'], 10);
        expect(result['new_balance'], '200.00');
      });

      test('should throw exception on insufficient balance (422)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            json.encode({
              'success': false,
              'message': 'Insufficient balance',
            }),
            422,
          );
        });

        walletService = WalletService(client: mockClient);

        expect(
          () => walletService.chargeWalletForBooking(
            amount: '1000.00',
            currency: 'SAR',
            bookingReference: 'BK123',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTransactionById', () {
      test('should find transaction in list', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'data': [
                  {
                    'id': 5,
                    'type': 'topup',
                    'amount': '100.00',
                    'currency': 'SAR',
                    'status': 'completed',
                    'created_at': '2025-01-01T00:00:00Z',
                  }
                ],
                'total': 1,
                'current_page': 1,
                'last_page': 1,
              }
            }),
            200,
          );
        });

        walletService = WalletService(client: mockClient);
        final transaction = await walletService.getTransactionById(5);

        expect(transaction, isNotNull);
        expect(transaction!.id, 5);
      });

      test('should return null if transaction not found', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'data': [],
                'total': 0,
                'current_page': 1,
                'last_page': 1,
              }
            }),
            200,
          );
        });

        walletService = WalletService(client: mockClient);
        final transaction = await walletService.getTransactionById(999);

        expect(transaction, isNull);
      });
    });
  });
}
