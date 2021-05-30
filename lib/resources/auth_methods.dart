import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:placeholder/constants/strings.dart';
import 'package:placeholder/enum/user_state.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/utils/utilities.dart';

class AuthMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseUser user = FirebaseUser();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = _auth.currentUser;

    return currentUser;
  }

  Future<FirebaseUser> getUserDetails() async {
    User? currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser!.uid).get();
    return FirebaseUser.fromMap(
        documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<FirebaseUser?> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(id).get();

      return FirebaseUser.fromMap(
          documentSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signIn() async {
    GoogleSignInAccount _signInAccount =
        await (_googleSignIn.signIn() as FutureOr<GoogleSignInAccount>);
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
        userList.add(FirebaseUser.fromMap(
            querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }

    return userList;
  }

  void setUserState({required String userId, required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.doc(userId).update({"state": stateNum});
  }
 
  Stream<DocumentSnapshot> getUserStream({required String uid}) =>
      _userCollection.doc(uid).snapshots();
}
