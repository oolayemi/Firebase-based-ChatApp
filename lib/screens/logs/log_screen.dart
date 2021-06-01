import 'package:flutter/material.dart';
import 'package:placeholder/screens/callscreens/pickup/pickup_layout.dart';
import 'package:placeholder/screens/logs/widgets/floating_columns.dart';
import 'package:placeholder/screens/logs/widgets/log_list_container.dart';
import 'package:placeholder/utils/unversal_variables.dart';
import 'package:placeholder/widgets/general_appbar.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: GeneralAppBar(
          title: "Calls",
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
          ],
        ),
        floatingActionButton: FloatingColumn(),
        body: Padding(
          padding: EdgeInsets.only(left: 15),
          child: LogListContainer(),
        ),
      ),
    );
  }
}
