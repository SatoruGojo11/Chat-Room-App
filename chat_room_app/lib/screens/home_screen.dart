import 'dart:developer';

import 'package:chat_room_app/models/create_room.dart';
import 'package:chat_room_app/models/join_room.dart';
import 'package:chat_room_app/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_room_app/models/text.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Map userData = {};
  late String roomId;
  late String currentUserId;
  late String userName;
  String? userNameSP;
  List<Map<String, dynamic>> roomData = [];

  @override
  void initState() {
    super.initState();

    currentUserId = widget.userUid.toString();

    // fetchData();

    getSharedPrefData();
    setState(() {});
  }

  Future getSharedPrefData() async {
    await Future.delayed(const Duration(seconds: 1));
    final getDataInLocal = await SharedPreferences.getInstance();

    userNameSP = getDataInLocal.getString('UserName').toString();
    log(userNameSP.toString());
    setState(() {});
  }

  // Future<void> fetchData() async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   var documentReference = userCollectionReference.doc(currentUserId);

  //   await documentReference.get().then((value) {
  //     userData.addAll(value.data() as Map);
  //   });
  //   setState(() {}); // For updating User name
  // }

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
                    currentUserName: userNameSP.toString(),
                  );
                },
              );
            },
            tooltip: 'Create Room',
            icon: const Icon(
              Icons.add,
              color: Colors.black,
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
                      'Admin :- $userNameSP ',
                      fontWeight: FontWeight.bold,
                      fontsize: 20,
                    ),
                    onTap: () {},
                    trailing: IconButton(
                      tooltip: 'Sign Out',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            alignment: Alignment.center,
                            elevation: 10.0,
                            title: Center(
                              child: text(
                                'Log Out',
                                clr: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontsize: 30,
                              ),
                            ),
                            content: Center(
                              heightFactor: 1,
                              child: text(
                                'Are you sure??',
                                clr: Colors.black,
                                fontsize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                      (route) => false);
                                },
                                child: text(
                                  'Yes',
                                  fontsize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: text(
                                  'No',
                                  fontsize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                    ),
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
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return joinRoom(
                                                  ctx: context,
                                                  title: 'Join Room',
                                                  currentUserId:
                                                      currentUserId.toString(),
                                                  currentUserName:
                                                      userNameSP.toString(),
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
                                          splashColor: Colors.transparent,
                                          onPressed: () {},
                                          tooltip: 'Join Room',
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                          ),
                                        ),
                                        tileColor: Colors.green,
                                      );
                                    }
                                    // return const Center(
                                    //   child: CircularProgressIndicator(),
                                    // );
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
