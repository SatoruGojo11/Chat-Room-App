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
TextEditingController createRoomNameController = TextEditingController();
TextEditingController createRoomPasswordController = TextEditingController();

// Create Room
createRoomDialog({
  required BuildContext ctx,
  required String? title,
  required String currentUserId,
  required String currentUserName,
}) {
  bool obscurity = false;

  String? adminName;
  String? adminId;

  List<String> roomUsers = [];

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
              // autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  textformfield(
                    createRoomNameController,
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
                  StatefulBuilder(
                    builder: (context, setState) => textformfield(
                      createRoomPasswordController,
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
                final roomCollectionReference =
                    FirebaseFirestore.instance.collection('Room');
                final userCollectionReference =
                    FirebaseFirestore.instance.collection('User');
                DocumentReference documentReferenceRoom =
                    roomCollectionReference.doc();

                DocumentReference documentReferenceUser =
                    userCollectionReference.doc(currentUserId);

                await documentReferenceUser.get().then((value) {
                  final adminUserData = value.data() as Map;
                  adminId = adminUserData['UserUid'].toString();
                  adminName = adminUserData['UserName'].toString();
                  roomUsers.add(adminUserData['UserUid'].toString());
                });

                final roomID = documentReferenceRoom.id.toString();

                Map<String, dynamic> roomData = {
                  'RoomName': createRoomNameController.text.toString(),
                  'RoomPassword': createRoomPasswordController.text.toString(),
                  'RoomId': roomID,
                  'Admin': adminName,
                  'AdminId': adminId,
                  'RoomUsersId': roomUsers,
                };

                await documentReferenceRoom
                    .set(roomData)
                    .whenComplete(() => log('Room Created'))
                    .onError((error, stackTrace) => log(error.toString()));

                final roomName = createRoomNameController.text.toString();
                if (ctx.mounted) {
                  Navigator.pushAndRemoveUntil(
                    ctx,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomePage(userUid: currentUserId.toString()),
                    ),
                    (route) => false,
                  );
                  Navigator.push(ctx, MaterialPageRoute(
                    builder: (ctx) {
                      return ChatRoomPage(
                        userUid: currentUserId,
                        roomId: roomID.toString(),
                        roomName: roomName,
                        adminUid: currentUserId,
                        currentUserName: currentUserName,
                      );
                    },
                  ));

                  createRoomNameController.clear();
                  createRoomPasswordController.clear();

                  Fluttertoast.showToast(
                      fontSize: 15,
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      gravity: ToastGravity.BOTTOM,
                      msg: 'Room Created Successfully...');
                }
              } else {
                Navigator.pop(ctx);
                Fluttertoast.showToast(
                    fontSize: 15,
                    toastLength: Toast.LENGTH_LONG,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    gravity: ToastGravity.BOTTOM,
                    msg: 'Please, fulfill the above conditions...');
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
              createRoomNameController.clear();
              createRoomPasswordController.clear();
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
