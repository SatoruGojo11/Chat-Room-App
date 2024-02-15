import 'package:chat_room_app/screens/home_screen.dart';
import 'package:chat_room_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String? userUid;
  @override
  void initState() {
    super.initState();
    userUid = getSharedPrefData().toString();
  }

  Future<String> getSharedPrefData() async {
    final getDataInLocal = await SharedPreferences.getInstance();

    final userUid = getDataInLocal.getString('UserId');
    return userUid!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // user logged In
          if (snapshot.hasData) {
            return HomePage(userUid: userUid.toString());
          } else if (snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // user not logged in
          else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
