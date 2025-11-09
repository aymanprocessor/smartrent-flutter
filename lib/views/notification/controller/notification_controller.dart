import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/api/model/common_success_model.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../../congratulations/model/congratulations_model.dart';
import '../../congratulations/screen/congratulations_screen.dart';
import '../model/notification_model.dart';
import '../model/re_payment_input_fields_model.dart';
import '../widget/get_manual_dynamic_input_field.dart';

class NotificationController extends GetxController {
  @override
  void onInit() {
    getNotificationInfo();
    super.onInit();
  }

  RxString trxId = ''.obs;
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  late NotificationModel _notificationModel;

  NotificationModel get notificationModel => _notificationModel;

  Future<NotificationModel?> getNotificationInfo() async {
    return RequestProcess().request<NotificationModel>(
      fromJson: NotificationModel.fromJson,
      apiEndpoint: ApiEndpoint.notification,
      isLoading: _isLoading,
      onSuccess: (value) {
        _notificationModel = value!;
        // Use null-aware operators and check for null values
        trxId.value =
            _notificationModel.data.notification.first.message.trxId ??
            'default_value';
      },
    );
  }

  List<TextEditingController> inputFieldControllers = [];
  RxList inputFields = [].obs;
  RxList inputFileFields = [].obs;
  RxBool hasFile = false.obs;
  RxString selectType = "".obs;
  List<String> listImagePath = [];
  List<String> listFieldName = [];

  final _isRepaymentLoading = false.obs;

  bool get isRepaymentLoading => _isRepaymentLoading.value;

  late RePaymentInputFields _rePaymentInputFields;

  RePaymentInputFields get rePaymentInputFields => _rePaymentInputFields;

  Future<RePaymentInputFields?> rePaymentManualInsert() async {
    return RequestProcess().request<RePaymentInputFields>(
      fromJson: RePaymentInputFields.fromJson,
      apiEndpoint: ApiEndpoint.rePayment,
      isLoading: _isRepaymentLoading,
      showSuccessMessage: false,
      showResult: true,
      queryParams: {'trx_id': trxId.value},
      onSuccess: (value) {
        _rePaymentInputFields = value!;
        getManualReDynamicInputField(
          data: _rePaymentInputFields.data.inputFields,
          inputFieldControllers: inputFieldControllers,
          inputFields: inputFields,
          inputFileFields: inputFileFields,
          hasFile: hasFile,
          selectType: selectType,
        );
        Get.toNamed(Routes.RePaymentManualField);
      },
    );
  }

  late CommonSuccessModel _commonSuccessModel;

  CommonSuccessModel get commonSuccessModel => _commonSuccessModel;

  Future<CommonSuccessModel?> rePaymentProcess() async {
    Map<String, String> inputBody = {'trx_id': trxId.value};
    final data = _rePaymentInputFields.data.inputFields;

    for (int i = 0; i < data.length; i += 1) {
      if (data[i].type != 'file') {
        inputBody[data[i].name] = inputFieldControllers[i].text;
      }
    }
    inputFileFields.clear();
    inputFields.clear();
    listImagePath.clear();
    listFieldName.clear();
    inputFieldControllers.clear();
    update();

    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.manualRePayment,
      isLoading: _isRepaymentLoading,
      method: HttpMethod.POST,
      body: inputBody,
      fieldList: listFieldName,
      pathList: listImagePath,
      onSuccess: (value) {
        inputFields.clear();
        listImagePath.clear();
        listFieldName.clear();
        inputFieldControllers.clear();
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  }

  void _confirmation(CommonSuccessModel commonSuccessModel) {
    Congratulation congratulation = Congratulation(
      details: commonSuccessModel.message.success.first,
      route: Routes.dashboardScreen,
      buttonText: Strings.backToHome,
      type: Strings.payment,
    );

    Get.to(() => CongratulationsScreen(), arguments: congratulation);
  }
}
