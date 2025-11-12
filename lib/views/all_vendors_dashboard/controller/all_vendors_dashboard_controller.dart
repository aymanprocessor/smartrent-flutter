import 'package:carbo/base/utils/basic_import.dart';
import 'package:dynamic_languages/dynamic_languages.dart';
import 'package:carbo/base/widgets/logger.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../model/vendor_cars_model.dart';
import 'package:http/http.dart' as http;
import 'package:carbo/base/utils/local_storage.dart';

final log = logger(AllVendorsDashboardController);

class AllVendorsDashboardController extends GetxController {
  // Basic selections
  RxInt currentIndex = 0.obs;
  var selectedCarIndex = 0.obs;
  RxString selectedCarId = ''.obs;
  RxString carToken = ''.obs;

  // Cars list - New vendor cars model
  var vendorCars = <VendorCar>[].obs;
  RxString carImgUrl = ''.obs;

  // Pagination
  Rx<Pagination?> pagination = Rx<Pagination?>(null);
  RxInt currentPage = 1.obs;
  RxBool hasMore = false.obs;

  // Meta info
  Rx<MetaInfo?> metaInfo = Rx<MetaInfo?>(null);

  // Loading states
  final _isLoad = false.obs;
  bool get isLoad => _isLoad.value;

  final _isSearchingCar = false.obs;
  bool get isSearchingCar => _isSearchingCar.value;

  final _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;

  // Pull to refresh state
  final _isRefreshing = false.obs;
  bool get isRefreshing => _isRefreshing.value;

  // Favorites
  var favoriteCars = <String>[].obs;

  // Sorting
  RxString sortOption =
      'popularity'.obs; // popularity, priceLowToHigh, priceHighToLow, rating

  // Quick filters
  RxString quickFilter = 'all'.obs; // all, available, limited

  @override
  void onInit() {
    super.onInit();
    log.i('AllVendorsDashboardController initialized');
    log.i('Current language: ${DynamicLanguage.selectedLanguage.value}');
    log.i('App language is loading: ${DynamicLanguage.isLoading}');
    log.i('Language direction: ${DynamicLanguage.languageDirection}');
    // Load all cars without filters
    searchAllVendorsCars();
  }

  // SEARCH ALL CARS FROM ALL VENDORS - Simplified without filters
  Future<void> searchAllVendorsCars({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore.value || _isLoadingMore.value) return;
      _isLoadingMore.value = true;
      currentPage.value++;
    } else {
      vendorCars.clear();
      currentPage.value = 1;
      _isSearchingCar.value = true;
    }

    try {
      // Build query parameters - only pagination, no filters
      Map<String, String> queryParams = {
        'page': currentPage.value.toString(),
        'per_page': '15',
      };

      final token = LocalStorage.token;
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Build URI with query parameters properly
      final baseUri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiEndpoint.vendorCars.path}',
      );
      final uri = baseUri.replace(queryParameters: queryParams);

      log.i('Fetching vendor cars from: $uri');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        VendorCarsModel? vendorCarsModel;
        try {
          vendorCarsModel = vendorCarsModelFromJson(response.body);
        } catch (e) {
          log.e('Failed to parse vendor cars JSON: $e');
          log.d(
            'Response body (first 2000 chars): ${response.body.length > 2000 ? response.body.substring(0, 2000) : response.body}',
          );
          throw e;
        }

        if (vendorCarsModel.success) {
          if (loadMore) {
            vendorCars.addAll(vendorCarsModel.data.cars);
          } else {
            vendorCars.value = vendorCarsModel.data.cars;
          }

          pagination.value = vendorCarsModel.data.pagination;
          hasMore.value = vendorCarsModel.data.pagination.hasMore;
          metaInfo.value = vendorCarsModel.data.meta;

          if (vendorCars.isEmpty && !loadMore) {
            CustomSnackBar.error(
              DynamicLanguage.isLoading
                  ? ""
                  : DynamicLanguage.key(Strings.noCarFindMessage),
            );
          }
        } else {
          CustomSnackBar.error(
            vendorCarsModel.message.isNotEmpty
                ? vendorCarsModel.message.first
                : 'Failed to load cars',
          );
        }
      } else {
        log.e('Failed to fetch vendor cars: ${response.statusCode}');
        CustomSnackBar.error('Failed to load cars. Please try again.');
      }
    } catch (e) {
      log.e('searchAllVendorsCars error: $e');
      CustomSnackBar.error('An error occurred. Please try again.');
    } finally {
      if (loadMore) {
        _isLoadingMore.value = false;
      } else {
        _isSearchingCar.value = false;
      }
    }
  }

  // Pull to refresh
  Future<void> refreshCars() async {
    _isRefreshing.value = true;
    log.i('Refreshing vendor cars list');
    await searchAllVendorsCars();
    _isRefreshing.value = false;
  }

  // Toggle favorite
  void toggleFavorite(String carId) {
    if (favoriteCars.contains(carId)) {
      favoriteCars.remove(carId);
      log.i('Removed car $carId from favorites');
    } else {
      favoriteCars.add(carId);
      log.i('Added car $carId to favorites');
    }
    // TODO: Persist to backend or local storage
  }

  bool isFavorite(String carId) {
    return favoriteCars.contains(carId);
  }

  // Change sort option
  void changeSortOption(String option) {
    sortOption.value = option;
    log.i('Sort option changed to: $option');
    _applySortAndFilter();
  }

  // Change quick filter
  void changeQuickFilter(String filter) {
    quickFilter.value = filter;
    log.i('Quick filter changed to: $filter');
    _applySortAndFilter();
  }

  // Apply sorting and filtering
  void _applySortAndFilter() {
    var filteredCars = List<VendorCar>.from(vendorCars);

    // Apply filter
    if (quickFilter.value == 'available') {
      filteredCars = filteredCars
          .where((car) => car.availabilityStatus == 'available')
          .toList();
    } else if (quickFilter.value == 'limited') {
      filteredCars = filteredCars
          .where((car) => car.availabilityStatus != 'available')
          .toList();
    }

    // Apply sort
    switch (sortOption.value) {
      case 'priceLowToHigh':
        filteredCars.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'priceHighToLow':
        filteredCars.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'rating':
        filteredCars.sort((a, b) => b.vendorRating.compareTo(a.vendorRating));
        break;
      case 'popularity':
      default:
        // Keep original order (assumed to be popularity-based from API)
        break;
    }

    vendorCars.value = filteredCars;
    log.i('Applied sort and filter. Result: ${filteredCars.length} cars');
  }
}
