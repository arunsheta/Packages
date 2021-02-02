import 'dart:convert';
import 'alert_string.dart';
import 'api_setup.dart';

ResponseObj defaultRespInfo(String str) => str.isEmpty
    ? ResponseObj()
    : ResponseObj.fromJson(
        json.decode(str),
      );

class ResponseObj {
  ResponseObj({
    this.title = AlertMessageString.defaultErrorTitle,
    this.message = AlertMessageString.somethingWentWrong,
    this.resultObj = const {},
    this.resultArray = const [],
  });

  String message, title;
  Map resultObj;
  List resultArray;

  factory ResponseObj.fromJson(Map<String, dynamic> json) {
    Map data = <String, dynamic>{};
    List dataSet = [];

    // Error/Success title...
    String title =
        json[APISetup.errorTitleKey] ?? AlertMessageString.defaultErrorTitle;

    // Error/Success message...
    String message =
        json[APISetup.errorMessageKey] ?? AlertMessageString.somethingWentWrong;

    // Get object...
    if (json[APISetup.dataKey] != null && json[APISetup.dataKey] is Map) {
      data = json[APISetup.dataKey];
    }

    // Get object array...
    if (json[APISetup.datasetKey] != null &&
        json[APISetup.datasetKey] is List) {
      dataSet = json[APISetup.datasetKey];
    }

    return ResponseObj(
      title: title,
      message: message,
      resultObj: data,
      resultArray: dataSet,
    );
  }
}
