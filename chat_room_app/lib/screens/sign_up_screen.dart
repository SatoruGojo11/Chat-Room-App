import 'dart:developer';
import 'package:chat_room_app/models/user_firebase_database.dart';
import 'package:chat_room_app/models/text.dart';
import 'package:chat_room_app/models/textformfield.dart';
import 'package:chat_room_app/screens/home_screen.dart';
import 'package:chat_room_app/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final _validationkey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String userUid = '';
  List<String> docIds = [];

  @override
  void initState() {
    super.initState();
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('User');

    collectionReference.get().then((QuerySnapshot snapshot) {
      log('init method Sign In Page');
      snapshot.docs.map((e) => log(e.id.toString())).toList().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: text(
          'Sign In Page',
          fontsize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
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
                        validator: (value) {
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
                        phoneController,
                        labeltxt: 'Phone-No',
                        hinttxt: 'Enter your Phone-No',
                        maxLength: 10,
                        keyboardtype: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter your Phone-no.";
                          } else if (value.length < 10) {
                            return "Please Enter valid Phone-no.";
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
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    log('Sign up button Clicked');
                    if (_validationkey.currentState!.validate()) {
                      try {
                        showDialog(
                          context: context,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        final credential =
                            await auth.createUserWithEmailAndPassword(
                          email: emailController.text.toLowerCase(),
                          password: pwdController.text.toString(),
                        );

                        CloudDatabase.addItem(
                          username: usernameController.text.toString(),
                          useremail: emailController.text.toLowerCase(),
                          userPassword: pwdController.text.toString(),
                        );
                        log('Set Completed');

                        final currentUserId = CloudDatabase.userUid;
                        log(currentUserId.toString(), name: 'UserId');

                        FirebaseFirestore.instance
                            .collection('User')
                            .doc(currentUserId)
                            .update({
                          'UserUid': currentUserId.toString(),
                        });
                        log('update UserUid Completed');
                        Future.delayed(const Duration(seconds: 2));

                        if (context.mounted) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  userUid: currentUserId.toString(),
                                ),
                              ));
                          Fluttertoast.showToast(
                            msg: 'Signed Up Successful',
                            backgroundColor: Colors.green,
                          );
                        }
                        log('try Part');
                        log(credential.user!.email.toString());
                        usernameController.clear();
                        phoneController.clear();
                        emailController.clear();
                        pwdController.clear();
                      } on FirebaseAuthException catch (e) {
                        log('Catch On Part');
                        if (e.code == 'user-not-found') {
                          Fluttertoast.showToast(
                            msg: 'User Not Found',
                            backgroundColor: Colors.red,
                          );
                        } else if (e.code == 'wrong-password') {
                          Fluttertoast.showToast(
                            msg: 'Wrong Password',
                            backgroundColor: Colors.red,
                          );
                        } else {
                          log(e.toString());
                          Fluttertoast.showToast(
                            msg:
                                'Email-id is already in use by another Account',
                            backgroundColor: Colors.red,
                          );
                        }
                      } catch (e) {
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
                  child: text('Sign Up'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    text(
                      'Already Registered??',
                      fontsize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ));
                      },
                      child: text(
                        'Login',
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
        ),
      ),
    );
  }
}
