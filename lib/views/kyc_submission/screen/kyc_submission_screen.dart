import 'package:flutter/material.dart';
import '../../../base/api/model/kyc_model.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/utils/basic_import.dart';
import '../controller/kyc_submission_controller.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class KycSubmissionScreen extends StatelessWidget {
  const KycSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: KycSubmissionMobileScreen(),
      tablet: KycSubmissionMobileScreen(),
    );
  }
}

class KycSubmissionMobileScreen extends StatelessWidget {
  const KycSubmissionMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KycSubmissionController>();

    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        title: Text(
          DynamicLanguage.key(Strings.submitKycDocuments),
          style: TextStyle(
            fontSize: Dimensions.titleLarge,
            color: CustomColor.typography,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingFields.value) {
          return Center(
            child: CircularProgressIndicator(color: CustomColor.primary),
          );
        }

        if (controller.kycFields.isEmpty) {
          if (controller.kycStatus.value == 1) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.paddingSize),
                child: _statusMessage(
                  Icons.verified,
                  Colors.green,
                  DynamicLanguage.key(Strings.yourIdentityApproved),
                ),
              ),
            );
          }
          if (controller.kycStatus.value == 2) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.paddingSize),
                child: _statusMessage(
                  Icons.hourglass_top,
                  Colors.orange,
                  DynamicLanguage.key(Strings.kycPendingCannotSubmit),
                ),
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (controller.kycStatus.value == 3)
                  _statusMessage(
                    Icons.error_outline,
                    Colors.red,
                    '${DynamicLanguage.key(Strings.kycRejected)}${controller.rejectReason.value.isEmpty ? '' : '\n${DynamicLanguage.key(Strings.reason)}: ${controller.rejectReason.value}'}',
                  ),
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: CustomColor.typographyShade[40],
                ),
                SizedBox(height: Dimensions.heightSize),
                Text(
                  controller.pageError.value.isEmpty
                      ? DynamicLanguage.key(Strings.kycFieldsUnavailable)
                      : controller.pageError.value,
                  style: TextStyle(
                    fontSize: Dimensions.titleMedium,
                    color: CustomColor.typographyShade[40],
                  ),
                ),
                SizedBox(height: Dimensions.heightSize),
                OutlinedButton(
                  onPressed: controller.refreshKycFields,
                  child: Text(DynamicLanguage.key(Strings.retry)),
                ),
              ],
            ),
          );
        }

        return _buildBody(controller);
      }),
    );
  }

  Widget _buildBody(KycSubmissionController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.paddingSize),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.kycStatus.value == 1)
              _statusMessage(
                Icons.verified,
                Colors.green,
                DynamicLanguage.key(Strings.yourIdentityApproved),
              ),
            if (controller.kycStatus.value == 2)
              _statusMessage(
                Icons.hourglass_top,
                Colors.orange,
                DynamicLanguage.key(Strings.kycPendingCannotSubmit),
              ),
            if (controller.kycStatus.value == 3) ...[
              _statusMessage(
                Icons.error_outline,
                Colors.red,
                '${DynamicLanguage.key(Strings.kycRejected)}${controller.rejectReason.value.isEmpty ? '' : '\n${DynamicLanguage.key(Strings.reason)}: ${controller.rejectReason.value}'}',
              ),
            ],
            if (!controller.profileComplete.value &&
                controller.kycStatus.value != 1 &&
                controller.kycStatus.value != 2)
              _statusMessage(
                Icons.info_outline,
                Colors.orange,
                DynamicLanguage.key(Strings.completeProfileBeforeKyc),
              ),
            if (controller.pageError.value.isNotEmpty &&
                controller.kycFields.isNotEmpty)
              _statusMessage(
                Icons.error_outline,
                Colors.red,
                controller.pageError.value,
              ),
            SizedBox(height: Dimensions.heightSize * 2),

            Text(
              DynamicLanguage.key(Strings.pleaseUploadRequiredDocuments),
              style: TextStyle(
                fontSize: Dimensions.titleMedium,
                color: CustomColor.typographyShade[40],
              ),
            ),

            SizedBox(height: Dimensions.heightSize * 3),

            // Dynamic form fields
            ...controller.kycFields.map((field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDynamicField(field, controller),
                  SizedBox(height: Dimensions.heightSize * 2),
                ],
              );
            }).toList(),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: Dimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ||
                          !controller.profileComplete.value ||
                          controller.kycStatus.value == 1 ||
                          controller.kycStatus.value == 2
                      ? null
                      : controller.submitKyc,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.primary,
                    disabledBackgroundColor: CustomColor.primary.withOpacity(
                      0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          DynamicLanguage.key(Strings.submitKycDocuments),
                          style: TextStyle(
                            fontSize: Dimensions.titleMedium,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),

            SizedBox(height: Dimensions.heightSize * 2),
          ],
        ),
      ),
    );
  }

  Widget _statusMessage(IconData icon, Color color, String message) =>
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: Dimensions.heightSize),
        padding: EdgeInsets.all(Dimensions.paddingSize),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(Dimensions.radius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            SizedBox(width: Dimensions.widthSize),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: CustomColor.typography),
              ),
            ),
          ],
        ),
      );

  Widget _buildDynamicField(
    KycField field,
    KycSubmissionController controller,
  ) {
    switch (field.type) {
      case KycFieldType.text:
      case KycFieldType.number:
        return _buildTextField(field, controller);

      case KycFieldType.textarea:
        return _buildTextAreaField(field, controller);

      case KycFieldType.date:
        return _buildDateField(field, controller);

      case KycFieldType.select:
        return _buildSelectField(field, controller);

      case KycFieldType.file:
        return _buildFileField(field, controller);

      default:
        return _buildTextField(field, controller);
    }
  }

  Widget _buildTextField(KycField field, KycSubmissionController controller) {
    final label = field.localizedLabel(DynamicLanguage.selectedLanguage.value);
    final placeholder = field.localizedPlaceholder(
      DynamicLanguage.selectedLanguage.value,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        TextFormField(
          controller: controller.textControllers[field.name],
          keyboardType: field.type == KycFieldType.number
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            hintText:
                placeholder ??
                '${DynamicLanguage.key(Strings.enterValue)} $label',
            filled: true,
            fillColor: CustomColor.typographyShade[0]!.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSize,
              vertical: Dimensions.paddingSize * 0.75,
            ),
          ),
          validator: field.required
              ? FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText:
                        '$label ${DynamicLanguage.key(Strings.isRequired)}',
                  ),
                  if (field.maxLength != null)
                    FormBuilderValidators.maxLength(
                      field.maxLength!,
                      errorText:
                          '${DynamicLanguage.key(Strings.maximumCharacters)} ${field.maxLength}',
                    ),
                ])
              : null,
        ),
      ],
    );
  }

  Widget _buildTextAreaField(
    KycField field,
    KycSubmissionController controller,
  ) {
    final label = field.localizedLabel(DynamicLanguage.selectedLanguage.value);
    final placeholder = field.localizedPlaceholder(
      DynamicLanguage.selectedLanguage.value,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        TextFormField(
          controller: controller.textControllers[field.name],
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                placeholder ??
                '${DynamicLanguage.key(Strings.enterValue)} $label',
            filled: true,
            fillColor: CustomColor.typographyShade[0]!.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(Dimensions.paddingSize),
          ),
          validator: field.required
              ? FormBuilderValidators.required(
                  errorText:
                      '$label ${DynamicLanguage.key(Strings.isRequired)}',
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField(KycField field, KycSubmissionController controller) {
    final label = field.localizedLabel(DynamicLanguage.selectedLanguage.value);
    final placeholder = field.localizedPlaceholder(
      DynamicLanguage.selectedLanguage.value,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        TextFormField(
          controller: controller.textControllers[field.name],
          readOnly: true,
          decoration: InputDecoration(
            hintText:
                placeholder ??
                '${DynamicLanguage.key(Strings.selectValue)} $label',
            filled: true,
            fillColor: CustomColor.typographyShade[0]!.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSize,
              vertical: Dimensions.paddingSize * 0.75,
            ),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.textControllers[field.name]!.text =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          },
          validator: field.required
              ? FormBuilderValidators.required(
                  errorText:
                      '$label ${DynamicLanguage.key(Strings.isRequired)}',
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildSelectField(KycField field, KycSubmissionController controller) {
    final label = field.localizedLabel(DynamicLanguage.selectedLanguage.value);
    final placeholder = field.localizedPlaceholder(
      DynamicLanguage.selectedLanguage.value,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedValues[field.name],
            decoration: InputDecoration(
              hintText:
                  placeholder ??
                  '${DynamicLanguage.key(Strings.selectValue)} $label',
              filled: true,
              fillColor: CustomColor.typographyShade[0]!.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSize,
                vertical: Dimensions.paddingSize * 0.75,
              ),
            ),
            items: field.options?.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectDropdownValue(field.name, value);
              }
            },
            validator: field.required
                ? FormBuilderValidators.required(
                    errorText:
                        '$label ${DynamicLanguage.key(Strings.isRequired)}',
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFileField(KycField field, KycSubmissionController controller) {
    final label = field.localizedLabel(DynamicLanguage.selectedLanguage.value);
    final maxSize = field.maxFileSizeKb;
    final cameraSuitable =
        field.mimes.isEmpty ||
        field.mimes.any(
          (mime) => const {
            'jpg',
            'jpeg',
            'png',
            'image/jpeg',
            'image/png',
          }.contains(mime.toLowerCase()),
        );
    final guidance = [
      if (field.mimes.isNotEmpty)
        '${DynamicLanguage.key(Strings.accepted)}: ${field.mimes.join(', ')}',
      if (maxSize != null)
        '${DynamicLanguage.key(Strings.maximumSize)}: ${maxSize >= 1024 ? '${(maxSize / 1024).round()} MB' : '$maxSize KB'}',
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, field.required),
        if (guidance.isNotEmpty) ...[
          SizedBox(height: Dimensions.heightSize * 0.3),
          Text(
            guidance,
            style: TextStyle(
              fontSize: Dimensions.titleSmall,
              color: CustomColor.typographyShade[40],
            ),
          ),
        ],
        SizedBox(height: Dimensions.heightSize * 0.5),
        Obx(() {
          final hasFile = controller.fileNames.containsKey(field.name);

          return Container(
            decoration: BoxDecoration(
              color: CustomColor.typographyShade[0]!.withOpacity(0.5),
              borderRadius: BorderRadius.circular(Dimensions.radius),
            ),
            padding: EdgeInsets.all(Dimensions.paddingSize),
            child: Column(
              children: [
                if (hasFile) ...[
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: Dimensions.widthSize),
                      Expanded(
                        child: Text(
                          controller.fileNames[field.name]!,
                          style: TextStyle(
                            fontSize: Dimensions.titleSmall,
                            color: CustomColor.typography,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.removeFile(field.name);
                        },
                        icon: Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.heightSize),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.pickFile(field.name),
                        icon: Icon(Icons.upload_file),
                        label: Text(
                          DynamicLanguage.key(
                            hasFile ? Strings.changeFile : Strings.chooseFile,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomColor.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSize * 0.6,
                          ),
                        ),
                      ),
                    ),
                    if (cameraSuitable) ...[
                      SizedBox(width: Dimensions.widthSize),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.pickImage(field.name),
                          icon: Icon(Icons.camera_alt),
                          label: Text(
                            DynamicLanguage.key(
                              hasFile ? Strings.changePhoto : Strings.takePhoto,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CustomColor.primary,
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSize * 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLabel(String text, bool required) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w600,
          color: CustomColor.typography,
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
