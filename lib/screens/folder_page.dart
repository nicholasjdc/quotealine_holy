import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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
  late String routeToFolderCollection;

  @override
  void initState() {
    super.initState();
    _filterStreamByFavTags();
  }

/*------------------------------------METHODS---------------------------------*/

  // filters posts by a user's faved tags
  /* Stream<QuerySnapshot> */ _filterStreamByFavTags() async {
    //DocumentSnapshot self;

    // if User is not logged in, they see an empty stream for the curated page
    /*
    if (widget.currUserID != null) {
      self = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currUserID)
          .get();
    } else {
      setState(() {
        folderStream = Stream.empty();
      });
      return;
    }
*/
    //Map<String, String> favTags = Map<String, String>.from(self['favTags']);
    //List<String> keysFavTags = favTags.keys.toList();

    // if the user has no favorite tags, the FOR YOU page is empty
    //if (keysFavTags.isEmpty) return Stream.empty();

    // otherwise, use the current users faved tags to filter for posts that contain
    // corresponding tagIDs
    Stream<QuerySnapshot> filteredStream =
        FirebaseFirestore.instance.collection('folders').snapshots();

    setState(() {
      folderStream = filteredStream;
    });
    setState(() {
      addFoldercontroller = TextEditingController();
    });
    setState(() {
      routeToFolderCollection = "folders";
    });
  }

  /*--------------------------------------------------------------------------*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: folderStream,
        // stream: Firestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.none ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            //     // return SizedBox(
            //     //     width: 20, height: 20, child: CircularProgressIndicator());
            //     return Center(
            //     child: SpinKitFadingCube(
            //       color: Colors.white,
            //       size: 100.0,
            //     ));
            if (snapshot.connectionState == ConnectionState.done) {
              return Container();
            }
            //   // return CircularProgressIndicator();
            //   return Center(
            //     child: SpinKitFadingCube(
            //       color: Colors.white,
            //       size: 50.0,
            //     ));
          } else if (snapshot.hasError) {
            // return Text("${snapshot.error}");
            return Container();
          }
          return _buildList(context, snapshot.data!.docs);
        },
      ),
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
            onPressed: () => submitAddFolderDialog(addFoldercontroller.text),
          )
        ],
      ),
    );
  }

  submitAddFolderDialog(String folderName) async {
    Folder testFolder = Folder.fromMap({
      'folderID': 'lovelyFolderID',
      'folderName': folderName,
      'parentFolderID': 'lovelyParentFolderID',
      'folderContents': testMap,
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
