# PayTabs Flutter Integration with Laravel Backend

This guide explains how to integrate your Flutter mobile app with the PayTabs-enabled Laravel backend.

## Overview

The payment flow works as follows:

1. **Flutter App** → Calls Laravel API to create a payment
2. **Laravel Backend** → Creates PayTabs hosted payment page
3. **Laravel Backend** → Returns payment URL to Flutter
4. **Flutter App** → Opens payment URL in WebView or browser
5. **User** → Completes payment on PayTabs hosted page
6. **PayTabs** → Sends callback to Laravel backend
7. **PayTabs** → Redirects user back to return URL
8. **Flutter App** → Verifies payment status with Laravel API

## Prerequisites

### Laravel Backend Setup

Ensure your Laravel backend is properly configured:

1. PayTabs credentials set in `.env`:

```env
PAYTABS_PROFILE_ID=your_profile_id
PAYTABS_SERVER_KEY=your_server_key
PAYTABS_CURRENCY=SAR
PAYTABS_REGION=SAU
PAYTABS_ENVIRONMENT=sandbox  # or 'production'
```

2. Publicly accessible callback URL (required for PayTabs to send payment notifications)

### Flutter Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
    http: ^1.1.0
    webview_flutter: ^4.4.2 # For displaying PayTabs payment page
    url_launcher: ^6.2.1 # Alternative to WebView
```

## API Endpoints

Base URL: `https://your-domain.com/api/paytabs`

### 1. Create Payment

**Endpoint:** `POST /api/paytabs/create-payment`

**Authentication:** Required (Bearer token)

**Request Body:**

```json
{
    "cart_id": "ORDER_12345",
    "cart_amount": 100.5,
    "cart_description": "Car rental booking #12345",
    "customer_name": "Ahmed Ali",
    "customer_email": "ahmed@example.com",
    "customer_phone": "+966501234567",
    "customer_street": "King Fahd Road",
    "customer_city": "Riyadh",
    "customer_state": "Riyadh",
    "customer_country": "SAU",
    "customer_zip": "12345",
    "transaction_type": "sale",
    "transaction_class": "ecom",
    "payment_method": "all",
    "language": "en",
    "hide_shipping": true,
    "user_defined": {
        "booking_id": "12345",
        "user_id": "67890"
    }
}
```

**Response (Success):**

```json
{
    "success": true,
    "message": "Payment page created successfully",
    "data": {
        "payment_url": "https://secure.paytabs.sa/payment/page/...",
        "transaction_ref": "TST2213800357411"
    }
}
```

### 2. Verify Payment

**Endpoint:** `POST /api/paytabs/verify-payment`

**Authentication:** Required (Bearer token)

**Request Body:**

```json
{
    "transaction_ref": "TST2213800357411"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Payment successful",
    "data": {
        "transaction_ref": "TST2213800357411",
        "cart_id": "ORDER_12345",
        "amount": 100.5,
        "currency": "SAR",
        "status": "A",
        "code": "100",
        "transaction_time": "2025-11-07 14:30:00"
    }
}
```

### 3. Refund Payment

**Endpoint:** `POST /api/paytabs/refund-payment`

**Authentication:** Required (Bearer token)

**Request Body:**

```json
{
    "transaction_ref": "TST2213800357411",
    "refund_amount": 100.5,
    "refund_reason": "Customer cancellation"
}
```

### 4. Get Payment Methods

**Endpoint:** `GET /api/paytabs/payment-methods`

**Authentication:** Required (Bearer token)

### 5. Get Supported Currencies

**Endpoint:** `GET /api/paytabs/currencies`

**Authentication:** Required (Bearer token)

## Flutter Implementation

### 1. API Service Class

Create a PayTabs service class in Flutter:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PayTabsService {
  final String baseUrl;
  final String authToken;

  PayTabsService({
    required this.baseUrl,
    required this.authToken,
  });

  Future<Map<String, dynamic>> createPayment({
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
    final url = Uri.parse('$baseUrl/api/paytabs/create-payment');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'cart_id': cartId,
        'cart_amount': cartAmount,
        'cart_description': cartDescription,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'customer_street': customerStreet,
        'customer_city': customerCity,
        'customer_state': customerState,
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
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String transactionRef) async {
    final url = Uri.parse('$baseUrl/api/paytabs/verify-payment');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'transaction_ref': transactionRef,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> refundPayment({
    required String transactionRef,
    required double refundAmount,
    String? refundReason,
  }) async {
    final url = Uri.parse('$baseUrl/api/paytabs/refund-payment');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'transaction_ref': transactionRef,
        'refund_amount': refundAmount,
        'refund_reason': refundReason,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to refund payment: ${response.body}');
    }
  }
}
```

### 2. Payment Screen Widget

Create a payment screen that opens the PayTabs hosted page:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String transactionRef;
  final Function(bool success, String transactionRef) onPaymentComplete;

  const PaymentScreen({
    Key? key,
    required this.paymentUrl,
    required this.transactionRef,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check if redirected to return URL
            if (url.contains('/payment/return')) {
              _handlePaymentReturn();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('/payment/return')) {
              _handlePaymentReturn();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentReturn() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Verify payment with backend
      final payTabsService = PayTabsService(
        baseUrl: 'https://your-domain.com',
        authToken: 'your_auth_token',
      );

      final result = await payTabsService.verifyPayment(widget.transactionRef);

      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pop(); // Close payment screen

      // Call callback with result
      widget.onPaymentComplete(
        result['success'] == true,
        widget.transactionRef,
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pop(); // Close payment screen
      widget.onPaymentComplete(false, widget.transactionRef);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onPaymentComplete(false, widget.transactionRef);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
```

### 3. Usage Example

Here's how to use the payment flow in your app:

```dart
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Initialize PayTabs service
      final payTabsService = PayTabsService(
        baseUrl: 'https://your-domain.com',
        authToken: 'your_auth_token', // Get from your auth system
      );

      // Create payment
      final paymentResponse = await payTabsService.createPayment(
        cartId: 'ORDER_12345',
        cartAmount: 100.50,
        cartDescription: 'Car rental booking #12345',
        customerName: 'Ahmed Ali',
        customerEmail: 'ahmed@example.com',
        customerPhone: '+966501234567',
        customerCity: 'Riyadh',
        customerCountry: 'SAU',
        language: 'en',
        userDefined: {
          'booking_id': '12345',
          'user_id': '67890',
        },
      );

      setState(() {
        _isProcessing = false;
      });

      if (paymentResponse['success']) {
        final paymentUrl = paymentResponse['data']['payment_url'];
        final transactionRef = paymentResponse['data']['transaction_ref'];

        // Navigate to payment screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              paymentUrl: paymentUrl,
              transactionRef: transactionRef,
              onPaymentComplete: _handlePaymentComplete,
            ),
          ),
        );
      } else {
        _showError('Failed to create payment');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Error: $e');
    }
  }

  void _handlePaymentComplete(bool success, String transactionRef) {
    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful'),
          content: Text('Transaction: $transactionRef'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to success screen or update UI
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Failed'),
          content: const Text('Your payment was not completed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _processPayment,
                child: const Text('Pay Now'),
              ),
      ),
    );
  }
}
```

## Payment Status Codes

PayTabs uses the following status codes:

-   **A** - Approved (Payment successful)
-   **H** - Hold (Requires action)
-   **P** - Pending
-   **V** - Voided
-   **E** - Error
-   **D** - Declined

## Testing

### Sandbox Test Cards

When using sandbox mode, use these test cards:

**Successful Payment:**

-   Card Number: `4111 1111 1111 1111`
-   Expiry: Any future date
-   CVV: `123`

**Declined Payment:**

-   Card Number: `4000 0000 0000 0002`
-   Expiry: Any future date
-   CVV: `123`

### Testing Checklist

-   [ ] Create payment successfully returns payment URL
-   [ ] WebView loads and displays PayTabs payment page
-   [ ] Successful payment redirects to return URL
-   [ ] Payment verification returns correct status
-   [ ] Failed payment is handled gracefully
-   [ ] Network errors are caught and displayed
-   [ ] Callback endpoint receives payment notifications

## Security Best Practices

1. **Never expose server key in Flutter app** - All API calls should go through your Laravel backend
2. **Use HTTPS only** - Ensure your Laravel backend uses SSL/TLS
3. **Validate on backend** - Always verify payment status on the server side
4. **Implement rate limiting** - Protect your payment endpoints from abuse
5. **Store auth tokens securely** - Use flutter_secure_storage or similar
6. **Validate callback signatures** - Verify PayTabs callbacks are authentic (implement in Laravel)

## Troubleshooting

### Common Issues

**Issue:** Payment URL not loading

-   **Solution:** Check CORS settings in Laravel backend
-   Ensure `return_url` and `callback_url` are publicly accessible

**Issue:** Callback not received

-   **Solution:** Make sure your Laravel app is accessible from the internet (not localhost)
-   Check PayTabs logs in `storage/logs/PayTabs.log`

**Issue:** Payment verification fails

-   **Solution:** Wait a few seconds before verifying (payment may still be processing)
-   Check transaction reference is correct

**Issue:** WebView shows blank page

-   **Solution:** Enable JavaScript in WebView
-   Check payment URL is valid and not expired

## Additional Resources

-   [PayTabs Official Documentation](https://docs.paytabs.com/)
-   [PayTabs Laravel Package](https://github.com/paytabscom/paytabs-laravel)
-   [Flutter WebView Plugin](https://pub.dev/packages/webview_flutter)

## Support

For Laravel backend issues:

-   Check logs: `storage/logs/PayTabs.log`
-   Check Laravel logs: `storage/logs/laravel.log`

For PayTabs issues:

-   Contact PayTabs support: customercare@paytabs.com
-   Visit: https://support.paytabs.com/

## Example Project Structure

```
flutter_app/
├── lib/
│   ├── models/
│   │   └── payment_request.dart
│   ├── services/
│   │   └── paytabs_service.dart
│   ├── screens/
│   │   ├── payment_screen.dart
│   │   └── booking_screen.dart
│   └── main.dart
└── pubspec.yaml
```

---

**Last Updated:** November 7, 2025
