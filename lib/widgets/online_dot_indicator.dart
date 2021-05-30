import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placeholder/enum/user_state.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/resources/auth_methods.dart';
import 'package:placeholder/utils/utilities.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;

  OnlineDotIndicator({required this.uid});

  getColor(int state) {
    switch (Utils.numToState(state)) {
      case UserState.Offline:
        return Colors.red;
      case UserState.Online:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  final AuthMethods _authMethods = AuthMethods();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _authMethods.getUserStream(uid: uid),
      builder: (context, snapshot) {
        FirebaseUser user = FirebaseUser();
        if (snapshot.hasData && snapshot.data!.data() != null) {
          user = FirebaseUser.fromMap(
              snapshot.data!.data() as Map<String, dynamic>);
        }

        return Container(
          height: 10,
          width: 10,
          margin: EdgeInsets.only(right: 8, top: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: getColor(user.state ?? 0),
          ),
        );
      },
    );
  }
}
