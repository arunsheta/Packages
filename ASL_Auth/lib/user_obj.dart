import 'dart:convert';
import 'package:flutter/material.dart';

import 'api_end_points.dart';
import 'api_response_obj.dart';
import 'api_service.dart';
import 'auth_obj.dart';
import 'custom_enum.dart';

// UserInfo from stored json...
UserInfoObj userInfoFromStoredJson(String str) => str.isEmpty
    ? null
    : UserInfoObj.fromJson(
        json.decode(str),
      );

// UserInfo from server json...
UserInfoObj userInfoFromServerJson(String str) => UserInfoObj.fromJson(
      defaultRespInfo(str).resultObj,
    );

// UserInfo to raw json (Json to json string)...
String userInfoToRawJson(UserInfoObj userInfo) => json.encode(
      userInfo.toJson(),
    );

class UserInfoObj {
  // User object keys...
  static String _kId = "";
  static String _kName = "";
  static String _kEmail = "";
  static String _kPassword = "";
  static String _kOldPassword = "";
  static String _kNewPassword = "";
  static String _kFCMToken = "";
  static String _kDeviceId = "";
  static String _kAuthCredential = "";

  UserInfoObj({
    this.id,
    this.name = "",
    this.email = "",
    this.password = "",
    this.newPassword = "",
    this.fcmToken = "",
    this.deviceId = "",
    this.authCredential,
    @required this.auhtType,
  });
  int id;
  String name, email, password, newPassword, fcmToken, deviceId, message;
  AuthCredential authCredential;
  AuthType auhtType;

  factory UserInfoObj.fromJson(Map<String, dynamic> json) => UserInfoObj(
        id: json[_kId],
        name: json[_kName] ?? "",
        email: json[_kEmail] ?? "",
        fcmToken: json[_kFCMToken] ?? "",
        authCredential: json[_kAuthCredential] == null
            ? null
            : AuthCredential.fromJson(json[_kAuthCredential]),
        auhtType: AuthType.None,
      );

  Map<String, dynamic> toJson() => {
        _kId: id,
        _kName: name?.trim() ?? "",
        _kEmail: email?.trim()?.toLowerCase() ?? "",
        _kOldPassword: password?.trim() ?? "",
        _kNewPassword: newPassword?.trim() ?? "",
        _kFCMToken: fcmToken ?? "",
        _kDeviceId: deviceId ?? "",
        _kAuthCredential: authCredential?.toJson(),
      };

  // To cloned data...
  UserInfoObj get toClonedInfo => UserInfoObj.fromJson(this.toJson());

  // API Request Info (Set parameters and Request type according to your Postman API collection)...
  APIRequestInfoObj toAPIRequestInfo() {
    Map<String, dynamic> _params = {};
    HTTPRequestType requestType = HTTPRequestType.POST;

    switch (this.auhtType) {

      // Login params...
      case AuthType.Login:
        _params[_kEmail] = email?.trim() ?? "";
        _params[_kPassword] = password?.trim() ?? "";
        break;

      // SignUp params...
      case AuthType.SignUp:
        _params[_kName] = name?.trim() ?? "";
        _params[_kEmail] = email?.trim() ?? "";
        _params[_kPassword] = password?.trim() ?? "";
        break;

      // Forgot password params...
      case AuthType.ForgotPassword:
        _params[_kEmail] = email?.trim() ?? "";
        break;

      //Change password params...
      case AuthType.ChangePassword:
        _params[_kOldPassword] = password?.trim() ?? "";
        _params[_kNewPassword] = newPassword?.trim() ?? "";
        break;

      // Update profile...
      case AuthType.UpdateProfile:
        requestType = HTTPRequestType.PUT;
        _params[_kName] = name?.trim() ?? "";
        _params[_kEmail] = email?.trim() ?? "";
        break;

      // Set FCM token...
      case AuthType.SetFcmToken:
        _params[_kFCMToken] = fcmToken?.trim() ?? "";
        _params[_kDeviceId] = deviceId?.trim() ?? "";
        break;

      // Terms and Condition...
      case AuthType.TermsAndCondition:
        requestType = HTTPRequestType.GET;
        break;

      // Privacy Policy...
      case AuthType.PrivacyPolicy:
        requestType = HTTPRequestType.GET;
        break;

      // Refresh token...
      case AuthType.RefreshToken:
        break;

      // Logout...
      case AuthType.Logout:
        break;

      case AuthType.None:
        break;
    }

    return APIRequestInfoObj(
      requestType: requestType,
      endPoint: EndPoints.auth.authEndpoint(this),
      parameter: _params,
    );
  }
}
