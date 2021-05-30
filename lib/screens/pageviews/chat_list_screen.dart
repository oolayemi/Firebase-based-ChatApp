import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placeholder/models/contacts.dart';
// import 'package:placeholder/models/contacts.dart';
import 'package:placeholder/provider/user_provider.dart';
import 'package:placeholder/resources/chat_methods.dart';
import 'package:placeholder/screens/pageviews/widgets/contact_view.dart';
import 'package:placeholder/screens/pageviews/widgets/new_chat_button.dart';
import 'package:placeholder/screens/pageviews/widgets/user_circle.dart';
import 'package:placeholder/widgets/quiet_box.dart';
import 'package:provider/provider.dart';
import '../../utils/unversal_variables.dart';
import '../../widgets/appbar.dart';

class ChatListScreen extends StatelessWidget {
  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      title: UserCircle(),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/search_screen');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onPressed: () {},
        )
      ],
      leading: IconButton(
        icon: Icon(
          Icons.notifications,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      floatingActionButton: NewChatButton(),
      body: ChatListContainer(),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: _chatMethods.fetchContacts(
              userId: userProvider.getUser!.uid,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var docList = snapshot.data!.docs;
                if (docList.isEmpty) {
                  return QuietBox();
                }
                return ListView.builder(
                  itemCount: docList.length,
                  itemBuilder: (context, index) {
                    Contacts contacts = Contacts.fromMap(
                        docList[index].data() as Map<String, dynamic>);
                    return ContactView(contacts: contacts);
                  },
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
