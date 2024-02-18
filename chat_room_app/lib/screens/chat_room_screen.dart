import 'dart:developer';

import 'package:chat_room_app/models/text.dart';
import 'package:chat_room_app/models/textformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.userUid,
    required this.roomId,
    required this.roomName,
    required this.adminUid,
    required this.currentUserName,
  });

  final String userUid, roomId, roomName, adminUid, currentUserName;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late String userId, roomName, roomId, adminUid, currentUserName;

  CollectionReference collectionReferenceChat =
      FirebaseFirestore.instance.collection('Chat');
  late String chatDocId;
  String? userName;
  bool longMessage = false;
  bool shortMessage = false;

  TextEditingController chatController = TextEditingController();

  // Map chatData = {};

  bool isUserMessage = true;
  String? roomIdOfChat;

  @override
  void initState() {
    super.initState();

    userId = widget.userUid.toString();
    userName = widget.currentUserName.toString();
    log(userName.toString(), name: 'UserName');
    roomId = widget.roomId.toString();
    adminUid = widget.adminUid.toString();
    roomName = widget.roomName.toString();
  }

  longMessages(
    txt,
    time,
    rowMainAlignment,
    messageUserName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: rowMainAlignment,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 1.4,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                text(
                  messageUserName.toString(),
                  fontsize: 20,
                  fontWeight: FontWeight.bold,
                  clr: Colors.white,
                ),
                const SizedBox(height: 5),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: text(
                        txt,
                        fontsize: 20,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    text(
                      time,
                      fontsize: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  messages(
    txt,
    time,
    rowMainAlignment,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: rowMainAlignment,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  child: text(
                    txt,
                    fontsize: 20,
                  ),
                ),
                const SizedBox(width: 10),
                text(
                  time,
                  fontsize: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    // var widget = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: text(
          roomName,
          fontsize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: GestureDetector(
        onTap: () => Focus.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: collectionReferenceChat
                        .where('RoomId', isEqualTo: roomId)
                        .orderBy('CurrentTime')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        log(snapshot.error.toString());
                        Fluttertoast.showToast(
                          msg: 'Error Occurred',
                          backgroundColor: Colors.red,
                        );
                        return text('Error Occurred');
                      } else if (snapshot.hasData || snapshot.data != null) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.connectionState ==
                                ConnectionState.done ||
                            snapshot.connectionState ==
                                ConnectionState.active) {
                          if (snapshot.data!.docs.isNotEmpty) {
                            // ScrollController _scrollController =
                            //     ScrollController();

                            // _scrollController.addListener(() {});
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final message = snapshot
                                    .data!.docs[index]['ChatMessage']
                                    .toString();
                                final time = snapshot
                                    .data!.docs[index]['TimeStamp']
                                    .toString();
                                final messageUserId = snapshot
                                    .data!.docs[index]['UserUid']
                                    .toString();
                                final messageUserName = snapshot
                                    .data!.docs[index]['UserName']
                                    .toString();
                                log(messageUserName.toString());

                                if (messageUserId == userId) {
                                  isUserMessage = true;
                                } else if (messageUserId != userId) {
                                  isUserMessage = false;
                                }
                                // if ((message.length + time.length) >
                                //     (widget / 2)) {
                                //   longMessage = true;
                                //   shortMessage = false;
                                // } else if ((message.length + time.length) <=
                                //     (widget / 2)) {
                                //   shortMessage = true;
                                //   longMessage = false;
                                // }

                                return isUserMessage
                                    ? longMessages(
                                        message.toString(),
                                        time,
                                        MainAxisAlignment.end,
                                        messageUserName.toString(),
                                      )
                                    : longMessages(
                                        message.toString(),
                                        time,
                                        MainAxisAlignment.start,
                                        messageUserName.toString(),
                                      );

                                /// for Final Code
                                // ? longMessage
                                //     ? longMessages(
                                //         message.toString(),
                                //         time,
                                //         MainAxisAlignment.end,
                                //       )
                                //     : messages(
                                //         message.toString(),
                                //         time,
                                //         MainAxisAlignment.end,
                                //       )
                                // : longMessage
                                //     ? longMessages(
                                //         message.toString(),
                                //         time,
                                //         MainAxisAlignment.start,
                                //       )
                                //     : messages(
                                //         message.toString(),
                                //         time,
                                //         MainAxisAlignment.start,
                                //       );
                              },
                            );
                          } else if (roomIdOfChat != roomId) {
                            return Center(
                              child: text(
                                'No Messages..',
                                fontsize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return Center(
                              child: text(
                                'No Messages..',
                                fontsize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        } else {
                          return Center(
                            child: text(snapshot.connectionState.toString()),
                          );
                        }
                      } else {
                        return Center(
                          child: text('No Messages...'),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: textformfield(
                      chatController,
                      labeltxt: 'Type Message',
                      maxLines: 2,
                      suffixicn: IconButton(
                        onPressed: () {
                          if (chatController.text.isNotEmpty) {
                            final documentReferenceChat =
                                collectionReferenceChat.doc();

                            chatDocId = documentReferenceChat.id.toString();

                            log(userName.toString(), name: 'UserName');

                            Map<String, dynamic> chat = {
                              'UserUid': userId.toString(),
                              'UserName': userName,
                              'ChatMessage': chatController.text.toString(),
                              'TimeStamp':
                                  TimeOfDay.now().format(context).toString(),
                              'CurrentTime': DateTime.now(),
                              'RoomId': roomId.toString(),
                              'ChatId': chatDocId,
                            };
                            documentReferenceChat.set(chat);
                            chatController.clear();
                          }
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
