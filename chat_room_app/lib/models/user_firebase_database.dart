import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class CloudDatabase {
  static String? userUid;
  static Future<void> addItem({
    required String username,
    required String useremail,
    required String userPassword,
    required String userPhoneNo,
  }) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('User').doc();

    userUid = documentReference.id.toString();
    Map<String, dynamic> data = {
      'UserName': username,
      'UserEmail': useremail,
      'UserPassword': userPassword,
      'UserPhoneNo': userPhoneNo,
      'UserUid': userUid,
    };

    await documentReference
        .set(data)
        .whenComplete(() => log('add Data Completed'))
        .catchError((e) => log(e.toString()));
  }

  static Stream<QuerySnapshot> readItems() {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('User');

    return collectionReference.snapshots();
  }

  static Future<void> deleteItem({required String userUid}) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('User').doc(userUid);

    await documentReference
        .delete()
        .whenComplete(() => log('Delete Data'))
        .catchError((e) => log(e.toString()));
  }
}
