import 'dart:async';
import 'dart:developer';

import 'package:chat_room_app/models/text.dart';
import 'package:chat_room_app/models/textformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.userUid,
    required this.roomId,
    required this.roomName,
    required this.adminUid,
  });

  final String userUid, roomId, roomName, adminUid;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late String userId, collectionName, roomId;

  CollectionReference collectionReferenceChat =
      FirebaseFirestore.instance.collection('Chat');

  TextEditingController chatController = TextEditingController();

  Map roomData = {};
  Map chatData = {};
  bool isUserMessage = true;

  @override
  void initState() {
    super.initState();

    log('Init method in Chat Room Page');
    userId = widget.userUid.toString();
    roomId = widget.roomId.toString();

    fetchData();
    log(userId, name: 'UserID');
    log(roomId, name: 'RoomID');
  }

  Future<void> fetchData() async {
    await FirebaseFirestore.instance
        .collection('Room')
        .doc(roomId)
        .get()
        .then((value) {
      roomData = value.data()!;
      log(roomData.toString(), name: '${roomData['RoomName']} Data');
      setState(() {});
    });
  }

  Align myMessage(txt, time) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: text(
                      txt ?? 'chat',
                      fontsize: 20,
                      clr: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: text(
                      time ?? 'time',
                      fontsize: 10,
                      clr: Colors.black,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Align othersMessage(txt, time) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Align(
                alignment: Alignment.center,
                child: text(
                  txt ?? 'chat',
                  fontsize: 20,
                  clr: Colors.black,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: text(
                  time ?? 'time',
                  fontsize: 10,
                  clr: Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: text(
          roomData['RoomName'].toString(),
          fontsize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: StreamBuilder(
                  stream:
                      collectionReferenceChat.orderBy('TimeStamp').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return text('Error Occurred');
                    } else if (snapshot.hasData) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.connectionState ==
                              ConnectionState.done ||
                          snapshot.connectionState == ConnectionState.active) {
                        return ListView.builder(
                          dragStartBehavior: DragStartBehavior.down,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: text(
                                  'No Messages..',
                                  fontsize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else if (snapshot.data!.docs.isNotEmpty) {
                              final message = snapshot.data!.docs
                                  .map((e) => e['ChatMessage'])
                                  .toList()[index]
                                  .toString();
                              final time = snapshot.data!.docs
                                  .map((e) => e['TimeStamp'])
                                  .toList()[index]
                                  .toString();
                              return isUserMessage
                                  ? myMessage(message.toString(), time)
                                  : othersMessage(message.toString(), time);
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
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
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: textformfield(
                  chatController,
                  labeltxt: 'Type Message',
                  inputFormate: [FilteringTextInputFormatter.deny(RegExp(' '))],
                  suffixicn: IconButton(
                    onPressed: () {
                      if (userId == userId) {
                        setState(() {
                          isUserMessage = true;
                        });
                      } else {
                        setState(() {
                          isUserMessage = false;
                        });
                      }
                      Map<String, dynamic> chat = {
                        'UserUid': userId.toString(),
                        'ChatMessage': chatController.text.toString(),
                        'TimeStamp': TimeOfDay.now().format(context).toString(),
                      };
                      final documentReference = collectionReferenceChat.doc();
                      documentReference.set(chat);
                      chatController.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
