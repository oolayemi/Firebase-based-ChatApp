import 'package:flutter/material.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/provider/user_provider.dart';
import 'package:placeholder/resources/auth_methods.dart';
import 'package:placeholder/screens/chatscreens/widgets/cached_image.dart';
import 'package:placeholder/screens/login_screen.dart';
import 'package:placeholder/widgets/appbar.dart';
import 'package:provider/provider.dart';

class UserDetailsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    signOut() async {
      bool isLoggedOut = await AuthMethods().signOut();

      if (isLoggedOut) {
        print("signed out");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 28),
      child: Column(
        children: [
          CustomAppBar(
            title: Text(""),
            //title: ShimmeringLogo(),
            actions: <Widget>[
              TextButton(
                onPressed: () => signOut(),
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            ],
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
          ),
          UserDetailsBody(),
        ],
      ),
    );
  }
}

class UserDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final FirebaseUser? user = userProvider.getUser;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          CachedImage(
            user!.profilePhoto,
            isRound: true,
            radius: 50,
          ),
          SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              user.name!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 3),
            Text(
              user.email!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            )
          ])
        ],
      ),
    );
  }
}
