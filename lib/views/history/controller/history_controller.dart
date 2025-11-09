import 'package:carbo/views/history/model/history_model.dart';
import 'package:get/get.dart';

import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';

class HistoryController extends GetxController {
  final List<RxBool> isExpanded = List.generate(1000, (_) => false.obs);

  void toggleCardExpansion(int index) {
    for (int i = 0; i < isExpanded.length; i++) {
      if (i != index) {
        isExpanded[i].value = false;
      }
    }
    isExpanded[index].toggle();
  }

  @override
  void onInit() {
    super.onInit();
    getHistoryInfo();
  }

  var historyList = <History>[].obs;

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  late HistoryModel _historyModel;

  HistoryModel get historyModel => _historyModel;

  Future<HistoryModel?> getHistoryInfo() async {
    return RequestProcess().request<HistoryModel>(
      fromJson: HistoryModel.fromJson,
      apiEndpoint: ApiEndpoint.history,
      isLoading: _isLoading,
      showErrorMessage: true,
      onSuccess: (value) {
        _historyModel = value!;
        _historyModel.data.history.forEach((element) {
          historyList.add(
            History(
              message: element.message,
              distance: element.distance,
              createdAt: element.createdAt,
              updatedAt: element.updatedAt,
              status: element.status,
              amount: element.amount,
              destination: element.destination,
              location: element.location,
              paymentType: element.paymentType,
              pickupDate: element.pickupDate,
              pickupTime: element.pickupTime,
              roundPickupDate: element.roundPickupDate,
              roundPickupTime: element.roundPickupTime,
              cars: element.cars,
            ),
          );
        });
        historyList.first.cars.carModel;
      },
    );
  }
}
