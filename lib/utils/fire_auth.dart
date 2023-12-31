import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quotealine_holy/base_classes/folder.dart';
import 'package:quotealine_holy/base_classes/quote_user.dart';

class FireAuth {
  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;

      await user!.updateProfile(displayName: name);
      await user.reload();

      user = auth.currentUser;

      await createQuoteUserWithEmailAndPassword(name, user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return user;
  }

  static Future<QuoteUser?> createQuoteUserWithEmailAndPassword(
      username, String userID) async {
    List<DocumentReference> initFolders = [];
    List<DocumentReference> initFriends = [];
    QuoteUser currQuoteUser = QuoteUser.fromMap({
      'userID': userID,
      'username': username,
      'joinedFolders': initFolders,
      'dateCreated': Timestamp.now(),
      'friends': initFriends,
    });

    DocumentReference currQuoteUserDocRef =
        await currQuoteUser.addUser(currQuoteUser);
    Map<String, dynamic> personalFolderMap = {
      'folderID': 'tempID',
      'folderName': 'personal',
      'parentFolderID': 'root',
      'adminIDs': [currQuoteUserDocRef.id],
      'memberUserIDs': [currQuoteUserDocRef.id],
      'dateCreated': Timestamp.now(),
    };
    Folder personalFolder = Folder.fromMap(personalFolderMap);
    DocumentReference personalFolderRef =
        await personalFolder.addFolder(personalFolder);
    initFolders.add(personalFolderRef);
    await currQuoteUserDocRef.update(
        {'joinedFolders': initFolders, 'userID': currQuoteUserDocRef.id});
    return currQuoteUser;
  }

  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      }
    }

    return user;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}
