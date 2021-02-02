import 'dart:convert';

class AuthCredential {
  AuthCredential({
    this.accessToken = "",
    this.refreshToken = "",
    this.tokenType = "",
    this.expiresIn = 0,
  });

  String accessToken;
  String refreshToken;
  String tokenType;
  int expiresIn;

  factory AuthCredential.fromJson(Map<String, dynamic> json) => AuthCredential(
        accessToken: json["access_token"] ?? "",
        refreshToken: json["refresh_token"] ?? "",
        tokenType: json["token_type"] ?? "",
        expiresIn: json["expires_in"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken ?? "",
        "refresh_token": refreshToken ?? "",
        "token_type": tokenType ?? "",
        "expires_in": expiresIn,
      };

  // Get access token...
  String get getAccessToken => tokenType + " " + accessToken;

  // Get token expire timestamp...
  int get getTokenExpTimeStamp => accessToken?.getJsonFromJWT["exp"] ?? 0;

  // Check if token is expired...
  bool get isTokenExpired {
    // timestamp in token is in sec so multiply it with 1000 to convert in mili sec to campare it with current Epoch time stamp...
    int timeStamp = getTokenExpTimeStamp * 1000;
    print("JWT token timeStamp:- $timeStamp");
    print(
        "Current timeStamp:-   ${DateTime.now().toUtc().millisecondsSinceEpoch}");

    return timeStamp <
        DateTime.now()
            .millisecondsSinceEpoch; // Minus 60000 miliseconds from epoch time to avoid token expired error, and call refresh token API 1 minute ago...(1sec = 1000 mili sec.)
  }
}

extension ExtJWTTimeStamp on String {
  //Decode JWT Token...
  Map<String, dynamic> get getJsonFromJWT {
    try {
      if (this.isEmpty) {
        return {"exp": "0"};
      } else {
        String normalizedSource = base64Url.normalize(this.split(".")[1]);
        return json.decode(
          utf8.decode(
            base64Url.decode(normalizedSource),
          ),
        );
      }
    } catch (error) {
      print("Error converting token data, $error");
      return {"exp": "0"};
    }
  }
}
