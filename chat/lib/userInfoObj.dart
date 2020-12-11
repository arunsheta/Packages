part of chat;

UserInfoObj userInfoObjFromJson(String str) =>
    str.isEmpty ? null : UserInfoObj.fromJson(json.decode(str));

String userInfoObjToJson(UserInfoObj data) => json.encode(data.toJson());

class UserInfoObj {
  UserInfoObj({
    this.id,
    this.name,
    this.email,
    this.chattingWith,
    this.status,
    this.type,
    this.fcmId,
    this.deviceId,
    this.profileUrl,
    this.blockList,
  });
  String id;
  String name;
  String email;
  String chattingWith;
  String status;
  String type;
  List<dynamic> fcmId;
  String deviceId;
  List<dynamic> profileUrl;
  List<dynamic> blockList = [];

  factory UserInfoObj.fromJson(Map<String, dynamic> json) => UserInfoObj(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        chattingWith: json["chattingWith"] ?? "",
        status: json["status"] ?? "",
        type: json["type"] ?? "",
        fcmId: json["fcm_id"],
        deviceId: json["device_id"] ?? "",
        profileUrl: json["profileUrl"] == null ? [] : json["profileUrl"],
        blockList: json["blockList"],
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? "",
        "name": name ?? "",
        "email": email ?? "",
        "chattingWith": chattingWith ?? "",
        "status": status ?? "",
        "type": type ?? "",
        "fcm_id": fcmId,
        "device_id": deviceId ?? "",
        "profileUrl": profileUrl,
        "blockList": blockList,
      };
}
