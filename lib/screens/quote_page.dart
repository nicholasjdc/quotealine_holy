import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:quotealine_holy/base_classes/quote.dart';

class QuotePage extends StatelessWidget {
  final String currUserID;
  final CollectionReference cr;
  const QuotePage(this.currUserID, this.cr, {super.key});

  @override
  Widget build(BuildContext context) {
    return PostList(currUserID, cr);
  }
}

// return a card template widget
class PostList extends StatefulWidget {
  final String currUserID;
  final CollectionReference cr;
  const PostList(this.currUserID, this.cr, {super.key});

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late TextEditingController quoteContentController;
  late Stream<QuerySnapshot> quoteStream;

  @override
  void initState() {
    super.initState();
    _filterQuoteStream();
  }

/*------------------------------------METHODS---------------------------------*/

  _filterQuoteStream() async {
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
                snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }

            if (snapshot.connectionState == ConnectionState.done) {
              return Container();
            }
          } else if (snapshot.hasError) {
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
        title: const Text("New Quote"),
        content: TextField(
          decoration: const InputDecoration(
              hintText: "I am become death, destroyer of worlds"),
          controller: quoteContentController,
        ),
        actions: [
          TextButton(
            child: const Text('Submit'),
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
      'dateCreated': Timestamp.now(),
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
