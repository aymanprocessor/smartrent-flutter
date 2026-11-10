import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../base/api/services/profile_kyc_service.dart';
import '../../../base/widgets/custom_snackbar.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../../booking/controller/booking_controller.dart';
import '../../dashboard/controller/dashboard_controller.dart';

class KycSubmissionController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isFetching = true.obs;

  final Rxn<File> nationalIdFile = Rxn<File>();
  final RxString nationalIdFileName = ''.obs;
  final RxString existingNationalIdUrl = ''.obs;
  final RxBool isNationalIdRemoved = false.obs;

  final Rxn<File> drivingLicenseFile = Rxn<File>();
  final RxString drivingLicenseFileName = ''.obs;
  final RxString existingDrivingLicenseUrl = ''.obs;
  final RxBool isDrivingLicenseRemoved = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

  dynamic pendingCar;
  void Function()? onSuccessCallback;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      pendingCar = args['car'] ?? args['pendingCar'];
      onSuccessCallback = args['onSuccess'] as void Function()?;
    }
    fetchExistingDocuments();
  }

  Future<void> fetchExistingDocuments() async {
    isFetching.value = true;
    try {
      final status = await ProfileKycService.getKycStatus();
      if (status != null) {
        if (status['national_id_image_url'] != null &&
            status['national_id_image_url'].toString().isNotEmpty) {
          existingNationalIdUrl.value =
              status['national_id_image_url'].toString();
        }
        if (status['driving_license_image_url'] != null &&
            status['driving_license_image_url'].toString().isNotEmpty) {
          existingDrivingLicenseUrl.value =
              status['driving_license_image_url'].toString();
        }
      }
    } catch (_) {} finally {
      isFetching.value = false;
    }
  }

  Future<void> pickNationalId(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image != null) {
        nationalIdFile.value = File(image.path);
        nationalIdFileName.value = image.name.isNotEmpty
            ? image.name
            : image.path.split(Platform.pathSeparator).last;
        isNationalIdRemoved.value = false;
      }
    } catch (_) {
      CustomSnackBar.error(DynamicLanguage.key(Strings.couldNotPickPhoto));
    }
  }

  void removeNationalId() {
    nationalIdFile.value = null;
    nationalIdFileName.value = '';
    existingNationalIdUrl.value = '';
    isNationalIdRemoved.value = true;
  }

  Future<void> pickDrivingLicense(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image != null) {
        drivingLicenseFile.value = File(image.path);
        drivingLicenseFileName.value = image.name.isNotEmpty
            ? image.name
            : image.path.split(Platform.pathSeparator).last;
        isDrivingLicenseRemoved.value = false;
      }
    } catch (_) {
      CustomSnackBar.error(DynamicLanguage.key(Strings.couldNotPickPhoto));
    }
  }

  void removeDrivingLicense() {
    drivingLicenseFile.value = null;
    drivingLicenseFileName.value = '';
    existingDrivingLicenseUrl.value = '';
    isDrivingLicenseRemoved.value = true;
  }

  bool get hasNationalId =>
      nationalIdFile.value != null || existingNationalIdUrl.value.isNotEmpty;

  bool get hasDrivingLicense =>
      drivingLicenseFile.value != null ||
      existingDrivingLicenseUrl.value.isNotEmpty;

  int get completedCount =>
      (hasNationalId ? 1 : 0) + (hasDrivingLicense ? 1 : 0);

  double get progressRatio => completedCount / 2.0;

  bool get isAllCompleted => hasNationalId && hasDrivingLicense;

  String? get pendingCarName {
    if (pendingCar == null) return null;
    try {
      if (pendingCar is Map) {
        final b = pendingCar['brand_name'] ?? pendingCar['brand'];
        final m = pendingCar['model_name'] ??
            pendingCar['name'] ??
            pendingCar['model'];
        if (b != null && m != null) return '$b $m';
        return m?.toString() ?? b?.toString();
      }
      final dynamic car = pendingCar;
      final b = car.brandName ?? car.brand;
      final m = car.modelName ?? car.name;
      if (b != null && m != null) return '$b $m';
      return m?.toString() ?? b?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> submitDocuments() async {
    final bool hasNewFiles =
        nationalIdFile.value != null || drivingLicenseFile.value != null;
    final bool hasRemovals =
        isNationalIdRemoved.value || isDrivingLicenseRemoved.value;

    // If nothing changed, proceed directly
    if (!hasNewFiles && !hasRemovals) {
      _proceedAfterSuccess();
      return;
    }

    isLoading.value = true;
    try {
      final success = await ProfileKycService.uploadDocuments(
        nationalIdPath: nationalIdFile.value?.path,
        drivingLicensePath: drivingLicenseFile.value?.path,
        removeNationalId: isNationalIdRemoved.value,
        removeDrivingLicense: isDrivingLicenseRemoved.value,
      );

      isLoading.value = false;
      if (success) {
        isNationalIdRemoved.value = false;
        isDrivingLicenseRemoved.value = false;
        CustomSnackBar.success(
          title: DynamicLanguage.key(Strings.success),
          message: DynamicLanguage.key(Strings.documentsUploadedSuccessfully),
        );
        _proceedAfterSuccess();
      } else {
        CustomSnackBar.error(
          ProfileKycService.lastError.isNotEmpty
              ? ProfileKycService.lastError
              : DynamicLanguage.key(Strings.kycUnavailable),
        );
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.error(DynamicLanguage.key(Strings.kycUnavailable));
    }
  }

  void _proceedAfterSuccess() {
    try {
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().getDashboardInfo();
      }
    } catch (_) {}

    if (onSuccessCallback != null && isAllCompleted) {
      Get.back();
      onSuccessCallback!();
    } else if (pendingCar != null && isAllCompleted) {
      try {
        final bookingController = Get.find<BookingController>();
        bookingController.initializeWithCar(pendingCar);
      } catch (_) {}
      Get.offNamed(Routes.bookingScreen, arguments: {'car': pendingCar});
    } else {
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      } else {
        Get.offAllNamed(Routes.dashboardScreen);
      }
    }
  }
}
