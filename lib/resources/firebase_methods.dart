import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../constants/strings.dart';
import '../../models/firebase_user.dart';
import '../../models/message.dart';
import '../../provider/image_upload_provider.dart';
import '../../utils/utilities.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late Reference _storageReference;

  FirebaseUser user = FirebaseUser();

  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = _auth.currentUser;

    return currentUser;
  }

  Future<User?> signIn() async {
    GoogleSignInAccount _signInAccount = await (_googleSignIn.signIn() as FutureOr<GoogleSignInAccount>);
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: _signInAuthentication.accessToken,
      idToken: _signInAuthentication.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    return userCredential.user;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(User currentUser) async {
    String username = Utils.getUsername(currentUser.email!);
    user = FirebaseUser(
      uid: currentUser.uid,
      email: currentUser.email,
      name: currentUser.displayName,
      profilePhoto: currentUser.photoURL,
      username: username,
    );

    firestore
        .collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .set(user.toMap(user) as Map<String, dynamic>);
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<List<FirebaseUser>> fetchAllUsers(User? currentUser) async {
    List<FirebaseUser> userList = <FirebaseUser>[];
    QuerySnapshot querySnapshot =
        await firestore.collection(USERS_COLLECTION).get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser!.uid) {
        userList.add(FirebaseUser.fromMap(querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }

    return userList;
  }

  Future<DocumentReference<Map<String, dynamic>>> addMessageToDb(
      Message message, FirebaseUser? sender, FirebaseUser? receiver) async {
    var map = message.toMap();
    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    return await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  Future<String?> uploadImageToStorage(File image) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');

      UploadTask _storageUploadTask = _storageReference.putFile(image);

      var url = await (await _storageUploadTask).ref.getDownloadURL();

      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void sendContact(
      Map<dynamic, dynamic>? contact, String? senderId, String? receiverId) async {
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

    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(_message.senderId)
        .collection(_message.receiverId!)
        .add(map as Map<String, dynamic>);

    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(_message.receiverId)
        .collection(_message.senderId!)
        .add(map);
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

    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(_message.senderId)
        .collection(_message.receiverId!)
        .add(map as Map<String, dynamic>);

    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(_message.receiverId)
        .collection(_message.senderId!)
        .add(map);
  }

  void uploadImage(File image, String? receiverId, String? senderId,
      ImageUploadProvider imageUploadProvider) async {
    imageUploadProvider.setToLoading();
    String? url = await uploadImageToStorage(image);

    imageUploadProvider.setToIdle();

    setImageMsg(url, receiverId, senderId);
  }
}
