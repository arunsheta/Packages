part of asl_auth;

ResponseObj defaultRespInfo(String str) => str.isEmpty
    ? ResponseObj()
    : ResponseObj.fromJson(
        json.decode(str),
      );

class ResponseObj {
  static String errorTitleKey = "";
  static String errorMessageKey = "";
  static String dataKey = "";
  static String datasetKey = "";

  ResponseObj({
    this.title = APIErrorMsg.defaultErrorTitle,
    this.message = APIErrorMsg.somethingWentWrong,
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
    String title = json[errorTitleKey] ?? APIErrorMsg.defaultErrorTitle;

    // Error/Success message...
    String message = json[errorMessageKey] ?? APIErrorMsg.somethingWentWrong;

    // Get object...
    if (json[dataKey] != null && json[dataKey] is Map) {
      data = json[dataKey];
    }

    // Get object array...
    if (json[datasetKey] != null && json[datasetKey] is List) {
      dataSet = json[datasetKey];
    }

    return ResponseObj(
      title: title,
      message: message,
      resultObj: data,
      resultArray: dataSet,
    );
  }
}
