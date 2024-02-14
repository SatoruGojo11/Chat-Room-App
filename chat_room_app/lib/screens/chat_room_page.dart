import 'dart:async';
import 'dart:developer';

import 'package:chat_room_app/models/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.userUid,
    required this.roomId,
    required this.roomName,
  });

  final String userUid, roomId, roomName;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late String userId, collectionName, roomId;

  TextEditingController chatController = TextEditingController();
  List<String> chatlist = [];
  StreamSocket streamSocket = StreamSocket();

  Map roomData = {};
  List<String> roomChats = [];

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
      log(roomData.toString(), name: '${widget.roomName} Data');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: text(widget.roomName),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: streamSocket.getResponse,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.connectionState ==
                            ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.active) {
                      return ListView.builder(
                        itemCount: chatlist.length,
                        itemBuilder: (context, index) {
                          return text(snapshot.data!.toString(), fontsize: 20);
                        },
                      );
                    } else {
                      return Text(snapshot.connectionState.toString());
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: chatController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'Type Message',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        chatlist.add(chatController.text);
                        streamSocket.addResponse(chatlist);
                        chatController.clear();
                      },
                      icon: const Icon(
                        Icons.send,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StreamSocket {
  final _stream = StreamController<List<String>>.broadcast();

  void Function(List<String>) get addResponse => _stream.sink.add;

  Stream<List<String>> get getResponse => _stream.stream.asBroadcastStream();
}
