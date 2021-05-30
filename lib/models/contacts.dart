import 'package:cloud_firestore/cloud_firestore.dart';

class Contacts {
  String? uid;
  Timestamp? addedOn;

  Contacts({
    this.uid,
    this.addedOn,
  });

  Map toMap(Contacts contacts) {
    var data = Map<String, dynamic>();
    data['contact_id'] = contacts.uid;
    data['added_on'] = contacts.addedOn;

    return data;
  }

  Contacts.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['contact_id'];
    this.addedOn = mapData['added_on'];
  }
}
