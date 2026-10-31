enum KycFieldType {
  text('text'),
  textarea('textarea'),
  number('number'),
  date('date'),
  select('select'),
  file('file');

  final String value;
  const KycFieldType(this.value);

  static KycFieldType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return KycFieldType.text;
      case 'textarea':
        return KycFieldType.textarea;
      case 'number':
        return KycFieldType.number;
      case 'date':
        return KycFieldType.date;
      case 'select':
        return KycFieldType.select;
      case 'file':
        return KycFieldType.file;
      default:
        return KycFieldType.text;
    }
  }
}

class KycFieldsResponseModel {
  final bool success;
  final String message;
  final List<KycField>? fields;
  final int kycStatus;
  final String? rejectReason;
  final Map<String, dynamic> kycData;

  KycFieldsResponseModel({
    required this.success,
    required this.message,
    this.fields,
    this.kycStatus = 0,
    this.rejectReason,
    this.kycData = const {},
  });

  factory KycFieldsResponseModel.fromJson(Map<String, dynamic> json) {
    // Extract message properly - handle nested success message
    String messageText = '';
    if (json['message'] is Map) {
      final msgMap = json['message'] as Map<String, dynamic>;
      if (msgMap['success'] is List && (msgMap['success'] as List).isNotEmpty) {
        messageText = (msgMap['success'] as List).first.toString();
      } else if (msgMap['error'] is List &&
          (msgMap['error'] as List).isNotEmpty) {
        messageText = (msgMap['error'] as List).first.toString();
      }
    } else if (json['message'] is List) {
      messageText = (json['message'] as List).join(', ');
    } else {
      messageText = json['message']?.toString() ?? '';
    }

    // Extract kyc_fields from nested data object
    List<KycField> fieldsList = [];
    if (json['data'] != null && json['data'] is Map) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['kyc_fields'] != null && dataMap['kyc_fields'] is List) {
        fieldsList = (dataMap['kyc_fields'] as List)
            .map((e) => KycField.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return KycFieldsResponseModel(
      success: (json['type'] == 'success') || (json['success'] ?? false),
      message: messageText,
      fields: fieldsList,
      kycStatus: int.tryParse(dataMap['kyc_status']?.toString() ?? '0') ?? 0,
      rejectReason: dataMap['reject_reason']?.toString(),
      kycData: dataMap['kyc_data'] is Map
          ? Map<String, dynamic>.from(dataMap['kyc_data'])
          : const {},
    );
  }
}

class KycField {
  final String name;
  final String label;
  final String? labelAr;
  final KycFieldType type;
  final bool required;
  final List<String>? options;
  final String? placeholder;
  final String? placeholderAr;
  final int? maxLength;
  final String? validationRegex;
  final List<String> mimes;
  final int? maxFileSizeKb;

  KycField({
    required this.name,
    required this.label,
    this.labelAr,
    required this.type,
    required this.required,
    this.options,
    this.placeholder,
    this.placeholderAr,
    this.maxLength,
    this.validationRegex,
    this.mimes = const [],
    this.maxFileSizeKb,
  });

  factory KycField.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'] is Map
        ? Map<String, dynamic>.from(json['translations'] as Map)
        : <String, dynamic>{};
    final arabicTranslation = translations['ar'] is Map
        ? Map<String, dynamic>.from(translations['ar'] as Map)
        : <String, dynamic>{};
    // Extract maxLength from validation.max if available
    int? maxLength;
    if (json['validation'] is Map) {
      final validation = json['validation'] as Map<String, dynamic>;
      if (validation['max'] != null) {
        maxLength = int.tryParse(validation['max'].toString());
      }
    } else if (json['max_length'] != null) {
      maxLength = int.tryParse(json['max_length'].toString());
    }

    return KycField(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      labelAr:
          json['label_ar']?.toString() ??
          arabicTranslation['label']?.toString(),
      type: KycFieldType.fromString(json['type']?.toString() ?? 'text'),
      required: json['required'] == true || json['required'] == 1,
      options:
          ((json['validation'] is Map
                      ? (json['validation'] as Map)['options']
                      : null) ??
                  json['options'])
              is List
          ? (((json['validation'] is Map
                            ? (json['validation'] as Map)['options']
                            : null) ??
                        json['options'])
                    as List)
                .map(
                  (e) => e is Map
                      ? (e['value'] ?? e['label'] ?? '').toString()
                      : e.toString(),
                )
                .where((e) => e.isNotEmpty)
                .toList()
          : null,
      placeholder: json['placeholder']?.toString(),
      placeholderAr:
          json['placeholder_ar']?.toString() ??
          arabicTranslation['placeholder']?.toString(),
      maxLength: maxLength,
      validationRegex: json['validation_regex']?.toString(),
      mimes:
          json['validation'] is Map &&
              (json['validation'] as Map)['mimes'] is List
          ? ((json['validation'] as Map)['mimes'] as List)
                .map((e) => e.toString().toLowerCase().replaceFirst('.', ''))
                .toList()
          : const [],
      // Laravel's file max is conventionally KB (2048 = 2 MB), while some
      // KYC configurations store the same limit as whole MB (2 = 2 MB).
      maxFileSizeKb: _normalizeMaxFileSize(
        json['validation'] is Map
            ? int.tryParse((json['validation'] as Map)['max']?.toString() ?? '')
            : null,
      ),
    );
  }

  String localizedLabel(String languageCode) {
    if (!languageCode.toLowerCase().startsWith('ar')) return label;
    if (labelAr != null && labelAr!.trim().isNotEmpty) return labelAr!.trim();

    // These are the labels currently returned by the user KYC configuration.
    // Keep matching on labels so the configured field names remain untouched.
    return switch (label.trim().toLowerCase()) {
      'national id fron' || 'national id front' => 'بطاقة الهوية امامية',
      'national id back' => 'بطاقة الهوية الخلفية',
      'license drive' || 'driving license' => 'الرخصة',
      _ => label,
    };
  }

  String? localizedPlaceholder(String languageCode) =>
      languageCode.toLowerCase().startsWith('ar') &&
          placeholderAr != null &&
          placeholderAr!.trim().isNotEmpty
      ? placeholderAr!.trim()
      : placeholder;

  static int? _normalizeMaxFileSize(int? max) {
    if (max == null || max <= 0) return max;
    return max <= 10 ? max * 1024 : max;
  }
}

class KycSubmitResponseModel {
  final bool success;
  final String message;
  final KycSubmitData? data;

  KycSubmitResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory KycSubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return KycSubmitResponseModel(
      success: json['success'] ?? true,
      message: (json['message'] is List)
          ? (json['message'] as List).join(', ')
          : json['message']?.toString() ?? '',
      data: json['data'] != null ? KycSubmitData.fromJson(json['data']) : null,
    );
  }
}

class KycSubmitData {
  final int kycStatus;
  final String nextAction;

  KycSubmitData({required this.kycStatus, required this.nextAction});

  factory KycSubmitData.fromJson(Map<String, dynamic> json) {
    return KycSubmitData(
      kycStatus: int.tryParse(json['kyc_status']?.toString() ?? '2') ?? 2,
      nextAction: json['next_action']?.toString() ?? 'none',
    );
  }
}
