import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quotealine_holy/base_classes/quote_user.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:quotealine_holy/base_classes/folder.dart';
import 'package:quotealine_holy/screens/quote_page.dart';

class FolderPage extends StatelessWidget {
  final String currUserID;
  const FolderPage(this.currUserID, {super.key});

  @override
  Widget build(BuildContext context) {
    return PostList(currUserID);
  }
}

Map<String, dynamic> testMap = {
  'haha hoho': 'hehe haha',
};

// return a card template widget
class PostList extends StatefulWidget {
  final String currUserID;
  const PostList(this.currUserID, {super.key});

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late Stream<QuerySnapshot> folderStream;
  late TextEditingController addFoldercontroller;
  late int folderCount;
  late List<DocumentSnapshot> currentUserFoldersSnaps;
  final String routeToFolderCollection = "folders";

  @override
  void initState() {
    super.initState();
    _filterUserFolders();
  }

/*------------------------------------METHODS---------------------------------*/

  _filterUserFolders() async {
    QuoteUser currentQuoteUser = QuoteUser.fromMap({}); //Could Cause issues
    currentQuoteUser = await currentQuoteUser.getUser(widget.currUserID);
    List<DocumentReference> currentQuoteUserFoldersRefs =
        currentQuoteUser.joinedFolders;
    List<DocumentSnapshot> tempCurrentUserFoldersSnaps = [];
    for (DocumentReference fid in currentQuoteUser.joinedFolders) {
      tempCurrentUserFoldersSnaps.add(await fid.get());
    }

    Stream<QuerySnapshot> filteredStream =
        FirebaseFirestore.instance.collection('folders').snapshots();
    setState(() {
      folderStream = filteredStream;
    });
    setState(() {
      addFoldercontroller = TextEditingController();
    });
    setState(() {
      currentUserFoldersSnaps = tempCurrentUserFoldersSnaps;
    });
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
                addFoldercontroller.text, widget.currUserID),
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
    });
    FirebaseFirestore.instance
        .collection(routeToFolderCollection)
        .add(testFolder.toMap());
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
