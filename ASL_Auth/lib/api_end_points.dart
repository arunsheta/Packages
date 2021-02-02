// End Points...
import 'package:ASL_Auth/user_obj.dart';

import 'custom_enum.dart';

class EndPoints {
  static AuthEndPoints auth = AuthEndPoints();
}

// Auth...
class AuthEndPoints {
  static const String _login = '';
  static const String _signUp = '';
  static const String _forgotPassword = '';
  static const String _changePassword = '';
  static const String _updateProfile = '';
  static const String _refreshToken = '';
  static const String _setFCMToken = '';
  static const String _termsNcondi = '';
  static const String _privacyPolicy = '';
  static const String _logout = '';

  String authEndpoint(UserInfoObj userInfo) {
    String endPoint = "";
    switch (userInfo.auhtType) {
      // Login...
      case AuthType.Login:
        endPoint = _login;
        break;
      // SignUp...
      case AuthType.SignUp:
        endPoint = _signUp;
        break;

      //Forgot password...
      case AuthType.ForgotPassword:
        endPoint = _forgotPassword;
        break;

      //Change password...
      case AuthType.ChangePassword:
        endPoint = _changePassword;
        break;

      // Update profile...
      case AuthType.UpdateProfile:
        endPoint = _updateProfile;
        break;

      // Refresh Token...
      case AuthType.RefreshToken:
        endPoint = _refreshToken;
        break;

      // Set FCM Token...
      case AuthType.SetFcmToken:
        endPoint = _setFCMToken;
        break;

      // Terms and Condition...
      case AuthType.TermsAndCondition:
        endPoint = _termsNcondi;
        break;

      // Privacy policy...
      case AuthType.PrivacyPolicy:
        endPoint = _privacyPolicy;
        break;

      // Logout...
      case AuthType.Logout:
        endPoint = _logout;
        break;

      case AuthType.None:
        throw "Please select valid auth type";
        break;
    }

    return endPoint;
  }

  // Check if API call is for refreshing token...
  bool isRefeshingToken(String endPoint) => endPoint == _refreshToken;
}
