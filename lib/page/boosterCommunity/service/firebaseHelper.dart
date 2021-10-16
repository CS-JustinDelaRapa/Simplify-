import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simplify/page/boosterCommunity/model/myuser.dart';

final CollectionReference userCollection =
    FirebaseFirestore.instance.collection('users');
final CollectionReference threadCollection =
    FirebaseFirestore.instance.collection('posts');

class AuthService {
  String? uid;

  AuthService({this.uid});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //getter for userInfo
  MyUser? _userfromFirebase(User user) {
    // ignore: unnecessary_null_comparison
    return user != null
        ? MyUser(uid: user.uid, verified: user.emailVerified)
        : null;
  }

  //auth change user stream, value signin
  Stream<MyUser?> get user {
    return _auth.userChanges().map((User? user) => _userfromFirebase(user!));
  }

  //to add post in database
  Future addItem(String title, String description) async {
    try {
      User? user = _auth.currentUser;
      // DocumentReference documentReferencer =
      //     threadCollection.doc(user!.uid).collection('posts').doc();
      // //updated
      // Map<String, dynamic> data = <String, dynamic>{
      //   "title": title,
      //   "description": description,
      //   "time-posted": DateTime.now()
      // };
      await threadCollection.doc().set({
        'title': title,
        'description': description,
        'publisher-Id': user!.uid,
        'time-stamp': DateTime.now(),
        'up-votes': 0,
        'down-votes': 0
      });

      // await documentReferencer
      //     .set(data)
      //     .whenComplete(() => print("Note item added to the database"))
      //     .catchError((e) => print(e));
    } on FirebaseException catch (error) {
      Fluttertoast.showToast(msg: error.message.toString());
    }
  }

  Future registerWithEmailandPassword(
      String email,
      String password,
      String firstName,
      String lastName,
      String school,
      BuildContext context) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      // create a new document for the user with the uid
      await userCollection.doc(user!.uid).set({
        'first-name': firstName,
        'last-name': lastName,
        'school': school,
        'userIcon': '001-panda.png',
      });
      Navigator.pop(context);
      return _userfromFirebase(user);
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(msg: error.message.toString());
      //push
    }
  }

  //sign in with email and password
  Future signInWithEmailandPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userfromFirebase(user!);
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(msg: error.message.toString());
    }
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userfromFirebase(user!);
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(msg: error.message.toString());
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(msg: error.message.toString());
    }
  }
}
