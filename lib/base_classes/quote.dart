import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quotealine_holy/base_classes/base_model.dart';

class Quote implements BaseModel {
  String quoteID = '';
  String quote = '';
  Timestamp dateCreated;
  String parentFolderID = '';
  Quote.fromMap(Map<String, dynamic> map)
      : quoteID = map['quoteID'],
        quote = map['quote'],
        parentFolderID = map['parentFolderID'],
        dateCreated = map['dateCreated'];
  @override
  Map<String, dynamic> toMap() {
    return {
      'quoteID': quoteID,
      'quote': quote,
      'parentFolderID': parentFolderID,
      'dateCreated': dateCreated,
    };
  }

  String routeToCollection = 'quotes';

  Future<void> addQuote(Quote quote) async {
    FirebaseFirestore.instance.collection(routeToCollection).add(quote.toMap());
  }

  Future<Quote> getQuote(String id) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(routeToCollection)
        .doc(id)
        .get();
    return Quote.fromMap(snapshot.data as Map<String, dynamic>);
  }

  Future<List<Quote>> getQuotes() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(routeToCollection).get();
    return snapshot.docs
        .map((doc) => Quote.fromMap(doc.data as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Quote>> getQuotesStream() {
    return FirebaseFirestore.instance
        .collection(routeToCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Quote.fromMap(doc.data as Map<String, dynamic>))
            .toList());
  }

  Future<void> batchUpdateQuotes(List<Quote> quotes) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var quote in quotes) {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(routeToCollection)
          .doc(quote.quoteID);
      batch.update(ref, quote.toMap());
    }
    await batch.commit();
  }
  /*
  Future<List<Quote>> paginateQuotes(int page) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('quotes').orderBy('title').limit(10).
  }
  */
}
