
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quotealine_holy/base_classes/base_model.dart';

class QuoteUser implements BaseModel {
  String userID = '';
  String username = '';
  List<String> joinedFolders = [];
  QuoteUser.fromMap(Map<String, dynamic> map)
      : userID = map['userID'],
        username = map['username'],
        joinedFolders = map['joinedFolders'];
  @override
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'username': username,
      'joinedFolders': joinedFolders,
    };
  }

  String routeToCollection = 'users';

  Future<void> addUser(QuoteUser user) async {
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection(routeToCollection)
        .add(user.toMap());
  }

  Future<QuoteUser> getUser(String id) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(routeToCollection)
        .doc(id)
        .get();
    return QuoteUser.fromMap(snapshot.data as Map<String, dynamic>);
  }

  Future<List<QuoteUser>> getUsers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(routeToCollection).get();
    return snapshot.docs
        .map((doc) => QuoteUser.fromMap(doc.data as Map<String, dynamic>))
        .toList();
  }

  Stream<List<QuoteUser>> getUsersStream() {
    return FirebaseFirestore.instance
        .collection(routeToCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuoteUser.fromMap(doc.data as Map<String, dynamic>))
            .toList());
  }

  Future<void> batchUpdateUsers(List<QuoteUser> users) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var user in users) {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(routeToCollection)
          .doc(user.userID);
      batch.update(ref, user.toMap());
    }
    await batch.commit();
  }
  /*
  Future<List<User>> paginateFolders(int page) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Folders').orderBy('title').limit(10).
  }
  */
}
