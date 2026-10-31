import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../base/api/services/profile_kyc_service.dart';
import '../../../base/api/model/kyc_model.dart';
import '../../../base/utils/next_action_guard.dart';
import '../../../base/widgets/custom_snackbar.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../languages/strings.dart';

class KycSubmissionController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingFields = true.obs;
  final RxList<KycField> kycFields = <KycField>[].obs;
  final RxBool profileComplete = false.obs;
  final RxInt kycStatus = 0.obs;
  final RxString rejectReason = ''.obs;
  final RxString pageError = ''.obs;

  // Store text field controllers
  final Map<String, TextEditingController> textControllers = {};

  // Store selected values for dropdowns
  final RxMap<String, String> selectedValues = <String, String>{}.obs;

  // Store selected files
  final RxMap<String, File> selectedFiles = <String, File>{}.obs;
  final RxMap<String, String> fileNames = <String, String>{}.obs;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _fetchKycFields();
  }

  @override
  void onClose() {
    // Dispose all text controllers
    textControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.onClose();
  }

  Future<void> refreshKycFields() async {
    isLoadingFields.value = true;

    try {
      final response = await ProfileKycService.getKycFields();
      final status = await ProfileKycService.getKycStatus();
      if (status != null) {
        profileComplete.value =
            status['profile_complete'] == true ||
            status['profile_complete'] == 1;
        kycStatus.value =
            int.tryParse(status['kyc_status']?.toString() ?? '0') ?? 0;
        rejectReason.value = status['reject_reason']?.toString() ?? '';
      } else {
        pageError.value = DynamicLanguage.key(Strings.completeProfileBeforeKyc);
      }

      if (response != null && response.success && response.fields != null) {
        kycFields.value = response.fields!;
        kycStatus.value = status == null ? response.kycStatus : kycStatus.value;
        rejectReason.value = status == null
            ? response.rejectReason ?? ''
            : rejectReason.value;
        if (status != null) pageError.value = '';
        if (kycFields.isEmpty) {
          pageError.value = ProfileKycService.lastError.isNotEmpty
              ? ProfileKycService.lastError
              : DynamicLanguage.key(Strings.kycFieldsUnavailable);
        }

        // Initialize controllers for text fields
        for (var field in kycFields) {
          if (field.type == KycFieldType.text ||
              field.type == KycFieldType.textarea ||
              field.type == KycFieldType.number ||
              field.type == KycFieldType.date) {
            textControllers[field.name]?.dispose();
            textControllers[field.name] = TextEditingController(
              text: response.kycData[field.name]?.toString() ?? '',
            );
          } else if (field.type == KycFieldType.select &&
              response.kycData[field.name] != null) {
            selectedValues[field.name] = response.kycData[field.name]
                .toString();
          }
        }
      } else {
        pageError.value = ProfileKycService.lastError.isNotEmpty
            ? ProfileKycService.lastError
            : (response?.message ??
                  DynamicLanguage.key(Strings.kycUnavailable));
      }
    } catch (e) {
      pageError.value = DynamicLanguage.key(Strings.kycUnavailable);
    } finally {
      isLoadingFields.value = false;
    }
  }

  Future<void> _fetchKycFields() => refreshKycFields();

  Future<void> pickFile(String fieldName) async {
    try {
      final field = kycFields.firstWhere((f) => f.name == fieldName);
      final extensions = field.mimes.isEmpty
          ? <String>['jpg', 'jpeg', 'png']
          : field.mimes
                .map(
                  (m) => m == 'image/jpeg'
                      ? 'jpg'
                      : m == 'image/png'
                      ? 'png'
                      : m.split('/').last,
                )
                .toSet()
                .toList();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (!_validateFile(field, file, result.files.single.name)) return;
        selectedFiles[fieldName] = file;
        fileNames[fieldName] = result.files.single.name;
        selectedFiles.refresh();
        fileNames.refresh();
      }
    } catch (e) {
      CustomSnackBar.error(DynamicLanguage.key(Strings.couldNotPickFile));
    }
  }

  Future<void> pickImage(String fieldName) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 65,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (image != null) {
        final field = kycFields.firstWhere((f) => f.name == fieldName);
        final file = File(image.path);
        final fileName = image.name.isNotEmpty
            ? image.name
            : image.path.split(Platform.pathSeparator).last;
        if (!_validateFile(field, file, fileName)) return;
        selectedFiles[fieldName] = file;
        fileNames[fieldName] = fileName;
        selectedFiles.refresh();
        fileNames.refresh();
      }
    } catch (e) {
      CustomSnackBar.error(DynamicLanguage.key(Strings.couldNotPickPhoto));
    }
  }

  bool _validateFile(KycField field, File file, String name) {
    final filename = name.contains('.') ? name : file.path;
    final extension = filename.split('.').last.toLowerCase();
    final allowed = field.mimes
        .map(
          (m) => m == 'image/jpeg'
              ? 'jpg'
              : m == 'image/png'
              ? 'png'
              : m.split('/').last,
        )
        .toSet();
    if (allowed.isNotEmpty &&
        !allowed.contains(extension) &&
        !(extension == 'jpeg' && allowed.contains('jpg'))) {
      CustomSnackBar.error(
        'Choose a supported file type: ${allowed.join(', ')}',
      );
      return false;
    }
    final max = field.maxFileSizeKb;
    if (max != null && file.lengthSync() > max * 1024) {
      CustomSnackBar.error(
        '${field.label} must be smaller than ${max > 1024 ? (max / 1024).round().toString() + ' MB' : '$max KB'}',
      );
      return false;
    }
    return true;
  }

  void removeFile(String fieldName) {
    selectedFiles.remove(fieldName);
    fileNames.remove(fieldName);
    selectedFiles.refresh();
    fileNames.refresh();
  }

  void selectDropdownValue(String fieldName, String value) {
    selectedValues[fieldName] = value;
    selectedValues.refresh();
  }

  Future<void> submitKyc() async {
    if (!profileComplete.value) {
      pageError.value = DynamicLanguage.key(Strings.completeProfileBeforeKyc);
      return;
    }
    if (kycStatus.value == 1 || kycStatus.value == 2) return;
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate required files
    for (var field in kycFields) {
      if (field.required && field.type == KycFieldType.file) {
        if (!selectedFiles.containsKey(field.name)) {
          CustomSnackBar.error('${field.label} is required');
          return;
        }
      }
    }

    isLoading.value = true;

    try {
      // Prepare text fields
      final Map<String, String> fields = {};
      textControllers.forEach((key, controller) {
        fields[key] = controller.text.trim();
      });

      // Add dropdown selections
      selectedValues.forEach((key, value) {
        fields[key] = value;
      });

      // Prepare file paths
      final Map<String, String> filePaths = {};
      selectedFiles.forEach((key, file) {
        filePaths[key] = file.path;
      });

      final response = await ProfileKycService.submitKyc(
        fields: fields,
        filePaths: filePaths,
      );

      isLoading.value = false;

      if (response != null && response.success && response.data != null) {
        kycStatus.value = response.data!.kycStatus;
        if (response.data!.kycStatus == 2) kycStatus.value = 2;
        pageError.value = '';
        // Use guard to navigate to next step
        await NextActionGuard.handleAfterKycSubmit(response.data!);
      } else {
        pageError.value = ProfileKycService.lastError.isNotEmpty
            ? ProfileKycService.lastError
            : (response?.message ??
                  DynamicLanguage.key(Strings.kycUnavailable));
        CustomSnackBar.error(pageError.value);
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.error(DynamicLanguage.key(Strings.kycUnavailable));
    }
  }
}
