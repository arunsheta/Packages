// UserInfo from stored json...
import 'dart:convert';

UserInfoObj userInfoFromStoredJson(String str) => str.isEmpty
    ? null
    : UserInfoObj.fromJson(
        json.decode(str),
      );

// UserInfo to raw json (Json to json string)...
String userInfoToRawJson(UserInfoObj userInfo) => json.encode(
      userInfo.toJson(),
    );

class UserInfoObj {
  // User object keys...
  static String _kId = "id";
  static String _kName = "name";
  static String _kEmail = "email";
  static String _kOldPassword = "old_password";
  static String _kNewPassword = "new_password";
  static String _kFCMToken = "fcm_token";
  static String _kDeviceId = "device_id";

  UserInfoObj({
    this.id,
    this.name = "",
    this.email = "",
    this.password = "",
    this.newPassword = "",
    this.fcmToken = "",
    this.deviceId = "",
  });
  int id;
  String name, email, password, newPassword, fcmToken, deviceId, message;

  factory UserInfoObj.fromJson(Map<String, dynamic> json) => UserInfoObj(
        id: json[_kId],
        name: json[_kName] ?? "",
        email: json[_kEmail] ?? "",
        fcmToken: json[_kFCMToken] ?? "",
      );

  Map<String, dynamic> toJson() => {
        _kId: id,
        _kName: name?.trim() ?? "",
        _kEmail: email?.trim()?.toLowerCase() ?? "",
        _kOldPassword: password?.trim() ?? "",
        _kNewPassword: newPassword?.trim() ?? "",
        _kFCMToken: fcmToken ?? "",
        _kDeviceId: deviceId ?? "",
      };
}

// Social log-in type...
enum SocialLoginType {
  Google,
  Facebook,
  Twitter,
  EmailPassword,
  Anonymously,
}
