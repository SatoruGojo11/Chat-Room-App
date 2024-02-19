import 'dart:developer';

import 'package:chat_room_app/screens/home_screen.dart';
import 'package:chat_room_app/screens/sign_up_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_room_app/models/text.dart';
import 'package:chat_room_app/models/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final _validationkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('User');
  List<String> docIds = [];
  List<Map<dynamic, dynamic>> docs = [];
  var recentData = {};

  bool obscurity = false;

  dynamic suffixicn() {
    return IconButton(
      onPressed: () {
        setState(() {
          obscurity = !obscurity;
        });
      },
      icon: Icon(
        obscurity ? Icons.visibility_off : Icons.visibility,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    collectionReference.get().then((QuerySnapshot snapshot) {
      snapshot.docs
          .map((e) {
            log(e.id.toString());
            setState(() {});
            docIds.add(e.id);
          })
          .toList()
          .toString();
    });
  }

  Future<void> addDataInSharedPreference(currentUserId, currentUserName) async {
    final setDataInLocal = await SharedPreferences.getInstance();
    log(currentUserId.toString(), name: 'User Id Added in SharedPreference');
    await setDataInLocal.setString('UserId', currentUserId.toString());
    await setDataInLocal.setString('UserName', currentUserName.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: text(
          'Login Page',
          fontsize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Form(
              key: _validationkey,
              // autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  textformfield(
                    emailController,
                    labeltxt: 'Email-id',
                    hinttxt: 'Enter Your Email-id',
                    keyboardtype: TextInputType.emailAddress,
                    inputFormate: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z1-90@.]'))
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter your Email-id";
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
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
                    hinttxt: 'Enter Your Password',
                    obscurity: obscurity,
                    suffixicn: suffixicn(),
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
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                if (_validationkey.currentState!.validate()) {
                  try {
                    showDialog(
                      context: context,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    await auth.signInWithEmailAndPassword(
                      email: emailController.text.toLowerCase(),
                      password: pwdController.text.toString(),
                    );

                    for (int i = 0; i < docIds.length; i++) {
                      final snapShot =
                          await collectionReference.doc(docIds[i]).get();
                      docs.add(snapShot.data() as Map);

                      if (docs[i]
                          .containsValue(emailController.text.toLowerCase())) {
                        recentData.addAll(docs[i]);

                        i = docIds.length;
                      }
                    }
                    if (recentData
                        .containsValue(emailController.text.toLowerCase())) {
                      if (recentData
                          .containsValue(pwdController.text.toString())) {
                        final userUid = recentData['UserUid'];
                        final userName = recentData['UserName'];

                        await addDataInSharedPreference(
                          userUid.toString(),
                          userName.toString(),
                        );
                        log('Add Data in Shared Preference',
                            name: 'Shared Preference');

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  userUid: userUid.toString(),
                                ),
                              ),
                              (route) => false);
                          Fluttertoast.showToast(
                            msg: 'Logged In Successful',
                            backgroundColor: Colors.green,
                          );
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Wrong Password',
                          backgroundColor: Colors.red,
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: 'User Not Found',
                        backgroundColor: Colors.red,
                      );
                    }

                    emailController.clear();
                    pwdController.clear();
                  } on FirebaseAuthException catch (e) {
                    log('Catch On Part');

                    Fluttertoast.showToast(
                      msg: 'Wrong Password',
                      backgroundColor: Colors.red,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    log(e.toString());
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
              },
              child: text('Login'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text(
                  'Not Registered??',
                  fontsize: 15,
                  fontWeight: FontWeight.bold,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: text(
                    'Sign Up',
                    clr: Colors.red,
                    fontsize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
