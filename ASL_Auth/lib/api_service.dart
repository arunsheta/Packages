import 'dart:convert';
import 'dart:io';

import 'package:ASL_Auth/user_obj.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'alert_string.dart';
import 'api_response_obj.dart';
import 'api_setup.dart';
import 'app_exception.dart';
import 'custom_alert.dart';
import 'custom_enum.dart';
import 'shared_preference.dart';

class ApiSerivce {
  static String _deivceType = Platform.isAndroid ? "android" : "ios";
  static String _appVersion = "";
  static String appVersionBuild = "";
  static String _deviceUUID = "";

  // Default params...
  static Future<void> getDefaultParams() async {
    await _fetchAppVersion();
    await _fetchDeviceInfo();
  }

  // Fetch app. version...
  static Future<void> _fetchAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    appVersionBuild = 'Version:$version Build:$buildNumber';
    _appVersion = version;
  }

  // Default parameter to add in all parameter...
  static Map<String, dynamic> get _getDefaultParams => {
        "device_type": _deivceType,
        "app_version": _appVersion,
        "device_id": _deviceUUID,
      };

  // Get Device Info... (Device Unique Id(UUID))
  static Future<void> _fetchDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceUUID = androidInfo.androidId;
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceUUID = iosInfo.identifierForVendor;
      }
    } catch (e) {
      print("Error fetching device info");
      return "";
    }
  }

  // Call API...
  static Future<String> callService({
    @required BuildContext context,
    @required APIRequestInfoObj requestInfo,
    bool callAsMultipart = false,
  }) async {
    try {
      // Check Internet...
      await checkConnectivity();

      // // Don't allow to enter for refresh token API call...
      // if (!EndPoints.auth.isRefeshingToken(requestInfo?.endPoint ?? "")) {
      //   // Refresh token if exipred...
      //   await Provider.of<AuthProvider>(context, listen: false)
      //       .refreshExpiredToken();
      // }

      // Add Default params...
      if (requestInfo?.parameter?.isEmpty ?? true) {
        requestInfo.parameter = _getDefaultParams;
      } else {
        requestInfo?.parameter?.addAll(_getDefaultParams);
      }

      // Get Response...
      return callAsMultipart
          ? await requestInfo.getMultipartResposneFromAPI
          : await requestInfo.getResponseFromAPI;
    } on SocketException catch (e) {
      throw AppException(
        message: e.message,
        type: ExceptionType.NoInternet,
      );
    } on HttpException catch (e) {
      throw AppException(
        message: e.message,
        type: ExceptionType.HTTPException,
      );
    } on FormatException catch (e) {
      throw AppException(
        message: e?.source?.toString(),
        type: ExceptionType.FormatException,
      );
    } catch (error) {
      if (error is AppException &&
          error.type == ExceptionType.UnderMaintainance) {
        // Show error alert...
        showAlert(
          context: context,
          barrierDismissible: false,
          message: error,
          rigthBttnTitle: "Retry",
          onRightAction: () {
            callService(
              context: context,
              requestInfo: requestInfo,
              callAsMultipart: callAsMultipart,
            );
          },
        );
        return "";
      } else {
        throw error;
      }
    }
  }

  //Check Internet...
  static Future<bool> checkConnectivity() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw AppException(
        title: AlertMessageString.noInternet,
        message: AlertMessageString.noInternet,
      );
    }
    return true;
  }
}

// API Request Obj...
class APIRequestInfoObj {
  HTTPRequestType requestType;
  String customBaseURL;
  String endPoint;
  String id;
  Map<String, dynamic> parameter;
  Map<String, String> headers;
  List<UploadDocumentObj> docList;

  APIRequestInfoObj({
    this.requestType = HTTPRequestType.POST,
    this.customBaseURL = "",
    @required this.endPoint,
    this.parameter,
    this.headers,
    this.id = "",
    this.docList,
  });

  //Get Final URL...
  String get _getFinalURL =>
      endPoint.getFinalURL(id: id, customBaseURL: customBaseURL);

  //Get normal API Response...
  Future<String> get getResponseFromAPI => _getFinalURL.callAPI(
        requestType,
        parameter,
        headers,
      );

  //Get multipart API Response...
  Future<String> get getMultipartResposneFromAPI =>
      _getFinalURL.callMultipartAPI(
        requestType,
        parameter,
        headers,
        docList: docList ?? [],
      );
}

extension APIHelper on String {
  //Get Final Url...
  String getFinalURL({
    String id = "",
    String customBaseURL = "",
  }) {
    String newBaseURL = SharedPreferencesHelper.getCustomBaseURL;

    //Live Base URL...
    String _liveBaseURL = customBaseURL.isEmpty
        ? (newBaseURL.isEmpty ? APISetup.liveURL : newBaseURL)
        : customBaseURL;

    // Test URL...
    String _testBaseURL = APISetup.useLiveToTest
        ? _liveBaseURL
        : customBaseURL.isEmpty
            ? APISetup.testURL
            : customBaseURL;

    String url = this;

    //Check if App is in Debug or Live Mode...
    String baseURL = kReleaseMode ? _liveBaseURL : _testBaseURL;
    url = baseURL + this + (id.isNotEmpty ? id : "");
    print("");
    print(
        "//---------------------------- New API Call -------------------------------//");
    print('URL:- $url');
    return url;
  }

  //Get Header...
  Map<String, String> get getHeader {
    Map<String, String> _header = {'Content-Type': 'application/json'};
    UserInfoObj userInfo = SharedPreferencesHelper.getUserInfo;

    if (userInfo?.authCredential?.accessToken?.isNotEmpty ?? false) {
      _header["Authorization"] = userInfo.authCredential.getAccessToken;
      _header["X-Authorization"] = userInfo.authCredential.refreshToken;
    }
    // print(_header);
    return _header;
  }

  //Call API...
  Future<String> callAPI(
    HTTPRequestType requestType,
    Map<String, dynamic> parameter,
    Map<String, String> headers,
  ) async {
    // Http Response...
    http.Response response;
    print("RequestType:- $requestType");

    // Add header...
    Map<String, dynamic> apiHeader = headers ?? getHeader;

    //Call API with respect to request type...
    switch (requestType) {
      case HTTPRequestType.POST:
        print("Parameters:- $parameter");
        response = await http.post(
          this,
          body: json.encode(parameter),
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.GET:
        response = await http.get(
          this,
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.DELETE:
        response = await http.delete(
          this,
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.PUT:
        print("Parameters:- $parameter");
        response = await http.put(
          this,
          body: json.encode(parameter),
          headers: apiHeader,
        );
        break;
    }
    //Return Received Response...
    return response.processResponse();
  }

  // Multipart request...
  Future<String> callMultipartAPI(
    HTTPRequestType requestType,
    Map<String, dynamic> parameter,
    Map<String, String> headers, {
    List<UploadDocumentObj> docList,
  }) async {
    print("Parameters:- $parameter");

    //Get URI...
    Uri uri = Uri.parse(this);
    http.MultipartRequest request =
        http.MultipartRequest(requestType.toString().split(".").last, uri);

    //Add Parameters...
    parameter?.forEach((key, value) => request.fields[key] = value);

    //Add header...
    Map<String, dynamic> apiHeader = headers ?? getHeader;
    apiHeader?.forEach((key, value) => request.headers[key] = value);

    //Add Attached File...
    if (docList.isNotEmpty) {
      for (int i = 0; i < docList.length; i++) {
        if (docList[i].docKey.isNotEmpty && docList[i].docPathList.isNotEmpty) {
          for (int j = 0; j < docList[i].docPathList.length; j++) {
            request.files.add(
              await http.MultipartFile.fromPath(
                  docList[i].docKey, docList[i].docPathList[j],
                  filename: basename(docList[i].docPathList[j])),
            );
          }
        }
      }
    }

    //Send Request...
    http.Response response =
        await http.Response.fromStream(await request.send());

    //Return Received Response...
    return response.processResponse();
  }
}

// Process Respnse...
extension ProcessHttpResponse on http.Response {
  //Get Error Title...
  String get getErrorTitle => this?.body?.isEmpty ?? true
      ? AlertMessageString.defaultErrorTitle
      : defaultRespInfo(this?.body ?? "").title;

  //Get Error Message...
  String get getErrorMsg => this?.body?.isEmpty ?? true
      ? AlertMessageString.somethingWentWrong
      : defaultRespInfo(this?.body ?? "").message;

  //Process Response...
  String processResponse() {
    switch (this.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        return this?.body ?? "";
        break;

      case 401:
      case 410:
        throw AppException(
          statusCode: this.statusCode,
          title: getErrorTitle,
          message: getErrorMsg,
          type: ExceptionType.UnAuthorised,
        );
        break;

      case 400:
      case 403:
      case 404:
      case 422:
        throw AppException(
          statusCode: this.statusCode,
          title: getErrorTitle,
          message: getErrorMsg,
          type: ExceptionType.None,
        );
        break;

      // Service Unavailable...
      case 503:
        throw AppException(
          statusCode: this.statusCode,
          title: getErrorTitle,
          message: getErrorMsg,
          type: ExceptionType.UnderMaintainance,
        );
        break;

      default:
        throw AppException(
          statusCode: this.statusCode,
          title: getErrorTitle,
          message: getErrorMsg,
          type: ExceptionType.None,
        );
    }
  }
}

//Uploading document Object...
class UploadDocumentObj {
  String docKey;
  List<String> docPathList;

  UploadDocumentObj({
    this.docKey = "",
    this.docPathList = const [],
  });
}
