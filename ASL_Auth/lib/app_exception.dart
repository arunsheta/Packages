import 'alert_string.dart';

class AppException implements Exception {
  final String message;
  final String title;
  final ExceptionType type;
  final int statusCode;

  AppException({
    this.title,
    this.message,
    this.type = ExceptionType.None,
    this.statusCode = 200,
  });

  AlertInfo get getAlertInfo {
    String alertTitle = "";
    String msg = "";
    switch (type) {
      // No Internet...
      case ExceptionType.NoInternet:
        alertTitle = AlertMessageString.noInternet;
        msg = AlertMessageString.noInternetMsg;
        break;

      // Un-Authorised...
      case ExceptionType.UnAuthorised:
        alertTitle = AlertMessageString.unAuthorisedTitle;
        msg = AlertMessageString.unAuthorisedMsg;
        break;

      // HTTP Exception...
      case ExceptionType.HTTPException:
        alertTitle = title ?? AlertMessageString.defaultErrorTitle;
        msg = message ?? AlertMessageString.somethingWentWrong;
        break;

      // Format Exception...(Backend side have an invalid value set in the 'Request Format' property of a REST API method, or don't have any value set at all.)
      case ExceptionType.FormatException:
        alertTitle = title ?? AlertMessageString.defaultErrorTitle;
        msg = message ?? AlertMessageString.somethingWentWrong;
        break;

      // General Error...
      case ExceptionType.None:
        alertTitle = title ?? AlertMessageString.defaultErrorTitle;
        msg = message ?? AlertMessageString.somethingWentWrong;
        break;

      // Under Maintainance...
      case ExceptionType.UnderMaintainance:
        alertTitle = title ?? AlertMessageString.underMaintainanceTitle;
        msg = message ?? AlertMessageString.underMaintainanceMsg;
        break;
    }
    return AlertInfo(title: alertTitle, message: msg);
  }

  String get getTitle => getAlertInfo.title;
  String get getMessage => getAlertInfo.message;
}

enum ExceptionType {
  NoInternet,
  HTTPException,
  FormatException,
  UnAuthorised,
  UnderMaintainance,
  None,
}

class AlertInfo {
  final String title;
  final String message;
  AlertInfo({
    this.title,
    this.message,
  });
}
