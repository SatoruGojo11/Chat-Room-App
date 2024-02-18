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
import 'package:shared_preferences/shared_preferences.dart';

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

  addDataInSharedPreference(currentUserId, currentUserName) async {
    final setDataInLocal = await SharedPreferences.getInstance();
    log(currentUserId.toString(), name: 'User Id Added in SharedPreference');
    await setDataInLocal.setString('UserId', currentUserId.toString());
    await setDataInLocal.setString('UserName', currentUserName.toString());
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
                  // autovalidateMode: AutovalidateMode.always,
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

                        await auth.createUserWithEmailAndPassword(
                          email: emailController.text.toLowerCase(),
                          password: pwdController.text.toString(),
                        );

                        CloudDatabase.addItem(
                          username: usernameController.text.toString(),
                          useremail: emailController.text.toLowerCase(),
                          userPassword: pwdController.text.toString(),
                          userPhoneNo:
                              int.parse(phoneController.text).toString(),
                        );

                        final currentUserId = CloudDatabase.userUid;
                        final currentUserName =
                            usernameController.text.toString();

                        FirebaseFirestore.instance
                            .collection('User')
                            .doc(currentUserId)
                            .update({
                          'UserUid': currentUserId.toString(),
                        });
                        Future.delayed(const Duration(seconds: 2));
                        await addDataInSharedPreference(
                          currentUserId.toString(),
                          currentUserName.toString(),
                        );
                        log('Add Data in Shared Preference',
                            name: 'Shared Preference');

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  userUid: currentUserId.toString(),
                                ),
                              ),
                              (route) => false);
                          Fluttertoast.showToast(
                            msg: 'Signed Up Successful',
                            backgroundColor: Colors.green,
                          );
                        }
                        usernameController.clear();
                        phoneController.clear();
                        emailController.clear();
                        pwdController.clear();
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          Fluttertoast.showToast(
                            msg: 'User Not Found',
                            backgroundColor: Colors.red,
                          );
                        } else if (e.code == 'wrong-password') {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          Fluttertoast.showToast(
                            msg: 'Wrong Password',
                            backgroundColor: Colors.red,
                          );
                        } else {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }

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
