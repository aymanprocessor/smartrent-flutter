import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/basic_import.dart';
import '../endpoint/api_endpoint.dart';
import '../../utils/local_storage.dart';
import '../../widgets/logger.dart';

class PayTabsService {
  static final log = logger(PayTabsService);

  /// Create a payment transaction
  /// Returns payment URL and transaction reference
  static Future<Map<String, dynamic>?> createPayment({
    required String cartId,
    required double cartAmount,
    required String cartDescription,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? customerStreet,
    String? customerCity,
    String? customerState,
    String? customerCountry,
    String? customerZip,
    String transactionType = 'sale',
    String transactionClass = 'ecom',
    String paymentMethod = 'all',
    String language = 'en',
    bool hideShipping = true,
    Map<String, dynamic>? userDefined,
  }) async {
    try {
      final url = Uri.parse(ApiEndpoint.paytabsCreatePayment.url());
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
        body: jsonEncode({
          'cart_id': cartId,
          'cart_amount': cartAmount,
          'cart_description': cartDescription,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'customer_street': customerStreet ?? '',
          'customer_city': customerCity ?? '',
          'customer_state': customerState ?? '',
          'customer_country': customerCountry ?? 'SAU',
          'customer_zip': customerZip ?? '00000',
          'transaction_type': transactionType,
          'transaction_class': transactionClass,
          'payment_method': paymentMethod,
          'language': language,
          'hide_shipping': hideShipping,
          'user_defined': userDefined,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        log.e('PayTabs Create Payment Error: ${response.body}');
        CustomSnackBar.error('Failed to create payment: ${response.body}');
        return null;
      }
    } catch (e) {
      log.e('PayTabs Create Payment Exception: $e');
      CustomSnackBar.error('Error creating payment: $e');
      return null;
    }
  }

  /// Verify payment status
  /// Returns payment details and status
  static Future<Map<String, dynamic>?> verifyPayment(
      String transactionRef) async {
    try {
      final url = Uri.parse(ApiEndpoint.paytabsVerifyPayment.url());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
        body: jsonEncode({
          'transaction_ref': transactionRef,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        log.e('PayTabs Verify Payment Error: ${response.body}');
        CustomSnackBar.error('Failed to verify payment: ${response.body}');
        return null;
      }
    } catch (e) {
      log.e('PayTabs Verify Payment Exception: $e');
      CustomSnackBar.error('Error verifying payment: $e');
      return null;
    }
  }

  /// Refund a payment transaction
  /// Returns refund status
  static Future<Map<String, dynamic>?> refundPayment({
    required String transactionRef,
    required double refundAmount,
    String? refundReason,
  }) async {
    try {
      final url = Uri.parse(ApiEndpoint.paytabsRefundPayment.url());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
        body: jsonEncode({
          'transaction_ref': transactionRef,
          'refund_amount': refundAmount,
          'refund_reason': refundReason ?? 'Customer refund request',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        log.e('PayTabs Refund Payment Error: ${response.body}');
        CustomSnackBar.error('Failed to refund payment: ${response.body}');
        return null;
      }
    } catch (e) {
      log.e('PayTabs Refund Payment Exception: $e');
      CustomSnackBar.error('Error refunding payment: $e');
      return null;
    }
  }

  /// Get available payment methods
  static Future<Map<String, dynamic>?> getPaymentMethods() async {
    try {
      final url = Uri.parse(ApiEndpoint.paytabsPaymentMethods.url());

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        log.e('PayTabs Get Payment Methods Error: ${response.body}');
        return null;
      }
    } catch (e) {
      log.e('PayTabs Get Payment Methods Exception: $e');
      return null;
    }
  }

  /// Get supported currencies
  static Future<Map<String, dynamic>?> getSupportedCurrencies() async {
    try {
      final url = Uri.parse(ApiEndpoint.paytabsCurrencies.url());

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        log.e('PayTabs Get Currencies Error: ${response.body}');
        return null;
      }
    } catch (e) {
      log.e('PayTabs Get Currencies Exception: $e');
      return null;
    }
  }
}
