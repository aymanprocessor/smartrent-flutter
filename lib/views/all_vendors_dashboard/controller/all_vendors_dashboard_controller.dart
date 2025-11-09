import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/views/dashboard/model/area_has_type_model.dart';
import 'package:carbo/views/dashboard/model/type_has_model.dart';
import 'package:carbo/views/dashboard/model/model_has_years.dart';
import 'package:dynamic_languages/dynamic_languages.dart';
import 'package:carbo/base/widgets/logger.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../dashboard/model/car_info_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carbo/base/utils/local_storage.dart';

final log = logger(AllVendorsDashboardController);

class AllVendorsDashboardController extends GetxController {
  // Filter selections
  RxInt currentIndex = 0.obs;
  var selectedCarIndex = 0.obs;
  RxString selectedCarId = ''.obs;
  RxString carToken = ''.obs;

  // Type selection
  Rxn<TypesAll> selectedType = Rxn<TypesAll>();
  final List<TypesAll> typeList = [];
  RxInt carTypeId = 0.obs;
  RxString selectedTypeName = RxString(Strings.SelectType);

  // Model selection
  Rxn<ModelsAll> selectedModel = Rxn<ModelsAll>();
  final List<ModelsAll> modelList = [];
  RxInt carModelId = 0.obs;
  RxString selectedModelName = RxString(Strings.SelectModel);

  // Year selection
  final List<String> modelYearsList = [];
  RxString selectedYearName = RxString(Strings.SelectYear);
  RxnInt selectedYear = RxnInt();
  RxInt carYear = 0.obs;

  // Cars list
  var cars = <Car>[].obs;
  RxString carImgUrl = ''.obs;

  // Loading states
  final _isLoad = false.obs;
  bool get isLoad => _isLoad.value;

  final _isSearchingCar = false.obs;
  bool get isSearchingCar => _isSearchingCar.value;

  @override
  void onInit() {
    super.onInit();
    getAllTypes();
  }

  void clearFilters() {
    cars.clear();
    typeList.clear();
    modelList.clear();
    modelYearsList.clear();
    selectedType.value = null;
    selectedModel.value = null;
    selectedYear.value = null;
    carTypeId.value = 0;
    carModelId.value = 0;
    carYear.value = 0;
    selectedTypeName.value = Strings.SelectType;
    selectedModelName.value = Strings.SelectModel;
    selectedYearName.value = Strings.SelectYear;
  }

  // GET ALL TYPES (from all vendors)
  Future<void> getAllTypes() async {
    _isLoad.value = true;
    typeList.clear();
    try {
      final token = LocalStorage.token;
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiEndpoint.getAllTypes.path}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List rawTypes = jsonData['data']?['area']?['typesAll'] ?? [];

        for (var item in rawTypes) {
          try {
            final name = item['type']?['name']?.toString();
            final id = item['id'] ?? 0;

            dynamic createdAtRaw = item['created_at'] ?? item['createdAt'];
            dynamic createdAt;
            if (createdAtRaw is String) {
              createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
            } else if (item['createdAt'] != null) {
              createdAt = DateTime.tryParse(item['createdAt'].toString()) ?? DateTime.now();
            } else {
              createdAt = DateTime.now();
            }

            dynamic updatedAtRaw = item['updated_at'] ?? item['updatedAt'];
            dynamic updatedAt;
            if (updatedAtRaw != null) {
              updatedAt = DateTime.tryParse(updatedAtRaw.toString()) ?? updatedAtRaw;
            } else {
              updatedAt = null;
            }

            final carTypeIdVal = int.tryParse(item['car_type_id']?.toString() ?? '') ?? id;
            final carAreaIdVal = int.tryParse(item['car_area_id']?.toString() ?? '') ?? 0;

            typeList.add(
              TypesAll(
                name: name,
                id: id,
                updatedAt: updatedAt,
                createdAt: createdAt,
                type: item['type'] is Map ? item['type'] : null,
                carTypeId: carTypeIdVal,
                carAreaId: carAreaIdVal,
              ),
            );
          } catch (e) {
            log.e('Error parsing type item: $e');
            continue;
          }
        }
      } else {
        log.e('Failed to fetch types: ${response.statusCode}');
      }
    } catch (e) {
      log.e('getAllTypes error: $e');
    } finally {
      _isLoad.value = false;
    }
  }

  // TYPE HAS MODEL
  late TypeHasModelModel _typeHasModelModel;
  TypeHasModelModel get typeHasModelModel => _typeHasModelModel;

  Future<TypeHasModelModel?> typeHasModel() async {
    modelList.clear();
    Map<String, dynamic> inputBody = {'type': carTypeId.value.toString()};
    return RequestProcess().request<TypeHasModelModel>(
      fromJson: TypeHasModelModel.fromJson,
      apiEndpoint: ApiEndpoint.postTypeHasModel,
      isLoading: _isLoad,
      method: HttpMethod.POST,
      showResult: true,
      body: inputBody,
      onSuccess: (value) {
        _typeHasModelModel = value!;
        _typeHasModelModel.data.type.models?.forEach((v) {
          modelList.add(
            ModelsAll(
              id: v.id,
              carTypeId: v.carTypeId,
              slug: v.slug,
              name: v.name,
              status: v.status,
              lastEditBy: v.lastEditBy,
              createdAt: v.createdAt,
              updatedAt: v.updatedAt,
            ),
          );
        });
        selectedModelName.value = Strings.SelectModel;
        modelYearsList.clear();
        selectedYearName.value = Strings.SelectYear;
        selectedYear.value = null;
      },
    );
  }

  // MODEL HAS YEARS
  Future<ModelHasYearsModel?> modelHasYears() async {
    if (selectedModel.value == null || carTypeId.value == 0) return null;
    modelYearsList.clear();
    Map<String, dynamic> inputBody = {
      'type': carTypeId.value.toString(),
      'model': selectedModel.value!.id.toString(),
    };
    return RequestProcess().request<ModelHasYearsModel>(
      fromJson: ModelHasYearsModel.fromJson,
      apiEndpoint: ApiEndpoint.postModelHasYears,
      isLoading: _isLoad,
      method: HttpMethod.POST,
      showResult: true,
      body: inputBody,
      onSuccess: (value) {
        var res = value!;
        modelYearsList.clear();
        res.data.years.forEach((y) {
          modelYearsList.add(y.toString());
        });
        selectedYearName.value = Strings.SelectYear;
        selectedYear.value = null;
      },
    );
  }

  // SEARCH ALL CARS FROM ALL VENDORS
  late CarInfoModel _carInfoModel;
  CarInfoModel get carInfoModel => _carInfoModel;

  Future<CarInfoModel?> searchAllVendorsCars() async {
    cars.clear();
    
    // Build query with only selected filters
    Map<String, dynamic> inputBody = {};
    
    if (carTypeId.value > 0) {
      inputBody['car_type'] = carTypeId.value;
    }
    if (carModelId.value > 0) {
      inputBody['car_model'] = carModelId.value;
    }
    if (carYear.value > 0) {
      inputBody['car_year'] = carYear.value;
    }

    return RequestProcess().request<CarInfoModel>(
      fromJson: CarInfoModel.fromJson,
      apiEndpoint: ApiEndpoint.searchCar,
      isLoading: _isSearchingCar,
      method: HttpMethod.POST,
      body: inputBody,
      showResult: true,
      onSuccess: (value) {
        _carInfoModel = value!;
        carToken.value = _carInfoModel.data.token;

        carImgUrl.value =
            '${_carInfoModel.data.dataPath.baseUrl}/${_carInfoModel.data.dataPath.imagePath}/';
        
        _carInfoModel.data.cars.forEach((element) {
          cars.add(
            Car(
              carAreaId: element.carAreaId,
              id: element.id,
              carTypeId: element.carTypeId,
              slug: element.slug,
              status: element.status,
              fees: element.fees,
              image: element.image,
              approval: element.approval,
              carModel: element.carModel,
              carType: element.carType,
              carYear: element.carYear,
              createdAt: element.createdAt,
              seat: element.seat,
              updatedAt: element.updatedAt,
              vendorId: element.vendorId,
              carTitle: element.carTitle,
              images: element.images,
              model: element.model,
              branchId: element.branchId,
              carModelId: element.carModelId,
            ),
          );
        });
        
        if (cars.isEmpty) {
          CustomSnackBar.error(
            DynamicLanguage.isLoading
                ? ""
                : DynamicLanguage.key(Strings.noCarFindMessage),
          );
        }
      },
    );
  }
}
