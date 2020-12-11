part of chat;

class ChatService {
  String _projectName = "project_name";
  String _usersCollection = "user_collection_name";
  String _chatRoomCollection = "chatroom_collection_name";

  ChatService({
    @required String projectName,
    @required String userCollectionName,
    @required String chatRoomCollectionName,
  }) {
    _projectName = projectName;
    _usersCollection = chatRoomCollectionName;
    _chatRoomCollection = chatRoomCollectionName;
  }

  printVarialble() {
    print(_projectName);
    print(_usersCollection);
    print(_chatRoomCollection);
  }
}

//Add user to cloud firestore...
Future<void> addUserToCloudFireStore(
    {String userId,
    String userEmail,
    String userName,
    String userProfileUrl,
    List<String> fcmId}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .get()
      .then((docSnapshot) async {
    if (!docSnapshot.exists) {
      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "id": userId,
        "email": userEmail,
        "name": userEmail,
        "profileUrl": userProfileUrl,
        "chattingWith": "",
        "blockList": [],
        "type": "single",
        "status": "online",
        "fcm_id": fcmId,
      });
    }
  });
}

//Store photo in firebase storage for profile picture...
Future<dynamic> setProfilePictureToFirebaseStorage({
  String userId,
  File imageFile,
}) async {
  firebase_storage.Reference reference = firebase_storage
      .FirebaseStorage.instance
      .ref()
      .child("$userId/profilePhoto");
  await reference.putData((imageFile.readAsBytesSync()));
  // firebase_storage.TaskSnapshot taskSnapshot = uploadTask.snapshot;
  return await reference.getDownloadURL();
}

//Update profile picture...
Future<void> updateProfileUrlToCloudFireStore(
    {String userId, String userNewProfileUrl}) async {
  await FirebaseFirestore.instance.collection("users").doc(userId).update({
    "profileUrl": userNewProfileUrl,
  });
}

//Get all users from cloud firestore...
Future<Stream<QuerySnapshot>> getAllUsersFromCloudFireStore() async {
  return FirebaseFirestore.instance
      .collection("users")
      .orderBy("id", descending: true)
      .snapshots();
}

//Set recent chat card for current user and other user...
Future<void> setRecentChatCardForBothUser(
    {String currentUserId,
    String currentUserName,
    String currentUserEmail,
    List<String> currentUserProfileUrl,
    String conversationUserId,
    String otherUserName,
    String otherUserEmail,
    List<String> otheruserProfileUrl}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .collection("recent_chats")
      .doc(conversationUserId)
      .get()
      .then((value) async {
    if (!value.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("recent_chats")
          .doc(conversationUserId)
          .set(
            RecentChatObj(
                    name: otherUserName,
                    email: otherUserEmail,
                    id: conversationUserId,
                    profileUrl: otheruserProfileUrl,
                    pendingMsg: "",
                    pendingMsgWith: "",
                    lastMessage: "Start chatting",
                    lastMsgTime: null,
                    type: "single",
                    memberList: [currentUserId, conversationUserId],
                    cardStatus: 1,
                    typingStatus: 0,
                    typingWith: "",
                    isBlock: false,
                    blockBy: "",
                    blockList: [],
                    status: "",
                    count: 0)
                .toJson(),
          );
    }
  });
  await FirebaseFirestore.instance
      .collection("users")
      .doc(conversationUserId)
      .collection("recent_chats")
      .doc(currentUserId)
      .get()
      .then((value) async {
    if (!value.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(conversationUserId)
          .collection("recent_chats")
          .doc(currentUserId)
          .set(
            RecentChatObj(
                    name: currentUserName,
                    email: currentUserEmail,
                    id: currentUserId,
                    profileUrl: currentUserProfileUrl,
                    pendingMsg: "",
                    pendingMsgWith: "",
                    lastMessage: "Start chatting",
                    lastMsgTime: null,
                    type: "single",
                    memberList: [currentUserId, conversationUserId],
                    cardStatus: 1,
                    typingStatus: 0,
                    typingWith: "",
                    isBlock: false,
                    blockBy: "",
                    blockList: [],
                    status: "",
                    count: 0)
                .toJson(),
          );
    }
  });
}

//Create chatId...
getChatId({String currentUserId, String conversationUserId}) {
  List<String> ab = [currentUserId, conversationUserId];
  ab.sort((a, b) => a.compareTo(b));
  return ab.reduce((value, element) => value + element);
}

//Set chattingwith...
Future<void> setChattingWith(
    {String currentUserId, String conversationUserId}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .update({
    "chattingWith": conversationUserId,
  });
}

//Send message as Text...
Future<void> sendMessageAsText({
  String message,
  String currentUserId,
  String conversationUserId,
  bool isForGroup = false,
}) async {
  String chatId = isForGroup
      ? conversationUserId
      : getChatId(
          currentUserId: currentUserId, conversationUserId: conversationUserId);

  //String chatId = getChatId(userInfoObj.id, recentChatObj.id);

  await FirebaseFirestore.instance
      .collection("messages")
      .doc(chatId)
      .collection("chats")
      .where("chatDate",
          isEqualTo: DateFormat('dd MMMM yyyy').format(DateTime.now().toUtc()))
      .get()
      .then((value) async {
    if (value.docs.isNotEmpty) {
      List<dynamic> messageList = [];
      await FirebaseFirestore.instance
          .collection("messages")
          .doc(chatId)
          .collection("chats")
          .where("chatDate",
              isEqualTo:
                  DateFormat('dd MMMM yyyy').format(DateTime.now().toUtc()))
          .get()
          .then((querySnapshot) => querySnapshot.docs.forEach((element) async {
                List<dynamic> oldMsgList = element.data()["messageObj"];
                oldMsgList.forEach((element) {
                  messageList.add(element);
                });
                messageList.add({
                  "toSend": conversationUserId,
                  "sendBy": currentUserId,
                  "message": message,
                  "time": DateTime.now().toUtc().millisecondsSinceEpoch,
                  "type": 0,
                  "image_url": "",
                  "deleteBy": [],
                  "recieverPath": "",
                  "senderPath": "",
                  "isDownloaded": false,
                });
                await FirebaseFirestore.instance
                    .collection("messages")
                    .doc(chatId)
                    .collection("chats")
                    .doc(element.id)
                    .update({
                  "messageObj": messageList,
                });
              }));
    } else {
      await FirebaseFirestore.instance
          .collection("messages")
          .doc(chatId)
          .collection("chats")
          .add({
        "time": DateTime.now().toUtc().millisecondsSinceEpoch,
        "chatDate": DateFormat('dd MMMM yyyy').format(DateTime.now().toUtc()),
        "messageObj": [
          {
            "toSend": conversationUserId,
            "sendBy": currentUserId,
            "message": message,
            "time": DateTime.now().toUtc().millisecondsSinceEpoch,
            "type": 0,
            "image_url": "",
            "deleteBy": [],
            "recieverPath": "",
            "senderPath": "",
            "isDownloaded": false,
          }
        ]
      });
    }
  });

  _afterMessageSendActionsForSingleChat(
      currentUserId: currentUserId,
      conversationUserId: conversationUserId,
      type: 0,
      message: message,
      toSend: conversationUserId);
  if (isForGroup) {}
}

//transaction demo method...
Future<void> _afterMessageSendActionsForSingleChat(
    {String currentUserId,
    String conversationUserId,
    int type,
    String toSend,
    String message}) async {
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentSnapshot documentSnapshot = await transaction.get(
        FirebaseFirestore.instance.collection("users").doc(conversationUserId));
    DocumentSnapshot documentForGetCount = await transaction.get(
        FirebaseFirestore.instance
            .collection("users")
            .doc(conversationUserId)
            .collection("recent_chats")
            .doc(currentUserId));
    //Re set recent chat for both users group and single user...
    transaction.update(
        FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserId)
            .collection("recent_chats")
            .doc(conversationUserId),
        {"cardStatus": 1});
    transaction.update(
        FirebaseFirestore.instance
            .collection("users")
            .doc(conversationUserId)
            .collection("recent_chats")
            .doc(currentUserId),
        {"cardStatus": 1});

    //Set last message for other user...
    transaction.update(
        FirebaseFirestore.instance
            .collection("users")
            .doc(conversationUserId)
            .collection("recent_chats")
            .doc(currentUserId),
        {
          "lastMessage": type == 0 ? message : "You recieved photo",
          "lastMsgTime": DateTime.now().toUtc().millisecondsSinceEpoch,
        });
    //Set last message for current user...
    transaction.update(
        FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserId)
            .collection("recent_chats")
            .doc(conversationUserId),
        {
          "lastMessage": type == 0 ? message : "You sent a photo",
          "lastMsgTime": DateTime.now().toUtc().millisecondsSinceEpoch,
        });
    //Send notifications...
    if (toSend == conversationUserId) {
      transaction.set(
          FirebaseFirestore.instance
              .collection("users")
              .doc(conversationUserId)
              .collection("notifications")
              .doc(),
          {
            "content": message,
            "idTo": conversationUserId,
            "idFrom": currentUserId,
          });
    } else {
      transaction.set(
          FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserId)
              .collection("notifications")
              .doc(),
          {
            "content": message,
            "idTo": currentUserId,
            "idFrom": conversationUserId,
          });
    }
    //Set pending message for other user...
    if (documentSnapshot.data()["chattingWith"] != currentUserId) {
      transaction.update(
          FirebaseFirestore.instance
              .collection("users")
              .doc(conversationUserId)
              .collection("recent_chats")
              .doc(currentUserId),
          {
            "pendingMsg": "true",
            "pendingMsgWith": currentUserId,
          });
    }

    //Set pending msg count for other user...
    if (documentSnapshot.data()["chattingWith"] != currentUserId) {
      int count = documentForGetCount.data()["count"];
      count++;
      transaction.update(
          FirebaseFirestore.instance
              .collection("users")
              .doc(conversationUserId)
              .collection("recent_chats")
              .doc(currentUserId),
          {
            "count": count,
          });
    }
  });
}

//Send message as image...
Future<void> sendImageAsMessage({
  String currentUserId,
  String conversationUserId,
  List<File> resultList,
  bool isForGroup = false,
}) async {
  String chatId = isForGroup
      ? conversationUserId
      : getChatId(
          currentUserId: currentUserId, conversationUserId: conversationUserId);

  //List<String> fileList = [];
  for (var imageFile in resultList) {
    await postImageForSend(
      imageFile: imageFile,
    ).then((downloadUrl) async {
      String senderPath = imageFile.path;
      //Send Message as a image...
      await FirebaseFirestore.instance
          .collection("messages")
          .doc(chatId)
          .collection("chats")
          .where("chatDate",
              isEqualTo:
                  DateFormat('dd MMMM yyyy').format(DateTime.now().toUtc()))
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          List<dynamic> messageList = [];
          await FirebaseFirestore.instance
              .collection("messages")
              .doc(chatId)
              .collection("chats")
              .where("chatDate",
                  isEqualTo:
                      DateFormat('dd MMMM yyyy').format(DateTime.now().toUtc()))
              .get()
              .then((querySnapshot) =>
                  querySnapshot.docs.forEach((element) async {
                    List<dynamic> oldMsgList = element.data()["messageObj"];
                    oldMsgList.forEach((element) {
                      messageList.add(element);
                    });

                    messageList.add({
                      "toSend": conversationUserId,
                      "sendBy": currentUserId,
                      "message": "",
                      "time": DateTime.now().toUtc().millisecondsSinceEpoch,
                      "type": 1,
                      "image_url": downloadUrl,
                      "deleteBy": [],
                      "recieverPath": "",
                      "senderPath": senderPath,
                      "isDownloaded": false,
                    });

                    await FirebaseFirestore.instance
                        .collection("messages")
                        .doc(chatId)
                        .collection("chats")
                        .doc(element.id)
                        .update({
                      "messageObj": messageList,
                    });
                  }));
        } else {
          List<Map<String, dynamic>> messageObjList = [];

          messageObjList.add({
            "toSend": conversationUserId,
            "sendBy": currentUserId,
            "message": "",
            "time": DateTime.now().toUtc().millisecondsSinceEpoch,
            "type": 1,
            "image_url": downloadUrl,
            "deleteBy": [],
            "recieverPath": "",
            "senderPath": senderPath,
            "isDownloaded": false,
          });

          await FirebaseFirestore.instance
              .collection("messages")
              .doc(chatId)
              .collection("chats")
              .add({
            "time": DateTime.now().toUtc().millisecondsSinceEpoch,
            "chatDate":
                DateFormat('dd MMMM yyyy').format(DateTime.now().toUtc()),
            "messageObj": messageObjList,
          });
        }
      });
      // Get the download URL...
      //fileList.add(downloadUrl.toString());
    }).catchError((err) {
      print(err);
    });
  }

  _afterMessageSendActionsForSingleChat(
      currentUserId: currentUserId,
      conversationUserId: conversationUserId,
      type: 1,
      message: "",
      toSend: conversationUserId);
  if (isForGroup) {}
}

//Post image to firebase storage for send image...
Future<dynamic> postImageForSend(
    {File imageFile,
    String currentUserId,
    String conversationUserId,
    bool isFroGroup = false}) async {
  String chatId = isFroGroup
      ? conversationUserId
      : getChatId(
          currentUserId: currentUserId, conversationUserId: conversationUserId);
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  // Provider.of<ChatProvider>(context, listen: false).setTime =
  //     int.parse(fileName);
  //................set time here and get time when image send..........................
  firebase_storage.Reference reference =
      firebase_storage.FirebaseStorage.instance.ref().child(
          isFroGroup ? "$conversationUserId/$fileName" : "$chatId/$fileName");
  await reference.putData((imageFile.readAsBytesSync()));
  // firebase_storage.TaskSnapshot taskSnapshot = uploadTask.snapshot;
  return await reference.getDownloadURL();
}

//Chatting with empty...
Future<void> chattingWithEmpty({String currentUserId}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .update({
    "chattingWith": "",
  });
}

//Remove Pending Message...
Future<void> removePendingMessage(
    {String currentUserId, String conversationUserId}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .collection("recent_chats")
      .get()
      .then((value) async {
    if (value.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("recent_chats")
          .doc(conversationUserId)
          .update({
        "pendingMsg": "false",
        "pendingMsgWith": "",
      });
    }
  });
}

//..........................................................................................................................
//..........................................................................................................................
//Set last message and last message time for group chat...
void setLastMessageNLastMessageTimeForGroup(
    {String currentUserId,
    String conversationUserId,
    List<String> memberIdList,
    int type,
    String message}) {
  memberIdList.forEach((element) async {
    if (element != currentUserId) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(element)
          .collection("recent_chats")
          .doc(conversationUserId)
          .update({
        "lastMessage": type == 0 ? message : "You recieved photo",
        "lastMsgTime": DateTime.now().toUtc().millisecondsSinceEpoch,
      });
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(element)
          .collection("recent_chats")
          .doc(conversationUserId)
          .update({
        "lastMessage": type == 0 ? message : "you sent a Photo",
        "lastMsgTime": DateTime.now().toUtc().millisecondsSinceEpoch,
      });
    }
  });
}

//Set count is zero...
Future<void> setCountOfPendingMessage(
    {String currentUserId, String conversationUserId}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .collection("recent_chats")
      .doc(conversationUserId)
      .update({
    "count": 0,
  });
}

//IsTyping set in other user card....
Future<void> isTypingSetToOtherUser(
    {String currentUserId,
    String conversationUserId,
    bool isForGroup = false,
    List<String> memberIdList}) async {
  isForGroup
      ? memberIdList.forEach((element) async {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(element)
              .collection("recent_chats")
              .doc(conversationUserId)
              .update({
            "typingStatus": 1,
            "typingWith": conversationUserId,
          });
        })
      : await FirebaseFirestore.instance
          .collection("users")
          .doc(conversationUserId)
          .collection("recent_chats")
          .doc(currentUserId)
          .update({
          "typingStatus": 1,
          "typingWith": currentUserId,
        });
}

//IsTyping remove in other user card....
Future<void> isTypingRemoveToOtherUser(
    {String currentUserId,
    String conversationUserId,
    bool isForGroup = false,
    List<String> memberIdList}) async {
  isForGroup
      ? memberIdList.forEach((element) async {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(element)
              .collection("recent_chats")
              .doc(conversationUserId)
              .update({
            "typingStatus": 0,
            "typingWith": "",
          });
        })
      : await FirebaseFirestore.instance
          .collection("users")
          .doc(conversationUserId)
          .collection("recent_chats")
          .doc(currentUserId)
          .update({
          "typingStatus": 0,
          "typingWith": "",
        });
}

//set Online status...
Future<void> statusSetOnline({String currentUserId}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .update({
    "status": "online",
  });
}

//set Offline status...
Future<void> statusSetOffline({String currentUserId}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .update({
    "status": "offline",
  });
}

//Get chats...
Future<Stream<QuerySnapshot>> getChats(
    {String currentUserid, String conversationUserId, bool isForGroup}) async {
  String chatId = isForGroup
      ? conversationUserId
      : getChatId(
          currentUserId: currentUserid, conversationUserId: conversationUserId);

  return FirebaseFirestore.instance
      .collection("messages")
      .doc(chatId)
      .collection("chats")
      .orderBy("time", descending: true)
      .snapshots();
}

//Clear messages for me...
Future<void> clearMessagesForOnlyOneUser(
    {String currentUserId,
    String conversationUserId,
    bool isForGroup = false}) async {
  String chatId = isForGroup
      ? conversationUserId
      : getChatId(
          currentUserId: currentUserId, conversationUserId: conversationUserId);
  List<dynamic> updatedList = [];
  await FirebaseFirestore.instance
      .collection("messages")
      .doc(chatId)
      .collection("chats")
      .orderBy("time", descending: true)
      .get()
      .then((doclist) => doclist.docs.forEach((element1) async {
            List<MessageObj> msgObjList = [];
            element1.data()["messageObj"].forEach((msgObj) {
              msgObjList.add(messageObjFromJson(json.encode(msgObj)));
            });
            print(msgObjList);
            msgObjList.forEach((element) {
              List<dynamic> olderDeletedBy = [];
              if (element.deleteBy.isNotEmpty) {
                element.deleteBy.forEach((element) {
                  olderDeletedBy.add(element);
                });
              }
              olderDeletedBy.add(currentUserId);
              updatedList.add(MessageObj(
                      toSend: element.toSend,
                      sendBy: element.sendBy,
                      message: element.message,
                      time: element.time,
                      type: element.type,
                      imageUrl: element.imageUrl,
                      deleteBy: olderDeletedBy,
                      recieverPath: element.recieverPath,
                      senderPath: element.senderPath,
                      isDownloaded: element.isDownloaded)
                  .toJson());
            });
            print(updatedList);
            await FirebaseFirestore.instance
                .collection("messages")
                .doc(chatId)
                .collection("chats")
                .doc(element1.id)
                .update({"messageObj": updatedList});
          }));

  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .collection("recent_chats")
      .doc(conversationUserId)
      .update({
    "lastMessage": "",
    "lastMsgTime": null,
  });
}

//Block unblock user...
Future<void> blockUnblockUser(
    {String currentUserId, String conversationUserId}) async {
  //Set block unblock in firestore for current user...
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .collection("recent_chats")
      .doc(conversationUserId)
      .get()
      .then((value) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("recent_chats")
        .doc(conversationUserId)
        .update({
      "isBlock": !value.data()["isBlock"],
      "blockBy": !value.data()["isBlock"] ? currentUserId : ""
    });
  });
  //Set block unblock in firestore for current user...
  await FirebaseFirestore.instance
      .collection("users")
      .doc(conversationUserId)
      .collection("recent_chats")
      .doc(currentUserId)
      .get()
      .then((value) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(conversationUserId)
        .collection("recent_chats")
        .doc(currentUserId)
        .update({"isBlock": !value.data()["isBlock"], "blockBy": ""});
  });
  //Set blocklist of current user...
  List<dynamic> blockList = [];
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .get()
      .then((value) {
    UserInfoObj userInfoObj = userInfoObjFromJson(json.encode(value.data()));
    if (userInfoObj.blockList.isNotEmpty) {
      List<dynamic> getBlockList = [];
      userInfoObj.blockList.forEach((element) {
        getBlockList.add(element);
        blockList = getBlockList;
      });
    }
  });

  int index = blockList.indexWhere((element) => element == conversationUserId);
  index < 0 ? blockList.add(conversationUserId) : blockList.removeAt(index);

  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .update({
    "blockList": blockList,
  });

//Set blocklist of other user...
  List<dynamic> blockListOfOtherUser = [];
  await FirebaseFirestore.instance
      .collection("users")
      .doc(conversationUserId)
      .get()
      .then((value) {
    UserInfoObj userInfoObj = userInfoObjFromJson(json.encode(value.data()));
    if (userInfoObj.blockList.isNotEmpty) {
      List<dynamic> getBlockList = [];
      userInfoObj.blockList.forEach((element) {
        getBlockList.add(element);
        blockListOfOtherUser = getBlockList;
      });
    }
  });

  int index1 =
      blockListOfOtherUser.indexWhere((element) => element == currentUserId);
  index1 < 0
      ? blockListOfOtherUser.add(currentUserId)
      : blockListOfOtherUser.removeAt(index1);

  await FirebaseFirestore.instance
      .collection("users")
      .doc(conversationUserId)
      .update({
    "blockList": blockListOfOtherUser,
  });
}

//Create chat Id for group...
getGroupChatId(List<String> groupmemberIdList) {
  //if (currentUser.isNotEmpty) userList.add(currentUser);
  groupmemberIdList.sort((a, b) => a.compareTo(b));
  return groupmemberIdList.reduce((value, element) => value + element) + "G";
}

Future<void> deleteConversationCard(
    {String currentUserId, String conversationUserId}) async {
  clearMessagesForOnlyOneUser();
  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .collection("recent_chats")
      .doc(conversationUserId)
      .update({"cardStatus": 0});
}

//Set pending message in group chat...
void setPendingMessageForGroup(
    {String currentUserId,
    String conversationUserId,
    List<String> memberIdList}) {
  //String groupChatId = getGroupChatId(recentChatObj.memberList);

  memberIdList.forEach((element) async {
    if (element != currentUserId) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(element)
          .get()
          .then((value) async {
        if (value.data()["chattingWith"] != currentUserId) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(element)
              .collection("recent_chats")
              .doc(conversationUserId)
              .update({
            "pendingMsg": "true",
            "pendingMsgWith": conversationUserId,
          });
        }
      });
    }
  });
}

//create group...
Future<void> createGroup(
    {String currentuserId,
    List<dynamic> groupMemberIdList,
    String groupName,
    String groupProfileUrl}) async {
  //Create group chat id...
  String groupChatId = getGroupChatId(groupMemberIdList);
  String id;
  await FirebaseFirestore.instance.collection("groups").add(RecentChatObj(
        name: groupName,
        email: "",
        id: groupChatId,
        profileUrl: [groupProfileUrl],
        pendingMsg: "",
        pendingMsgWith: "",
        lastMessage: "start Chatting",
        lastMsgTime: null,
        type: "group",
        memberList: groupMemberIdList,
        cardStatus: 1,
        typingStatus: 0,
        typingWith: "",
        isBlock: false,
        blockBy: "",
        blockList: [],
        adminList: [currentuserId],
        count: 0,
      ).toJson());
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("groups")
      .where("id", isEqualTo: groupChatId)
      .get();
  querySnapshot.docs.forEach((element) async {
    id = element.id;
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(element.id)
        .update({"id": element.id});
  });

  groupMemberIdList.forEach((element) async {
    //Add group card in all members of group...
    await FirebaseFirestore.instance
        .collection("users")
        .doc(element)
        .collection("recent_chats")
        .doc(id)
        .set(RecentChatObj(
          name: groupName,
          email: "",
          id: id,
          profileUrl: [groupProfileUrl],
          pendingMsg: "",
          pendingMsgWith: "",
          lastMessage: "start Chatting",
          lastMsgTime: null,
          type: "group",
          memberList: groupMemberIdList,
          cardStatus: 1,
          typingStatus: 0,
          typingWith: "",
          isBlock: false,
          blockBy: "",
          blockList: [],
          adminList: [currentuserId],
          count: 0,
        ).toJson());
  });
}

//Clear messages for everyone...
Future<void> clearMessagesForEveryOne(
    {bool isForGroup = false,
    String currentUserId,
    String conversationUserId}) async {
  String chatId = isForGroup
      ? conversationUserId
      : getChatId(
          currentUserId: currentUserId, conversationUserId: conversationUserId);

  await FirebaseFirestore.instance
      .collection("messages")
      .doc(chatId)
      .collection("chats")
      .get()
      .then((documentsList) => documentsList.docs.forEach((element) async {
            await FirebaseFirestore.instance
                .collection("messages")
                .doc(chatId)
                .collection("chats")
                .doc(element.id)
                .delete();
          }));

  await FirebaseFirestore.instance
      .collection("users")
      .doc(conversationUserId)
      .collection("recent_chats")
      .doc(currentUserId)
      .update({
    "lastMessage": "",
    "lastMsgTime": null,
  });

  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .collection("recent_chats")
      .doc(conversationUserId)
      .update({
    "lastMessage": "",
    "lastMsgTime": null,
  });
}

//exit group...
Future<void> exitGroup(
    {String currentUserId,
    String conversationUserId,
    List<String> groupMemberIdList}) async {
  //create new member list without current user who wants to exit group...
  List<dynamic> newuserList = [];
  groupMemberIdList.forEach((element) {
    if (element != currentUserId) {
      newuserList.add(element);
    }
  });

  groupMemberIdList.forEach((element) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(element)
        .collection("recent_chats")
        .doc(conversationUserId)
        .update({
      "memberList": newuserList,
    });
  });
  await FirebaseFirestore.instance
      .collection("groups")
      .doc(conversationUserId)
      .update({
    "memberList": newuserList,
  });
}

//add member in group...
Future<void> addMemberInGroup(
    {String conversationUserId,
    String currentUserId,
    String groupName,
    String groupProfileUrl,
    List<String> currentgroupMemberIdList,
    List<String> newMemberIdList}) async {
  List<dynamic> userList = [];
  newMemberIdList.forEach((element) {
    userList.add(element);
  });
  currentgroupMemberIdList.forEach((element) {
    userList.add(element);
  });
  currentgroupMemberIdList.forEach((element) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(element)
        .collection("recent_chats")
        .doc(conversationUserId)
        .update({
      "memberList": userList,
    });
  });
  await FirebaseFirestore.instance
      .collection("groups")
      .doc(conversationUserId)
      .update({
    "memberList": userList,
  });

  newMemberIdList.forEach((element) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(element)
        .collection("recent_chats")
        .doc(conversationUserId)
        .set(RecentChatObj(
                name: groupName,
                email: "",
                id: conversationUserId,
                profileUrl: [groupProfileUrl],
                pendingMsg: "",
                pendingMsgWith: "",
                lastMessage: "start Chatting",
                lastMsgTime: null,
                type: "group",
                memberList: userList,
                cardStatus: 1,
                typingStatus: 0,
                typingWith: "",
                isBlock: false,
                blockList: [],
                adminList: [currentUserId],
                count: 0)
            .toJson());
  });
}

Future<void> sendNotificationForGroup(
    {String currentUserId,
    String conversationUserId,
    String groupName,
    String groupProfileurl,
    List<String> groupMemberIdList,
    String message}) async {
  List<dynamic> fcmIdList = [];
  for (int i = 0; i < groupMemberIdList.length; i++) {
    String memberUserId = groupMemberIdList[i];
    if (memberUserId != currentUserId) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(memberUserId)
          .get();
      print(documentSnapshot.data());
      fcmIdList.addAll(documentSnapshot.data()["fcm_id"]);
    }
  }
  print(fcmIdList);
  if (fcmIdList.isNotEmpty) {
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(conversationUserId)
        .collection("notifications")
        .doc()
        .set({
      "content": message,
      "idTo": "",
      "idFrom": groupName,
      "fcmIdList": fcmIdList,
      "data": {
        "clickAction": "FLUTTER_NOTIFICATION_CLICK",
        "name": groupName,
        "id": conversationUserId,
        "profileUrl": groupProfileurl,
      }
    });
  }
}

Future<String> downloadFile({String sendBy, String toSend, int time}) async {
  String chatId = getChatId(currentUserId: sendBy, conversationUserId: toSend);
  print(chatId);
  print(time);
  firebase_storage.Reference reference =
      firebase_storage.FirebaseStorage.instance.ref().child("$chatId/$time");
  Directory documentDirectory = await getApplicationDocumentsDirectory();
  String filePathAndName =
      documentDirectory.path + '/images/${reference.name}.jpg';
  print(filePathAndName);
  await reference.writeToFile(File(filePathAndName));
  print("------------downloaded--------------");
  return filePathAndName;
}

Future<void> isDownloaded(
    {int time,
    String toSend,
    String sendBy,
    String type,
    String path,
    bool isForGroup}) async {
  String chatId = isForGroup
      ? toSend
      : getChatId(currentUserId: sendBy, conversationUserId: toSend);
  List<dynamic> updatedList = [];
  await FirebaseFirestore.instance
      .collection("messages")
      .doc(chatId)
      .collection("chats")
      .orderBy("time", descending: true)
      .get()
      .then((doclist) => doclist.docs.forEach((element1) async {
            List<MessageObj> msgObjList = [];
            element1.data()["messageObjList"].forEach((msgObj) {
              msgObjList.add(messageObjFromJson(json.encode(msgObj)));
            });
            print(msgObjList);
            msgObjList.forEach((element) {
              if (element.time == time) {
                updatedList.add(MessageObj(
                        toSend: element.toSend,
                        sendBy: element.sendBy,
                        message: element.message,
                        time: element.time,
                        type: element.type,
                        imageUrl: element.imageUrl,
                        deleteBy: element.deleteBy,
                        isDownloaded: true,
                        recieverPath: path,
                        senderPath: element.senderPath)
                    .toJson());
              } else {
                updatedList.add(MessageObj(
                        toSend: element.toSend,
                        sendBy: element.sendBy,
                        message: element.message,
                        time: element.time,
                        type: element.type,
                        imageUrl: element.imageUrl,
                        deleteBy: element.deleteBy,
                        isDownloaded: element.isDownloaded,
                        recieverPath: "",
                        senderPath: element.senderPath)
                    .toJson());
              }
            });
            print(updatedList);
            await FirebaseFirestore.instance
                .collection("messages")
                .doc(chatId)
                .collection("chats")
                .doc(element1.id)
                .update({"messageObjList": updatedList});
          }));
}

//Get recentChat...
Stream<QuerySnapshot> getRecentChat({String currentUserId}) {
  return FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserId)
      .collection("recent_chats")
      .orderBy("lastMsgTime", descending: true)
      .where("cardStatus", isEqualTo: 1)
      .snapshots();
}
