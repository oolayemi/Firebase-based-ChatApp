import 'package:flutter/material.dart';
import 'package:placeholder/models/contacts.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/resources/auth_methods.dart';
import 'package:placeholder/screens/chatscreens/chat_screen.dart';
import 'package:placeholder/screens/chatscreens/widgets/cached_image.dart';
import 'package:placeholder/widgets/custom_tile.dart';

class ContactsView extends StatelessWidget {
  final Contacts? contacts;
  final AuthMethods _authMethods = AuthMethods();

  ContactsView({this.contacts});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser?>(
      future: _authMethods.getUserDetailsById(contacts!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          FirebaseUser user = snapshot.data!;

          return ViewLayout(
            contact: user,
          );
        }

        return SizedBox();

        // return Center(
        //   child: CircularProgressIndicator(),
        // );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final FirebaseUser? contact;

  ViewLayout({@required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: CustomTile(
        mini: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          ),
        ),
        title: Text(
          contact?.name ?? "..",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Arial",
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          contact?.username ?? "..",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        leading: Container(
          constraints: BoxConstraints(maxHeight: 55, maxWidth: 55),
          child: CachedImage(
            contact!.profilePhoto,
            radius: 80,
            isRound: true,
          ),
        ),
      ),
    );
  }
}
