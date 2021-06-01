import 'package:flutter/material.dart';
import 'package:placeholder/models/contacts.dart';
import 'package:placeholder/provider/user_provider.dart';
import 'package:placeholder/resources/chat_methods.dart';
import 'package:placeholder/screens/callscreens/pickup/pickup_layout.dart';
import 'package:placeholder/screens/contactscreen/widgets/contacts_view.dart';
import 'package:placeholder/utils/unversal_variables.dart';
import 'package:placeholder/widgets/general_appbar.dart';
import 'package:placeholder/widgets/quiet_box.dart';
import 'package:provider/provider.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider _userProvider = Provider.of<UserProvider>(context);
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: GeneralAppBar(
          title: "Contacts",
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
        body: StreamBuilder(
            stream:
                _chatMethods.fetchContacts(userId: _userProvider.getUser!.uid),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var docList = snapshot.data!.docs;
                if (docList.isEmpty) {
                  return QuietBox(
                    heading: "This is where all your contacts are listed",
                    subtitle:
                        "Search for your friends to start calling or chatting them😃",
                  );
                }
                return ListView.builder(
                  itemCount: docList.length,
                  itemBuilder: (context, index) {
                    Contacts contacts = Contacts.fromMap(
                        docList[index].data() as Map<String, dynamic>);
                    return ContactsView(contacts: contacts);
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
