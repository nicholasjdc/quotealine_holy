import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:quotealine_holy/base_classes/quote.dart';

class QuotePage extends StatelessWidget {
  final String currUserID;
  final CollectionReference cr;
  QuotePage(this.currUserID, this.cr);

  @override
  Widget build(BuildContext context) {
    return PostList(currUserID, cr);
  }
}

// return a card template widget
class PostList extends StatefulWidget {
  final String currUserID;
  final CollectionReference cr;
  PostList(this.currUserID, this.cr);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late TextEditingController quoteContentController;
  late Stream<QuerySnapshot> quoteStream;

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
        quoteStream = Stream.empty();
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
    Stream<QuerySnapshot> filteredStream = widget.cr.snapshots();

    setState(() {
      quoteStream = filteredStream;
    });
    setState(() {
      quoteContentController = TextEditingController();
    });
  }

  /*--------------------------------------------------------------------------*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: quoteStream,
        // stream: Firestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.none ||
                snapshot.connectionState == ConnectionState.waiting)
              return Container();
            //     // return SizedBox(
            //     //     width: 20, height: 20, child: CircularProgressIndicator());
            //     return Center(
            //     child: SpinKitFadingCube(
            //       color: Colors.white,
            //       size: 100.0,
            //     ));
            if (snapshot.connectionState == ConnectionState.done)
              return Container();
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
        onPressed: () => addQuoteDialog(),
        tooltip: 'Add Folder',
        child: const Icon(Icons.add),
      ),
    );
  }

  addQuoteDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Quote"),
        content: TextField(
          decoration: InputDecoration(
              hintText: "I am become death, destroyer of worlds"),
          controller: quoteContentController,
        ),
        actions: [
          TextButton(
            child: Text('Submit'),
            onPressed: () => submitAddQuoteDialog(quoteContentController.text),
          )
        ],
      ),
    );
  }

  submitAddQuoteDialog(String quoteContent) async {
    Quote testQuote = Quote.fromMap({
      'quoteID': 'lovelyFolderID',
      'quote': quoteContent,
      'parentFolderID': 'lovelyParentFolderID',
    });
    widget.cr.add(testQuote.toMap());
    Navigator.of(context).pop();
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
          return ListTile(title: Text(snapshots[index]['quote']));
        });
  }
}
