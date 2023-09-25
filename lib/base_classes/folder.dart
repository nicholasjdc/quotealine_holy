import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quotealine_holy/base_classes/base_model.dart';

class Folder implements BaseModel {
  String folderID = '';
  String folderName = '';
  String parentFolderID = '';
  Map<String, dynamic> initFolderContents = {};
  Folder.fromMap(Map<String, dynamic> map)
      : folderID = map['folderID'],
        folderName = map['folderName'],
        parentFolderID = map['parentFolderID'];
  @override
  Map<String, dynamic> toMap() {
    return {
      'folderID': folderID,
      'folderName': folderName,
      'parentFolderID': parentFolderID,
    };
  }

  String routeToCollection = 'folders';

  Future<void> addFolder(Folder folder) async {
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection(routeToCollection)
        .add(folder.toMap());
    docRef.collection('quotes').add(initFolderContents);
  }

  Future<Folder> getFolder(String id) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(routeToCollection)
        .doc(id)
        .get();
    return Folder.fromMap(snapshot.data as Map<String, dynamic>);
  }

  Future<List<Folder>> getFolders() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(routeToCollection).get();
    return snapshot.docs
        .map((doc) => Folder.fromMap(doc.data as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Folder>> getFoldersStream() {
    return FirebaseFirestore.instance
        .collection(routeToCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Folder.fromMap(doc.data as Map<String, dynamic>))
            .toList());
  }

  Future<void> batchUpdateFolders(List<Folder> folders) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var folder in folders) {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(routeToCollection)
          .doc(folder.folderID);
      batch.update(ref, folder.toMap());
    }
    await batch.commit();
  }
  /*
  Future<List<Folder>> paginateFolders(int page) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Folders').orderBy('title').limit(10).
  }
  */
}
