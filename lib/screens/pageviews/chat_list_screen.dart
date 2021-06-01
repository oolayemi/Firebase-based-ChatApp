import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placeholder/models/contacts.dart';
import 'package:placeholder/provider/user_provider.dart';
import 'package:placeholder/resources/chat_methods.dart';
import 'package:placeholder/screens/pageviews/widgets/contact_view.dart';
import 'package:placeholder/screens/pageviews/widgets/new_chat_button.dart';
import 'package:placeholder/screens/pageviews/widgets/user_circle.dart';
import 'package:placeholder/widgets/general_appbar.dart';
import 'package:placeholder/widgets/quiet_box.dart';
import 'package:provider/provider.dart';
import '../../utils/unversal_variables.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: GeneralAppBar(
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
      ),
      floatingActionButton: NewChatButton(),
      body: ChatListContainer(),
    );
  }
}

class ChatListContainer extends StatefulWidget {
  @override
  _ChatListContainerState createState() => _ChatListContainerState();
}

class _ChatListContainerState extends State<ChatListContainer> {
  final ChatMethods _chatMethods = ChatMethods();
  late Key key;

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
                  return QuietBox(
                    heading: "This is where all the contacts are listed",
                    subtitle:
                        "Search for your friends to start calling or chatting them😃",
                  );
                }
                return ListView.builder(
                  itemCount: docList.length,
                  itemBuilder: (context, index) {
                    Contacts contacts = Contacts.fromMap(
                        docList[index].data() as Map<String, dynamic>);
                    return Dismissible(
                      key: UniqueKey(),
                      child: ContactView(contacts: contacts),
                      onDismissed: (direction) {
                        setState(() {
                          docList.removeAt(index);
                        });
                      },
                      secondaryBackground: Container(
                        child: Center(
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        color: Colors.red,
                      ),
                      background: Container(
                        child: Center(
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        color: Colors.red,
                      ),
                      //direction: DismissDirection.startToEnd,
                    );
                  },
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
