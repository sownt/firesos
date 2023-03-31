import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  Future<User?> createAccount(
    String displayName,
    String phoneNumber,
    String email,
    String password,
  ) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore store = FirebaseFirestore.instance;
    try {
      // Create user with email and password
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if register successfully
      credential.user!.updateDisplayName(displayName);

      // Update user information to Firebase
      await store.collection('users').doc(auth.currentUser!.uid).set({
        "name": displayName,
        "phoneNum": phoneNumber,
        "email": email,
        "status": "Unavailable",
        "uid": auth.currentUser!.uid,
      });

      return credential.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signIn(
    String email,
    String password,
  ) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore store = FirebaseFirestore.instance;
    try {
      // Login using email and password
      UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      store
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) => credential.user!.updateDisplayName(value['name']),);

      return credential.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }
}
