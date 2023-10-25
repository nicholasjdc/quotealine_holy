import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quotealine_holy/base_classes/folder.dart';
import 'package:quotealine_holy/screens/folder_page.dart';
import 'package:quotealine_holy/screens/login_page.dart';
import 'package:quotealine_holy/screens/login_page_temp.dart';
import 'package:quotealine_holy/utils/fire_auth.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;
  final String routeToFolderCollection = "folders";
  final String routeToUserCollection = "users";
  TextEditingController addUserToFoldercontroller = TextEditingController();
  TextEditingController addFriendController = TextEditingController();
  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NAME: ${_currentUser.displayName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              'EMAIL: ${_currentUser.email}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            _currentUser.emailVerified
                ? Text(
                    'Email verified',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.green),
                  )
                : Text(
                    'Email not verified',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.red),
                  ),
            const SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: () => {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FolderPage(_currentUser),
                        ),
                      )
                    },
                child: const Text('To FolderPage')),
            const SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: () => {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PrettyLoginPage(),
                        ),
                      )
                    },
                child: const Text('To temp_login_page')),
            const SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: () => addUserToFolderDialog(),
                child: const Text('Join Group')),
            const SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: () => addFriendDialog(),
                child: const Text('Add Friend')),
            const SizedBox(height: 16.0),
            _isSendingVerification
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isSendingVerification = true;
                          });
                          await _currentUser.sendEmailVerification();
                          setState(() {
                            _isSendingVerification = false;
                          });
                        },
                        child: const Text('Verify email'),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          User? user = await FireAuth.refreshUser(_currentUser);

                          if (user != null) {
                            setState(() {
                              _currentUser = user;
                            });
                          }
                        },
                      ),
                    ],
                  ),
            const SizedBox(height: 16.0),
            _isSigningOut
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isSigningOut = true;
                      });
                      await FirebaseAuth.instance.signOut();
                      setState(() {
                        _isSigningOut = false;
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Sign out'),
                  ),
          ],
        ),
      ),
    );
  }

  addUserToFolderDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Please Enter FolderID"),
        content: TextField(
          decoration: const InputDecoration(hintText: "3P0dkjfK41"),
          controller: addUserToFoldercontroller,
        ),
        actions: [
          TextButton(
            child: const Text('Submit'),
            onPressed: () => submitAddUserToFolderDialog(
                addUserToFoldercontroller.text, widget.user.uid),
          )
        ],
      ),
    );
  }

  submitAddUserToFolderDialog(String folderName, String userID) {
    //Update folder MemberUserIDS
    DocumentReference newFolderRef = FirebaseFirestore.instance
        .collection(routeToFolderCollection)
        .doc(folderName);
    newFolderRef.update({
      "memberUserIDs": FieldValue.arrayUnion([userID])
    });

    //update User joined Folders
    FirebaseFirestore.instance
        .collection(routeToUserCollection)
        .doc(userID)
        .update({
      "joinedFolders": FieldValue.arrayUnion([newFolderRef])
    });

    Navigator.of(context).pop();
  }

  addFriendDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Please Enter FriendID"),
        content: TextField(
          decoration: const InputDecoration(hintText: "3P0dkjfK41"),
          controller: addFriendController,
        ),
        actions: [
          TextButton(
            child: const Text('Submit'),
            onPressed: () => submitAddFriendDialog(
                addFriendController.text, widget.user.uid),
          )
        ],
      ),
    );
  }

  submitAddFriendDialog(String friendName, String userID) {
    //Update folder MemberUserIDS
    DocumentReference currUserRef = FirebaseFirestore.instance
        .collection(routeToUserCollection)
        .doc(userID);
    DocumentReference friendUserRef = FirebaseFirestore.instance
        .collection(routeToUserCollection)
        .doc(friendName);

    currUserRef.update({
      "friends": FieldValue.arrayUnion([friendUserRef])
    });

    //update User joined Folders
    friendUserRef.update({
      "friends": FieldValue.arrayUnion([currUserRef])
    });

    Navigator.of(context).pop();
  }
}
