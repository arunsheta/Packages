part of chat;

MessageListObj messageListObjFromJson(String str) =>
    MessageListObj.fromJson(json.decode(str));

String messageListObjToJson(MessageListObj data) => json.encode(data.toJson());

class MessageListObj {
  MessageListObj({
    this.chatDate,
    this.messageObj,
  });

  String chatDate;
  List<MessageObj> messageObj;

  factory MessageListObj.fromJson(Map<String, dynamic> json) => MessageListObj(
        chatDate: json["chatDate"] ?? "",
        messageObj: List<MessageObj>.from(
            json["messageObj"].map((x) => MessageObj.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "chatDate": chatDate ?? "",
        "messageObj": List<dynamic>.from(messageObj.map((x) => x.toJson())),
      };
}

MessageObj messageObjFromJson(String str) =>
    MessageObj.fromJson(json.decode(str));

String messageObjToJson(MessageObj data) => json.encode(data.toJson());

class MessageObj {
  MessageObj({
    this.toSend,
    this.sendBy,
    this.message,
    this.time,
    this.type,
    this.imageUrl,
    this.deleteBy,
    this.recieverPath,
    this.senderPath,
    this.isDownloaded,
  });

  String toSend;
  String sendBy;
  String message;
  int time;
  int type;
  String imageUrl;
  List<dynamic> deleteBy = [];
  String recieverPath;
  String senderPath;
  bool isDownloaded;

  factory MessageObj.fromJson(Map<String, dynamic> json) => MessageObj(
        toSend: json["toSend"] ?? "",
        sendBy: json["sendBy"] ?? "",
        message: json["message"] ?? "",
        time: json["time"],
        type: json["type"],
        imageUrl: json["image_url"],
        deleteBy: json["deleteBy"],
        recieverPath: json["recieverPath"],
        senderPath: json["senderPath"],
        isDownloaded: json["isDownloaded"],
      );
  Map<String, dynamic> toJson() => {
        "toSend": toSend ?? "",
        "sendBy": sendBy ?? "",
        "message": message ?? "",
        "time": time,
        "type": type,
        "image_url": imageUrl ?? "",
        "deleteBy": deleteBy,
        "recieverPath": recieverPath,
        "senderPath": senderPath,
        "isDownloaded": isDownloaded,
      };
}
