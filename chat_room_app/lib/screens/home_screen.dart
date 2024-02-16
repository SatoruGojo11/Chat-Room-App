import 'dart:developer';
import 'package:chat_room_app/models/create_room.dart';
import 'package:chat_room_app/models/join_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_room_app/models/text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userUid});

  final String? userUid;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final roomCollectionReference = FirebaseFirestore.instance.collection('Room');
  final userCollectionReference = FirebaseFirestore.instance.collection('User');

  late String roomId;
  late String currentUserId;
  late String userName;
  List<Map<String, dynamic>> roomData = [];

  @override
  void initState() {
    super.initState();

    log('Init method in Home Page');
    currentUserId = widget.userUid.toString();
    log(currentUserId.toString());
    currentUserId = getSharedPrefData().toString();
    getSharedPrefData();
  }

  getSharedPrefData() async {
    final getDataInLocal = await SharedPreferences.getInstance();

    // userUid = getDataInLocal.getString('UserId');
    userName = getDataInLocal.getString('UserName')!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: text(
          'Home Page',
          fontsize: 25,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return createRoomDialog(
                    ctx: context,
                    title: 'Create Room',
                    currentUserId: currentUserId.toString(),
                  );
                },
              );
            },
            tooltip: 'Create Room',
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.orange, width: 1),
                        borderRadius: BorderRadius.circular(20)),
                    title: text(
                      'Admin :- $currentUserId',
                      fontWeight: FontWeight.bold,
                      fontsize: 20,
                    ),
                    onTap: () {},
                    tileColor: Colors.orange,
                    splashColor: Colors.amber,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black, height: 10),
                Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: text(
                        'Rooms',
                        fontWeight: FontWeight.bold,
                        fontsize: 30,
                      ),
                    ),
                    SizedBox(
                      height: 600,
                      child: Scaffold(
                          body: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: StreamBuilder(
                          stream: roomCollectionReference.snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Object?>> snapShot1) {
                            if (snapShot1.hasError) {
                              Fluttertoast.showToast(
                                  msg: 'Something went wrong');
                            } else if (snapShot1.hasData ||
                                snapShot1.data != null) {
                              if (snapShot1.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.red,
                                  ),
                                );
                              } else if (snapShot1.connectionState ==
                                      ConnectionState.done ||
                                  snapShot1.connectionState ==
                                      ConnectionState.active) {
                                return ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 20),
                                  itemCount: snapShot1.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    if (snapShot1.data!.docs.isEmpty) {
                                      Center(
                                        child: text(
                                          'No Rooms..',
                                          fontsize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    } else if (snapShot1
                                        .data!.docs.isNotEmpty) {
                                      return ListTile(
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        onTap: () {
                                          final roomId = snapShot1.data!.docs
                                              .map((e) => e['RoomId'])
                                              .toList()[index]
                                              .toString();
                                          final roomName = snapShot1.data!.docs
                                              .map((e) => e['RoomName'])
                                              .toList()[index]
                                              .toString();
                                          final roomPassword = snapShot1
                                              .data!.docs
                                              .map((e) => e['RoomPassword'])
                                              .toList()[index]
                                              .toString();
                                          log(roomId.toString(),
                                              name: 'Room Id');
                                          log(roomName.toString(),
                                              name: 'Room Name');
                                          log(roomPassword.toString(),
                                              name: 'Room Password');
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return joinRoom(
                                                  ctx: context,
                                                  title: 'Join Room',
                                                  currentUserId:
                                                      currentUserId.toString(),
                                                  roomId: roomId,
                                                  roomName: roomName,
                                                  roomPassword: roomPassword);
                                            },
                                          );
                                        },
                                        title: text(
                                          'Room Name :- ${snapShot1.data!.docs.map((e) => e['RoomName']).toList()[index]}',
                                          clr: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontsize: 15,
                                        ),
                                        subtitle: text(
                                          'Created by :- ${snapShot1.data!.docs.map((e) => e['Admin']).toList()[index]}',
                                          clr: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontsize: 15,
                                        ),
                                        leading: text('${index + 1}'),
                                        trailing: IconButton(
                                          onPressed: () {},
                                          tooltip: 'Join Room',
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                          ),
                                        ),
                                        tileColor: Colors.green,
                                      );
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );
                              } else {
                                return Text(
                                    snapShot1.connectionState.toString());
                              }
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
