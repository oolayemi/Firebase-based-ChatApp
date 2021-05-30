import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:placeholder/constants/strings.dart';
import 'package:placeholder/models/contacts.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/models/message.dart';

class ChatMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _messageCollection =
      _firestore.collection(MESSAGES_COLLECTION);

  CollectionReference _userCollection = _firestore.collection(USERS_COLLECTION);

  Future<DocumentReference<Map<String, dynamic>>> addMessageToDb(
      Message message, FirebaseUser? sender, FirebaseUser? receiver) async {
    var map = message.toMap();
    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    return await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  DocumentReference getContactDocuments({String? of, String? forContact}) =>
      _userCollection.doc(of).collection(CONTACTS_COLLECTION).doc(forContact);

  void addToContacts({String? senderId, String? receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSendersContact(senderId, receiverId, currentTime);
    await addToReceiversContact(senderId, receiverId, currentTime);
  }

  Future<void> addToSendersContact(
      String? senderId, String? receiverId, currentTime) async {
    DocumentSnapshot senderSnapshot =
        await getContactDocuments(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      Contacts receiverContact = Contacts(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactDocuments(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

  Future<void> addToReceiversContact(
      String? senderId, String? receiverId, currentTime) async {
    DocumentSnapshot receiverSnapshot =
        await getContactDocuments(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      Contacts senderContact = Contacts(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactDocuments(of: receiverId, forContact: senderId)
          .set(senderMap);
    }
  }

  void setImageMsg(String? url, String? receiverId, String? senderId) async {
    Message _message;

    _message = Message.imageMessage(
      message: "IMAGE",
      receiverId: receiverId,
      senderId: senderId,
      photoUrl: url,
      timestamp: Timestamp.now(),
      type: 'image',
    );

    var map = _message.toImageMap();

    await _messageCollection
        .doc(_message.senderId)
        .collection(_message.receiverId!)
        .add(map as Map<String, dynamic>);

    await _messageCollection
        .doc(_message.receiverId)
        .collection(_message.senderId!)
        .add(map);
  }

  void sendContact(Map<dynamic, dynamic>? contact, String? senderId,
      String? receiverId) async {
    Message _message;

    _message = Message.contactMessage(
      message: "CONTACT",
      receiverId: receiverId,
      senderId: senderId,
      timestamp: Timestamp.now(),
      type: "contact",
      contact: contact,
    );

    var map = _message.toContactMap();
    //print(map);

    await _messageCollection
        .doc(_message.senderId)
        .collection(_message.receiverId!)
        .add(map as Map<String, dynamic>);

    await _messageCollection
        .doc(_message.receiverId)
        .collection(_message.senderId!)
        .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({String? userId}) =>
      _userCollection.doc(userId).collection(CONTACTS_COLLECTION).snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween(
          {@required String? senderId, @required String? receiverId}) =>
      _messageCollection
          .doc(senderId)
          .collection(receiverId!)
          .orderBy("timestamp")
          .snapshots();
}
