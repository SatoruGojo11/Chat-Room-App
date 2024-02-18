import 'dart:developer';

import 'package:chat_room_app/models/text.dart';
import 'package:chat_room_app/models/textformfield.dart';
import 'package:chat_room_app/screens/chat_room_screen.dart';
import 'package:chat_room_app/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

final _validationkey = GlobalKey<FormState>();
TextEditingController joinRoomNameController = TextEditingController();
TextEditingController joinRoomPasswordController = TextEditingController();

CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('Room');

// Join Room
joinRoom({
  required BuildContext ctx,
  required String? title,
  required String currentUserId,
  required String? currentUserName,
  required String? roomPassword,
  required String? roomId,
  required String? roomName,  
}) {
  bool obscurity = false;
  Map roomData = {};
  return Align(
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
              key: _validationkey,
              child: Column(
                children: [
                  // textformfield(
                  //   joinRoomNameController,
                  //   labeltxt: 'Room-Name',
                  //   hinttxt: 'Enter Your Room-Name',
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return "Please Enter your Room_Name";
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // const SizedBox(height: 15),
                  StatefulBuilder(
                    builder: (context, setState) => textformfield(
                      joinRoomPasswordController,
                      labeltxt: 'Room Password',
                      hinttxt: 'Enter Your Password',
                      obscurity: obscurity,
                      suffixicn: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurity = !obscurity;
                          });
                        },
                        icon: Icon(
                          obscurity ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                      inputFormate: [
                        FilteringTextInputFormatter.deny(
                          RegExp(' '),
                        ),
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter your password";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_validationkey.currentState!.validate()) {
                if (roomPassword ==
                    joinRoomPasswordController.text.toString()) {
                  final roomDocumentReference =
                      FirebaseFirestore.instance.collection('Room').doc(roomId);

                  await roomDocumentReference.get().then((value) {
                    final totalData = value.data() as Map;
                    roomData.addAll(totalData);
                  });

                  log(roomData.toString());

                  if (!roomData['RoomUsersId']
                      .toString()
                      .contains(currentUserId.toString())) {
                    final List roomUsers = roomData['RoomUsersId'] as List;

                    roomUsers.add(currentUserId.toString());

                    roomDocumentReference.update({
                      'RoomUsersId': roomUsers,
                    });
                  }
                  if (ctx.mounted) {
                    Navigator.pushAndRemoveUntil(
                      ctx,
                      MaterialPageRoute(
                        builder: (context) =>
                            HomePage(userUid: currentUserId.toString()),
                      ),
                      (route) => false,
                    );
                    Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(
                            userUid: currentUserId,
                            roomId: roomId.toString(),
                            roomName: roomName.toString(),
                            adminUid: roomData['AdminId'],
                            currentUserName: currentUserName.toString(),
                          ),
                        ));
                  }
                  joinRoomNameController.clear();
                  joinRoomPasswordController.clear();

                  Fluttertoast.showToast(
                      fontSize: 15,
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      gravity: ToastGravity.BOTTOM,
                      msg: 'Joined..');
                } else if (roomPassword !=
                    joinRoomPasswordController.text.toString()) {
                  Fluttertoast.showToast(
                      fontSize: 15,
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      gravity: ToastGravity.BOTTOM,
                      msg: 'Wrong Password');
                }
              } else {
                Fluttertoast.showToast(
                    fontSize: 15,
                    toastLength: Toast.LENGTH_LONG,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    gravity: ToastGravity.BOTTOM,
                    msg: 'Please, Enter your password');
              }
            },
            child: text(
              'Submit',
              fontsize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              joinRoomNameController.clear();
              joinRoomPasswordController.clear();
              Navigator.pop(ctx);
            },
            child: text(
              'Cancel',
              fontsize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
