//RecentChatObj Object...

part of chat;

RecentChatObj recentChatObjFromJson(String str) =>
    RecentChatObj.fromJson(json.decode(str));

String recentChatObjToJson(RecentChatObj data) => json.encode(data.toJson());

class RecentChatObj {
  RecentChatObj({
    this.name,
    this.email,
    this.id,
    this.profileUrl,
    this.pendingMsg,
    this.pendingMsgWith,
    this.lastMessage,
    this.lastMsgTime,
    this.type,
    this.memberList,
    this.cardStatus,
    this.typingStatus,
    this.typingWith,
    this.isBlock,
    this.blockBy,
    this.blockList,
    this.status,
    this.count,
    this.adminList,
  });
  String name;
  String email;
  String id;
  List<dynamic> profileUrl;
  String pendingMsg;
  String pendingMsgWith;
  String lastMessage;
  int lastMsgTime;
  String type;
  List<dynamic> memberList = [];
  int cardStatus;
  int typingStatus;
  String typingWith;
  bool isBlock;
  String blockBy;
  List<dynamic> blockList = [];
  String status;
  int count;
  List<dynamic> adminList;

  factory RecentChatObj.fromJson(Map<String, dynamic> json) => RecentChatObj(
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        id: json["id"] ?? "",
        profileUrl: json["profileUrl"] == null ? [] : json["profileUrl"],
        pendingMsg: json["pendingMsg"],
        pendingMsgWith: json["pendingMsgWith"] ?? "",
        lastMessage: json["lastMessage"] ?? "",
        lastMsgTime: json["lastMsgTime"],
        type: json["type"] ?? "",
        memberList: json["memberList"],
        cardStatus: json["cardStatus"],
        typingStatus: json["typingStatus"],
        typingWith: json["typingWith"] ?? "",
        isBlock: json["isBlock"],
        blockBy: json["blockBy"] ?? "",
        blockList: json["blockList"] == null ? [] : json["blockList"],
        status: json["status"] ?? "",
        count: json["count"],
        adminList: json["adminList"] == null ? [] : json["adminList"],
      );

  Map<String, dynamic> toJson() => {
        "name": name ?? "",
        "email": email ?? "",
        "id": id ?? "",
        "profileUrl": profileUrl,
        "pendingMsg": pendingMsg ?? "",
        "pendingMsgWith": pendingMsgWith ?? "",
        "lastMessage": lastMessage ?? "",
        "lastMsgTime": lastMsgTime,
        "type": type ?? "",
        "memberList": memberList,
        "cardStatus": cardStatus,
        "typingStatus": typingStatus,
        "typingWith": typingWith,
        "isBlock": isBlock,
        "blockBy": blockBy,
        "blockList": blockList,
        "status": status,
        "count": count,
        "adminList": adminList,
      };
}
