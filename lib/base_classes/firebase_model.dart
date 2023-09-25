import 'package:quotealine_holy/base_classes/base_model.dart';

abstract class FirebaseModel implements BaseModel {
  Future<void> add(BaseModel baseModel);
}
