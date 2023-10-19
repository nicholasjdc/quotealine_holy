import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quotealine_holy/base_classes/quote_user.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quotealine_holy/base_classes/folder.dart';
import 'package:quotealine_holy/screens/quote_page.dart';

class FolderPage extends StatelessWidget {
  final User user;
  const FolderPage(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return PostList(user);
  }
}

// return a card template widget
class PostList extends StatefulWidget {
  final User user;
  const PostList(this.user, {super.key});

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late Stream<QuerySnapshot> folderStream;
  late TextEditingController addFoldercontroller;
  late int folderCount;
  List<DocumentSnapshot> currentUserFoldersSnaps = [];
  final String routeToFolderCollection = "folders";
  final String routeToUserCollection = "users";

  @override
  void initState() {
    super.initState();
    _filterUserFolders();
  }

/*------------------------------------METHODS---------------------------------*/

  _filterUserFolders() async {
    print("USERID");
    print(widget.user.uid);
    QuoteUser currentQuoteUser = await QuoteUser.staticGetUser(widget.user.uid);
    List<DocumentSnapshot> tempCurrentUserFoldersSnaps = [];
    for (DocumentReference fRef in currentQuoteUser.joinedFolders) {
      tempCurrentUserFoldersSnaps.add(await fRef.get());
      print(fRef.id);
    }

    setState(() {
      addFoldercontroller = TextEditingController();
    });
    setState(() {
      currentUserFoldersSnaps = tempCurrentUserFoldersSnaps;
    });
    setState(() {});
  }

  /*--------------------------------------------------------------------------*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildList(context, currentUserFoldersSnaps),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addFolderDialog(),
        tooltip: 'Add Folder',
        child: const Icon(Icons.add),
      ),
    );
  }

  addFolderDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Folder"),
        content: TextField(
          decoration: const InputDecoration(hintText: "Folder Name"),
          controller: addFoldercontroller,
        ),
        actions: [
          TextButton(
            child: const Text('Submit'),
            onPressed: () => submitAddFolderDialog(
                addFoldercontroller.text, widget.user.uid),
          )
        ],
      ),
    );
  }

  submitAddFolderDialog(String folderName, String creatorID) async {
    Map<String, dynamic> initContents = {};
    Folder testFolder = Folder.fromMap({
      'folderID': 'tempID',
      'folderName': folderName,
      'parentFolderID': 'root',
      'folderContents': initContents,
      'memberUserIDs': [creatorID],
      'adminIDs': [creatorID],
      'dateCreated': Timestamp.now(),
    });
    DocumentReference newFolderRef = await FirebaseFirestore.instance
        .collection(routeToFolderCollection)
        .add(testFolder.toMap()); //Create new folder in folder collection
    FirebaseFirestore.instance
        .collection(routeToUserCollection)
        .doc(widget.user.uid)
        .update({
      "joinedFolders": FieldValue.arrayUnion([newFolderRef])
    });
    //.set({"joinedFolders": newFolderRef}, SetOptions(merge: true));
    //Update User's list of folders
    Navigator.of(context).pop();
  }

  CollectionReference createRoute(
      String collectionName, DocumentReference currentDoc) {
    final CollectionReference finalRef = currentDoc.collection(collectionName);

    return finalRef;
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshots) {
    //snapshots.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));
    return ListView.builder(
        itemCount: snapshots.length,
        padding: const EdgeInsets.only(top: 20.0),
        itemBuilder: (context, index) {
          /*
          return PostItem(
              context, snapshots[index], widget.currUserID, false, UniqueKey());
              */
          return ListTile(
            title: Text(snapshots[index]['folderName']),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuotePage(
                  'Nick',
                  createRoute("quotes", snapshots[index].reference),
                ),
              ),
            ),
          );
        });
  }
}
