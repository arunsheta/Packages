import 'dart:core';

import 'package:ASL_Auth/user_obj.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_setup.dart';
import 'custom_url_obj.dart';

class SharedPreferencesHelper {
  // Shared Preference Keys
  static final String _kUserInfo = 'user_info';
  static final String _baseURL = 'base_url';

  // Variables...
  static UserInfoObj _userInfo;
  static SharedPreferences _prefs;
  static List<CustomUrl> _customURLList;

  // Load saved data...
  static Future<void> loadSavedData() async {
    _prefs = await SharedPreferences.getInstance();
    _getBaseURLs();
    _getUserDetail();
  }

  //!------------------------------------------------- Setter --------------------------------------------------//

  // Set UserInfo...
  static set setUserInfo(UserInfoObj userInfo) {
    _userInfo = userInfo;
    _prefs.setString(_kUserInfo, userInfoToRawJson(userInfo));
  }

  //!------------------------------------------------- Getter --------------------------------------------------//

  // Custom base url...
  static String get getCustomBaseURL =>
      _customURLList.firstWhere((url) => url.isActiveURL, orElse: () {
        return CustomUrl();
      }).baseUrl;

  // Custom base url...
  static List<CustomUrl> get getCustomBaseURLList => _customURLList;

  // User detail...
  static UserInfoObj get getUserInfo => _userInfo;

  // User detail...
  static UserInfoObj _getUserDetail() {
    String userInfo = _prefs.getString(_kUserInfo) ?? "";
    _userInfo = userInfo.isEmpty ? null : userInfoFromStoredJson(userInfo);
    return getUserInfo;
  }

  // Base URL...
  static List<CustomUrl> _getBaseURLs() {
    String urls = _prefs.getString(_baseURL) ?? '';
    List<CustomUrl> customURLList = [];
    if (urls.isEmpty) {
      customURLList.addAll([
        CustomUrl(
          baseUrl: APISetup.liveURL,
          isActiveURL: true,
        ),
        CustomUrl(
          baseUrl: APISetup.testURL,
        )
      ]);
    } else {
      customURLList = customUrlListFromJson(urls);
    }

    return customURLList;
  }

//!------------------------------------------------- Remove Cache Data --------------------------------------------------//
  // Remove Cache Data (Use only when user wants to remove all store data on app)...
  static Future<bool> removeCacheData() async {
    return _prefs.remove(_kUserInfo);
  }
}
