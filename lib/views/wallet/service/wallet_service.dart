import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:carbo/base/api/endpoint/api_endpoint.dart';
import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/models/wallet_balance.dart';
import 'package:carbo/models/wallet_transaction.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class WalletService {
  final http.Client _client;
  final Logger log = Logger();
  final _uuid = const Uuid();

  WalletService({http.Client? client}) : _client = client ?? http.Client();

  /// Get authorization headers with Bearer token
  Map<String, String> _getHeaders({String? idempotencyKey}) {
    final token = LocalStorage.token;
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
    };
    return headers;
  }

  /// Get wallet balance(s)
  /// If [currency] is provided, returns balance for that currency only
  /// Otherwise returns all balances grouped by currency
  /// 
  /// May return partial results if some currencies cannot be resolved (API returns placeholder entries).
  /// Check [WalletBalance.hasError] to detect partial/failed entries.
  Future<List<WalletBalance>> getBalance({String? currency}) async {
    try {
      final uri = Uri.parse(
        ApiEndpoint.walletBalance.url(
          params: currency != null ? {'currency': currency} : null,
        ),
      );

      log.i('Fetching wallet balance${currency != null ? ' for $currency' : ''}');

      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      log.i('Balance response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final balances = (data['data']['balances'] as List)
              .map((b) => WalletBalance.fromJson(b))
              .toList();
          
          // Log partial results if any have errors
          final errorCount = balances.where((b) => b.hasError).length;
          if (errorCount > 0) {
            log.w('Fetched ${balances.length} balance(s) with $errorCount error(s)');
            for (final b in balances.where((b) => b.hasError)) {
              log.w('  Currency ${b.currency}: ${b.error}');
            }
          } else {
            log.i('Fetched ${balances.length} balance(s) successfully');
          }
          
          return balances;
        }
      }

      throw Exception('Failed to fetch balance: ${response.statusCode}');
    } on SocketException catch (e) {
      log.e('Network error fetching balance: $e');
      throw Exception('No internet connection');
    } on TimeoutException catch (e) {
      log.e('Timeout fetching balance: $e');
      throw Exception('Request timed out');
    } catch (e) {
      log.e('Error fetching balance: $e');
      rethrow;
    }
  }

  /// Get paginated wallet transactions
  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int perPage = 20,
    String? currency,
    WalletTransactionType? type,
  }) async {
    try {
      final params = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (currency != null) 'currency': currency,
        if (type != null) 'type': type.toApiString(),
      };

      final uri = Uri.parse(ApiEndpoint.walletTransactions.url(params: params));

      log.i('Fetching transactions: page=$page, perPage=$perPage');

      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final transactions = (data['data']['data'] as List)
              .map((t) => WalletTransaction.fromJson(t))
              .toList();
          
          return {
            'transactions': transactions,
            'total': data['data']['total'] ?? 0,
            'currentPage': data['data']['current_page'] ?? 1,
            'lastPage': data['data']['last_page'] ?? 1,
          };
        }
      }

      throw Exception('Failed to fetch transactions: ${response.statusCode}');
    } on SocketException catch (e) {
      log.e('Network error fetching transactions: $e');
      throw Exception('No internet connection');
    } on TimeoutException catch (e) {
      log.e('Timeout fetching transactions: $e');
      throw Exception('Request timed out');
    } catch (e) {
      log.e('Error fetching transactions: $e');
      rethrow;
    }
  }

  /// Initiate wallet top-up via PayTabs
  /// Returns payment URL and transaction ID
  /// Idempotency key is used to prevent duplicate charges
  Future<Map<String, dynamic>> topUp({
    required String amount,
    required String currency,
    String? description,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? _uuid.v4();
      
      final body = {
        'amount': amount,
        'currency': currency,
        'idempotency_key': key,
        'description': description ?? 'Mobile top up',
      };

      log.i('Initiating top-up: amount=$amount, currency=$currency, idempotencyKey=$key');

      final response = await _client
          .post(
            Uri.parse(ApiEndpoint.walletTopUp.url()),
            headers: _getHeaders(idempotencyKey: key),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 20));

      log.i('Top-up response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final transactionId = data['data']['wallet_transaction_id'];
          final paymentUrl = data['data']['payment_url'];
          log.i('Top-up initiated successfully: transactionId=$transactionId, url=$paymentUrl');
          return {
            'payment_url': paymentUrl,
            'wallet_transaction_id': transactionId,
            'status': data['data']['status'],
            'idempotency_key': key,
          };
        }
      }

      // Handle duplicate idempotency (409) or validation errors (400/422)
      if (response.statusCode == 409) {
        final data = json.decode(response.body);
        log.w('Duplicate top-up request detected (409): ${data['message']}');
        throw Exception(data['message'] ?? 'Duplicate transaction');
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final data = json.decode(response.body);
        log.w('Validation error (${response.statusCode}): ${data['message']}');
        throw Exception(data['message'] ?? 'Invalid request');
      }

      throw Exception('Failed to initiate top-up: ${response.statusCode}');
    } on SocketException catch (e) {
      log.e('Network error initiating top-up: $e');
      throw Exception('No internet connection');
    } on TimeoutException catch (e) {
      log.e('Timeout initiating top-up: $e');
      throw Exception('Request timed out');
    } catch (e) {
      log.e('Error initiating top-up: $e');
      rethrow;
    }
  }

  /// Test top-up (QA / development only)
  /// Immediately credits the authenticated user's wallet without invoking payment gateway.
  /// Returns transaction details and new balance. Uses the test-only endpoint.
  Future<Map<String, dynamic>> topUpTest({
    required String amount,
    required String currency,
    String? description,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? _uuid.v4();

      final body = {
        'amount': amount,
        'currency': currency,
        'idempotency_key': key,
        'description': description ?? 'QA credit',
      };

      log.i('Initiating test top-up: amount=$amount, currency=$currency, idempotencyKey=$key');

      final response = await _client
          .post(
            Uri.parse(ApiEndpoint.walletTopUpTest.url()),
            headers: _getHeaders(idempotencyKey: key),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 20));

      log.i('Test top-up response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Example response includes transaction_id and balance_after
          final transactionId = data['data']['transaction_id'] ?? data['data']['wallet_transaction_id'];
          final balanceAfter = data['data']['balance_after'] ?? data['data']['new_balance'];
          log.i('Test top-up completed: transactionId=$transactionId, newBalance=$balanceAfter');
          return {
            'transaction_id': transactionId,
            'amount': data['data']['amount'] ?? amount,
            'currency': data['data']['currency'] ?? currency,
            'balance_after': balanceAfter,
            'idempotency_key': key,
          };
        }
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final data = json.decode(response.body);
        log.w('Validation error (${response.statusCode}): ${data['message']}');
        throw Exception(data['message'] ?? 'Invalid request');
      }

      if (response.statusCode == 409) {
        final data = json.decode(response.body);
        log.w('Duplicate test top-up (409): ${data['message']}');
        throw Exception(data['message'] ?? 'Duplicate transaction');
      }

      throw Exception('Failed to perform test top-up: ${response.statusCode}');
    } on SocketException catch (e) {
      log.e('Network error initiating test top-up: $e');
      throw Exception('No internet connection');
    } on TimeoutException catch (e) {
      log.e('Timeout initiating test top-up: $e');
      throw Exception('Request timed out');
    } catch (e) {
      log.e('Error initiating test top-up: $e');
      rethrow;
    }
  }

  /// Charge wallet for booking
  /// This deducts from wallet balance
  /// Returns transaction ID and new balance if successful
  Future<Map<String, dynamic>> chargeWalletForBooking({
    required String amount,
    required String currency,
    required String bookingReference,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? _uuid.v4();
      
      final body = {
        'amount': amount,
        'currency': currency,
        'booking_reference': bookingReference,
        'idempotency_key': key,
        'description': 'Booking payment: $bookingReference',
      };

      log.i('Charging wallet: amount=$amount, currency=$currency, booking=$bookingReference, idempotencyKey=$key');

      final response = await _client
          .post(
            Uri.parse(ApiEndpoint.walletChargeForBooking.url()),
            headers: _getHeaders(idempotencyKey: key),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      log.i('Charge response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final newBalance = data['data']['new_balance'];
          log.i('Wallet charged successfully, new balance: $newBalance');
          return {
            'transaction_id': data['data']['transaction_id'],
            'new_balance': newBalance,
            'idempotency_key': key,
          };
        }
      }

      // Insufficient balance (422)
      if (response.statusCode == 422) {
        final data = json.decode(response.body);
        log.w('Insufficient wallet balance: ${data['message']}');
        throw Exception(data['message'] ?? 'Insufficient balance');
      }

      throw Exception('Failed to charge wallet: ${response.statusCode}');
    } on SocketException catch (e) {
      log.e('Network error charging wallet: $e');
      throw Exception('No internet connection');
    } on TimeoutException catch (e) {
      log.e('Timeout charging wallet: $e');
      throw Exception('Request timed out');
    } catch (e) {
      log.e('Error charging wallet: $e');
      rethrow;
    }
  }

  /// Poll transaction status
  /// Used after PayTabs redirect to verify payment completion
  Future<WalletTransaction?> getTransactionById(int transactionId) async {
    try {
      log.i('Polling transaction $transactionId');
      
      final response = await getTransactions(perPage: 100);
      final transactions = response['transactions'] as List<WalletTransaction>;
      
      final transaction = transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      log.i('Transaction $transactionId status: ${transaction.status}');
      return transaction;
    } catch (e) {
      log.e('Error polling transaction: $e');
      return null;
    }
  }

  /// Poll transaction until completed or max attempts reached
  Future<WalletTransaction?> pollTransactionUntilComplete({
    required int transactionId,
    int maxAttempts = 10,
    Duration initialDelay = const Duration(seconds: 2),
  }) async {
    var attempts = 0;
    var delay = initialDelay;

    while (attempts < maxAttempts) {
      await Future.delayed(delay);
      
      final transaction = await getTransactionById(transactionId);
      
      if (transaction != null) {
        if (transaction.isCompleted || transaction.isFailed) {
          return transaction;
        }
      }

      attempts++;
      delay = Duration(seconds: delay.inSeconds * 2); // Exponential backoff
      log.i('Poll attempt $attempts/$maxAttempts, next delay: ${delay.inSeconds}s');
    }

    log.w('Max polling attempts reached for transaction $transactionId');
    return null;
  }

  void dispose() {
    _client.close();
  }
}
