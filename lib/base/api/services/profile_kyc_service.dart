import 'dart:convert';
import 'package:http/http.dart' as http;
import '../endpoint/api_endpoint.dart';
import '../model/kyc_model.dart';
import '../model/next_action_response.dart';
import '../../utils/local_storage.dart';
import '../../widgets/logger.dart';

final log = logger(ProfileKycService);

class ProfileKycService {
  static String lastError = '';

  static Future<Map<String, dynamic>?> getKycStatus() async {
    try {
      final token = LocalStorage.token;
      if (token.isEmpty) return null;
      final response = await http.get(
        Uri.parse(ApiEndpoint.kycStatus.url()),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError = _errorMessage(response.body, response.statusCode);
        return null;
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null;
    } catch (e) {
      log.e('getKycStatus error: $e');
      return null;
    }
  }

  // Enhanced OTP verify with next_action response
  static Future<OtpVerifyResponseModel?> verifyOtpWithNextAction({
    required String mobileCode,
    required String mobile,
    required String otpCode,
  }) async {
    try {
      final url = ApiEndpoint.verifyOtp.url();

      log.i('POST $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobile_code': mobileCode,
          'mobile': mobile,
          'otp_code': otpCode,
        }),
      );

      log.i('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return OtpVerifyResponseModel.fromJson(jsonData);
      } else {
        // Log error response body for debugging
        log.e('OTP verify failed with status ${response.statusCode}');
        log.e('Response body: ${response.body}');
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          log.e(
            'Error message: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}',
          );
        } catch (_) {}
      }

      return null;
    } catch (e) {
      log.e('verifyOtpWithNextAction error: $e');
      return null;
    }
  }

  // Get profile status
  static Future<ProfileStatusModel?> getProfileStatus() async {
    try {
      final token = LocalStorage.token;
      if (token.isEmpty) {
        log.w('No token found');
        lastError =
            'Your session has expired. Sign in again to load identity verification.';
        return null;
      }

      final url = ApiEndpoint.profileStatus.url();

      log.i('GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log.i('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProfileStatusModel.fromJson(jsonData);
      } else {
        log.e('getProfileStatus failed with status ${response.statusCode}');
        log.e('Response body: ${response.body}');
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          log.e(
            'Error message: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}',
          );
        } catch (_) {}
      }

      return null;
    } catch (e) {
      log.e('getProfileStatus error: $e');
      return null;
    }
  }

  // Complete profile
  static Future<ProfileCompleteResponseModel?> completeProfile({
    required String firstname,
    required String lastname,
    required String email,
  }) async {
    try {
      final token = LocalStorage.token;
      if (token.isEmpty) {
        log.w('No token found');
        return null;
      }

      final url = ApiEndpoint.profileComplete.url();

      log.i('POST $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
        }),
      );

      log.i('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProfileCompleteResponseModel.fromJson(jsonData);
      } else {
        log.e('completeProfile failed with status ${response.statusCode}');
        log.e('Response body: ${response.body}');
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          log.e(
            'Error message: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}',
          );
        } catch (_) {}
      }

      return null;
    } catch (e) {
      log.e('completeProfile error: $e');
      return null;
    }
  }

  // Get KYC fields
  static Future<KycFieldsResponseModel?> getKycFields() async {
    lastError = '';
    try {
      final token = LocalStorage.token;
      if (token.isEmpty) {
        log.w('No token found');
        lastError =
            'Your session has expired. Sign in again to load identity verification.';
        return null;
      }

      final url = ApiEndpoint.kycFields.url();

      log.i('GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log.i('Response status: ${response.statusCode}');

      lastError = '';
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = KycFieldsResponseModel.fromJson(jsonData);
        if (result.fields == null || result.fields!.isEmpty) {
          lastError = result.message.isNotEmpty
              ? result.message
              : 'No active identity verification fields are configured. Please contact support.';
        }
        return result;
      } else {
        lastError = _errorMessage(response.body, response.statusCode);
        log.e('getKycFields failed with status ${response.statusCode}');
        log.e('Response body: ${response.body}');
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          log.e(
            'Error message: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}',
          );
        } catch (_) {}
      }

      return null;
    } catch (e) {
      log.e('getKycFields error: $e');
      lastError =
          'Could not reach the identity verification service. Check your connection and try again.';
      return null;
    }
  }

  // Submit KYC with multipart/form-data
  static Future<KycSubmitResponseModel?> submitKyc({
    required Map<String, String> fields,
    required Map<String, String> filePaths,
  }) async {
    try {
      final token = LocalStorage.token;
      if (token.isEmpty) {
        log.w('No token found');
        return null;
      }

      final url = ApiEndpoint.kycSubmit.url();

      log.i('POST (multipart) $url');

      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add file fields
      for (var entry in filePaths.entries) {
        final file = await http.MultipartFile.fromPath(entry.key, entry.value);
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log.i('Response status: ${response.statusCode}');

      lastError = '';
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        return KycSubmitResponseModel.fromJson(jsonData);
      } else {
        lastError = _errorMessage(response.body, response.statusCode);
        log.e('submitKyc failed with status ${response.statusCode}');
        log.e('Response body: ${response.body}');
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          log.e(
            'Error message: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}',
          );
        } catch (_) {}
      }

      return null;
    } catch (e) {
      log.e('submitKyc error: $e');
      return null;
    }
  }

  static String _errorMessage(String body, int status) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final errors = json['errors'];
      final details = errors is Map
          ? errors.entries
                .map(
                  (e) =>
                      '${e.key}: ${e.value is List ? (e.value as List).join(', ') : e.value}',
                )
                .join('\n')
          : '';
      final message = json['message']?.toString() ?? json['error']?.toString();
      final detailsText = [
        if (message != null && message.isNotEmpty) message,
        if (details.isNotEmpty) details,
      ].join('\n');
      return detailsText.isNotEmpty
          ? detailsText
          : 'Identity verification request failed ($status). Please try again.';
    } catch (_) {
      return 'Request failed ($status). Please try again.';
    }
  }
}
