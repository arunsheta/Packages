part of asl_auth;

class ApiCall {
  // Call API...
  static Future<http.Response> callService({
    required APIRequestInfoObj requestInfo,
  }) async {
    try {
      // Check Internet...
      await checkConnectivity();

      // Print Request info...
      _printApiDetial(requestInfo);

      // Get Response...
      return requestInfo.docList.isEmpty
          ? await _callAPI(requestInfo: requestInfo)
              .timeout(Duration(seconds: requestInfo.timeSecond))
          : await _callMultipartAPI(requestInfo: requestInfo)
              .timeout(Duration(seconds: requestInfo.timeSecond));

      // Exceptions...
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
        message: e.source?.toString(),
        type: ExceptionType.FormatException,
      );
    } on TimeoutException {
      throw AppException(
        title: APIErrorMsg.requestTimeOutTitle,
        message: APIErrorMsg.requestTimeOutMessage,
        type: ExceptionType.TimeOut,
      );
    } catch (error) {
      throw error;
    }
  }

  //Check Internet connectivity...
  static Future<bool> checkConnectivity() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw AppException(
        title: APIErrorMsg.noInternet,
        message: APIErrorMsg.noInternetMsg,
      );
    }
    return true;
  }

  //Call API...
  static Future<http.Response> _callAPI({
    required APIRequestInfoObj requestInfo,
  }) async {
    // final URL...
    String _url = requestInfo.url;

    // Http Response...
    http.Response response;

    // Add header...
    Map<String, String>? apiHeader = requestInfo.headers;

    //Call API with respect to request type...
    switch (requestInfo.requestType) {
      case HTTPRequestType.POST:
        response = await http.post(
          Uri.parse(_url),
          body: requestInfo.parameter == null
              ? null
              : json.encode(requestInfo.parameter),
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.GET:
        response = await http.get(
          Uri.parse(_url),
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.DELETE:
        response = await http.delete(
          Uri.parse(_url),
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.PUT:
        response = await http.put(
          Uri.parse(_url),
          body: requestInfo.parameter == null
              ? null
              : json.encode(requestInfo.parameter),
          headers: apiHeader,
        );
        break;
    }

    // Print Request info...
    _printResponse(response, requestInfo.serviceName);

    //Return Received Response...
    return response;
  }

  // Multipart request...
  static Future<http.Response> _callMultipartAPI({
    required APIRequestInfoObj requestInfo,
  }) async {
    //Get URI...
    Uri uri = Uri.parse(requestInfo.url);
    http.MultipartRequest request = http.MultipartRequest(
      describeEnum(requestInfo.requestType),
      uri,
    );

    //Add Parameters...
    requestInfo.parameter?.forEach((key, value) => request.fields[key] = value);

    //Add header...
    Map<String, String>? apiHeader = requestInfo.headers;
    apiHeader?.forEach((key, value) => request.headers[key] = value);

    //Set Documents
    List<Future<http.MultipartFile>> _files = requestInfo.docList
        .map(
          (docInfo) => docInfo.docPathList.map(
            (docPath) => http.MultipartFile.fromPath(
              docInfo.docKey,
              docPath,
              filename: basename(docPath),
            ).catchError(
              (error) {
                print(
                    "----------------Error While uploading Image: $docPath, Error: $error-------------");
              },
            ),
          ),
        )
        .expand((multipartFile) => multipartFile)
        .toList();

    // Upload all files...
    List<http.MultipartFile> _multiPartFiles =
        await Future.wait<http.MultipartFile>(_files);
    request.files.addAll(_multiPartFiles);

    //Send Request...
    http.Response response =
        await http.Response.fromStream(await request.send());

    // Print Request info...
    _printResponse(response, requestInfo.serviceName);

    //Return Received Response...
    return response;
  }

  // API info...
  static void _printApiDetial(APIRequestInfoObj info) {
    if (kReleaseMode) return;
    String apiLog = """

        ${info.serviceName} Service Parameters
        |-------------------------------------------------------------------------------------------------------------------------
        | ApiType :- ${describeEnum(info.requestType)}
        | URL     :- ${info.url}
        | Params  :- ${info.parameter}
        |-------------------------------------------------------------------------------------------------------------------------
        """;
    print(apiLog);
  }

  // API resposne info...
  static void _printResponse(http.Response response, String serviceName) {
    if (kReleaseMode) return;
    if (response.statusCode < 300) return;
    String apiLog = """

        $serviceName Service Response
        |--------------------------------------------------------------------------------------------------------------------------
        | API        :- $serviceName
        | StatusCode :- ${response.statusCode}
        | Message    :- ${response.body}
        |--------------------------------------------------------------------------------------------------------------------------
        """;
    print(apiLog);
  }
}

// API Request Obj...
class APIRequestInfoObj {
  HTTPRequestType requestType;
  String url;
  Map<String, dynamic>? parameter;
  Map<String, String>? headers;
  List<UploadDocumentObj> docList;
  String serviceName;
  int timeSecond = 30;

  APIRequestInfoObj({
    this.requestType = HTTPRequestType.POST,
    this.parameter,
    this.headers,
    this.docList = const [],
    required this.url,
    this.serviceName = "",
    this.timeSecond = 30,
  });
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
