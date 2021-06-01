import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:placeholder/enum/user_state.dart';
import 'package:placeholder/resources/auth_methods.dart';
import 'package:placeholder/resources/local_db/repository/log_repository.dart';
import 'package:placeholder/screens/contactscreen/contact_screen.dart';
import 'package:placeholder/screens/logs/log_screen.dart';
import '../provider/user_provider.dart';
import '../screens/callscreens/pickup/pickup_layout.dart';
import '../screens/pageviews/chat_list_screen.dart';
import '../utils/unversal_variables.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController? pageController;
  int _page = 0;

  AuthMethods _authMethods = AuthMethods();

  late UserProvider userProvider;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      _authMethods.setUserState(
        userId: userProvider.getUser!.uid!,
        userState: UserState.Online,
      );

      LogRepository.init(
        isHive: false,
        dbName: userProvider.getUser!.uid!,
      );
    });

    WidgetsBinding.instance!.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _authMethods.setUserState(
      userId: userProvider.getUser!.uid!,
      userState: UserState.Offline,
    );
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String? currentUserId =
        (userProvider != null && userProvider.getUser != null)
            ? userProvider.getUser!.uid
            : "";
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("resumed state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController!.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        body: PageView(
          children: <Widget>[
            Container(
              child: ChatListScreen(),
            ),
            Container(
              child: LogScreen(),
            ),
            Container(
              child: ContactScreen(),
            ),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: UniversalVariables.blackColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat,
                    color: (_page == 0)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  label: "Chats",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.call,
                    color: (_page == 1)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  label: "Call",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.contacts,
                    color: (_page == 2)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  label: "Contacts",
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
      ),
    );
  }
}
