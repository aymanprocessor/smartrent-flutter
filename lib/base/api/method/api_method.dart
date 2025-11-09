import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../routes/routes.dart';
import '../../maintenance/maintenance_dialog.dart';
import '../../maintenance/maintenance_model.dart';
import '../../utils/basic_import.dart';
import '../../utils/local_storage.dart';
import '../../widgets/logger.dart';
import '../model/error_message_model.dart';

final log = logger(ApiMethod);

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}

Future<Map<String, String>> bearerHeaderInfo() async {
  String accessToken = LocalStorage.token;

  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
}

class ApiMethod {
  ApiMethod({required this.isBasic});

  bool isBasic;

  // Get method
  Future<Map<String, dynamic>?> get(
    String url, {
    int code = 200,
    int duration = 120,
    bool showResult = false,
    bool showErrorMessage = true,
  }) async {
    log.i(
      '|📍📍📍|----------------- [[ GET ]] method details start -----------------|📍📍📍|',
    );
    log.i(url);
    log.i(
      '|📍📍📍|----------------- [[ GET ]] method details ended -----------------|📍📍📍|',
    );

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i(
        '|📒📒📒|-----------------[[ GET ]] method response start -----------------|📒📒📒|',
      );

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
        '|📒📒📒|-----------------[[ GET ]] method response end -----------------|📒📒📒|',
      );

      bool isMaintenance = response.statusCode == 503;

      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.otpLoginScreen);
      }
      if (response.statusCode == 401) {
        Get.offAllNamed(Routes.otpLoginScreen);
        LocalStorage.clear();
      }

      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == code) {
        try {
          return jsonDecode(response.body);
        } on FormatException catch (fe) {
          // Log raw response in debug mode to help backend debugging
          if (kDebugMode) {
            log.e('🐞 JSON parse error (GET) for $url: ${fe.message}');
            log.e('🐞 Raw response body: ${response.body}');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        // Try to decode error body safely for user message; fall back to raw body
        try {
          final decoded = jsonDecode(response.body);
          log.e('unknown error hitted in status code$decoded');
          ErrorResponse res = ErrorResponse.fromJson(decoded);
          if (isMaintenance) {
          } else {
            if (showErrorMessage) {
              CustomSnackBar.error(res.message.error.join(''));
            }
          }
        } catch (e) {
          log.e('Error decoding error response: $e');
          if (kDebugMode) log.e('Raw error response body: ${response.body}');
          if (showErrorMessage) CustomSnackBar.error(Strings.serverError);
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');
      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');
      if (showErrorMessage) {
        CustomSnackBar.error('Something Went Wrong! Try again');
      }
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> post(
    String url,
    Map<String, dynamic> body, {
    int code = 201,
    int duration = 120,
    bool showResult = true,
    bool showErrorMessage = true,
  }) async {
    try {
      log.i(
        '|📍📍📍|-----------------[[ POST ]] method details start -----------------|📍📍📍|',
      );

      log.i(url);

      log.i(body);

      log.i(
        '|📍📍📍|-----------------[[ POST ]] method details end ------------|📍📍📍|',
      );

      final response = await http
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|',
      );

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|',
      );
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, response.body);

      // Check Unauthorized
      if (response.statusCode == 401) {
        LocalStorage.clear();
      }
      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.otpLoginScreen);
      }
      if (response.statusCode == 401) {
        Get.offAllNamed(Routes.otpLoginScreen);
        LocalStorage.clear();
      }

      if (response.statusCode == code) {
        try {
          return jsonDecode(response.body);
        } on FormatException catch (fe) {
          if (kDebugMode) {
            log.e('🐞 JSON parse error (POST) for $url: ${fe.message}');
            log.e('🐞 Raw response body: ${response.body}');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');
        try {
          final decoded = jsonDecode(response.body);
          log.e('unknown error hitted in status code $decoded');
          ErrorResponse res = ErrorResponse.fromJson(decoded);
          if (isMaintenance) {
          } else {
            if (showErrorMessage) {
              CustomSnackBar.error(res.message.error.join(''));
            }
          }
        } catch (e) {
          log.e('Error decoding error response: $e');
          if (kDebugMode) log.e('Raw error response body: ${response.body}');
          if (showErrorMessage) CustomSnackBar.error(Strings.serverError);
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());
      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> multipart(
    String url,
    Map<String, String> body,
    String filepath,
    String filedName, {
    int code = 200,
    bool showResult = false,
  }) async {
    try {
      log.i(
        '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|',
      );

      log.i(url);

      log.i(body);
      log.i(filepath);

      log.i(
        '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|',
      );

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll(isBasic ? basicHeaderInfo() : await bearerHeaderInfo())
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|',
      );

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|',
      );
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        try {
          return jsonDecode(jsonData.body) as Map<String, dynamic>;
        } on FormatException catch (fe) {
          if (kDebugMode) {
            log.e('🐞 JSON parse error (multipart) for $url: ${fe.message}');
            log.e('🐞 Raw response body: ${jsonData.body}');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');
        try {
          final decoded = jsonDecode(jsonData.body);
          log.e('unknown error hitted in status code $decoded');
          ErrorResponse res = ErrorResponse.fromJson(decoded);
          if (!isMaintenance) CustomSnackBar.error(res.message.error.toString());
        } catch (e) {
          log.e('Error decoding error response: $e');
          if (kDebugMode) log.e('Raw error response body: ${jsonData.body}');
          if (!isMaintenance) CustomSnackBar.error(Strings.serverError);
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // multipart multi file Method
  Future<Map<String, dynamic>?> multipartMultiFile(
    String url,
    Map<String, String> body, {
    int code = 200,
    bool showResult = false,
    required List<String> pathList,
    required List<String> fieldList,
  }) async {
    try {
      log.i(
        '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|',
      );

      log.i(url);

      if (showResult) {
        log.i(body);
        log.i(pathList);
        log.i(fieldList);
      }

      log.i(
        '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|',
      );
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        );

      for (int i = 0; i < fieldList.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldList[i], pathList[i]),
        );
      }

      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|',
      );

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|',
      );
      bool isMaintenance = response.statusCode == 503;

      if (response.statusCode == 500) {
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.otpLoginScreen);
      }
      if (response.statusCode == 401) {
        Get.offAllNamed(Routes.otpLoginScreen);
        LocalStorage.clear();
      }
      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        try {
          return jsonDecode(jsonData.body) as Map<String, dynamic>;
        } on FormatException catch (fe) {
          if (kDebugMode) {
            log.e('🐞 JSON parse error (multipartMultiFile) for $url: ${fe.message}');
            log.e('🐞 Raw response body: ${jsonData.body}');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');
        try {
          final decoded = jsonDecode(jsonData.body);
          log.e('unknown error hitted in status code $decoded');
          ErrorResponse res = ErrorResponse.fromJson(decoded);
          if (!isMaintenance) CustomSnackBar.error(res.message.error.toString());
        } catch (e) {
          log.e('Error decoding error response: $e');
          if (kDebugMode) log.e('Raw error response body: ${jsonData.body}');
          if (!isMaintenance) CustomSnackBar.error(Strings.serverError);
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  void _maintenanceCheck(bool isMaintenance, var jsonData) {
    final controller = Get.put(SystemMaintenanceController());
    if (isMaintenance) {
      controller.maintenanceStatus.value = true;
      MaintenanceModel maintenanceModel = MaintenanceModel.fromJson(
        jsonDecode(jsonData),
      );
      MaintenanceDialog().show(maintenanceModel: maintenanceModel);
    } else {
      controller.maintenanceStatus.value = false;
    }
  }
}
