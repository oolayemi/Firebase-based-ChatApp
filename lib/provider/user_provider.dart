import 'package:flutter/widgets.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  FirebaseUser? _user;
  AuthMethods _authMethods = AuthMethods();

  FirebaseUser? get getUser => _user;

  Future<void> refreshUser() async {
    FirebaseUser user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
