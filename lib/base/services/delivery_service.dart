import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../widgets/logger.dart';
import '../api/endpoint/api_endpoint.dart';
import '../../views/all_vendors_dashboard/model/delivery_check_model.dart';

final log = logger(DeliveryService);

class DeliveryService extends GetxService {
  static DeliveryService get instance => Get.find();

  // Cache delivery results per branch
  // Key: "branchId_lat_lng" (rounded to 2 decimals)
  final _deliveryCache = <String, DeliveryCheckResponse>{}.obs;

  /// Check delivery availability for a specific branch
  Future<DeliveryCheckResponse?> checkDeliveryAvailability({
    required int branchId,
    required double userLat,
    required double userLng,
  }) async {
    try {
      // Create cache key (round coordinates to 2 decimals for caching)
      final cacheKey = _getCacheKey(branchId, userLat, userLng);

      // Return cached result if available
      if (_deliveryCache.containsKey(cacheKey)) {
        log.i('Returning cached delivery result for branch $branchId');
        return _deliveryCache[cacheKey];
      }

      // Make API call
      final url = Uri.parse('${ApiConfig.mainDomain}${ApiEndpoint.deliveryCheck.path}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'branch_id': branchId,
          'user_lat': userLat,
          'user_lng': userLng,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 400 || response.statusCode == 404) {
        final result = deliveryCheckResponseFromJson(response.body);
        
        // Cache the result
        _deliveryCache[cacheKey] = result;
        
        log.i('Delivery check for branch $branchId: ${result.status}');
        return result;
      } else {
        log.e('Delivery check failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log.e('Error checking delivery availability: $e');
      return null;
    }
  }

  /// Check delivery for multiple branches at once
  Future<Map<int, DeliveryCheckResponse>> checkMultipleBranches({
    required List<int> branchIds,
    required double userLat,
    required double userLng,
  }) async {
    final results = <int, DeliveryCheckResponse>{};

    // Process branches in parallel with a limit
    final futures = branchIds.map((branchId) async {
      final result = await checkDeliveryAvailability(
        branchId: branchId,
        userLat: userLat,
        userLng: userLng,
      );
      if (result != null) {
        results[branchId] = result;
      }
    });

    await Future.wait(futures);
    return results;
  }

  String _getCacheKey(int branchId, double lat, double lng) {
    final roundedLat = (lat * 100).round() / 100;
    final roundedLng = (lng * 100).round() / 100;
    return '${branchId}_${roundedLat}_$roundedLng';
  }

  /// Clear delivery cache
  void clearCache() {
    _deliveryCache.clear();
    log.i('Delivery cache cleared');
  }

  /// Clear cache for specific branch
  void clearBranchCache(int branchId) {
    _deliveryCache.removeWhere((key, value) => key.startsWith('$branchId'));
    log.i('Cleared cache for branch $branchId');
  }
}
