import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:placeholder/resources/auth_methods.dart';
import 'package:placeholder/screens/callscreens/pickup/pickup_layout.dart';
import '../models/firebase_user.dart';
import '../utils/unversal_variables.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import '../widgets/custom_tile.dart';

import 'chatscreens/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthMethods _authMethods = AuthMethods();

  List<FirebaseUser>? userList;
  String query = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((User? user) {
      _authMethods.fetchAllUsers(user).then((List<FirebaseUser> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }

  searchAppBar(BuildContext context) {
    return NewGradientAppBar(
      gradient: LinearGradient(colors: [
        UniversalVariables.gradientColorStart,
        UniversalVariables.gradientColorEnd
      ]),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35,
            ),
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    searchController.clear();
                    // WidgetsBinding.instance.addPersistentFrameCallback(
                    //     (_) => searchController.clear());
                    // searchController.clear();
                  },
                ),
                border: InputBorder.none,
                hintText: "Search for a friend",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 27,
                  color: Color(0x88ffffff),
                )),
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query) {
    final List<FirebaseUser> suggestionList = query.isEmpty || userList == null
        ? []
        : userList!.where((FirebaseUser user) {
            String _getUsername = user.username!.toLowerCase();
            String _query = query.toLowerCase();
            String _getName = user.name!.toLowerCase();
            bool matchesUsername = _getUsername.contains(_query);
            bool matchesName = _getName.contains(_query);

            return (matchesUsername || matchesName);
          }).toList();

    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          FirebaseUser searchedUser = FirebaseUser(
              uid: suggestionList[index].uid,
              profilePhoto: suggestionList[index].profilePhoto,
              name: suggestionList[index].name,
              username: suggestionList[index].username);

          return Container(
            padding: EdgeInsets.only(top: 7),
            child: CustomTile(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(receiver: searchedUser),
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundImage: NetworkImage(searchedUser.profilePhoto!),
                backgroundColor: Colors.grey,
              ),
              title: Text(
                searchedUser.username!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                searchedUser.name!,
                style: TextStyle(color: UniversalVariables.greyColor),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: searchAppBar(context),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: buildSuggestions(query),
        ),
      ),
    );
  }
}
