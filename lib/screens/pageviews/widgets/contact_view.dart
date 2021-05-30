import 'package:flutter/material.dart';
import 'package:placeholder/models/contacts.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/provider/user_provider.dart';
import 'package:placeholder/resources/auth_methods.dart';
import 'package:placeholder/resources/chat_methods.dart';
import 'package:placeholder/screens/chatscreens/chat_screen.dart';
import 'package:placeholder/screens/chatscreens/widgets/cached_image.dart';
import 'package:placeholder/widgets/custom_tile.dart';
import 'package:placeholder/widgets/last_message_container.dart';
import 'package:placeholder/widgets/online_dot_indicator.dart';
import 'package:provider/provider.dart';

class ContactView extends StatelessWidget {
  final Contacts? contacts;
  final AuthMethods _authMethods = AuthMethods();

  ContactView({this.contacts});

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
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({@required this.contact});

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: CustomTile(
        mini: false,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      receiver: contact,
                    ))),
        title: Text(
          contact?.name ?? "..",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Arial",
            fontSize: 19,
          ),
        ),
        subtitle: LastMessageContainer(
          stream: _chatMethods.fetchLastMessageBetween(
            senderId: userProvider.getUser!.uid,
            receiverId: contact!.uid,
          ),
        ),
        leading: Container(
          constraints: BoxConstraints(maxHeight: 55, maxWidth: 55),
          child: Stack(
            children: [
              CachedImage(
                contact!.profilePhoto,
                radius: 80,
                isRound: true,
              ),
              OnlineDotIndicator(
                uid: contact!.uid!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
