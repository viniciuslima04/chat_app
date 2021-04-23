import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireBaseHelper {
  static final FireBaseHelper _instance = FireBaseHelper.internal();

  User currentUser;

  factory FireBaseHelper() => _instance;

  FireBaseHelper.internal() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      this.currentUser = user;
    });
  }

  Future<User> getUser() async {
    if (currentUser != null) return currentUser;

    final GoogleSignIn googleSingin = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSingin.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  }

  Stream<QuerySnapshot> snapshots() {
    return FirebaseFirestore.instance
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future<void> sendMessage(String text) async {
    User user = await getUser();

    FirebaseFirestore.instance.collection("Messages").add({
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "text": text,
      "time": Timestamp.now()
    });
  }

  Future<void> sendImage(File file) async {
    User user = await getUser();

    StorageUploadTask task = FirebaseStorage.instance
        .ref()
        .child('imgs')
        .child(DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(file);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();

    FirebaseFirestore.instance.collection("messages").add({
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "imgUrl": url,
      "time": Timestamp.now()
    });
  }
}
