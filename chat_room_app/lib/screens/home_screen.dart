import 'dart:developer';
import 'package:chat_room_app/models/textformfield.dart';
import 'package:chat_room_app/screens/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_room_app/models/text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userUid});

  final String? userUid;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final roomCollectionReference = FirebaseFirestore.instance.collection('Room');
  final userCollectionReference = FirebaseFirestore.instance.collection('User');

  final _validationkey = GlobalKey<FormState>();
  TextEditingController joinRoomNameController = TextEditingController();
  TextEditingController joinRoomPasswordController = TextEditingController();
  TextEditingController createRoomNameController = TextEditingController();
  TextEditingController createRoomPasswordController = TextEditingController();

  Map userData = {};
  late String roomId;
  late String currentUserId;
  List<Map<String, dynamic>> roomData = [];

  @override
  void initState() {
    super.initState();

    log('Init method in Home Page');
    currentUserId = widget.userUid.toString();
    log(currentUserId.toString());

    fetchData();
    log(userData.toString());
  }

  Future<void> fetchData() async {
    log('Fetch Data Method');
    var documentReference = userCollectionReference.doc(currentUserId);

    await documentReference.get().then((value) {
      userData.addAll(value.data() as Map);
    });
    setState(() {}); // For updating User name
  }

  // Create Room
  createRoom() async {
    if (_validationkey.currentState!.validate()) {
      DocumentReference documentReference = roomCollectionReference.doc();

      roomId = documentReference.id.toString();
      log(roomId, name: 'Room ID');

      Map<String, dynamic> roomData = {
        'RoomName': createRoomNameController.text.toString(),
        'RoomPassword': createRoomPasswordController.text.toString(),
        'RoomId': roomId,
        'RoomMessages': '',
      };

      await documentReference
          .set(roomData)
          .whenComplete(() => log('Room Created'))
          .onError((error, stackTrace) => log(error.toString()));

      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ChatRoomPage(
              userUid: currentUserId,
              roomId: roomId,
              roomName: createRoomNameController.text.toString(),
            );
          },
        ));
        log('show toast', name: 'Toast');

        Navigator.pop(context);
        Fluttertoast.showToast(
            fontSize: 15,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            msg: 'Room Created Successfully...');
      }
    } else {
      Fluttertoast.showToast(
          fontSize: 15,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          msg: 'Please, fulfill the above conditions...');
    }
  }

  // Join Room
  joinRoom() {
    if (_validationkey.currentState!.validate()) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              userUid: currentUserId,
              roomId: roomId,
              roomName: joinRoomNameController.text.toString(),
            ),
          ));
      Fluttertoast.showToast(
          fontSize: 15,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          msg: 'Joined..');
      joinRoomNameController.clear();
      joinRoomPasswordController.clear();
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
          fontSize: 15,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          msg: 'Please, fulfill the above conditions...');
    }
  }

  // Stream

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
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.orange, width: 1),
                      borderRadius: BorderRadius.circular(20)),
                  title: text(
                    '${userData['UserName']}',
                    fontWeight: FontWeight.bold,
                    fontsize: 20,
                  ),
                  tileColor: Colors.orange,
                  trailing: IconButton(
                    onPressed: () {
                      roomDialog(
                        ctx: context,
                        title: 'Create Room',
                        key: _validationkey,
                        roomNameController: createRoomNameController,
                        roomPwdController: createRoomPasswordController,
                        onPressed: createRoom,
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                    ),
                    tooltip: 'Create Room',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.black, height: 10),
            Flexible(
              flex: 8,
              child: Column(
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
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.done ||
                                snapshot.connectionState ==
                                    ConnectionState.active) {
                              snapshot.data!.docs.map((e) {
                                log(e.id, name: 'Room Doc ID');
                              });

                              return ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemCount: roomData.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Colors.red,
                                          width: 1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    tileColor: Colors.amber,
                                    title:
                                        text(roomData[index - 1]['RoomName']),
                                    leading: text('${index + 1}'),
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Room Dialog
roomDialog({
  required BuildContext ctx,
  required String? title,
  required Key? key,
  required roomNameController,
  required roomPwdController,
  required Function()? onPressed,
}) {
  return showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (ctx) => Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: AlertDialog(
          contentPadding: const EdgeInsets.all(20),
          title: text(
            '$title',
            fontWeight: FontWeight.bold,
            fontsize: 20,
          ),
          content: Column(
            children: [
              Form(
                key: key,
                child: Column(
                  children: [
                    textformfield(
                      roomNameController,
                      labeltxt: 'Room-Name',
                      hinttxt: 'Enter Your Room-Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter your Room_Name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    textformfield(
                      roomPwdController,
                      labeltxt: 'Room Password',
                      hinttxt: 'Enter Your Password',
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter your password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                onPressed;
                Navigator.pop(ctx);
              },
              child: text(
                'Submit',
                fontsize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: text(
                'Cancel',
                fontsize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



/*

Column(
                      children: [
                        text(
                          'Rooms',
                          fontWeight: FontWeight.bold,
                          fontsize: 30,
                        ),
                        ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: text(
                                'asd',
                                fontWeight: FontWeight.bold,
                                fontsize: 20,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.forward_outlined),
                                onPressed: () {},
                                tooltip: 'Join Room',
                              ),
                              onTap: () {
                                roomDialog(
                                  ctx: context,
                                  title: 'Join Room',
                                  key: _validationkey,
                                  roomNameController: joinRoomNameController,
                                  roomPwdController: joinRoomPasswordController,
                                  onPressed: joinRoom,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ///////////////////////////////

SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      roomDialog(
                        context: context,
                        key: _validationkey,
                        roomNameController: roomNameController,
                        roomPwdController: roomPasswordController,
                        onPressed: createRoom,
                      );
                    },
                    child: text(
                      'Create Room',
                      fontWeight: FontWeight.bold,
                      fontsize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      roomDialog(
                        context: context,
                        key: _validationkey,
                        roomNameController: roomNameController,
                        roomPwdController: roomPasswordController,
                        onPressed: joinRoom,
                      );
                    },
                    child: text(
                      'Join Room',
                      fontWeight: FontWeight.bold,
                      fontsize: 20,
                    ),
                  ),
                ),
*/

/* 

ModelBottomSheet

showModelBottomSheet(int index) {
    return showModalBottomSheet(
      backgroundColor: Colors.white38,
      context: context,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                height: MediaQuery.of(context).size.height / 1.2,
                decoration: BoxDecoration(
                  color: Colors.amber[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        text(
                          'Edit Data',
                          fontsize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _validationkey,
                          child: Column(
                            children: [
                              textformfield(
                                usernameController,
                                labeltxt: 'Username',
                                hinttxt: 'Enter your name',
                                inputFormate: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z1-90]'))
                                ],
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Enter your name";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              textformfield(
                                emailController,
                                labeltxt: 'Email-id',
                                hinttxt: 'Enter your email-id',
                                keyboardtype: TextInputType.emailAddress,
                                inputFormate: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z1-90@.]'))
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Enter your Email-id";
                                  } else if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return "Please Enter valid Email-id";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              textformfield(
                                pwdController,
                                labeltxt: 'Password',
                                hinttxt: 'Enter your Password',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Enter your Password";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[500],
                              elevation: 10,
                              shadowColor: Colors.green,
                              fixedSize: const Size(100, 50)),
                          onPressed: () {
                            if (_validationkey.currentState!.validate()) {
                              log('Update Data');
                              CloudDatabase.updateItem(
                                  username: usernameController.text.toString(),
                                  useremail: emailController.text.toLowerCase(),
                                  userPassword: pwdController.text.toString(),
                                  userUid: docIds[index]);
                              setState(() {});
                              Navigator.pop(context);
                            } else {
                              Fluttertoast.showToast(
                                  fontSize: 15,
                                  toastLength: Toast.LENGTH_LONG,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  gravity: ToastGravity.BOTTOM,
                                  msg:
                                      'Please,Fill up the above conditions...');
                            }
                          },
                          child: text(
                            'Submit',
                            clr: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontsize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }




*/ 