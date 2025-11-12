import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/logger.dart';

final log = logger(LanguageService);

class LanguageService {
  /// Fetch language data with proper UTF-8 handling
  static Future<Map<String, dynamic>> fetchLanguageData(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Ensure UTF-8 decoding
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return decoded as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to fetch language data: ${response.statusCode}',
        );
      }
    } catch (e) {
      log.e('Error fetching language data: $e');
      rethrow;
    }
  }
}
