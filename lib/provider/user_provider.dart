import 'package:flutter/widgets.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/resources/firebase_repository.dart';

class UserProvider with ChangeNotifier {
  FirebaseUser? _user;
  FirebaseRepository _firebaseRepository =FirebaseRepository();

  FirebaseUser? get getUser => _user;

  Future<void> refreshUser() async {
    FirebaseUser user = await _firebaseRepository.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
