import 'package:cloud_firestore/cloud_firestore.dart';

class Fridge{
  String iName;
  String quantity;
  final DocumentReference reference;

  Fridge.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['iName'] != null),
        iName = map['iName'],
        quantity = map['quantity'];

  Fridge.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}